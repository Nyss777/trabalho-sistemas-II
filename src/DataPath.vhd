-------------------------------------------------------------------------
-- Breno, Nycolas, Estevão
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.GenerateKeyStream_pkg.all;

entity DataPath is
    generic (
        DATA_WIDTH  : integer := 8;
        ADDR_WIDTH  : integer := 8
    );
	port (
		clk			      : in std_logic;
		rst			      : in std_logic;

        data_in           : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Entrada para dado lido da memória
        dado              : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Entrada para valor dado pelo usuário
        data_av           : in std_logic; -- Sinal de controle para indicar que o valor da entrada 'data' é válido e pode ser registrado

        ctrl_in : in ControlPath_Out_Record;

        data_ok           : out std_logic; -- Sinal de controle para indicar que os dados estão registrados e prontos para serem processados
        k_menor_text_size : out std_logic; -- Sinal de controle para indicar que o valor de k é menor que o tamanho do texto
        mod_pronto        : out std_logic; -- Sinal de controle para indicar que a operação de módulo foi concluída
        memory_address    : out std_logic_vector(ADDR_WIDTH-1 downto 0); -- Saída para índice da memória
        data_out          : out std_logic_vector(DATA_WIDTH-1 downto 0)  -- Saída para dado a ser escrito na memória
	);
end DataPath;

architecture structural of DataPath is
    signal data_av_sync : std_logic;

    signal data_index_out, data_index_next : STD_LOGIC_VECTOR(1 downto 0);
    signal av_decoder_out : STD_LOGIC_VECTOR(3 downto 0);

    signal ce_state, ce_state_size, ce_text_size, ce_key_stream : std_logic;
    signal state_out, state_size_out, text_size_out, key_stream_out : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

    signal data_mux, mux_upper_right_result : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal reg_i_out, reg_j_out, reg_k_out, reg_t_out : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

    signal mod_adder_b_mux : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal memory_addr_base, memory_addr_index : STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);

    signal adder_a, adder_b, adder_result : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            data_av_sync <= '0';
        elsif rising_edge(clk) then
            if data_av_sync = '1' then
                data_av_sync <= '0';
            else
                data_av_sync <= data_av;
            end if;
        end if;
    end process;

    data_index_next <= data_index_out + "01";

    data_index : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => 2)
        port map (
            clock => clk,
            reset => rst,
            d     => data_index_next,
            q     => data_index_out,
            ce    => data_av_sync
        );

    with data_index_out select
        av_decoder_out <= "0001" when "00",
                          "0010" when "01",
                          "0100" when "10",
                          "1000" when "11",
                          (others => '0') when others;

    ce_state      <= av_decoder_out(0) and data_av_sync and ctrl_in.rst_bd;
    ce_state_size <= av_decoder_out(1) and data_av_sync and ctrl_in.rst_bd;
    ce_text_size  <= av_decoder_out(2) and data_av_sync and ctrl_in.rst_bd;
    ce_key_stream <= av_decoder_out(3) and data_av_sync and ctrl_in.rst_bd;

    state : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => ADDR_WIDTH)
        port map (
            clock => clk,
            reset => rst,
            d     => dado,
            q     => state_out,
            ce    => ce_state
        );

    state_size : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => ADDR_WIDTH)
        port map (
            clock => clk,
            reset => rst,
            d     => dado,
            q     => state_size_out,
            ce    => ce_state_size
        );

    text_size : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => ADDR_WIDTH)
        port map (
            clock => clk,
            reset => rst,
            d     => dado,
            q     => text_size_out,
            ce    => ce_text_size
        );

    key_stream : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => ADDR_WIDTH)
        port map (
            clock => clk,
            reset => rst,
            d     => dado,
            q     => key_stream_out,
            ce    => ce_key_stream
        );

    data_ok <= '1' when ce_key_stream = '1' else '0';

    mod_adder_b_mux <= text_size_out when ctrl_in.acionar_mod = '0' else state_size_out;

    modulo : entity work.DataPathMod(behavioral)
        generic map(
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            clk         => clk,
            rst         => ctrl_in.rst_bd,
            acionar_mod => ctrl_in.acionar_mod,
            reg_k_out   => reg_k_out,
            minuendo    => adder_result,
            subtraendo  => mod_adder_b_mux,
            resto       => mux_upper_right_result,
            borrow_out  => k_menor_text_size,
            mod_pronto  => mod_pronto
        );

    with ctrl_in.dado select
        data_mux <= adder_result when "00",
                    reg_t_out when "01",
                    data_in when "10",
                    mux_upper_right_result when "11",
                    (others => '0') when others;

    data_out <= data_mux;

    req_i : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => DATA_WIDTH)
        port map (
            clock => clk,
            reset => ctrl_in.rst_bd,
            d     => data_mux,
            q     => reg_i_out,
            ce    => ctrl_in.en_i
        );

    req_j : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => DATA_WIDTH)
        port map (
            clock => clk,
            reset => ctrl_in.rst_bd,
            d     => data_mux,
            q     => reg_j_out,
            ce    => ctrl_in.en_j
        );

    req_k : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => DATA_WIDTH)
        port map (
            clock => clk,
            reset => ctrl_in.rst_bd,
            d     => data_mux,
            q     => reg_k_out,
            ce    => ctrl_in.en_k
        );

    req_t : entity work.RegisterNbits(behavioral)
        generic map (WIDTH => DATA_WIDTH)
        port map (
            clock => clk,
            reset => ctrl_in.rst_bd,
            d     => data_mux,
            q     => reg_t_out,
            ce    => ctrl_in.en_t
        );

    memory_addr_base <= state_out when ctrl_in.vetor = '0' else key_stream_out;
    with ctrl_in.indice select
        memory_addr_index <= reg_i_out when "00",
                             reg_j_out when "01",
                             reg_k_out when "10",
                             reg_t_out when "11",
                             (others => '0') when others;

    memory_address <= memory_addr_base + memory_addr_index;

    adder_a <= std_logic_vector(to_unsigned(1, DATA_WIDTH)) when ctrl_in.a_plus = '0' else Data_in;
    with ctrl_in.b_plus select
        adder_b <= reg_i_out when "00",
                   reg_j_out when "01",
                   reg_t_out when "10",
                   reg_k_out when "11",
                   (others => '0') when others;

    adder_result <= adder_a + adder_b;
end structural;
