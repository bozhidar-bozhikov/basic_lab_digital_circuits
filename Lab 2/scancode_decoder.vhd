library ieee;
use ieee.std_logic_1164.all;
use WORK.globals.all;

entity scancode_decoder is
  port (
    sys_clk, char_ready, reset  : in std_logic;
    char_code  : in std_logic_vector(7 downto 0);
    keytrigger  : out std_logic;
    keydigit  : out std_logic_vector(3 downto 0);
    keyevent  : out key_event_type
  );
end entity scancode_decoder;
  
architecture behav of scancode_decoder is
  type state_type is (IDLE, BUSY, IGNORE1, IGNORE2);
  signal state, next_state  : state_type;
  signal next_keydigit, keydigit_reg  : std_logic_vector(3 downto 0);
  signal next_keyevent, keyevent_reg  : key_event_type;
  signal keytrigger_reg : std_logic;
  signal char_code_reg  : std_logic_vector(7 downto 0);
  
begin
  
  -- storage process (reset, clock)
  -- manages the state
  storage: process (reset, sys_clk)
  begin
    if reset = '1' then
      state <= IDLE;
      keytrigger_reg <= '0';
      keydigit_reg <= (others => '0');
      keyevent_reg <= KEY_OTHER;
      char_code_reg <= (others => '0');
    elsif rising_edge(sys_clk) then
      state <= next_state;
      
      -- update outputs only when moving from IGNORE1 to BUSY, key press detected
      if state = IGNORE1 and next_state = BUSY then
        keydigit_reg <= next_keydigit;
        keyevent_reg <= next_keyevent;
        keytrigger_reg <= '1';
      else
        keytrigger_reg <= '0';
      end if;
      
      -- register char_code when transitioning from IDLE to BUSY
      if state = IDLE and char_ready = '1' then
        char_code_reg <= char_code;
      end if;
    end if;
  end process storage;
    
  -- Next_state state machine (state, char_ready, char_code)
  next_state_process: process (state, char_ready, char_code, char_code_reg)
  begin
    -- to avoid latches
    next_state <= state;
    
    case state is
      when IDLE =>
        -- await for char_ready and register the key
        if char_ready = '1' then 
          next_state <= BUSY;
        end if;
        
      when BUSY =>
        -- await for signal to stop
        if char_ready = '0' then 
          next_state <= IGNORE1;
        end if;
        
      when IGNORE1 =>
        -- check if key was actually released 
        if char_ready = '1' then
          if char_code = char_code_reg then 
            next_state <= BUSY;
          else
            next_state <= IGNORE2;
          end if;
        end if;
        
      when IGNORE2 =>
        -- await for release
        if char_ready = '0' then
          next_state <= IDLE;
        end if;
    end case;
  end process next_state_process;
    
  -- Assigns the next_keyevent, next_keydigit
  scancode: process (char_code)
  begin
    next_keyevent <= KEY_OTHER;
    next_keydigit <= "0000";
    
    case char_code is
      when x"4A" => next_keyevent <= KEY_DIV;  -- /
      when x"7C" => next_keyevent <= KEY_MUL;  -- *
      when x"7B" => next_keyevent <= KEY_SUB;  -- -
      when x"79" => next_keyevent <= KEY_ADD;  -- +
      when x"70" => next_keyevent <= KEY_NUM; next_keydigit <= "0000";  -- 0
      when x"69" => next_keyevent <= KEY_NUM; next_keydigit <= "0001";  -- 1
      when x"72" => next_keyevent <= KEY_NUM; next_keydigit <= "0010";  -- 2
      when x"7A" => next_keyevent <= KEY_NUM; next_keydigit <= "0011";  -- 3
      when x"6B" => next_keyevent <= KEY_NUM; next_keydigit <= "0100";  -- 4
      when x"73" => next_keyevent <= KEY_NUM; next_keydigit <= "0101";  -- 5
      when x"74" => next_keyevent <= KEY_NUM; next_keydigit <= "0110";  -- 6
      when x"6C" => next_keyevent <= KEY_NUM; next_keydigit <= "0111";  -- 7
      when x"75" => next_keyevent <= KEY_NUM; next_keydigit <= "1000";  -- 8
      when x"7D" => next_keyevent <= KEY_NUM; next_keydigit <= "1001";  -- 9
      when x"5A" => next_keyevent <= KEY_ENTER;
      when x"76" => next_keyevent <= KEY_RESET; -- esc
      when others => next_keyevent <= KEY_OTHER;
    end case;
  end process scancode;
  
  keytrigger <= keytrigger_reg;
  keydigit <= keydigit_reg;
  keyevent <= keyevent_reg;
  
end behav;