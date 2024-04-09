using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;

namespace POP3
{
    class Program
    {
        public int ConsumerInt = 40;
        public int ProducerInt = 2;
        public int CorrectNumber = 0;
        public int globalI = 0;
        public int globalJ = 0;

        static void Main(string[] args)
        {
            Program program = new Program();
            program.Starter(20, 100);

            Console.ReadKey();
        }


        private void Starter(int storageSize, int itemNumbers)
        {
            Access = new Semaphore(1, 1);
            ChekAccessI = new Semaphore(1, 1);
            ChekAccessJ = new Semaphore(1, 1);
            Full = new Semaphore(storageSize, storageSize);
            Empty = new Semaphore(0, storageSize);

            Thread[] threadConsumer = new Thread[ConsumerInt];
            for (int i = 0; i <threadConsumer.Length; i++)
            {
                threadConsumer[i] = new Thread(Consumer);
                threadConsumer[i].Start(itemNumbers);
            }

            Thread[] threadProducer = new Thread[ProducerInt];
            for (int i = 0; i < threadProducer.Length; i++)
            {
                threadProducer[i] = new Thread(Producer);
                threadProducer[i].Start(itemNumbers);
            }
        }

        private Semaphore Access;
        private Semaphore ChekAccessI;
        private Semaphore ChekAccessJ;
        private Semaphore Full;
        private Semaphore Empty;

        private readonly List<string> storage = new List<string>();

        private void Producer(Object itemNumbers)
        {
            int maxItem = 0;
            maxItem = (int)itemNumbers;
            while(true)
            {
                ChekAccessJ.WaitOne();
                    if (globalJ + 1 <= maxItem)
                        globalJ = globalJ + 1;
                else
                {
                    ChekAccessJ.Release();
                    break;
                }

                ChekAccessJ.Release();

                Full.WaitOne();
                Access.WaitOne();

                CorrectNumber = CorrectNumber + 1;

                storage.Add("item " + CorrectNumber);
                Console.WriteLine("Added item " + CorrectNumber);

                Access.Release();
                Empty.Release();

                Thread.Sleep(1000);
            }
        }

        private void Consumer(Object itemNumbers)
        {
            int maxItem = 0;
            maxItem = (int)itemNumbers;

            while (true)
            {
                ChekAccessI.WaitOne();
                if (globalI+1 <= maxItem)
                    globalI = globalI + 1;
                else
                {
                    ChekAccessI.Release();
                    break;
                }

                ChekAccessI.Release();

                Empty.WaitOne();
                Thread.Sleep(1000);
                Access.WaitOne();

                string item = storage.ElementAt(0);
                storage.RemoveAt(0);

                Full.Release();

                Access.Release();

                Console.WriteLine("Took " + item);
            }
        }
    }
}