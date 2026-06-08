-------------------------------------------------------------------------
-- Breno, Nycolas, Estevão
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.GenerateKeyStream_pkg.all;

entity GenerateKeyStream is
	generic(
		ADDR_WIDTH	: integer := 8;
        DATA_WIDTH  : integer := 8
	);
	port (
		clk		    : in std_logic;
        rst         : in std_logic;
        dado        : in std_logic_vector (DATA_WIDTH-1 downto 0);
		data_av		: in std_logic;
        done		: out std_logic
	);
end GenerateKeyStream;

architecture structural of GenerateKeyStream is
    signal d_memory, data_out, data_in: std_logic_vector (DATA_WIDTH-1 downto 0);
    signal data_ok, k_menor_text_size, mod_pronto, rw_signal: std_logic;
    signal memory_address: std_logic_vector(ADDR_WIDTH-1 downto 0);

    signal control_signals : ControlPath_Out_Record;
begin
	CONTROL_PATH: entity work.ControlPath(behavioral)
		port map (
			clk		          => clk,
			rst		          => rst,
            data_ok           => data_ok,
            k_menor_text_size => k_menor_text_size,
            mod_pronto        => mod_pronto,
            control_out       => control_signals
    );

	DATA_PATH: entity work.DataPath(structural)
		generic map (
			DATA_WIDTH	=> DATA_WIDTH,
            ADDR_WIDTH  => ADDR_WIDTH
		)
		port map (
			clk		          => clk,
			rst		          => rst,
            data_ok           => data_ok,
            k_menor_text_size => k_menor_text_size,
            mod_pronto        => mod_pronto,
            memory_address    => memory_address,
            data_in           => data_in,
            data_out          => data_out,
            dado              => dado,
            data_av           => data_av,
            ctrl_in           => control_signals
        );

     MEMORY: entity work.Memory(behavioral)
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH,
            IMAGE => "keyStreamImage.txt"
        )
        port map (
            clk => clk,
            rw => rw_signal,
            ce => control_signals.sel,
            address => memory_address,
            data => d_memory
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if control_signals.ld = '1' then
                data_in <= d_memory;
            end if;
        end if;
    end process;

    -- Sinal de controle da memória: inverter ld porque o rw é oposto
    rw_signal <= not control_signals.ld;
    d_memory  <= data_out when control_signals.ld = '0' else (others => 'Z');
end structural;

architecture behavioral of GenerateKeyStream is

    type State is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12);
    type DataAv is (D0, D1, D2, D3);

    signal currentState : State;
    signal dv : DataAv;

    -- Memory interface signals
    signal mem_ce, mem_rw: std_logic;
    signal mem_addr: std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal mem_data_in, mem_data_out, mem_data: std_logic_vector(DATA_WIDTH - 1 downto 0);

    -- Datapath signals
    signal i, j, k, t : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal state_addr : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal state_size : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal text_size : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal ValorMod : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal keystream_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal data_av_sincronizado, data_av_atual : std_logic := '0';

begin

    -- Memory control logic: set address and data based on current state
    mem_addr <= std_logic_vector(i) + state_addr when (currentState = S3 or currentState = S7) else
                std_logic_vector(j) + state_addr when (currentState = S6 or currentState = S8) else
                std_logic_vector(t) + state_addr when (currentState = S10) else
                std_logic_vector(k) + keystream_addr when (currentState = S11) else
                (others => '0');

    -- Determine memory write enable based on state
    mem_rw <= '1' when (currentState = S7 or currentState = S8 or currentState = S11) else '0';

    -- Memory chip enable
    mem_ce <= '1' when (currentState = S3 or currentState = S6 or currentState = S7 or currentState = S8 or currentState = S10 or currentState = S11) else '0';

    -- Done signal
    done <= '1' when (currentState = S1 and k >= text_size) else '0';

    --sincronizador do data_av para evitar problemas de timing
    process(clk)
    begin
        if rising_edge(clk) then
            -- se reset ativo, limpar os sinais de sincronização
            if rst = '1' then
                data_av_sincronizado <= '0';
                data_av_atual <= '0';
            else
                -- se o sincronizado for 1 volta para o zero
                if data_av_sincronizado = '1' then
                    data_av_sincronizado <= '0';
                -- se data_av mudou de 0 para 1, atualiza os sinais de sincronização
                elsif data_av = '1' and data_av_atual = '0' then
                    data_av_atual <= '1';
                    data_av_sincronizado <= '1';
                -- se data_av voltou para 0, atualiza o sinal de sincronização atual
                elsif data_av = '0' then
                    data_av_atual <= data_av;
                end if;
            end if;
        end if;
    end process;
    -- Sequential process for state transitions
    process(clk, rst)
    begin
        if rst = '1' then
            currentState <= S0;
            i <= (others => '0');
            j <= (others => '0');
            k <= (others => '0');
            t <= (others => '0');
            dv <= D0;

        elsif rising_edge(clk) then

            case currentState is

                when S0 =>

                    if data_av_sincronizado = '1' then
                        case dv is
                            when D0 =>
                                state_addr <= dado;
                                dv <= D1;
                            when D1 =>
                                state_size <= dado;
                                dv <= D2;
                            when D2 =>
                                text_size <= dado;
                                dv <= D3;
                            when D3 =>
                                keystream_addr <= dado;
                                currentState <= S1;
                        end case;
                    end if;

                when S1 =>
                    -- Check if k < stateSize
                    if k < text_size then
                        currentState <= S2;
                        ValorMod <= i + 1;
                    else
                        currentState <= S0;

                    end if;

                when S2 =>
                    -- i = (i + 1) % stateSize
                    if ValorMod < state_size then
                        i <= ValorMod;
                        currentState <= S3;
                    else
                        ValorMod <= ValorMod - state_size;
                        currentState <= S2;
                    end if;

                when S3 =>
                    -- Read state[i] from memory
                    currentState <= S4;
                    ValorMod <= j + mem_data_in;
                    -- mem_addr and mem_ce control the read

                when S4 =>
                    if ValorMod < state_size then
                        j <= ValorMod;
                        currentState <= S5;
                    else
                        ValorMod <= ValorMod - state_size;
                        currentState <= S4;
                    end if;

                when S5 =>
                    t <= mem_data_in;
                    currentState <= S6;

                when S6 =>
                    -- Read state[j] from memory
                    currentState <= S7;

                when S7 =>
                    currentState <= S8;

                when S8 =>
                    -- t to state[j]
                    currentState <= S9;
                    ValorMod <= t + mem_data_in;

                when S9 =>
                    -- t = (t + state[j]) % stateSize
                    if ValorMod < state_size then
                        t <= ValorMod;
                        currentState <= S10;
                    else
                        ValorMod <= ValorMod - state_size;
                        currentState <= S9;
                    end if;

                when S10 =>
                    -- Read state[t] from memory
                    currentState <= S11;

                when S11 =>
                    -- keystream[k] <= state[t] (available on mem_data_out)
                    -- Data already available on data_out
                    currentState <= S12;

                when others =>
                    -- Increment k and loop back
                    k <= k + 1;
                    currentState <= S1;


            end case;

        end if;
    end process;

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
            rw      => mem_rw,
            address => mem_addr,
            data    => mem_data
        );

    mem_data <= mem_data_out when mem_ce = '1' and mem_rw = '1' else (others => 'Z');
    mem_data_out <= mem_data_in when currentState = S7 or currentState = S11 else
                    t when currentState = S8 else
                    mem_data_out;
    mem_data_in <= mem_data when mem_ce = '1' and mem_rw = '0' else mem_data_in;


end behavioral;

