with Ada.Characters.Latin_1;

package MyStringTokeniser with SPARK_Mode is

   type TokenExtent is record
      Start : Positive;
      Length : Natural;
   end record;

   type TokenArray is array(Positive range <>) of TokenExtent;

   function Is_Whitespace(Ch : Character) return Boolean is
     (Ch = ' ' or Ch = Ada.Characters.Latin_1.LF or
        Ch = Ada.Characters.Latin_1.HT);

   procedure Tokenise(S : in String; Tokens : in out TokenArray; Count : out Natural) with
     Pre => (if S'Length > 0 then S'First <= S'Last) and Tokens'First <= Tokens'Last,

   -- Explain: Count records the current length of the tokenArray and it should less than or equal to the Max length of the tokenArray
   -- Why necessary: Ada does not know whether the Count will be larger than the maximum length of the tokenArray if not specified here
   -- Count should never be larger than it
     Post => Count <= Tokens'Length and
     -- Explain: Index is used to iterate all the tokens stored in the tokenArray
     (for all Index in Tokens'First..Tokens'First+(Count-1) =>
        -- Explain: each token's Start position should be larger than or equal to the first index of S
        -- Why necessary: Ada does not know whether Tokens(Index).Start will be 0 if not specified here
        -- if the start position is not correct, it means it is empty here or error
        (Tokens(Index).Start >= S'First and
           -- Explain: each token's Length should be larger than 0
           -- Why necessary: Ada does not know whether Tokens(Index).Length will be 0 if not specified here
           -- if it is equal to or less than 0, it means it is empty here or error
           Tokens(Index).Length > 0) and then
            -- Explain: each token should be inside the string
            -- Why necessary: Ada does not know whether the token's length will be larger than S'Last - Tokens(Index).Start if not specified here
            -- if it is larger, it means the token is not the subset of S  or error
            Tokens(Index).Length-1 <= S'Last - Tokens(Index).Start);


end MyStringTokeniser;
