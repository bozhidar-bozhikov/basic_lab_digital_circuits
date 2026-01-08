library ieee;
use ieee.std_logic_1164.all;
use work.all;
use work.globals.all;

entity top_level is
    port(
        CLOCK_50: in std_logic;
        
        -- Reset button (KEY0 on DE2-115, active low)
        KEY: in std_logic_vector(0 downto 0);
        
        PS2_CLK: in std_logic;
        PS2_DAT: in std_logic;
        
        HEX0: out std_logic_vector(6 downto 0);
        HEX1: out std_logic_vector(6 downto 0);
        HEX2: out std_logic_vector(6 downto 0);
        HEX3: out std_logic_vector(6 downto 0);
        HEX4: out std_logic_vector(6 downto 0);
        HEX5: out std_logic_vector(6 downto 0);
        HEX6: out std_logic_vector(6 downto 0);
        HEX7: out std_logic_vector(6 downto 0)
    );
end top_level;

architecture structural of top_level is
    component keyboard is
        port (
            sys_clk    : in  std_logic;
            reset      : in  std_logic;
            ps2_clk    : in  std_logic;
            ps2_data   : in  std_logic;
            char_code  : out std_logic_vector(7 downto 0);
            char_ready : out std_logic
        );
    end component;
    
    component scancode_decoder is
        port(
            sys_clk: in std_logic;
            reset: in std_logic;
            char_code: in std_logic_vector(7 downto 0);
            char_ready: in std_logic;
            keydigit: out std_logic_vector(3 downto 0);
            keyevent: buffer key_event_type;
            keytrigger: buffer std_logic
        );
    end component;
    
    component bcd_to_7seg is
        port(
            input: in std_logic_vector(3 downto 0);
            output: out std_logic_vector(6 downto 0)
        );
    end component;
	 
	 component statemachine is 
			port (
				sys_clk, keytrigger, reset  :  in std_logic;
				keydigit  :  in std_logic_vector(3 downto 0);
				keyevent  :  in key_event_type;
				operator  :  out operator_type;
				operand1, operand2  : out std_logic_vector (7 downto 0);
				result 	:  out std_logic_vector (15 downto 0)
			);
	 end component;
    
    -- Internal signals
    signal reset: std_logic;
    signal char_code: std_logic_vector(7 downto 0);
    signal char_ready: std_logic;
    signal keydigit: std_logic_vector(3 downto 0);
    signal keyevent: key_event_type;
    signal keytrigger: std_logic;
    
    -- Shift register for 8 digits
    signal digit0, digit1, digit2, digit3: std_logic_vector(3 downto 0);
    signal digit4, digit5, digit6, digit7: std_logic_vector(3 downto 0);
	 
	 -- State machine signals
    signal sm_clk: bit;
    signal sm_trigger: bit;
    signal sm_reset: bit;
    signal current_operator: operator_type;
    signal operand1: std_logic_vector(7 downto 0);
    signal operand2: std_logic_vector(7 downto 0);
    signal result: std_logic_vector(15 downto 0);
    
begin
    -- Reset is active high internally, KEY(0) is active low
    reset <= not KEY(0);
    
    -- Instantiate keyboard interface
    keyboard_inst: keyboard
        port map (
            sys_clk    => CLOCK_50,
            reset      => reset,
            ps2_clk    => PS2_CLK,
            ps2_data   => PS2_DAT,
            char_code  => char_code,
            char_ready => char_ready
        );
    
    -- Instantiate scancode decoder
    decoder_inst: scancode_decoder
        port map (
            sys_clk    => CLOCK_50,
            reset      => reset,
            char_code  => char_code,
            char_ready => char_ready,
            keydigit   => keydigit,
            keyevent   => keyevent,
            keytrigger => keytrigger
        );
		  
		
	statemachine_inst: statemachine
        port map (
            sys_clk    => sm_clk,
            keytrigger => sm_trigger,
            reset      => sm_reset,
            keydigit   => keydigit,
            keyevent   => keyevent,
            operator   => current_operator,
            operand1   => operand1,
            operand2   => operand2,
            result     => result
        );
    
	 
	 process(CLOCK_50, keytrigger, reset)
    begin
        if CLOCK_50 = '1' then
            sm_clk <= '1';
        else
            sm_clk <= '0';
        end if;
        
        if keytrigger = '1' then
            sm_trigger <= '1';
        else
            sm_trigger <= '0';
        end if;
        
        if reset = '1' then
            sm_reset <= '1';
        else
            sm_reset <= '0';
        end if;
    end process;
	 	

    seg0: bcd_to_7seg port map(input => digit0, output => HEX0);
    seg1: bcd_to_7seg port map(input => digit1, output => HEX1);
    seg2: bcd_to_7seg port map(input => digit2, output => HEX2);
    seg3: bcd_to_7seg port map(input => digit3, output => HEX3);
    seg4: bcd_to_7seg port map(input => digit4, output => HEX4);
    seg5: bcd_to_7seg port map(input => digit5, output => HEX5);
    seg6: bcd_to_7seg port map(input => digit6, output => HEX6);
    seg7: bcd_to_7seg port map(input => digit7, output => HEX7);
    
end architecture;