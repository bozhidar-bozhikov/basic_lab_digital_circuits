library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_task2 is
    port (
        clock    : in  STD_LOGIC;                      -- system clock
        reset_N  : in  STD_LOGIC;                      -- active-low reset from board

        ps2_clk  : in  STD_LOGIC;
        ps2_data : in  STD_LOGIC;

        seg0     : out STD_LOGIC_VECTOR(6 downto 0);
        seg1     : out STD_LOGIC_VECTOR(6 downto 0);
        seg2     : out STD_LOGIC_VECTOR(6 downto 0);
        seg3     : out STD_LOGIC_VECTOR(6 downto 0);
        seg4     : out STD_LOGIC_VECTOR(6 downto 0);
        seg5     : out STD_LOGIC_VECTOR(6 downto 0)
    );
end top_task2;

architecture rtl of top_task2 is

    signal reset      : STD_LOGIC;
    signal char_code  : STD_LOGIC_VECTOR(7 downto 0);
    signal char_ready : STD_LOGIC;

begin
    reset <= not reset_N;

    keyboard_inst : entity work.keyboard
        port map (
            sys_clk    => clock,
            reset      => reset,
            ps2_clk    => ps2_clk,
            ps2_data   => ps2_data,
            char_code  => char_code,
            char_ready => char_ready
        );

    display_inst : entity work.scancode_display
        port map (
            sys_clk    => clock,
            reset      => reset,
            char_code  => char_code,
            char_ready => char_ready,
            seg0       => seg0,
            seg1       => seg1,
            seg2       => seg2,
            seg3       => seg3,
            seg4       => seg4,
            seg5       => seg5
        );

end architecture rtl;