library ieee;
use ieee.std_logic_1164.all;

package globals is
  type key_event_type is (KEY_NUM, KEY_ADD, KEY_SUB, KEY_MUL, KEY_DIV, KEY_ENTER, KEY_RESET, KEY_OTHER);
end package globals;