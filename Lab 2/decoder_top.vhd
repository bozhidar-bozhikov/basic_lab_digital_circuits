library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.globals.all;

entity decoder_top is
    Port (
        -- Clock and Reset
        CLOCK_50    : in  STD_LOGIC;
        KEY         : in  STD_LOGIC_VECTOR(3 downto 0);
        
        -- PS/2 Keyboard
        PS2_CLK     : in  STD_LOGIC;
        PS2_DAT     : in  STD_LOGIC;
        
        -- 7-Segment Displays
        HEX0        : out STD_LOGIC_VECTOR(6 downto 0);
        HEX1        : out STD_LOGIC_VECTOR(6 downto 0);
        HEX2        : out STD_LOGIC_VECTOR(6 downto 0);
        HEX3        : out STD_LOGIC_VECTOR(6 downto 0);
        
        -- LEDs for debugging
        LEDR        : out STD_LOGIC_VECTOR(17 downto 0);
        LEDG        : out STD_LOGIC_VECTOR(8 downto 0)
    );
end entity decoder_top;

architecture behav of decoder_top is
    
    -- Component declarations
    component keyboard is
        Port (
            sys_clk    : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            ps2_clk    : in  STD_LOGIC;
            ps2_data   : in  STD_LOGIC;
            char_code  : out STD_LOGIC_VECTOR(7 downto 0);
            char_ready : out STD_LOGIC
        );
    end component;
    
    component scancode_decoder is
        Port (
            sys_clk      : in  STD_LOGIC;
            char_ready   : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            char_code    : in  STD_LOGIC_VECTOR(7 downto 0);
            keytrigger   : out STD_LOGIC;
            keydigit     : out STD_LOGIC_VECTOR(3 downto 0);
            keyevent     : out key_event_type
        );
    end component;
    
    component hex_to_7seg is
        Port (
            hex_i : in  STD_LOGIC_VECTOR(3 downto 0);
            seg_o : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;
    
    -- Internal signals
    signal reset          : STD_LOGIC;
    signal char_ready     : STD_LOGIC;
    signal char_code      : STD_LOGIC_VECTOR(7 downto 0);
    signal keytrigger     : STD_LOGIC;
    signal keydigit       : STD_LOGIC_VECTOR(3 downto 0);
    signal keyevent       : key_event_type;
    
    -- Shift register for Task 4 (16 bits = 4 hex digits)
    signal shift_reg      : STD_LOGIC_VECTOR(15 downto 0);
    
begin
    
    -- Reset is active high (KEY[0] is active low, so invert it)
    reset <= not KEY(0);
    
    -- Instantiate your existing Keyboard Driver
    keyboard_inst: keyboard
        port map (
            sys_clk    => CLOCK_50,
            reset      => reset,
            ps2_clk    => PS2_CLK,
            ps2_data   => PS2_DAT,
            char_code  => char_code,
            char_ready => char_ready
        );
    
    -- Instantiate your Scancode Decoder
    decoder_inst: scancode_decoder
        port map (
            sys_clk    => CLOCK_50,
            char_ready => char_ready,
            reset      => reset,
            char_code  => char_code,
            keytrigger => keytrigger,
            keydigit   => keydigit,
            keyevent   => keyevent
        );
    
    -- Shift Register Process (for Task 4)
    -- When you press numpad keys, they shift into the register
    shift_register: process(CLOCK_50, reset)
    begin
        if reset = '1' then
            shift_reg <= (others => '0');
        elsif rising_edge(CLOCK_50) then
            if keytrigger = '1' and keyevent = KEY_NUM then
                -- Shift left and insert new digit at LSB
                shift_reg <= shift_reg(11 downto 0) & keydigit;
            elsif keyevent = KEY_RESET and keytrigger = '1' then
                -- Clear shift register on ESC key
                shift_reg <= (others => '0');
            end if;
        end if;
    end process shift_register;
    
    -- Display shift register contents on 7-segment displays
    -- HEX0 is rightmost (LSB), HEX3 is leftmost (MSB)
    hex0_inst: hex_to_7seg
        port map (
            hex_i => shift_reg(3 downto 0),
            seg_o => HEX0
        );
    
    hex1_inst: hex_to_7seg
        port map (
            hex_i => shift_reg(7 downto 4),
            seg_o => HEX1
        );
    
    hex2_inst: hex_to_7seg
        port map (
            hex_i => shift_reg(11 downto 8),
            seg_o => HEX2
        );
    
    hex3_inst: hex_to_7seg
        port map (
            hex_i => shift_reg(15 downto 12),
            seg_o => HEX3
        );
    
    -- Debug LEDs
    -- Show current keydigit on LEDR(3:0)
    LEDR(3 downto 0) <= keydigit;
    
    -- Show keytrigger pulse on LEDR(17)
    LEDR(17) <= keytrigger;
    
    -- Show char_ready on LEDR(16)
    LEDR(16) <= char_ready;
    
    -- Show scan_code on LEDR(15:8)
    LEDR(15 downto 8) <= char_code;
    
    -- Show keyevent on green LEDs
    LEDG(0) <= '1' when keyevent = KEY_NUM else '0';
    LEDG(1) <= '1' when keyevent = KEY_ADD else '0';
    LEDG(2) <= '1' when keyevent = KEY_SUB else '0';
    LEDG(3) <= '1' when keyevent = KEY_MUL else '0';
    LEDG(4) <= '1' when keyevent = KEY_DIV else '0';
    LEDG(5) <= '1' when keyevent = KEY_ENTER else '0';
    LEDG(6) <= '1' when keyevent = KEY_RESET else '0';
    LEDG(7) <= '1' when keyevent = KEY_OTHER else '0';
    
end behav;