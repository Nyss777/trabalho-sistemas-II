library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Behavioral is
    generic (
        DATA_WIDTH  : integer := 8;
        ADDR_WIDTH  : integer := 8
    );
    port (  
        clk              : in std_logic;
        rst              : in std_logic;
        data             : in std_logic_vector(DATA_WIDTH -1 downto 0);
        data_av          : in std_logic; 
        data_ok          : out std_logic; 
        done             : out std_logic;
        
        -- Memory interface
        mem_ce           : out std_logic;
        mem_wr           : out std_logic;
        mem_addr         : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
        mem_data_in      : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        mem_data_out     : in std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end Behavioral;

architecture Behav of Behavioral is

    type State is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12);
    signal currentState : State;
    
    -- Datapath signals
    type DataAv is (D0, D1, D2, D3);
    signal dv : DataAv;

    signal i, j, k, t : unsigned(ADDR_WIDTH - 1 downto 0);
    signal state_addr : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal state_size : unsigned(ADDR_WIDTH - 1 downto 0);
    signal temp_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal keystream_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    
    -- Helper function for modulo operation
    function mod_operation(value : unsigned; divisor : unsigned) return unsigned is
    begin
        if value < divisor then
            return value;
        else
            return value mod divisor;
        end if;
    end function;

begin
    
    -- Memory control logic: set address and data based on current state
    mem_addr <= std_logic_vector(i) when (currentState = S3 or currentState = S4 or 
                                           currentState = S5 or currentState = S6) else
                std_logic_vector(j) when (currentState = S6 or currentState = S7) else
                std_logic_vector(t) when (currentState = S10) else
                (others => '0');
    
    -- Determine memory write enable based on state
    mem_wr <= '1' when (currentState = S7 or currentState = S8) else '0';
    
    -- Memory chip enable
    mem_ce <= '1' when currentState /= S0 and currentState /= S1 else '0';
    
    -- Write data to memory
    mem_data_in <= temp_data when (currentState = S7 or currentState = S8) else
                   (others => '0');
    
    -- Output the keystream byte
    -- data_out <= mem_data_out when currentState = S11 else (others => '0');
    
    -- Done signal
    done <= '1' when (currentState = S1 and k >= state_size) else '0';

    -- Sequential process for state transitions
    process(clk, rst)
    begin
        if rst = '1' then 
            currentState <= S0;
            i <= (others => '0');
            j <= (others => '0');
            k <= (others => '0');
            t <= (others => '0');
            temp_data <= (others => '0');
            dv <= D0;
            
        elsif rising_edge(clk) then
            
            case currentState is
            
                when S0 =>
                    
                    if data_av = '1' then
                        case dv is
                            when D0 =>
                                state_addr <= data;
                                dv <= D1;
                            when D1 =>
                                state_size <= unsigned(data);
                                dv <= D2;
                            when D2 =>
                                dv <= D3;
                            when D3 =>
                                keystream_addr <= data;
                                data_ok <= '1';
                                currentState <= S1;
                        end case;
                    end if;

                when S1 => 
                    -- Check if k < stateSize
                    if k < state_size then
                        currentState <= S2;
                    else
                        currentState <= S0;
                    end if;

                when S2 => 
                    -- i = (i + 1) % stateSize
                    i <= mod_operation(i + 1, state_size);
                    currentState <= S3;

                when S3 =>
                    -- Read state[i] from memory
                    currentState <= S4;
                    -- mem_addr and mem_ce control the read
                
                when S4 => 
                    -- Store state[i] in temp_data and calculate j
                    temp_data <= mem_data_out;
                    j <= mod_operation(j + unsigned(mem_data_out), state_size);
                    currentState <= S5;

                when S5 =>
                    -- t <= state[i] (already in temp_data)
                    currentState <= S6;
                
                when S6 => 
                    -- Read state[j] from memory
                    currentState <= S7;
                
                when S7 =>
                    -- Write state[j] to state[i], store state[j] in temp_data
                    mem_data_in <= mem_data_out;
                    temp_data <= mem_data_out;
                    currentState <= S8;
                
                when S8 => 
                    -- Write state[i] (temp_data) to state[j]
                    mem_data_in <= temp_data;
                    currentState <= S9;

                when S9 => 
                    -- t = (t + state[j]) % stateSize
                    t <= mod_operation(t + unsigned(temp_data), state_size);
                    currentState <= S10;

                when S10 =>
                    -- Read state[t] from memory
                    currentState <= S11;

                when S11 => 
                    -- keystream[k] <= state[t] (available on mem_data_out)
                    -- Data already available on data_out
                    currentState <= S12;

                when S12 => 
                    -- Increment k and loop back
                    k <= k + 1;
                    currentState <= S1;
                    
            end case;
            
        end if;
    end process;

end Behav;
