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
   
   --------Setting up master pin phase----------------
   if (MyCommandLine.Argument_Count = 1) then
      -- the pin should be from 0000-9999
      if(MyCommandLine.Argument(1)' Length = 4 and
           (for all I of MyCommandLine.Argument(1) => I >= '0' and I <= '9')) then
         MASTER_PIN := PIN.From_String(MyCommandLine.Argument(1));
      else
         Put_Line("Format is invalid!");
         return;
      end if;
   else
      Put_Line("Too many arguments!");
      return;
   end if;
   
     
   while True loop
      
      --------Unlocking the calculator phase----------------
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
            else
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
                           -- only locked state can use 'unlock 1234' otherwise do nothing 
                           if Lines.Equal(COMMAND,Lines.From_String("unlock")) and IsLocked and ENTER_PIN_STR'Length = 4 and
                             (for all I of ENTER_PIN_STR => I >= '0' and I <= '9') then
                              ENTER_PIN := PIN.From_String(ENTER_PIN_STR);
                              -- if the pin entered equals to the master pin, change the state to unlocked
                              if PIN."="(MASTER_PIN,ENTER_PIN) then
                                 IsLocked := False;
                              else
                                 Put_Line("The PIN is not correct.");
                              end if;
                           else
                              Put_Line("You need to unlock first.");
                           end if;
                        else
                           Put_Line("The length of the entered pin is not 4 OR the format is invalid!");
                        end if;
                     end if;
                  end;      
               end loop;
               
            end if;
         end;
   
         
      end loop;

      ---------------input commands phase------------------------
      
      while (IsLocked = False) loop
         pragma Loop_Invariant(OperandStack.Size(OpStack)>=0 and OperandStack.Size(OpStack)<= 512);
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
            else
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
                           Put_Line("The length of variable exceeds the max variable length(1024)");
                           return;
                        end if;

                     end if;
                  end;
               end loop;
               
               -- Check the length and format of the entered pin, will only be used when the COMMAND is lock
               if Lines.Equal(COMMAND,Lines.From_String("lock")) then
                  if(VariableStore.To_String(VAR)'Length = 4 and
                     (for all I of VariableStore.To_String(VAR) => I >= '0' and I <= '9')) then
                              -- get the entered pin
                     ENTER_PIN := PIN.From_String(VariableStore.To_String(VAR));
                              
                     if (IsLocked = False) then
                        Operations.Lock(IsLocked,MASTER_PIN,ENTER_PIN);
                     end if;
                  else
                     Put_Line("The length of the entered pin is not 4 OR the format is invalid!");
                  end if;
                        
               elsif Lines.Equal(COMMAND,Lines.From_String("+")) and (IsLocked = False) then
                  if OperandStack.Size(OpStack) >= 2 then
                     Operations.Plus(OpStack, IsLocked);
                  else
                     Put_Line("The number of items inside the stack is not enough to perform + !");
                  end if;
               elsif Lines.Equal(COMMAND,Lines.From_String("-")) and (IsLocked = False) then
                  if OperandStack.Size(OpStack) >= 2 then
                     Operations.Minus(OpStack, IsLocked);
                  else
                     Put_Line("The number of items inside the stack is not enough to perform - !");
                  end if;
               elsif Lines.Equal(COMMAND,Lines.From_String("*")) and (IsLocked = False) then
                  if OperandStack.Size(OpStack) >= 2 then
                     Operations.Multiply(OpStack, IsLocked);
                  else
                     Put_Line("The number of items inside the stack is not enough to perform * !");
                  end if;
               elsif Lines.Equal(COMMAND,Lines.From_String("/")) and (IsLocked = False) then
                  if OperandStack.Size(OpStack) >= 2 then
                     Operations.Divide(OpStack, IsLocked);
                  else
                     Put_Line("The number of items inside the stack is not enough to perform / !");
                  end if;
               elsif Lines.Equal(COMMAND,Lines.From_String("push")) and (IsLocked = False) and OperandStack.Size(OpStack)<512 then
                  Operations.Push_Operation(OpStack, NUMBER, IsLocked);
               elsif Lines.Equal(COMMAND,Lines.From_String("pop")) and (IsLocked = False) and OperandStack.Size(OpStack)>0 then
                  -- although the pop in commandline does not need argument, we store the value into the NUMBER
                  Operations.Pop_Operation(OpStack, NUMBER, IsLocked);
               elsif Lines.Equal(COMMAND,Lines.From_String("load")) and (IsLocked = False) and OperandStack.Size(OpStack)<512 then
                  Operations.Load(VAR, DB, OpStack, IsLocked);
               elsif Lines.Equal(COMMAND,Lines.From_String("store")) and (IsLocked = False) and OperandStack.Size(OpStack)>0 then
                  Operations.Store(VAR, DB, OpStack, IsLocked);
               elsif Lines.Equal(COMMAND,Lines.From_String("remove")) and (IsLocked = False) then
                  Operations.Remove(VAR, DB, IsLocked);
               elsif Lines.Equal(COMMAND,Lines.From_String("list")) and (IsLocked = False) then
                  Operations.List(DB, IsLocked);
               else
                  Put_Line("The Command is not correct or current state is not unlocked.");
               end if;
            end if;
         end;
      end loop; 
   end loop;
end Main;

