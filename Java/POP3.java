import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Semaphore;

public class POP3 {
    public int ConsumerInt = 5;
    public int ProducerInt = 3;
    public int CorrectNumber = 0;
    public int globalI = 0;
    public int globalJ = 0;

    Semaphore Access;
    Semaphore ChekAccessI;
    Semaphore ChekAccessJ;
    Semaphore Full;
    Semaphore Empty;

    public void main(String[] args) {
        POP3 program = new POP3();
        program.starter(20, 50);
    }

    private void starter(int storageSize, int itemNumbers) {
        Access = new Semaphore(1);
        ChekAccessI = new Semaphore(1);
        ChekAccessJ = new Semaphore(1);
        Full = new Semaphore(storageSize);
        Empty = new Semaphore(0);

        Thread[] threadConsumer = new Thread[ConsumerInt];
        for (int i = 0; i < threadConsumer.length; i++) {
            threadConsumer[i] = new Thread(() -> consumer(itemNumbers));
            threadConsumer[i].start();
        }

        Thread[] threadProducer = new Thread[ProducerInt];
        for (int i = 0; i < threadProducer.length; i++) {
            threadProducer[i] = new Thread(() -> producer(itemNumbers));
            threadProducer[i].start();
        }
    }

    private final List<String> storage = new ArrayList<>();

    private void producer(int itemNumbers) {
        while (true) {
            try {
                ChekAccessJ.acquire();
                if (globalJ + 1 <= itemNumbers)
                    globalJ = globalJ + 1;
                else {
                    ChekAccessJ.release();
                    break;
                }
                ChekAccessJ.release();

                Full.acquire();
                Access.acquire();

                CorrectNumber = CorrectNumber + 1;

                storage.add("item " + CorrectNumber);
                System.out.println("Added item " + CorrectNumber);

                Access.release();
                Empty.release();

                Thread.sleep(1000);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private void consumer(int itemNumbers) {
        while (true) {
            try {
                ChekAccessI.acquire();
                if (globalI + 1 <= itemNumbers)
                    globalI = globalI + 1;
                else {
                    ChekAccessI.release();
                    break;
                }
                ChekAccessI.release();

                Empty.acquire();
                Thread.sleep(1000);
                Access.acquire();

                String item = storage.get(0);
                storage.remove(0);

                Full.release();
                Access.release();

                System.out.println("Took " + item);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}