library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity flipy_tb is
end flipy_tb;

architecture behav of flipy_tb is
	signal input_tb : std_logic;
	signal output_tb : std_logic;
	signal clock_tb: std_logic;
	signal reset_tb : std_logic;

begin
r: process
begin
	reset_tb <= '1';
	wait for 5 ns;
	reset_tb <= '0';
	wait for 70 ns;
	reset_tb <= '1';
	wait for 10 ns;
	reset_tb <= '0';
	wait;
end process r;

c: process
	begin
	clock_tb <= '1';
	wait for 5 ns;
	clock_tb <= '0';
	wait for 5 ns;
end process c;

d: process
	begin
	input_tb <= '0';
	wait for 10 ns;
	input_tb <= '1';
	wait for 10 ns;
	input_tb <= '0';
	wait for 35 ns;
	input_tb <= '1';
	wait for 10 ns;
	input_tb <= '0';
	wait;
end process d;

	Mapping: entity flipy(behav)
	port map(
		D => input_tb,
		Q => output_tb,
		clock => clock_tb,
		reset => reset_tb);
end architecture behav;
