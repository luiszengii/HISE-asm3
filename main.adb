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
   ENTER_PIN : PIN.PIN;
   ENTER_PIN_STR : String := "0000";
   
   package Lines is new MyString(Max_MyString_Length => 2048);
   -- record user input
   P  : Lines.MyString;
   -- this system only has 2 state: locked/unlocked
   type State is (locked, unlocked);
   -- record the current state of this system
   Current_State: State := locked;
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
      if Lines.Equal(COMMAND,Lines.From_String("unlock")) and Current_State = locked and 
      (for all I of ENTER_PIN_STR => I >= '0' and I <= '9') then
         ENTER_PIN := PIN.From_String(ENTER_PIN_STR);
         -- if the pin entered equals to the master pin, change the state to unlocked
         If PIN."="(MASTER_PIN,ENTER_PIN) then
            Current_State := unlocked;
         else
            Put_Line("The PIN is not correct.");
            return;
         end if;
      else
         Put_Line("The Command is not correct or current state is not locked.");
         return;
      end if;
 
      
   
      ---------------input commands phase------------------------
      while Current_State = unlocked loop
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
                     if(TokStr'Length = 4 and
                          (for all I of TokStr => I >= '0' and I <= '9')) then
                        -- get the entered pin
                        ENTER_PIN := PIN.From_String(TokStr);
                     else
                        Put("The length of the entered pin is not 4 OR the format is invalid!");
                        return;
                     end if;
                     
                  end if;
               end;
            end loop;
            
         end;
         
        
         if Lines.Equal(COMMAND,Lines.From_String("lock")) and Current_State = unlocked then
            MASTER_PIN := ENTER_PIN;
            Current_State := locked; -- exit the input command phase
            
         
         elsif Lines.Equal(COMMAND,Lines.From_String("+")) and Current_State = unlocked then
              Operations.Plus(OpStack);
         elsif Lines.Equal(COMMAND,Lines.From_String("-")) and Current_State = unlocked then
              Operations.Minus(OpStack);
         elsif Lines.Equal(COMMAND,Lines.From_String("*")) and Current_State = unlocked then
              Operations.Multiply(OpStack);
         elsif Lines.Equal(COMMAND,Lines.From_String("/")) and Current_State = unlocked then
              Operations.Divide(OpStack);
         elsif Lines.Equal(COMMAND,Lines.From_String("push")) and Current_State = unlocked then
               Operations.Push_Operation(OpStack, NUMBER);
         elsif Lines.Equal(COMMAND,Lines.From_String("pop")) and Current_State = unlocked then
              Operations.Pop_Operation(OpStack, NUMBER); -- although the pop in commandline does not need argument, we store the value into the NUMBER
         elsif Lines.Equal(COMMAND,Lines.From_String("load")) and Current_State = unlocked then
              Operations.Load(VAR, DB, OpStack);
         elsif Lines.Equal(COMMAND,Lines.From_String("store")) and Current_State = unlocked then
              Operations.Store(VAR, DB, OpStack);
         elsif Lines.Equal(COMMAND,Lines.From_String("remove")) and Current_State = unlocked then
              Operations.Remove(VAR, DB);
         elsif Lines.Equal(COMMAND,Lines.From_String("list")) and Current_State = unlocked then
              Operations.List(DB);
         else
            Put_Line("The Command is not correct or current state is not unlocked.");
            return;
         end if;
         
      end loop;
      
   end loop;
end Main;

   -- MyCommandLine Output
   -- ./my_program is running!
   -- I was invoked with 3 arguments.
   -- Argument 1: "arg1"
   -- Argument 2: "arg2"
   -- Argument 3: "arg3"
--     Put(MyCommandLine.Command_Name); Put_Line(" is running!");
--     Put("I was invoked with "); Put(MyCommandLine.Argument_Count,0); Put_Line(" arguments.");
--     for Arg in 1..MyCommandLine.Argument_Count loop
--        Put("Argument "); Put(Arg,0); Put(": """);
--        Put(MyCommandLine.Argument(Arg)); Put_Line("""");
--     end loop;

   -- Put_Line("initialize the database");
   -- VariableStore.Init(DB);
   -- Put_Line("Adding an entry to the database");
--     VariableStore.Put(DB,a,5); 
   --     VariableStore.Put(DB,b,1000);
   
--     Put_Line("Reading the entry:");
--     Put(VariableStore.Get(DB,V1));
--     New_Line;
--     
--     Put_Line("Printing out the database: ");
--     VariableStore.Print(DB);
--     
--     Put_Line("Removing the entry");
--     VariableStore.Remove(DB,a);
     
--     If VariableStore.Has_Variable(DB,V1) then
--        Put_Line("Entry still present! It is: ");
--        Put(VariableStore.Get(DB,V1));
--        New_Line;
--     else
--        Put_Line("Entry successfully removed");
--     end if;

   
--     declare
--        Smallest_Integer : Integer := StringToInteger.From_String("-2147483648");
--        R : Long_Long_Integer := 
--          Long_Long_Integer(Smallest_Integer) * Long_Long_Integer(Smallest_Integer);
--     begin
--        Put_Line("This is -(2 ** 32) (where ** is exponentiation) :");
--        Put(Smallest_Integer); New_Line;
--        
--        if R < Long_Long_Integer(Integer'First) or
--           R > Long_Long_Integer(Integer'Last) then
--           Put_Line("Overflow would occur when trying to compute the square of this number");
--        end if;
--           
--     end;

--     Put_Line("2 ** 32 is too big to fit into an Integer...");
--     Put_Line("Hence when trying to parse it from a string, it is treated as 0:");
--     
--     -- How to use StringToInteger -> print(214) as integer
--     Put(StringToInteger.From_String("214")); New_Line;




