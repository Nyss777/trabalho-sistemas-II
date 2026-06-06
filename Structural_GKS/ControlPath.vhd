-------------------------------------------------------------------------
-- Breno, Nycolas, Estevão
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity ControlPath is
	port (  
		clk				: in std_logic;
		rst				: in std_logic;
        
        data_ok           : in std_logic;                   -- Sinal de controle para indicar que os dados estão REGISTRADOS e prontos para serem processados
        kMenorTextSize           : in std_logic;            -- Sinal de controle para indicar que o valor de k é menor que o tamanho do texto
        modPronto           : in std_logic;                 -- Sinal de controle para indicar que a operação de módulo foi concluída

        en_i           : out std_logic;                     -- Sinal de controle para habilitar escrita dos registradores
        en_j              : out std_logic;
        en_k              : out std_logic;
        en_t              : out std_logic;
        vetor           : out std_logic;                   -- Sinal de controle para selecionar o índice initial será o do keystream ou do texto que já está na memória
        indice      : out std_logic_vector(1 downto 0);                   -- Soma o initial com o valor do contador para selecionar o índice a ser lido/escrito na memória
        AcionarMod      : out std_logic;                    -- Sinal para acionar a operação de módulo
        sel          : out std_logic;                       -- Ativa a memória 
        ld          : out std_logic;                        -- Load da memória, leitura em zero, escrita em um
        A_plus          : out std_logic;                        -- Controla qual valor vai para o somador
        B_plus          : out std_logic_vector(1 downto 0);     -- Controla qual valor vai para o somador
        rst_bd         : out std_logic;                     -- Sinal de reset para a Datapath
        Dado           : out std_logic_vector(1 downto 0);  -- Sinal de controle para selecionar o dado a ser escrito nos registradores
        done            : out std_logic       -- Sinal de controle para indicar que a operação foi concluída
	);
end ControlPath;
                   

architecture behavioral of ControlPath is  
    --Definição dos estados   
    type State is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12);
    signal currentState, nextState : State;
    
begin
    
    -- Processo de transição de estados
    process(clk, rst)
    begin
        
        if rst = '1' then
            currentState <= S0;
        
        elsif rising_edge(clk) then
            currentState <= nextState;
            
        end if;
    end process;
    
    -- Lógica de transição de estados
    process(currentState, modPronto, kMenorTextSize, data_ok) -- A mudança de estado depende dos sinais de controle e do estado atual
    begin
        
        case currentState is
            when S0 =>
                if data_ok = '1' then
                    nextState <= S1;
                else
                    nextState <= S0;
                end if;
                
            when S1 =>
                if kMenorTextSize = '1' then
                    nextState <= S2;
                else
                    nextState <= S0;
                end if;
                
            when S2 =>
                if modPronto = '1' then
                    nextState <= S3;
                else
                    nextState <= S2;
                end if;
            
            when S3 =>
                nextState <= S4;
                
            when S4 =>
                if modPronto = '1' then
                    nextState <= S5;
                else
                    nextState <= S4;
                end if;
            
            when S5 => 
                nextState <= S6;
                
            when S6 =>
                nextState <= S7;
                
            when S7 =>
                nextState <= S8;

            when S8 =>
                nextState <= S9;

            when S9 =>
                if modPronto = '1' then
                    nextState <= S10;
                else
                    nextState <= S9;
                end if;

            when S10 =>
                nextState <= S11;

            when S11 =>
                nextState <= S12;
                
            when others =>
                nextState <= S1;
            
        end case;
        
    end process;
    
    -- Logica de controle para os sinais de saída, fazendo a associação de cada sinal com o estado atual
    done <= '1' when currentState = S1 and (kMenorTextSize = '0') else '0';
    en_i <= '1' when currentState = S2 else '0';
    en_j <= '1' when currentState = S4 else '0';
    en_k <= '1' when currentState = S12 else '0';
    en_t <= '1' when currentState = S5 or currentState = S9 else '0';
    indice <= "01" when currentState = S6 or currentState = S8 else
            "11" when currentState = S10 else
            "10" when currentState = S11 else
            "00";
    vetor <= '1' when currentState = S11 else '0';
    AcionarMod <= '1' when currentState = S2 or currentState = S4 or currentState = S9 else '0';
    sel <= '1' when currentState = S3 or currentState = S6 or currentState = S7 or currentState = S8 or currentState = S10 or currentState = S11 else '0';
    ld <= '1' when currentState = S3 or currentState = S6 or currentState = S10 else '0';
    A_plus <= '1' when currentState = S4 or currentState = S9 else '0';
    B_plus <= "01" when currentState = S4 else
            "10" when currentState = S9 else
            "11" when currentState = S12 else
            "00";
    rst_bd <= '1' when currentState = S0 else '0';
    Dado <= "11" when currentState = S2 or currentState = S4 or currentState = S9 else
            "01" when currentState = S8 else
            "10" when currentState = S5 or currentState = S7 or currentState = S11 else
            "00";


    
    

    
end behavioral;
