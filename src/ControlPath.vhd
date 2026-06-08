-------------------------------------------------------------------------
-- Breno, Nycolas, Estevão
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.GenerateKeyStream_pkg.all;

entity ControlPath is
	port (
		clk	               : in std_logic;
		rst	               : in std_logic;

        data_ok            : in std_logic;  -- Sinal de controle para indicar que os dados estão registrados e prontos para serem processados
        k_menor_text_size  : in std_logic;  -- Sinal de controle para indicar que o valor de k é menor que o tamanho do texto
        mod_pronto         : in std_logic;  -- Sinal de controle para indicar que a operação de módulo foi concluída

        control_out        : out ControlPath_Out_Record
	);
end ControlPath;

architecture behavioral of ControlPath is
    type State is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12);
    signal currentState, nextState : State;
begin
    process(clk, rst)
    begin
        if rst = '1' then
            currentState <= S0;
        elsif rising_edge(clk) then
            currentState <= nextState;
        end if;
    end process;

    process(currentState, mod_pronto, k_menor_text_size, data_ok)
    begin
        case currentState is
            when S0 =>
                if data_ok = '1' then
                    nextState <= S1;
                else
                    nextState <= S0;
                end if;

            when S1 =>
                if k_menor_text_size = '1' then
                    nextState <= S2;
                else
                    nextState <= S0;
                end if;

            when S2 =>
                if mod_pronto = '1' then
                    nextState <= S3;
                else
                    nextState <= S2;
                end if;

            when S3 =>
                nextState <= S4;

            when S4 =>
                if mod_pronto = '1' then
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
                if mod_pronto = '1' then
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

    process(currentState, k_menor_text_size)
    begin
        control_out.done        <= '0';
        control_out.en_i        <= '0';
        control_out.en_j        <= '0';
        control_out.en_k        <= '0';
        control_out.en_t        <= '0';
        control_out.indice      <= "00";
        control_out.vetor       <= '0';
        control_out.acionar_mod <= '0';
        control_out.sel         <= '0';
        control_out.ld          <= '0';
        control_out.a_plus      <= '0';
        control_out.b_plus      <= "00";
        control_out.rst_bd      <= '0';
        control_out.dado        <= "00";

        case currentState is
            when S0 =>
                control_out.rst_bd <= '1';

            when S1 =>
                if k_menor_text_size = '0' then
                    control_out.done <= '1';
                end if;

            when S2 =>
                control_out.en_i        <= '1';
                control_out.acionar_mod <= '1';
                control_out.dado        <= "11";

            when S3 =>
                control_out.sel <= '1';
                control_out.ld  <= '1';

            when S4 =>
                control_out.en_j        <= '1';
                control_out.acionar_mod <= '1';
                control_out.a_plus      <= '1';
                control_out.b_plus      <= "01";
                control_out.dado        <= "11";

            when S5 =>
                control_out.en_t <= '1';
                control_out.dado <= "10";

            when S6 =>
                control_out.indice <= "01";
                control_out.sel    <= '1';
                control_out.ld     <= '1';

            when S7 =>
                control_out.sel  <= '1';
                control_out.dado <= "10";

            when S8 =>
                control_out.indice <= "01";
                control_out.sel    <= '1';
                control_out.dado   <= "01";

            when S9 =>
                control_out.en_t        <= '1';
                control_out.acionar_mod <= '1';
                control_out.a_plus      <= '1';
                control_out.b_plus      <= "10";
                control_out.dado        <= "11";

            when S10 =>
                control_out.indice <= "11";
                control_out.sel    <= '1';
                control_out.ld     <= '1';

            when S11 =>
                control_out.indice <= "10";
                control_out.vetor  <= '1';
                control_out.sel    <= '1';
                control_out.dado   <= "10";

            when S12 =>
                control_out.en_k   <= '1';
                control_out.b_plus <= "11";

            when others =>
                null;
        end case;
    end process;
end behavioral;
