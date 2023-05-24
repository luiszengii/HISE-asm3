with VariableStore;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Stack;

package body Operations is

   procedure Plus(S: in out OperandStack.Stack; IsLocked: in Boolean) is
      RESULT: Integer;
      NUM1: Integer;
      NUM2: Integer;
   begin
      -- pop 2 values from the stack
      OperandStack.Pop(S, NUM1);
      OperandStack.Pop(S, NUM2);
      -- calculate the result using "+"
      RESULT := NUM1 + NUM2;
      -- store the result into the stack
      OperandStack.Push(S, RESULT);
   end Plus;

   procedure Minus(S: in out OperandStack.Stack; IsLocked: in Boolean) is
      RESULT: Integer;
      NUM1: Integer;
      NUM2: Integer;
   begin
      OperandStack.Pop(S, NUM1);
      OperandStack.Pop(S, NUM2);
      RESULT := NUM1 - NUM2;
      OperandStack.Push(S, RESULT);
   end Minus;

   procedure Multiply(S: in out OperandStack.Stack; IsLocked: in Boolean) is
      RESULT: Integer;
      NUM1: Integer;
      NUM2: Integer;
   begin
      OperandStack.Pop(S, NUM1);
      OperandStack.Pop(S, NUM2);
      RESULT := NUM1 * NUM2;
      OperandStack.Push(S, RESULT);
   end Multiply;

   procedure Divide(S: in out OperandStack.Stack; IsLocked: in Boolean) is
      RESULT: Integer;
      NUM1: Integer;
      NUM2: Integer;
   begin
      OperandStack.Pop(S, NUM1);
      OperandStack.Pop(S, NUM2);
      if NUM2 /= 0 then
         RESULT := NUM1 / NUM2;
         OperandStack.Push(S, RESULT);
      else
         Put("Cannot divide by 0!");
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
