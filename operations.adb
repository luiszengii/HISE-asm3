with VariableStore;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Stack;

package body Operations is

   procedure Lock (IsLocked: in out Boolean; MASTER_PIN: in out PIN.PIN; ENTER_PIN: in out PIN.PIN) is
   begin
      IsLocked := True;
      MASTER_PIN := ENTER_PIN;
   end Lock;

   procedure Unlock (IsLocked: in out Boolean; MASTER_PIN: in PIN.PIN; ENTER_PIN: in PIN.PIN) is
   begin
      If PIN."="(MASTER_PIN,ENTER_PIN) then
         IsLocked := False;
      else
         Put_Line("The PIN is not correct.");
      end if;
   end Unlock;

   procedure Plus(S: in out OperandStack.Stack; IsLocked: in Boolean) is
      RESULT: Integer;
      NUM1: Integer;
      NUM2: Integer;
   begin
      OperandStack.Pop(S, NUM1);
      OperandStack.Pop(S, NUM2);
      if NUM2 > 0 then
         if (Integer'Last - NUM2) < NUM1 then
            Put_Line("The result is larger than the largest integer 2147483647");
            OperandStack.Push(S, NUM2);
            OperandStack.Push(S, NUM1);
         end if;
      elsif NUM2 <0 then
         if (Integer'First - NUM2) > NUM1 then
            Put_Line("The result is smaller than the smallest integer -2147483648");
            OperandStack.Push(S, NUM2);
            OperandStack.Push(S, NUM1);
         end if;
      else
         RESULT := NUM1 + NUM2;
         OperandStack.Push(S, RESULT);
      end if;
   end Plus;

   procedure Minus(S: in out OperandStack.Stack; IsLocked: in Boolean) is
      RESULT: Integer;
      NUM1: Integer;
      NUM2: Integer;
   begin
      OperandStack.Pop(S, NUM1);
      OperandStack.Pop(S, NUM2);
      if NUM2 > 0 then
         if (Integer'First + NUM2) > NUM1 then
            Put_Line("The result is smaller than the smallest integer -2147483648");
            OperandStack.Push(S, NUM2);
            OperandStack.Push(S, NUM1);
         end if;
      elsif NUM2 <0 then
         if (Integer'Last + NUM2) > NUM1 then
            Put_Line("The result is larger than the largest integer 2147483647");
            OperandStack.Push(S, NUM2);
            OperandStack.Push(S, NUM1);
         end if;
      else
         RESULT := NUM1 - NUM2;
         OperandStack.Push(S, RESULT);
      end if;
   end Minus;

   procedure Multiply(S: in out OperandStack.Stack; IsLocked: in Boolean) is
      RESULT: Integer;
      NUM1: Integer;
      NUM2: Integer;
   begin
      OperandStack.Pop(S, NUM1);
      OperandStack.Pop(S, NUM2);
      if NUM2 > 0 and NUM1 > 0 then
         if (Integer'Last / NUM2) < NUM1 then
            Put_Line("The result is larger than the largest integer 2147483647");
            OperandStack.Push(S, NUM2);
            OperandStack.Push(S, NUM1);
         end if;
      elsif NUM1 > 0 and NUM2 <0 then
         if (Integer'First / NUM1) > NUM2 then
            Put_Line("The result is smaller than the smallest integer -2147483648");
            OperandStack.Push(S, NUM2);
            OperandStack.Push(S, NUM1);
         end if;
      elsif NUM1 < 0 and NUM2 > 0 then
         if (Integer'First / NUM2) > NUM1 then
            Put_Line("The result is smaller than the smallest integer -2147483648");
            OperandStack.Push(S, NUM2);
            OperandStack.Push(S, NUM1);
         end if;
      elsif NUM2 < 0 and NUM1 < 0 then
         if (Integer'Last / NUM2) < NUM1 then
            Put_Line("The result is larger than the largest integer 2147483647");
            OperandStack.Push(S, NUM2);
            OperandStack.Push(S, NUM1);
         end if;
      else
         RESULT := NUM1 * NUM2;
         OperandStack.Push(S, RESULT);
      end if;
   end Multiply;

   procedure Divide(S: in out OperandStack.Stack; IsLocked: in Boolean) is
      RESULT: Integer;
      NUM1: Integer;
      NUM2: Integer;
   begin
      OperandStack.Pop(S, NUM1);
      OperandStack.Pop(S, NUM2);
      if NUM2 = 0 then
         Put_Line("Cannot divide by 0! the numbers are pushed back to the stack");
         OperandStack.Push(S, NUM2);
         OperandStack.Push(S, NUM1);
      elsif NUM1 = Integer'First and NUM2 = -1 then
         Put_Line("num1 is the smallest integer -2147483648 and num2 is -1, the result is larger than the largest integer 2147483647");
         New_Line;
         OperandStack.Push(S, NUM2);
         OperandStack.Push(S, NUM1);
      else
         RESULT := NUM1 / NUM2;
         OperandStack.Push(S, RESULT);
      end if;
   end Divide;

   procedure Push_Operation(S: in out OperandStack.Stack; I: in Integer; IsLocked: in Boolean) is
   begin
      OperandStack.Push(S, I);
   end Push_Operation;

   procedure Pop_Operation(S: in out OperandStack.Stack; I: out Integer; IsLocked: in Boolean) is
   begin
      OperandStack.Pop(S, I);
   end Pop_Operation;

   --loads the value stored in variable var and pushes it onto the stack.
   procedure Load(V: in VariableStore.Variable; DB: in VariableStore.Database; S: in out OperandStack.Stack; IsLocked: in Boolean) is
      VALUE: Integer;
   begin
      VALUE := VariableStore.Get(DB, V);
      OperandStack.Push(S, VALUE);
   end Load;

   --pops the value from the top of the stack and stores it into variable var,
   --defining that variable if it is not already defined.
   procedure Store(V: in out VariableStore.Variable; DB: in out VariableStore.Database; S: in out OperandStack.Stack; IsLocked: in Boolean) is
      VALUE: Integer;
   begin
      OperandStack.Pop(S, VALUE);
      VariableStore.Put(DB, V, VALUE);
   end Store;

   -- makes variable var undefined
   procedure Remove(V: in out VariableStore.Variable; DB: in out VariableStore.Database; IsLocked: in Boolean) is
   begin
      VariableStore.Remove(DB, V);
   end Remove;

   procedure List(DB: in VariableStore.Database; IsLocked: in Boolean) is
   begin
      VariableStore.Print(DB);
   end List;

end Operations;
