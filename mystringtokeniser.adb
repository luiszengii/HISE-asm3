
package body MyStringTokeniser with SPARK_Mode is



   procedure Tokenise(S : in String; Tokens : in out TokenArray; Count : out Natural) is
      -- used to iterate in S
      Index : Positive;
      -- Start: Start position of the token
      -- Length: length of the token
      Extent : TokenExtent;
      -- used to iterate in Tokens
      OutIndex : Integer := Tokens'First;
   begin
      -- count is to record the length of the tokenArray
      Count := 0;
      -- check if the string S is empty
      -- if it is empty, S'First = 1 and S'Last = 0
      if (S'First > S'Last) then
         return;
      end if;

      -- when the string S is not empty,
      -- set the index as the index of the first character of the string
      Index := S'First;
      while OutIndex <= Tokens'Last and Index <= S'Last and Count < Tokens'Length loop
         -- for all the tokens stored in the tokenArray
         -- each token's Start position should be larger than or equal to the first index of S
         -- each token's Length should be larger than 0
         -- each token should be inside the string
         pragma Loop_Invariant
           (for all J in Tokens'First..OutIndex-1 =>
              (Tokens(J).Start >= S'First and
                   Tokens(J).Length > 0) and then
            Tokens(J).Length-1 <= S'Last - Tokens(J).Start);

         -- the count is the number of tokens found
         -- Tokens'First is the first index of the tokenArray
         -- OutIndex should be the next empty position of the tokenArray to store the next token
         pragma Loop_Invariant (OutIndex = Tokens'First + Count);

         -- look for start of next token
         -- skip all the white spaces contained in S before we find the next token
         while (Index >= S'First and Index < S'Last) and then Is_Whitespace(S(Index)) loop
            Index := Index + 1;
         end loop;

         if (Index >= S'First and Index <= S'Last) and then not Is_Whitespace(S(Index)) then
            -- found a token
            -- use Extent to record the token
            Extent.Start := Index;
            Extent.Length := 0;

            -- look for end of this token
            while Positive'Last - Extent.Length >= Index and then (Index+Extent.Length >= S'First and Index+Extent.Length <= S'Last) and then not Is_Whitespace(S(Index+Extent.Length)) loop
               Extent.Length := Extent.Length + 1;
            end loop;

            -- store the extent in the tokenArray
            Tokens(OutIndex) := Extent;
            Count := Count + 1;

            -- check for last possible token, avoids overflow when incrementing OutIndex
            if (OutIndex = Tokens'Last) then
               return;
            else
               OutIndex := OutIndex + 1;
            end if;

            -- check for end of string, avoids overflow when incrementing Index
            if S'Last - Extent.Length < Index then
               return;
            else
               Index := Index + Extent.Length;
            end if;
         end if;
      end loop;
   end Tokenise;

end MyStringTokeniser;
