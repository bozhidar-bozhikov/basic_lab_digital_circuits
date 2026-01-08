library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.globals.all;

entity statemachine is
    port (
        sys_clk, keytrigger, reset : in std_logic;
        keydigit  : in std_logic_vector(3 downto 0);
        keyevent  : in key_event_type;
        operator  : buffer operator_type;
        operand1, operand2 : out std_logic_vector(7 downto 0);
        result : out std_logic_vector(15 downto 0);
        HEX0, HEX1, HEX2, HEX3 : out std_logic_vector(6 downto 0);
        HEX4, HEX5, HEX6, HEX7 : out std_logic_vector(6 downto 0)
    );
end entity statemachine;

architecture behav of statemachine is
    type state_type is (INPUT_OP1, INPUT_OP2, FINISHED, DO_RESET);
    signal state : state_type := INPUT_OP1;
    signal next_state : state_type;
    signal next_operator : operator_type; 
	 signal operand1_reg, operand2_reg: std_logic_vector(7 downto 0) := "00000000";
signal result_reg: std_logic_vector(15 downto 0) := "0000000000000000";
  
    component bcd_to_7seg is
        port(
            input: in std_logic_vector(3 downto 0);
            output: out std_logic_vector(6 downto 0)
        );
    end component;
    
    signal digit0, digit1, digit2, digit3: std_logic_vector(3 downto 0) := "0000";
    signal digit4, digit5, digit6, digit7: std_logic_vector(3 downto 0) := "0000";
  
begin
  
    state_storage: process(sys_clk, reset)
    begin
        if reset = '1' then
            state <= INPUT_OP1;
            operator <= UNDEF;
        elsif rising_edge(sys_clk) then
            state <= next_state;
            if state = INPUT_OP2 then
                operator <= next_operator;
            end if;
        end if;
    end process state_storage;
  
    next_state_logic: process(state, keytrigger, keyevent)
    begin
        next_state <= state;
        
        case state is
            when INPUT_OP1 =>
                if keytrigger = '1' then
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
                if keytrigger = '1' then
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
                if keytrigger = '1' then
                    if keyevent = KEY_RESET then
                        next_state <= DO_RESET;
                    end if;
                end if;
                
            when DO_RESET =>
                next_state <= INPUT_OP1;
        end case;
    end process next_state_logic;
    
    -- display logic based on state
    display_logic: process(sys_clk, reset)
    variable temp_result: integer;
    variable op1_val, op2_val: integer;
begin
    if reset = '1' then
        digit0 <= "0000";
        digit1 <= "0000";
        digit2 <= "0000";
        digit3 <= "0000";
        digit4 <= "0000";
        digit5 <= "0000";
        digit6 <= "0000";
        digit7 <= "0000";
        operand1_reg <= "00000000";
        operand2_reg <= "00000000";
        result_reg <= "0000000000000000";
        
    elsif rising_edge(sys_clk) then
        case state is
            when INPUT_OP1 =>
                if keytrigger = '1' and keyevent = KEY_NUM then
                    -- shift digits
                    digit7 <= digit6;
                    digit6 <= keydigit;
                    -- operand1: shift left by multiplying by 10
                    op1_val := to_integer(unsigned(operand1_reg));
                    if op1_val < 10 then
                        operand1_reg <= std_logic_vector(to_unsigned(op1_val * 10 + to_integer(unsigned(keydigit)), 8));
                    end if;
                end if;
                
            when INPUT_OP2 =>
                if keytrigger = '1' and keyevent = KEY_NUM then
                    -- shift digitst
                    digit5 <= digit4;
                    digit4 <= keydigit;
                    -- operand2
                    op2_val := to_integer(unsigned(operand2_reg));
                    if op2_val < 10 then
                        operand2_reg <= std_logic_vector(to_unsigned(op2_val * 10 + to_integer(unsigned(keydigit)), 8));
                    end if;
                end if;
                
            when FINISHED =>
                -- perform calculation
                op1_val := to_integer(unsigned(operand1_reg));
                op2_val := to_integer(unsigned(operand2_reg));
                
                case operator is
                    when ADD =>
                        temp_result := op1_val + op2_val; -- using temp_result variable because need for buffering
                    when SUB =>
                        if op1_val >= op2_val then
                            temp_result := op1_val - op2_val;
                        else
                            temp_result := 0;
                        end if;
                    when MUL =>
                        temp_result := op1_val * op2_val;
                    when DIV =>
                        if op2_val /= 0 then
                            temp_result := op1_val / op2_val;
                        else
                            temp_result := 0;
                        end if;
                    when others =>
                        temp_result := 0;
                end case;
                
                result_reg <= std_logic_vector(to_unsigned(temp_result, 16));
                
                -- convert result to BCD digits
                digit0 <= std_logic_vector(to_unsigned(temp_result mod 10, 4));
                temp_result := temp_result / 10;
                digit1 <= std_logic_vector(to_unsigned(temp_result mod 10, 4));
                temp_result := temp_result / 10;
                digit2 <= std_logic_vector(to_unsigned(temp_result mod 10, 4));
                temp_result := temp_result / 10;
                digit3 <= std_logic_vector(to_unsigned(temp_result mod 10, 4));
                
            when DO_RESET =>
                digit0 <= "0000";
                digit1 <= "0000";
                digit2 <= "0000";
                digit3 <= "0000";
                digit4 <= "0000";
                digit5 <= "0000";
                digit6 <= "0000";
                digit7 <= "0000";
                operand1_reg <= "00000000";
                operand2_reg <= "00000000";
                result_reg <= "0000000000000000";
        end case;
    end if;
end process display_logic;

operand1 <= operand1_reg;
operand2 <= operand2_reg;
result <= result_reg;
 
    seg0: bcd_to_7seg port map(input => digit0, output => HEX0);
    seg1: bcd_to_7seg port map(input => digit1, output => HEX1);
    seg2: bcd_to_7seg port map(input => digit2, output => HEX2);
    seg3: bcd_to_7seg port map(input => digit3, output => HEX3);
    seg4: bcd_to_7seg port map(input => digit4, output => HEX4);
    seg5: bcd_to_7seg port map(input => digit5, output => HEX5);
    seg6: bcd_to_7seg port map(input => digit6, output => HEX6);
    seg7: bcd_to_7seg port map(input => digit7, output => HEX7);
 
end architecture;