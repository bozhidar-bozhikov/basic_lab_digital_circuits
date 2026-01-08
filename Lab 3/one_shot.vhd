library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity one_shot is
    port(
        trigger_i: in std_logic;
        pulse_o: out std_logic;
        clock: in std_logic;
        reset: in std_logic
    );
end one_shot;


architecture behav of one_shot is
    signal state, next_state: std_logic;
begin
    process(reset, clock)
    begin
        if reset = '1' then 
            state <= '0';
        elsif rising_edge(clock) then 
            state <= next_state;
        end if;
    end process;

    process(reset, trigger_i, state)
    begin
        if reset = '1' or state = '1'  then 
            next_state <= '0';
        elsif rising_edge(trigger_i) and state = '0' then
            next_state <= '1';
        end if;
    end process;

    pulse_o <= state;
end architecture;

