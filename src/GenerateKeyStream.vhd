-------------------------------------------------------------------------
--  Estevão, Nycolas, Breno,
--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity GenerateKeyStream is
	generic(
		ADDR_WIDTH	: integer := 8;
        DATA_WIDTH  : integer := 8
	);
	port (
		clk		    : in std_logic;
        rst         : in std_logic;
		data_av		: in std_logic;
        done		: out std_logic;
        data      : in std_logic_vector (DATA_WIDTH-1 downto 0)
	);

end GenerateKeyStream;

architecture structural of GenerateKeyStream is
    -- Sinais para interconexão dos componentes
    signal D_memory, Data_out, Data_in: std_logic_vector (DATA_WIDTH-1 downto 0);
    signal data_ok, kMenorTextSize, modPronto, en_i, en_j, en_k, en_t, vetor, AcionarMod, sel, ld, A_plus, rst_bd, rw_signal: std_logic;
    signal B_plus, Dado, indice: std_logic_vector(1 downto 0);
    signal A: std_logic_vector(ADDR_WIDTH-1 downto 0);

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

	DATA_PATH: entity work.DataPath(Estrutural)
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
            Data        => data,
            A          => A,
            data_av     => data_av
        );

     MEMORY: entity work.Memory
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH,
            IMAGE => "keyStreamImage.txt"
        )
        port map (
            clk => clk,
            rw => rw_signal,
            ce => sel,
            address => A,
            data => D_memory
        );

    -- Sinal de controle da memória: inverter ld (0 leitura, 1 escrita)
    rw_signal <= not ld;
    D_memory <= Data_in when ld = '1' else Data_out;

end structural;

architecture behavioral of GenerateKeyStream is

    -- Memory interface signals
    signal mem_ce, mem_wr: std_logic;
    signal mem_addr: std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal mem_data_in, mem_data_out: std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal stateSize_value: std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');

begin

    -- Behavioral FSM (replaces ControlPath + DataPath)
	FSMD: entity work.Behavioral
		generic map (
			DATA_WIDTH	=> DATA_WIDTH,
            ADDR_WIDTH  => ADDR_WIDTH
		)
		port map (
			clk		        => clk,
			rst		        => rst,
            data_av         => data_av,
            done            => done,
            data            => data,

            -- Memory interface
            mem_ce          => mem_ce,
            mem_wr          => mem_wr,
            mem_addr        => mem_addr,
            mem_data_in     => mem_data_in,
            mem_data_out    => mem_data_out
        );

    -- Memory for state array (RC4 state table)
    MEMORY: entity work.Memory
        generic map (
            DATA_WIDTH  => DATA_WIDTH,
            ADDR_WIDTH  => ADDR_WIDTH,
            IMAGE => "keyStreamImage.txt"
        )
        port map (
            clk     => clk,
            ce      => mem_ce,
            rw      => mem_wr,
            address => mem_addr,
            data    => mem_data_out
        );

end behavioral;
