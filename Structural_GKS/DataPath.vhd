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
		clk				: in std_logic;
		rst				: in std_logic;
        
        data_ok           : out std_logic;                   -- Sinal de controle para indicar que os dados estão REGISTRADOS e prontos para serem processados
        kMenorTextSize           : out std_logic;            -- Sinal de controle para indicar que o valor de k é menor que o tamanho do texto
        modPronto           : out std_logic;                 -- Sinal de controle para indicar que a operação de módulo foi concluída
        A               : out std_logic_vector(ADDR_WIDTH-1 downto 0);                        -- Saída para índice da memória
        Data_out        : out std_logic_vector(DATA_WIDTH-1 downto 0);                        -- Saída para dado a ser escrito na memória

        Data_in         : in std_logic_vector(DATA_WIDTH-1 downto 0);                       -- Entrada para dado lido da memória
        Data               : in std_logic_vector(DATA_WIDTH-1 downto 0);                          -- Entrada para valor dado pelo usuário
        en_i           : in std_logic;                     -- Sinal de controle para habilitar escrita dos registradores
        en_j              : in std_logic;
        en_k              : in std_logic;
        en_t              : in std_logic;
        vetor           : in std_logic;                   -- Sinal de controle para selecionar o índice initial será o do keystream ou do texto que já está na memória
        indice      : in std_logic_vector(1 downto 0);                   -- escolhe qual o indice para mecher na memória
        AcionarMod      : in std_logic;                    -- Sinal para acionar a operação de módulo
        A_plus          : in std_logic;                        -- Controla qual valor vai para o somador
        B_plus          : in std_logic_vector(1 downto 0);     -- Controla qual valor vai para o somador
        rst_bd         : in std_logic;                     -- Sinal de reset para a Datapath
        Dado           : in std_logic_vector(1 downto 0)  -- Sinal de controle para selecionar o dado a ser escrito nos registradores
	);
end DataPath;


architecture Estrutural of DataPath is
    
    -- Tem que usar o "RegisterNbits.vhd"
        
begin

end Estrutural;
