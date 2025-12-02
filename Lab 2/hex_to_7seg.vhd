library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hex_to_7seg is
    Port (
        hex_i : in  STD_LOGIC_VECTOR(3 downto 0);
        seg_o : out STD_LOGIC_VECTOR(6 downto 0)
    );
end hex_to_7seg;

architecture behavioral of hex_to_7seg is
begin
    process(hex_i)
    begin
        case hex_i is
            when X"0" => seg_o <= "1000000";  -- 0
            when X"1" => seg_o <= "1111001";  -- 1
            when X"2" => seg_o <= "0100100";  -- 2
            when X"3" => seg_o <= "0110000";  -- 3
            when X"4" => seg_o <= "0011001";  -- 4
            when X"5" => seg_o <= "0010010";  -- 5
            when X"6" => seg_o <= "0000010";  -- 6
            when X"7" => seg_o <= "1111000";  -- 7
            when X"8" => seg_o <= "0000000";  -- 8
            when X"9" => seg_o <= "0010000";  -- 9
            when X"A" => seg_o <= "0001000";  -- A
            when X"B" => seg_o <= "0000011";  -- b
            when X"C" => seg_o <= "1000110";  -- C
            when X"D" => seg_o <= "0100001";  -- d
            when X"E" => seg_o <= "0000110";  -- E
            when X"F" => seg_o <= "0001110";  -- F
            when others => seg_o <= "1111111";  -- Blank
        end case;
    end process;
end behavioral;
