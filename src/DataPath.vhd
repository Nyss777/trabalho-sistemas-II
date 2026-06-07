-------------------------------------------------------------------------
-- Nycolas, Breno, Estevão
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 	-- CONV_INTEGER function


entity DataPath is
    generic (
        DATA_WIDTH  : integer := 8;
        ADDR_WIDTH  : integer := 8
    );
	port (
		clk			   : in std_logic;
		rst			   : in std_logic;

        data_ok        : out std_logic;                   -- Sinal de controle para indicar que os dados estão REGISTRADOS e prontos para serem processados
        kMenorTextSize : out std_logic;            -- Sinal de controle para indicar que o valor de k é menor que o tamanho do texto
        modPronto      : out std_logic;                 -- Sinal de controle para indicar que a operação de módulo foi concluída
        A              : out std_logic_vector(ADDR_WIDTH-1 downto 0);                        -- Saída para índice da memória
        Data_out       : out std_logic_vector(DATA_WIDTH-1 downto 0);                        -- Saída para dado a ser escrito na memória

        Data_in        : in std_logic_vector(DATA_WIDTH-1 downto 0);                       -- Entrada para dado lido da memória
        Data           : in std_logic_vector(DATA_WIDTH-1 downto 0);                          -- Entrada para valor dado pelo usuário
        en_i           : in std_logic;                     -- Sinal de controle para habilitar escrita dos registradores
        en_j           : in std_logic;
        en_k           : in std_logic;
        en_t           : in std_logic;
        vetor          : in std_logic;                   -- Sinal de controle para selecionar o índice initial será o do keystream ou do texto que já está na memória
        indice         : in std_logic_vector(1 downto 0);                   -- escolhe qual o indice para mexer na memória
        AcionarMod     : in std_logic;                    -- Sinal para acionar a operação de módulo
        A_plus         : in std_logic;                        -- Controla qual valor vai para o somador
        B_plus         : in std_logic_vector(1 downto 0);     -- Controla qual valor vai para o somador
        rst_bd         : in std_logic;                     -- Sinal de reset para a Datapath
        Dado           : in std_logic_vector(1 downto 0);  -- Sinal de controle para selecionar o dado a ser escrito nos registradores
        data_av        : in std_logic
	);
end DataPath;


architecture Estrutural of DataPath is

    signal data_index, data_index_next : STD_LOGIC_VECTOR(1 downto 0);
    signal av_decoder_out              : STD_LOGIC_VECTOR(3 downto 0);
    signal dado_mux                    : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal reg_i_out, reg_j_out, reg_k_out, reg_t_out  : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    data_index_next <= data_index + "01";

    -- with Dado select
    --     dado_mux <= open    when "00",
    --                 open    when "01",
    --                 open    when "10",
    --                 open    when others;

    av_atual : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => 2)
        port map (
            clock => clk,
            reset => rst_bd,
            d   => data_index_next,
            q   => data_index,
            ce  => data_av
        );

    data_decoder : entity work.Decoder_2to4(behavioral)
        port map (
            A => data_index,
            Y => av_decoder_out
        );

    state : entity work.RegisterNbits(Comportamental)
        generic map (WIDTH => ADDR_WIDTH)
        port map (
            clock => clk,
            reset => rst_bd,
            d   => Data,
            -- q   => open,
            ce  => av_decoder_out(0)
        );

    state_size : entity work.RegisterNbits(Comportamental)
        generic map (WIDTH => ADDR_WIDTH)
        port map (
            clock => clk,
            reset => rst_bd,
            d   => Data,
            -- q   => open,
            ce  => av_decoder_out(1)
        );

    text_size : entity work.RegisterNbits(Comportamental)
        generic map (WIDTH => ADDR_WIDTH)
        port map (
            clock => clk,
            reset => rst_bd,
            d   => Data,
            -- q   => open,
            ce  => av_decoder_out(2)
        );

    key_stream : entity work.RegisterNbits(Comportamental)
        generic map (WIDTH => ADDR_WIDTH)
        port map (
            clock => clk,
            reset => rst_bd,
            d   => Data,
            -- q   => open,
            ce  => av_decoder_out(3)
        );

    -- reg_i_inst : entity work.RegisterNbits(behavioral)
    --     generic map (n => DATA_WIDTH)
    --     port map (
    --         clk => clk,
    --         rst => rst_bd,
    --         d   => dado_mux,
    --         q   => reg_i_out,
    --         ce  => en_i
    --     );

    -- reg_j_inst : entity work.RegisterNbits(behavioral)
    --     generic map (n => DATA_WIDTH)
    --     port map (
    --         clk => clk,
    --         rst => rst_bd,
    --         d   => dado_mux,
    --         q   => reg_j_out,
    --         ce  => en_j
    --     );

    -- reg_k_inst : entity work.RegisterNbits(behavioral)
    --     generic map (n => DATA_WIDTH)
    --     port map (
    --         clk => clk,
    --         rst => rst_bd,
    --         d   => dado_mux,
    --         q   => reg_k_out,
    --         ce  => en_k
    --     );

    -- reg_t_inst : entity work.RegisterNbits(behavioral)
    --     generic map (n => DATA_WIDTH)
    --     port map (
    --         clk => clk,
    --         rst => rst_bd,
    --         d   => dado_mux,
    --         q   => reg_t_out,
    --         ce  => en_t
    --     );

end Estrutural;


architecture Comportamental of DataPath is

    -- Tem que usar o "RegisterNbits.vhd"
begin

end Comportamental;