library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity led_register_top is
    Port (
        CLOCK_50   : in  STD_LOGIC;                    -- 50 MHz clock
        KEY        : in  STD_LOGIC_VECTOR(1 downto 0); -- KEY[0]=load, KEY[1]=reset
        SW         : in  STD_LOGIC_VECTOR(3 downto 0); -- 4 switches
        LEDR       : out STD_LOGIC_VECTOR(3 downto 0)  -- 4 red LEDs
    );
end led_register_top;

architecture behav of led_register_top is
    
    -- Component: One-Shot from Task 3
    component one_shot
        Port ( 
            sys_clk    : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            trigger_i  : in  STD_LOGIC;
            pulse_o    : out STD_LOGIC
        );
    end component;
    
    -- Component: Generic Register from Task 2
    component generic_register
        Generic (N : integer := 8);
        Port (
            clk    : in  STD_LOGIC;
            reset  : in  STD_LOGIC;
            enable : in  STD_LOGIC;
            D      : in  STD_LOGIC_VECTOR(N-1 downto 0);
            Q      : out STD_LOGIC_VECTOR(N-1 downto 0)
        );
    end component;
    
    -- Internal signals
    signal reset_N     : STD_LOGIC;  -- Active low reset from KEY[1]
    signal trigger_N   : STD_LOGIC;  -- Active low trigger from KEY[0]
    signal reset       : STD_LOGIC;  -- Active high reset
    signal trigger     : STD_LOGIC;  -- Active high trigger
    signal load_pulse  : STD_LOGIC;  -- One-shot output (enable for register)
    
begin
    
    -- Handle negative logic (buttons are active LOW on DE2-115)
    reset_N   <= KEY(1);
    trigger_N <= KEY(0);
    
    reset   <= not reset_N;
    trigger <= not trigger_N;
    
    -- One-Shot: converts button press to single clock pulse
    u_oneshot: one_shot
        port map (
            sys_clk   => CLOCK_50,
            reset     => reset,
            trigger_i => trigger,
            pulse_o   => load_pulse
        );
    
    -- 4-bit Register: stores switch values and displays on LEDs
    u_register: generic_register
        Generic map (N => 4)
        Port map (
            clk    => CLOCK_50,
            reset  => reset,
            enable => load_pulse,
            D      => SW,
            Q      => LEDR
        );
    
end behav;