library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity keyboard is
    Port (
        sys_clk    : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        ps2_clk    : in  STD_LOGIC;
        ps2_data   : in  STD_LOGIC;
        char_code  : out STD_LOGIC_VECTOR(7 downto 0);
        char_ready : out STD_LOGIC
    );
end keyboard;

architecture behav of keyboard is
    type state_type is (IDLE, DATA, PARITY, STOP);
    signal state, next_state : state_type;
    
    component one_shot is
        Port (
            trigger_i: in std_logic;
				pulse_o: out std_logic;
				clock: in std_logic;
				reset: in std_logic
        );
    end component;
    
    signal ps2_clk_sync : STD_LOGIC;
    signal bit_count    : integer range 0 to 7;
    signal data_shift   : STD_LOGIC_VECTOR(7 downto 0);
    signal parity_bit   : STD_LOGIC;
    signal char_code_reg : STD_LOGIC_VECTOR(7 downto 0);
    signal char_ready_reg : STD_LOGIC;
    
begin
    -- oneshot to synchronize PS/2 clock
    oneshot_inst: one_shot
        port map (
            clock		 => sys_clk,
            reset     => reset,
            trigger_i => ps2_clk,
            pulse_o   => ps2_clk_sync
        );
    
    -- storage process to save state and data
    storage_process: process(sys_clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            bit_count <= 0;
            data_shift <= (others => '0');
            parity_bit <= '0';
            char_code_reg <= (others => '0');
            char_ready_reg <= '0';
            
        elsif rising_edge(sys_clk) then
            state <= next_state;
            
            if char_ready_reg = '1' then
                char_ready_reg <= '0';
            end if;
            
            if ps2_clk_sync = '1' then
                case state is
                    when IDLE =>
                        bit_count <= 0;
                        data_shift <= (others => '0');
                        
                    when DATA =>
                        -- shift data bits, LSB first
                        data_shift <= ps2_data & data_shift(7 downto 1);
                        bit_count <= bit_count + 1;
                        
                    when PARITY =>
                        parity_bit <= ps2_data;
                        
                    when STOP =>
                        -- verify stop bit and parity
                        if ps2_data = '1' then  -- correct stop bit 1
                            -- odd parity
                            if (data_shift(0) xor data_shift(1) xor data_shift(2) xor 
                                data_shift(3) xor data_shift(4) xor data_shift(5) xor 
                                data_shift(6) xor data_shift(7) xor parity_bit) = '1' then
                                -- valid frame with correct parity
                                char_code_reg <= data_shift;
                                char_ready_reg <= '1';
                            end if;
                        end if;
                end case;
            end if;
        end if;
    end process storage_process;
    
    next_state_process: process(state, ps2_clk_sync, ps2_data, bit_count)
    begin
        case state is
            when IDLE =>
                -- wait for start bit (ps2_data = '0')
                if ps2_clk_sync = '1' and ps2_data = '0' then
                    next_state <= DATA;
                else
                    next_state <= IDLE;
                end if;
                
            when DATA =>
                -- receive 8 data bits
                if ps2_clk_sync = '1' then
                    if bit_count = 7 then
                        next_state <= PARITY;
                    else
                        next_state <= DATA;
                    end if;
                else
                    next_state <= DATA;
                end if;
                
            when PARITY =>
                -- receive parity bit
                if ps2_clk_sync = '1' then
                    next_state <= STOP;
                else
                    next_state <= PARITY;
                end if;
                
            when STOP =>
                -- receive stop bit and return to IDLE
                if ps2_clk_sync = '1' then
                    next_state <= IDLE;
                else
                    next_state <= STOP;
                end if;
        end case;
    end process next_state_process;
    
    -- output assignments
    char_code <= char_code_reg;
    char_ready <= char_ready_reg;
    
end behav;