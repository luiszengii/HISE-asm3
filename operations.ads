with VariableStore;
with Stack;

package Operations is
   package OperandStack is new Stack(Max_Size => 512, Item => Integer, Default_Item => 0);
   -- Instantiate the Stack package with the desired parameters

   procedure Plus(S: in out OperandStack.Stack);
   procedure Minus(S: in out OperandStack.Stack);
   procedure Multiply(S: in out OperandStack.Stack);
   procedure Divide(S: in out OperandStack.Stack);
   procedure Push_Operation(S: in out OperandStack.Stack; I : in Integer);
   procedure Pop_Operation(S: in out OperandStack.Stack; I : out Integer);

   --loads the value stored in variable var and pushes it onto the stack.
   procedure Load(V: in VariableStore.Variable; DB: in VariableStore.Database; S: in out OperandStack.Stack);

   --pops the value from the top of the stack and stores it into variable var,
   --defining that variable if it is not already defined.
   procedure Store(V: in out VariableStore.Variable; DB:in out VariableStore.Database; S: in out OperandStack.Stack);

   -- makes variable var undefined
   procedure Remove(V: in out VariableStore.Variable; DB:in out VariableStore.Database);

   procedure List(DB: in VariableStore.Database);

end Operations;