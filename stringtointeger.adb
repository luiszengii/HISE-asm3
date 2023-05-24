
package body StringToInteger with SPARK_MOde Is
   function From_String(S : in String) return Integer is
      Result : Integer := 0;
      C : Integer;
      Negate : Boolean := False;
      Pos : Integer;
   begin
      --  if the string is empty return 0
      if S'Length <= 0 then
         return 0;
      end if;
      
      --  start from the first char
      Pos := S'First;
      
      --  check if the integer is positive or negative
      if S(Pos) = '-' then
         Negate := True;
         --  if there is only a minus sign return 0
         if S'Length <= 1 then
            return 0;
         end if;
         Pos := S'First + 1;
      end if;
      
      
      while Pos <= S'Last loop
         --  constraint: the char being parsed should always be in the String
         -- and if the integer is decided to be negative the value should <=0
         pragma Loop_Invariant (Pos >= S'First and Pos <= S'Last and 
                                (if Negate then Result <= 0 else Result >= 0));
         
         --  if the largest integer is smaller than the integer return 0
         if Integer'Last / 10 < Result then            
            return 0;
         end if;
         --  if the smallest integer is larger than the integer return 0
         if Integer'First / 10 > Result then
            return 0;
         end if;
         
         
         Result := Result * 10;
         if S(Pos) >= '0' and S(Pos) <= '9' then
            C := Character'Pos(S(Pos)) - Character'Pos('0');
            if Negate then
               if Integer'First + C > Result then
                  return 0;
               else
                  Result := Result - C;
               end if;
            else
               if Integer'Last - C < Result then
                  return 0;
               else
                  Result := Result + C;
               end if;
            end if;
         else
            return 0;
         end if;
         if (Pos < S'Last) then
            Pos := Pos + 1;
         else
            return Result;
         end if;
      end loop;
      -- won't ever get here but keep SPARK Prover happy
      return Result;
   end From_String;
   
end StringToInteger;   
