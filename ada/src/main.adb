with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

procedure Main is
   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;

   procedure Starter (Storage_Size : in Integer; Item_Numbers : in Integer) is
      Storage : List;

       ConsumerInt : Integer := 5;
       ProducerInt: Integer := 3;
       CorrectNumber: Integer := 0;
       globalI : Integer := 1;
       globalJ : Integer := 1;

      Access_Storage : Counting_Semaphore (1, Default_Ceiling);
      Full_Storage   : Counting_Semaphore (Storage_Size, Default_Ceiling);
      Empty_Storage  : Counting_Semaphore (0, Default_Ceiling);
      ChekAccessI : Counting_Semaphore (1, Default_Ceiling);
      ChekAccessJ : Counting_Semaphore (1, Default_Ceiling);

      task type Consumer is
         entry Start(Item_Numbers : in Integer);
      end;

      task type Producer is
         entry Start(Item_Numbers : in Integer);
      end;

      ProducerArr : array(1..ProducerInt) of Producer;
      ConsumerArr : array(1..ConsumerInt) of Consumer;

      task body Producer is
           Item_Numbers : Integer;
      begin
           accept Start (Item_Numbers : in Integer) do
              Producer.Item_Numbers := Item_Numbers;
         end Start;

         while True loop
            ChekAccessJ.Seize;

            if globalJ <= Item_Numbers then
               globalJ := globalJ+1;
            else
               ChekAccessJ.Release;
               exit;
            end if;

            ChekAccessJ.Release;

            Full_Storage.Seize;
            Access_Storage.Seize;

            CorrectNumber := CorrectNumber+1;

            Storage.Append ("item " & CorrectNumber'Img);
            Put_Line ("Added item " & CorrectNumber'Img);

            Access_Storage.Release;
            Empty_Storage.Release;
            delay 1.5;
         end loop;
      end Producer;

      task body Consumer is
         Item_Numbers : Integer;
      begin
           accept Start (Item_Numbers : in Integer) do
              Consumer.Item_Numbers := Item_Numbers;
         end Start;

         while True loop

            ChekAccessI.Seize;

            if globalI<= Item_Numbers then
               globalI := globalI+1;
            else
               ChekAccessI.Release;
               exit;
            end if;

            ChekAccessI.Release;

            Empty_Storage.Seize;
            delay 1.0;
            Access_Storage.Seize;

            declare
               item : String := First_Element (Storage);
            begin
               Put_Line ("Took " & item);
            end;

            Storage.Delete_First;

            Access_Storage.Release;
            Full_Storage.Release;

         end loop;

      end Consumer;

   begin
      for i in 1..ConsumerInt loop
         ConsumerArr(i).Start(Item_Numbers);
      end loop;

      for i in 1..ProducerInt loop
         ProducerArr(i).Start(Item_Numbers);
      end loop;
   end Starter;

begin
   Starter (20, 200);
end Main;
