library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity generic_register is
    Generic (
        N : integer := 8
    );
    Port (
        clk, reset, enable    : in  STD_LOGIC;
        D      : in  STD_LOGIC_VECTOR(N-1 downto 0);
        Q      : out STD_LOGIC_VECTOR(N-1 downto 0)
    );
end generic_register;

architecture behav of generic_register is
begin
    s: process(clk, reset)
    begin
        if reset = '1' then
            Q <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                Q <= D;
            end if;
        end if;
    end process;
end behav;