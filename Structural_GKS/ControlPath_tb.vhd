-------------------------------------------------------------------------
-- Teste do ControlPath, eu tirei o estado 1010 que era redundante
-- Usa como base, se quiser, para o Test Bench do GenerateKeyStream
-------------------------------------------------------------------------

library IEEE;                        
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Test bench interface is always empty.
entity ControlPath_tb  is
end ControlPath_tb;


-- Instantiate the components and generates the stimuli.
architecture behavioral of ControlPath_tb is  
    
    signal clk, rst, data_ok, kMenorTextSize, modPronto: std_logic := '0';
    signal en_i, en_j, en_k, en_t, AcionarMod, sel, ld, vetor, A_plus, rst_bd, done: std_logic;
    signal indice, B_plus, Dado: std_logic_vector(1 downto 0);
    
begin

	CONTROL_PATH: entity work.ControlPath	
		port map (
			clk		    => clk,
			rst		    => rst,
            data_ok     => data_ok,
            kMenorTextSize => kMenorTextSize,
            modPronto   => modPronto,
            en_i        => en_i,
            en_j        => en_j,
            en_k        => en_k,
            en_t        => en_t,
            indice      => indice,
            AcionarMod   => AcionarMod,
            vetor       => vetor,
            A_plus     => A_plus,
            B_plus     => B_plus,
            rst_bd       => rst_bd,
            Dado        => Dado,
            done        => done,
            sel         => sel,
            ld          => ld
        );
        
    -- Generates the stimuli.
    rst <= '1', '0' after 3 ns;
    clk <= not clk after 5 ns;
    data_ok <= '1', '0' after 17 ns;
    kMenorTextSize <= '1', '0' after 17 ns;
    modPronto <= not modPronto after 22 ns;

       

end behavioral;


