library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.globals.all;

entity top_level is
    Port (
        CLOCK_50  : in  STD_LOGIC;
        KEY       : in  STD_LOGIC_VECTOR(3 downto 0);  -- KEY(0) = reset
        PS2_CLK   : in  STD_LOGIC;
        PS2_DAT   : in  STD_LOGIC;
        HEX0      : out STD_LOGIC_VECTOR(6 downto 0);  -- LSB nibble
        HEX1      : out STD_LOGIC_VECTOR(6 downto 0)   -- MSB nibble
    );
end top_level;

architecture struct of top_level is
    component keyboard_ctrl is
        Port (
            sys_clk    : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            ps2_clk    : in  STD_LOGIC;
            ps2_data   : in  STD_LOGIC;
            keyevent   : out key_event_type
        );
    end component;
    
    component hex_to_7seg is
        Port (
            hex_in  : in  STD_LOGIC_VECTOR(3 downto 0);
            seg_out : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;
    
    signal reset_n    : STD_LOGIC;
    signal reset      : STD_LOGIC;
    signal keyevent   : key_event_type;
    signal scancode_reg : STD_LOGIC_VECTOR(7 downto 0);
    
begin
    -- Reset is active low on KEY(0)
    reset_n <= KEY(0);
    reset <= not reset_n;
    
    -- Keyboard controller instance
    kbd_inst: keyboard_ctrl
        port map (
            sys_clk  => CLOCK_50,
            reset    => reset,
            ps2_clk  => PS2_CLK,
            ps2_data => PS2_DAT,
            keyevent => keyevent
        );
    
    -- Store latest valid scancode
    process(CLOCK_50, reset)
    begin
        if reset = '1' then
            scancode_reg <= (others => '0');
        elsif rising_edge(CLOCK_50) then
            if keyevent.valid = '1' then
                scancode_reg <= keyevent.scancode;
            end if;
        end if;
    end process;
    
    -- Display lower nibble on HEX0
    hex0_inst: hex_to_7seg
        port map (
            hex_in  => scancode_reg(3 downto 0),
            seg_out => HEX0
        );
    
    -- Display upper nibble on HEX1
    hex1_inst: hex_to_7seg
        port map (
            hex_in  => scancode_reg(7 downto 4),
            seg_out => HEX1
        );
    
end struct;