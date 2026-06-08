-------------------------------------------------------------------------
-- Breno, Nycolas, Estevão
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package GenerateKeyStream_pkg is

    -- Definição da record contendo os sinais do ControlPath para o DataPath
    type ControlPath_Out_Record is record
        en_i        : std_logic;                      -- Habilita escrita nos registradores
        en_j        : std_logic;
        en_k        : std_logic;
        en_t        : std_logic;
        vetor       : std_logic;                      -- Seleciona índice inicial (keystream ou texto)
        indice      : std_logic_vector(1 downto 0);   -- Índice para memória (initial + contador)
        acionar_mod : std_logic;                      -- Aciona a operação de módulo
        sel         : std_logic;                      -- Ativa a memória
        ld          : std_logic;                      -- Load da memória (0: escrita, 1: leitura)
        a_plus      : std_logic;                      -- Controle do somador (A)
        b_plus      : std_logic_vector(1 downto 0);   -- Controle do somador (B)
        rst_bd      : std_logic;                      -- Reset para o Datapath
        dado        : std_logic_vector(1 downto 0);   -- Seleciona dado para registradores
        done        : std_logic;                      -- Indica operação concluída
    end record ControlPath_Out_Record;

end package GenerateKeyStream_pkg;