-------------------------------------------------------------------------
--  Estevão, Nycolas, Breno,
--------------------------------------------------------------------------

library IEEE;						
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity GenerateKeyStream  is
	generic(
		ADDR_WIDTH	: integer := 8;
        DATA_WIDTH  : integer := 8
	);
	port (
		clk		    : in std_logic;
        rst         : in std_logic;
		data_av		: in std_logic;   
        done		: out std_logic;
        data      : in std_logic_vector (DATA_WIDTH-1 downto 0);
	);
		
end GenerateKeyStream;

architecture structural of GenerateKeyStream is  
    -- Sinais para interconexão dos componentes     
    signal D_memory, Data_out, Data_in: std_logic_vector (DATA_WIDTH-1 downto 0);
    signal data_ok, kMenorTextSize, modPronto, en_i, en_j, en_k, en_t, vetor, AcionarMod, sel, ld, A_plus, rst_bd, Dado: std_logic;
    signal B_plus, Dado, indice: std_logic_vector(1 downto 0);
    
begin
    -- Instanciação dos componentes
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
            sel         => sel,
            ld          => ld,
            vetor       => vetor,
            A_plus     => A_plus,
            B_plus     => B_plus,
            rst_bd       => rst_bd,
            Dado        => Dado,
            done        => done
    );
		
	DATA_PATH: entity work.DataPath
		generic map (
			DATA_WIDTH	=> DATA_WIDTH,
            ADDR_WIDTH  => ADDR_WIDTH
		)
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
            Data_out    => Data_out,
            Data_in     => Data_in,
            Data        => data
            A          => A
        );

    MEMORY: entity work.Memory
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH,
            IMAGE => "keyStreamImage.txt"
        )
        port map (
            clk => clk,
            rw => not ld, -- essa memória é oposto ao usado no Logisim, 0 é leitura e 1 é escrita, então inverti o sinal de controle ld para controlar a leitura e escrita da memória sem mudar a lógica do ControlPath
            ce => sel,
            address => A,
            data => D_memory
        );
    -- Atribuição para o sinal de controle da memória, dependendo do valor de ld, que indica se é leitura ou escrita
    D_memory <= Data_in when ld = '1' else Data_out; -- Se ld for 1, lê da memória, senão escreve na memória
		
end structural;