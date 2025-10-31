library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity one_shot_tb is
-- Testbench has no ports
end one_shot_tb;

architecture behav of one_shot_tb is
    component one_shot
        Port ( 
            sys_clk    : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            trigger_i  : in  STD_LOGIC;
            pulse_o    : out STD_LOGIC
        );
    end component;
    
    signal sys_clk   : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '0';
    signal trigger_i : STD_LOGIC := '0';
    signal pulse_o   : STD_LOGIC;
    
    constant clk_period : time := 20 ns;  -- 50 MHz clock
    
begin
    uut: one_shot
        Port map (
            sys_clk   => sys_clk,
            reset     => reset,
            trigger_i => trigger_i,
            pulse_o   => pulse_o
        );
    
    clk_process: process
    begin
        sys_clk <= '0';
        wait for clk_period/2;
        sys_clk <= '1';
        wait for clk_period/2;
    end process;
    
    bench_process: process
    begin
        reset <= '1';
        trigger_i <= '0';
        wait for 100 ns;
        
        reset <= '0';
        wait for 50 ns;
        
        trigger_i <= '1';
        wait for 30 ns;
        trigger_i <= '0';
        wait for 100 ns;
        
        trigger_i <= '1';
        wait for 200 ns;
        trigger_i <= '0';
        wait for 100 ns;
        
        trigger_i <= '1';
        wait for 50 ns;
        trigger_i <= '0';
        wait for 80 ns;
        trigger_i <= '1';
        wait for 40 ns;
        trigger_i <= '0';
        wait for 100 ns;
        
        wait;
    end process;
    
end behav;