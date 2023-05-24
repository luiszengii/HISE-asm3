pragma SPARK_Mode (On);

with StringToInteger;
with VariableStore;
with MyCommandLine;
with MyString;
with MyStringTokeniser;
with PIN;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

with Ada.Long_Long_Integer_Text_IO;
with Stack;
with Operations;

procedure Main is
   use Operations;
   DB : VariableStore.Database;
   VAR : VariableStore.Variable := VariableStore.From_String("");
   -- check if the pin entered is equal to this master pin
   MASTER_PIN : PIN.PIN;
 
   -- record the pin entered by the user
   ENTER_PIN : PIN.PIN := PIN.From_String("0000");
   ENTER_PIN_STR : String := "0000";
   
   package Lines is new MyString(Max_MyString_Length => 2048);
   -- record user input
   P  : Lines.MyString;
   
   -- this system only has 2 state: locked/unlocked
   -- record the current state of this system
   IsLocked : Boolean := True;
   
   -- record the COMMAND of the user input like "+" "-" "*" "/"
   COMMAND : Lines.MyString := Lines.From_String("");
   
   -- the value after command
   NUMBER : Integer := 0;
   
   -- stack with max of 512 integers, default integer is
   OpStack : OperandStack.Stack;
   
begin
   -- initialize stack and database
   Operations.OperandStack.Init(OpStack);
   VariableStore.Init(DB);
   -- first thing is setting up a master pin
   Put("$ ./main ");
   Lines.Get_Line(P);
   -- the pin should be from 0000-9999
   -- (!) Pre-condition did not check it so I check here (!)
   if(Lines.To_String(P)' Length = 4 and
        (for all I of Lines.To_String(P) => I >= '0' and I <= '9')) then
      MASTER_PIN := PIN.From_String(Lines.To_String(P));
   else
      Put("Format is invalid!");
      return;
   end if;
     
   while True loop
      --------Inputting master pin phase----------------
      
      while IsLocked=True loop
         Put("locked>   ");
         Lines.Get_Line(P);
         declare
            T : MyStringTokeniser.TokenArray(1..3) := (others => (Start => 1, Length => 0));
            NumTokens : Natural;
         begin
            MyStringTokeniser.Tokenise(Lines.To_String(P),T,NumTokens);
            -- check if the entered format "unlock 1234" is legal
            if NumTokens > 2 then
               Put_Line("You entered too many tokens expect 2");
               return;
            end if;
            -- loop getting command and value:
            for I in 1..NumTokens loop
               declare
                  TokStr : String := Lines.To_String(Lines.Substring(P,T(I).Start,T(I).Start+T(I).Length-1));
               begin
                  if I=1 then
                     -- get command
                     COMMAND := Lines.From_String(TokStr);
                  end if;
                  if I=2 then
                     -- Check the length and format of the entered pin
                     if(TokStr'Length = 4 and
                          (for all I of TokStr => I >= '0' and I <= '9')) then
                        -- get the entered pin
                        ENTER_PIN_STR := TokStr;
                     else
                        Put("The length of the entered pin is not 4 OR the format is invalid!");
                        return;
                     end if;
                  end if;
               end;      
            end loop; 
         end;
   
         -- only locked state can use 'unlock 1234' otherwise do nothing 
         if Lines.Equal(COMMAND,Lines.From_String("unlock")) and IsLocked and 
           (for all I of ENTER_PIN_STR => I >= '0' and I <= '9') then
            ENTER_PIN := PIN.From_String(ENTER_PIN_STR);
            -- if the pin entered equals to the master pin, change the state to unlocked
            If PIN."="(MASTER_PIN,ENTER_PIN) then
               IsLocked := False;
            else
               Put_Line("The PIN is not correct.");
               return;
            end if;
         else
            Put_Line("The Command is not correct or current state is not locked.");
         end if;
      end loop;

      ---------------input commands phase------------------------
      while IsLocked = False loop
         --pragma Loop_Invariant (ENTER_PIN);
         
         
         Put("unlocked> ");
         Lines.Get_Line(P);
         declare
            T : MyStringTokeniser.TokenArray(1..3) := (others => (Start => 1, Length => 0));
            NumTokens : Natural;
            
         begin
            MyStringTokeniser.Tokenise(Lines.To_String(P),T,NumTokens);
            -- check if the entered format "unlock 1234" is legal
            if NumTokens > 2 then
               Put_Line("You entered too many tokens --- I said at most 2");
               return;
            end if;
            
            -- loop getting command and value: unlock 1234
            for I in 1..NumTokens loop
               declare
                  TokStr : String := Lines.To_String(Lines.Substring(P,T(I).Start,T(I).Start+T(I).Length-1));
               begin
                  if I=1 then
                     -- get command
                     COMMAND := Lines.From_String(TokStr);
                  end if;
                  if I=2 then
                     -- get the integer value after command, will be used in push and pop
                     NUMBER := StringToInteger.From_String(TokStr);
                     
                     -- parse the variable name to VAR, will be used when COMMAND is load, store, remove
                     if TokStr'Length <= VariableStore.Max_Variable_Length then
                        VAR := VariableStore.From_String(TokStr);
                     else
                        Put("The length of variable exceeds the max variable length(1024)");
                        return;
                     end if;
                     
                     -- Check the length and format of the entered pin, will only be used when the COMMAND is lock
                     if Lines.Equal(COMMAND,Lines.From_String("lock")) then
                        if(TokStr'Length = 4 and
                             (for all I of TokStr => I >= '0' and I <= '9')) then
                           -- get the entered pin
                           ENTER_PIN := PIN.From_String(TokStr);
                        else
                           Put("The length of the entered pin is not 4 OR the format is invalid!");
                           return;
                        end if;
                     end if;
                  end if;
               end;
            end loop;
         end;
         
        
         if Lines.Equal(COMMAND,Lines.From_String("lock")) and (IsLocked = False) then
            MASTER_PIN := ENTER_PIN;
            IsLocked := True; -- exit the input command phase
         elsif Lines.Equal(COMMAND,Lines.From_String("+")) and (IsLocked = False) then
            if OperandStack.Size(OpStack) >= 2 then
               Operations.Plus(OpStack, IsLocked);
            else
               Put("The number of items inside the stack is not enough to perform + !");
            end if;
         elsif Lines.Equal(COMMAND,Lines.From_String("-")) and (IsLocked = False) then
            if OperandStack.Size(OpStack) >= 2 then
               Operations.Minus(OpStack, IsLocked);
            else
               Put("The number of items inside the stack is not enough to perform - !");
            end if;
         elsif Lines.Equal(COMMAND,Lines.From_String("*")) and (IsLocked = False) then
            if OperandStack.Size(OpStack) >= 2 then
               Operations.Multiply(OpStack, IsLocked);
            else
               Put("The number of items inside the stack is not enough to perform * !");
            end if;
         elsif Lines.Equal(COMMAND,Lines.From_String("/")) and (IsLocked = False) then
            if OperandStack.Size(OpStack) >= 2 then
               Operations.Divide(OpStack, IsLocked);
            else
               Put("The number of items inside the stack is not enough to perform / !");
            end if;
         elsif Lines.Equal(COMMAND,Lines.From_String("push")) and (IsLocked = False) then
               Operations.Push_Operation(OpStack, NUMBER, IsLocked);
         elsif Lines.Equal(COMMAND,Lines.From_String("pop")) and (IsLocked = False) then
              Operations.Pop_Operation(OpStack, NUMBER, IsLocked); -- although the pop in commandline does not need argument, we store the value into the NUMBER
         elsif Lines.Equal(COMMAND,Lines.From_String("load")) and (IsLocked = False) then
              Operations.Load(VAR, DB, OpStack, IsLocked);
         elsif Lines.Equal(COMMAND,Lines.From_String("store")) and (IsLocked = False) then
              Operations.Store(VAR, DB, OpStack, IsLocked);
         elsif Lines.Equal(COMMAND,Lines.From_String("remove")) and (IsLocked = False) then
              Operations.Remove(VAR, DB, IsLocked);
         elsif Lines.Equal(COMMAND,Lines.From_String("list")) and (IsLocked = False) then
              Operations.List(DB, IsLocked);
         else
            Put_Line("The Command is not correct or current state is not unlocked.");
         end if;
       
      end loop;
      
   end loop;
end Main;

