library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register_led_top is
    Port (
        CLOCK_50   : in  STD_LOGIC;                    -- 50 MHz clock on DE2-115
        KEY        : in  STD_LOGIC_VECTOR(1 downto 0); -- Pushbuttons (active low)
        SW         : in  STD_LOGIC_VECTOR(3 downto 0); -- Switches
        LEDR       : out STD_LOGIC_VECTOR(3 downto 0)  -- Red LEDs
    );
end register_led_top;

architecture Behavioral of register_led_top is
    
    -- Component declarations
    component one_shot
        Port ( 
            sys_clk    : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            trigger_i  : in  STD_LOGIC;
            pulse_o    : out STD_LOGIC
        );
    end component;
    
    -- Internal signals
    signal reset_N    : STD_LOGIC;  -- Active low reset (from KEY(0))
    signal load_N     : STD_LOGIC;  -- Active low load (from KEY(1))
    signal reset      : STD_LOGIC;  -- Active high reset
    signal load_pulse : STD_LOGIC;  -- One-shot pulse for load
    signal load       : STD_LOGIC;  -- Active high load
    signal reg_out    : STD_LOGIC_VECTOR(3 downto 0); -- Register output
    
begin
    
    -- Handle negative logic for buttons (KEY buttons are active low on DE2-115)
    reset_N <= KEY(0);
    load_N  <= KEY(1);
    
    reset <= not reset_N;
    load  <= not load_N;
    
    -- One-shot for load button (debouncing)
    load_oneshot: one_shot
        port map (
            sys_clk   => CLOCK_50,
            reset     => reset,
            trigger_i => load,
            pulse_o   => load_pulse
        );
    
    -- 4-bit register process
    register_process: process(CLOCK_50, reset)
    begin
        if reset = '1' then
            reg_out <= (others => '0');  -- Clear register on reset
        elsif rising_edge(CLOCK_50) then
            if load_pulse = '1' then
                reg_out <= SW;  -- Load switch values into register
            end if;
        end if;
    end process register_process;
    
    -- Connect register output to LEDs
    LEDR <= reg_out;
    
end Behavioral;