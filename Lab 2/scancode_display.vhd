library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity scancode_display is
    port (
        sys_clk    : in  STD_LOGIC;                 
        reset      : in  STD_LOGIC;                  
        char_code  : in  STD_LOGIC_VECTOR(7 downto 0); 
        char_ready : in  STD_LOGIC;               

        seg0       : out STD_LOGIC_VECTOR(6 downto 0);
        seg1       : out STD_LOGIC_VECTOR(6 downto 0); 
        seg2       : out STD_LOGIC_VECTOR(6 downto 0); 
        seg3       : out STD_LOGIC_VECTOR(6 downto 0); 
        seg4       : out STD_LOGIC_VECTOR(6 downto 0); 
        seg5       : out STD_LOGIC_VECTOR(6 downto 0)  
    );
end scancode_display;

architecture rtl of scancode_display is

    -- c1 = newest scancode, c3 = oldest
    signal c1, c2, c3 : STD_LOGIC_VECTOR(7 downto 0);

begin

    -- shift register: store last 3 scancodes
    process(sys_clk, reset)
    begin
        if reset = '1' then
            c1 <= (others => '0');
            c2 <= (others => '0');
            c3 <= (others => '0');
        elsif rising_edge(sys_clk) then
            if char_ready = '1' then
                c3 <= c2;
                c2 <= c1;
                c1 <= char_code;
            end if;
        end if;
    end process;
	 
    hex0 : entity work.hex_to_7seg
        port map (
            hex_i => c1(3 downto 0),
            seg_o => seg0
        );

    hex1 : entity work.hex_to_7seg
        port map (
            hex_i => c1(7 downto 4),
            seg_o => seg1
        );

    hex2 : entity work.hex_to_7seg
        port map (
            hex_i => c2(3 downto 0),
            seg_o => seg2
        );

    hex3 : entity work.hex_to_7seg
        port map (
            hex_i => c2(7 downto 4),
            seg_o => seg3
        );

    hex4 : entity work.hex_to_7seg
        port map (
            hex_i => c3(3 downto 0),
            seg_o => seg4
        );

    hex5 : entity work.hex_to_7seg
        port map (
            hex_i => c3(7 downto 4),
            seg_o => seg5
        );

end architecture rtl;