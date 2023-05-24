package body Stack with SPARK_Mode is

   procedure Init(S : out Stack) is
   begin
      S.size := 0;
      S.storage := (others => Default_Item);
   end Init;

   procedure Push(S : in out Stack; I : in Item) is
   begin
      S.size := S.size + 1;
      S.storage(S.size) := I;
   end Push;

   procedure Pop(S : in out Stack; I : out Item) is
   begin
      I := S.storage(S.size);
      S.size := S.size - 1;
   end Pop;


end Stack;
