library ieee;
use ieee.std_logic_1164.all;
use WORK.all;
use globals.all;

entity statemachine is
  port (
  sys_clk, keytrigger, reset  :  in bit;
  keydigit  :  in std_logic_vector(3 downto 0);
  keyevent  :  in key_event_type;
  operator  :  out operator_type;
  operand1, operand2  : out std_logic_vector(7 downto 0);
  result  :  out std_logic_vector(15 downto 0)
  );
end entity statemachine;

architecture behav of statemachine is
  type state_type is (INPUT_OP1, INPUT_OP2, FINISHED, DO_RESET);
  signal state  :  state_type;
  signal next_state  :  state_type;
  signal next_operator  :  operator_type; 
  
begin
  
  state_storage: process(sys_clk, reset)
  begin
    if (reset = '0') then
      if (sys_clk = '1') then
        state <= next_state;
        if (state = INPUT_OP2) then
          operator <= next_operator;
        end if;
      end if;
    end if;
  end process state_storage;
  
  next_state_process: process(keytrigger, keyevent, sys_clk)
    begin
    case state is
      when INPUT_OP1 =>
        if (keytrigger = '1') then
          case keyevent is
            when KEY_ADD =>
              next_operator <= ADD;
              next_state <= INPUT_OP2;
            when KEY_SUB =>
              next_operator <= SUB;
              next_state <= INPUT_OP2;
            when KEY_MUL =>
              next_operator <= MUL;
              next_state <= INPUT_OP2;
            when KEY_DIV =>
              next_operator <= DIV;
              next_state <= INPUT_OP2;
            when KEY_RESET =>
              next_state <= DO_RESET;
				when others =>
					next_state <= INPUT_OP1;
          end case;
        end if;
      when INPUT_OP2 =>
        if (keytrigger = '1') then
          case keyevent is
            when KEY_RESET =>
              next_state <= DO_RESET;
            when KEY_ENTER =>
              next_state <= FINISHED;
				  when others =>
					next_state <= INPUT_OP2;
          end case;
        end if;
      when FINISHED =>
        if (keytrigger = '1') then
          if (keyevent = KEY_RESET) then
            next_state <= DO_RESET;
          end if;
        end if;
      when DO_RESET =>
        if (sys_clk = '1') then 
          next_state <= INPUT_OP1;
        end if;
    end case;
  end process next_state_process;
 
 end architecture;