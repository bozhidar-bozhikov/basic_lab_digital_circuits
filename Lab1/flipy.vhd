library ieee;
use ieee.std_logic_1164.all;

entity flipy is
	port(
	D, clock, reset: in std_logic;
	Q: out std_logic);
end entity flipy;

architecture behav of flipy is
begin
	s: process (clock, reset) is
begin
	if reset = '1' then
		Q <= '0';
	elsif rising_edge(clock) then
		Q <= D;
	end if;
end process;
end architecture behav;