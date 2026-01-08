library ieee;
use ieee.std_logic_1164.all;
use work.all;
use work.globals.all;

entity top_level is
    port(
        CLOCK_50: in std_logic;
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
    
    component statemachine is 
        port (
            sys_clk, keytrigger, reset : in std_logic;
            keydigit  : in std_logic_vector(3 downto 0);
            keyevent  : in key_event_type;
            operator  : out operator_type;
            operand1, operand2 : out std_logic_vector(7 downto 0);
            result : out std_logic_vector(15 downto 0);
            HEX0, HEX1, HEX2, HEX3 : out std_logic_vector(6 downto 0);
            HEX4, HEX5, HEX6, HEX7 : out std_logic_vector(6 downto 0)
        );
    end component;
    
    signal reset: std_logic;
    signal char_code: std_logic_vector(7 downto 0);
    signal char_ready: std_logic;
    signal keydigit: std_logic_vector(3 downto 0);
    signal keyevent: key_event_type;
    signal keytrigger: std_logic;
    signal current_operator: operator_type;
    signal operand1: std_logic_vector(7 downto 0);
    signal operand2: std_logic_vector(7 downto 0);
    signal result: std_logic_vector(15 downto 0);
    
begin
    reset <= not KEY(0);
    
    keyboard_inst: keyboard
        port map (
            sys_clk    => CLOCK_50,
            reset      => reset,
            ps2_clk    => PS2_CLK,
            ps2_data   => PS2_DAT,
            char_code  => char_code,
            char_ready => char_ready
        );
    
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
            sys_clk    => CLOCK_50,
            keytrigger => keytrigger,
            reset      => reset,
            keydigit   => keydigit,
            keyevent   => keyevent,
            operator   => current_operator,
            operand1   => operand1,
            operand2   => operand2,
            result     => result,
            HEX0       => HEX0,
            HEX1       => HEX1,
            HEX2       => HEX2,
            HEX3       => HEX3,
            HEX4       => HEX4,
            HEX5       => HEX5,
            HEX6       => HEX6,
            HEX7       => HEX7
        );
    
end architecture;