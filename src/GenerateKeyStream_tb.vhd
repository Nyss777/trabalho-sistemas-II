-------------------------------------------------------------------------
-- Breno, Nycolas, Estevão
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Test bench interface is always empty.
entity GenerateKeyStream_tb is
end GenerateKeyStream_tb;

-- Instantiate the components and generates the stimuli.
architecture behavioral of GenerateKeyStream_tb is
    signal clk, rst, data_av : std_logic := '0';
    signal done_structural, done_behavioral : std_logic;
    signal dado : std_logic_vector(7 downto 0);
begin
    GENERATE_KEY_STREAM_STRUCTURAL: entity work.GenerateKeyStream(structural)
        port map (
            clk     => clk,
            rst     => rst,
            data_av => data_av,
            done    => done_structural,
            dado    => dado
        );

    GENERATE_KEY_STREAM_BEHAVIORAL: entity work.GenerateKeyStream(behavioral)
        port map (
            clk     => clk,
            rst     => rst,
            data_av => data_av,
            done    => done_behavioral,
            dado    => dado
        );

    -- Na memória deve estar
    -- 00 06 01 04 09 03 08 07 05 02
    -- Espera-se que a saída seja 09 04 07 03 00 08 06 01 05 02 09 05 07 02 04
    -- Tudo isso considerando hexadecimal
    rst     <= '1', '0' after 3 ns;
    clk     <= not clk after 1 ns;
    dado    <= "00000000", "00001010" after 9 ns, "00000101" after 19 ns, "00001010" after 29 ns;
    data_av <= '0', '1' after 4 ns, '0' after 9 ns, '1' after 14 ns, '0' after 19 ns, '1' after 24 ns, '0' after 29 ns, '1' after 34 ns, '0' after 39 ns;
end behavioral;
