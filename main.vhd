library IEEE;
use IEEE.std_logic_1164.all;

entity Behavioral is
    generic (
        DATA_WIDTH  : integer := 8;
        ADDR_WIDTH  : integer := 8
    );
	port (  
		clk				: in std_logic;
		rst				: in std_logic;
        
        srcAddr     : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
        stateSize        : in std_logic_vector (ADDR_WIDTH - 1 downto 0);

        data_ok           : out std_logic;                   -- Sinal de controle para indicar que os dados estão REGISTRADOS e prontos para serem processados

        Data_in         : in std_logic_vector(DATA_WIDTH-1 downto 0)                          -- Entrada para dado lido da memória        
	);
end Behavioral;

architecture Behav of GenK is 

    type State is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12);
    signal currentState : State;
    signal i, j, k: UNSIGNED(ADDR_WIDTH - 1 downto 0);
begin

    process(clk, rst)
    begin

        if rst = '1' then 
            currentState <= S0;

        elsif rising_edge(clk) then
            case currentState is
                when S0 =>
                   
                   i <= UNSIGNED(srcAddr);
                   j <= UNSIGNED(srcAddr);
                   k <= '0';
                   


                    if data_ok = '1' then
                        currentState <= S1;
                        
                    end if;

                when S1 => 
                    if k < textsize then
                        currentState <= S2;
                    else
                        currentState <= S1;
                    end if;

                when S2 => 
                    i <= (i + 1) % stateSize;
                    currentState <= S3;

                when S3 =>
                    Data_in <= state[i];
                    currentState <= S4;
                
                when S4 => 
                    j <= (j + Data_in) % stateSize;
                    currentState <= S5;

                when S5 =>
                    t <= state[i];
                    currentState <= S6;
                
                when S6 => 
                    Data_in <= state[j];
                    currentState <= S7;

                when S7 =>
                    state[i] <= Data_in;
                    currentState <= S8;
                
                when S8 => 
                    state[j] <= Data_in;
                    currentState <= S9;

                when S9 => 
                    t <= (t + Data_in) % stateSize;
                    currentState <= S10;

                when S10 =>
                    Data_in <= state[t];
                    currentState <= S11;

                when S11 => 
                    keystream[k] <= Data_in;
                    currentState <= S12;

                when S12 => 
                    k <= k + 1;
                    currentState <= S1;
                    
            end if
        end process
        Done <= '1' when currentState = S2 and k >= textsize else '0'   

end Behav


