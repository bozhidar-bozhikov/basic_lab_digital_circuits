library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package globals is

	type key_event_type is (KEY_NUM, KEY_RESET, KEY_ENTER, KEY_ADD, KEY_SUB, KEY_DIV, KEY_MUL, KEY_OTHER);
	type operator_type is (UNDEF, ADD, SUB, MUL, DIV);

	constant ESCAPE_CODE  : STD_LOGIC_VECTOR(7 downto 0) := X"E0"; -- should be 
   constant BREAK_CODE   : STD_LOGIC_VECTOR(7 downto 0) := X"F0";
    
   constant NUMPAD_0     : STD_LOGIC_VECTOR(7 downto 0) := X"70";
   constant NUMPAD_1     : STD_LOGIC_VECTOR(7 downto 0) := X"69";
   constant NUMPAD_2     : STD_LOGIC_VECTOR(7 downto 0) := X"72";
   constant NUMPAD_3     : STD_LOGIC_VECTOR(7 downto 0) := X"7A";
   constant NUMPAD_4     : STD_LOGIC_VECTOR(7 downto 0) := X"6B";
   constant NUMPAD_5     : STD_LOGIC_VECTOR(7 downto 0) := X"73";
   constant NUMPAD_6     : STD_LOGIC_VECTOR(7 downto 0) := X"74";
   constant NUMPAD_7     : STD_LOGIC_VECTOR(7 downto 0) := X"6C";
   constant NUMPAD_8     : STD_LOGIC_VECTOR(7 downto 0) := X"75";
   constant NUMPAD_9     : STD_LOGIC_VECTOR(7 downto 0) := X"7D";

end package globals;