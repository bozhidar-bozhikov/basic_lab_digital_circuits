library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity keyboard_driver_display is
    Port (
        clock      : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        ps2_clk    : in  STD_LOGIC;
        ps2_data   : in  STD_LOGIC;
        seg_h_h    : out STD_LOGIC_VECTOR(6 downto 0);
        seg_h_l    : out STD_LOGIC_VECTOR(6 downto 0);
        seg_l_h    : out STD_LOGIC_VECTOR(6 downto 0);
        seg_l_l    : out STD_LOGIC_VECTOR(6 downto 0)
    );
end keyboard_driver_display;

architecture structural of keyboard_driver_display is
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
    
    component hex_to_7seg is
        Port (
            hex_i : in  STD_LOGIC_VECTOR(3 downto 0);
            seg_o : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;
    
    signal char_code      : STD_LOGIC_VECTOR(7 downto 0);
    signal char_ready     : STD_LOGIC;
    signal display_digit  : STD_LOGIC_VECTOR(3 downto 0);
    signal prev_code      : STD_LOGIC_VECTOR(7 downto 0);
    
    constant ESCAPE_CODE  : STD_LOGIC_VECTOR(7 downto 0) := X"E0";
    constant BREAK_CODE   : STD_LOGIC_VECTOR(7 downto 0) := X"F0";
    
    -- numpad scancodes
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
    
begin
    keyboard_inst: keyboard
        port map (
            sys_clk    => clock,
            reset      => reset,
            ps2_clk    => ps2_clk,
            ps2_data   => ps2_data,
            char_code  => char_code,
            char_ready => char_ready
        );
    
    decode_process: process(clock, reset)
    begin
        if reset = '1' then
            display_digit <= (others => '0');
            prev_code <= (others => '0');
            
        elsif rising_edge(clock) then
            if char_ready = '1' then
                -- ignore escape codes (E0) and break codes (F0)
                if char_code /= ESCAPE_CODE and char_code /= BREAK_CODE and 
                   prev_code /= BREAK_CODE then
                    -- check if its a numpad digit and covnert to display value
                    case char_code is
                        when NUMPAD_0 => display_digit <= X"0";
                        when NUMPAD_1 => display_digit <= X"1";
                        when NUMPAD_2 => display_digit <= X"2";
                        when NUMPAD_3 => display_digit <= X"3";
                        when NUMPAD_4 => display_digit <= X"4";
                        when NUMPAD_5 => display_digit <= X"5";
                        when NUMPAD_6 => display_digit <= X"6";
                        when NUMPAD_7 => display_digit <= X"7";
                        when NUMPAD_8 => display_digit <= X"8";
                        when NUMPAD_9 => display_digit <= X"9";
                        when others   => null;  -- Ignore all other keys
                    end case;
                end if;
                
                prev_code <= char_code;
            end if;
        end if;
    end process decode_process;
    
    -- instantiate 4 hex-to-7segment decoders
    -- problem might be here
    hex_h_h: hex_to_7seg
        port map (
            hex_i => display_digit,
            seg_o => seg_h_h
        );
    
    hex_h_l: hex_to_7seg
        port map (
            hex_i => display_digit,
            seg_o => seg_h_l
        );
    
    hex_l_h: hex_to_7seg
        port map (
            hex_i => display_digit,
            seg_o => seg_l_h
        );
    
    hex_l_l: hex_to_7seg
        port map (
            hex_i => display_digit,
            seg_o => seg_l_l
        );
    
end structural;
