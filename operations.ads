with VariableStore;
with Stack;
with Pin;

package Operations is
   package OperandStack is new Stack(Max_Size => 512, Item => Integer, Default_Item => 0);
   -- Instantiate the Stack package with the desired parameters

   procedure Lock(IsLocked: in out Boolean; MASTER_PIN: in out PIN.PIN; ENTER_PIN: in out PIN.PIN) with
      Pre => IsLocked = False,
     Post => IsLocked = True;

   procedure Unlock(IsLocked: in out Boolean; MASTER_PIN: in PIN.PIN; ENTER_PIN: in PIN.PIN) with
      Pre => IsLocked = True;

   procedure Plus(S: in out OperandStack.Stack; IsLocked: in Boolean) with
      Pre => OperandStack.Size(S) >= 2 and OperandStack.Size(S) <= 512 and IsLocked = False,
      Post => OperandStack.Size(S) = OperandStack.Size(S'Old) - 1;


   procedure Minus(S: in out OperandStack.Stack; IsLocked: in Boolean) with
      Pre => OperandStack.Size(S) >= 2 and OperandStack.Size(S) <= 512 and IsLocked = False,
      Post => OperandStack.Size(S) = OperandStack.Size(S'Old) - 1;

   procedure Multiply(S: in out OperandStack.Stack; IsLocked: in Boolean) with
      Pre => OperandStack.Size(S) >= 2 and OperandStack.Size(S) <= 512 and IsLocked = False,
      Post => OperandStack.Size(S) = OperandStack.Size(S'Old) - 1;

   procedure Divide(S: in out OperandStack.Stack; IsLocked: in Boolean) with
      Pre => OperandStack.Size(S) >= 2 and OperandStack.Size(S) <= 512 and IsLocked = False,
      Post => OperandStack.Size(S) = OperandStack.Size(S'Old) - 1;

   procedure Push_Operation(S: in out OperandStack.Stack; I : in Integer; IsLocked: in Boolean) with
      Pre => IsLocked = False and OperandStack.Size(S) < 512,
      Post => OperandStack.Size(S) = OperandStack.Size(S'Old) + 1;

   procedure Pop_Operation(S: in out OperandStack.Stack; I : out Integer; IsLocked: in Boolean) with
      Pre => IsLocked = False and OperandStack.Size(S) > 0,
      Post => OperandStack.Size(S) = OperandStack.Size(S'Old) - 1;

   --loads the value stored in variable var and pushes it onto the stack.
   procedure Load(V: in VariableStore.Variable; DB: in VariableStore.Database; S: in out OperandStack.Stack; IsLocked: in Boolean) with
      Pre => IsLocked = False and OperandStack.Size(S) < 512,
      Post => OperandStack.Size(S) = OperandStack.Size(S'Old) + 1;

   --pops the value from the top of the stack and stores it into variable var,
   --defining that variable if it is not already defined.
   procedure Store(V: in out VariableStore.Variable; DB:in out VariableStore.Database; S: in out OperandStack.Stack; IsLocked: in Boolean) with
      Pre => IsLocked = False and OperandStack.Size(S) > 0,
      Post => OperandStack.Size(S) = OperandStack.Size(S'Old) - 1;

   -- makes variable var undefined
   procedure Remove(V: in out VariableStore.Variable; DB:in out VariableStore.Database; IsLocked: in Boolean) with
      Pre => IsLocked = False;

   procedure List(DB: in VariableStore.Database; IsLocked: in Boolean) with
      Pre => IsLocked = False;

   procedure SetMasterPin(MASTER_PIN : out PIN.PIN; ENTER_PIN_STR : in String) with
     Pre => ENTER_PIN_STR'Length = 4 and (for all I of ENTER_PIN_STR => I >= '0' and I <= '9');

end Operations;
