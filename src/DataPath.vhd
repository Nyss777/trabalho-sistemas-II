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


architecture structural of DataPath is
    signal data_index, data_index_next : STD_LOGIC_VECTOR(1 downto 0);
    signal av_decoder_out : STD_LOGIC_VECTOR(3 downto 0);

    signal ce_state, ce_state_size, ce_text_size, ce_key_stream : std_logic;
    signal state_out, state_size_out, text_size_out, key_stream_out : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

    signal data_mux, mux_upper_right_result : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal reg_i_out, reg_j_out, reg_k_out, reg_t_out : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);


    signal memory_addr_base, memory_addr_index : STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
begin
    data_index_next <= data_index + "01";

    av_atual : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => 2)
        port map (
            clock => clk,
            reset => rst,
            d     => data_index_next,
            q     => data_index,
            ce    => data_av
        );

    with data_index select
        av_decoder_out <= "0001" when "00",
                          "0010" when "01",
                          "0100" when "10",
                          "1000" when "11";

    ce_state      <= av_decoder_out(0) and data_av and rst_bd;
    ce_state_size <= av_decoder_out(1) and data_av and rst_bd;
    ce_text_size  <= av_decoder_out(2) and data_av and rst_bd;
    ce_key_stream <= av_decoder_out(3) and data_av and rst_bd;

    state : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => ADDR_WIDTH)
        port map (
            clock => clk,
            reset => rst,
            d     => Data,
            q     => state_out,
            ce    => ce_state
        );

    state_size : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => ADDR_WIDTH)
        port map (
            clock => clk,
            reset => rst,
            d     => Data,
            q     => state_size_out,
            ce    => ce_state_size
        );

    text_size : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => ADDR_WIDTH)
        port map (
            clock => clk,
            reset => rst,
            d     => Data,
            q     => text_size_out,
            ce    => ce_text_size
        );

    key_stream : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => ADDR_WIDTH)
        port map (
            clock => clk,
            reset => rst,
            d     => Data,
            q     => key_stream_out,
            ce    => ce_key_stream
        );

    data_ok <= '1' when data_index = "11" else '0';

    mod_adder_b_mux <= text_size_out when AcionarMod = '1' else state_size_out;

    modulo : entity work.Modulo(arch)
        generic map(
            DATA_WIDTH => DATA_WIDTH
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            clk              => clk,
            rst              => rst_bd,
            modulo           => AcionarMod,
            k                => reg_k_out,
            mux_upper_left_b => TO_BE_ADDED,
            AdderB           => mod_adder_b_mux,
            mux_upper_right  => mux_upper_right_result
            kMenorTextSize   => kMenorTextSize,
            modPronto        => modPronto
        );

    with Dado select
        data_mux <= mux_upper_right_result when "00",
                    reg_t_out when "01",
                    Data_in when "10",
                    TO_BE_ADDED when "11";

    req_i : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => DATA_WIDTH)
        port map (
            clock => clk,
            reset => rst_bd,
            d     => data_mux,
            q     => reg_i_out,
            ce    => en_i
        );

    req_j : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => DATA_WIDTH)
        port map (
            clock => clk,
            reset => rst_bd,
            d     => data_mux,
            q     => reg_j_out,
            ce    => en_j
        );

    req_k : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => DATA_WIDTH)
        port map (
            clock => clk,
            reset => rst_bd,
            d     => data_mux,
            q     => reg_k_out,
            ce    => en_k
        );

    req_t : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => DATA_WIDTH)
        port map (
            clock => clk,
            reset => rst_bd,
            d     => data_mux,
            q     => reg_t_out,
            ce    => en_t
        );

    memory_addr_base <= state_out when vetor = '0' else key_stream_out;
    with indice select
        memory_addr_index <= reg_i_out when "00",
                             reg_j_out when "01",
                             reg_k_out when "10",
                             reg_t_out when "11";

    A <= memory_addr_base + memory_addr_index;

end structural;
