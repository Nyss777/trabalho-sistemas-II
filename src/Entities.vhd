-------------------------------------------------------------------------
-- Breno, Nycolas, Estevão
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DataPathMod is
    generic (
        DATA_WIDTH  : integer := 8;
        ADDR_WIDTH  : integer := 8
    );
    port (
        clk              : in std_logic;
        rst              : in std_logic;
        acionar_mod      : in std_logic;
        reg_k_out        : in std_logic_vector(DATA_WIDTH-1 downto 0);
        minuendo         : in std_logic_vector(DATA_WIDTH-1 downto 0);
        subtraendo       : in std_logic_vector(DATA_WIDTH-1 downto 0);

        resto            : out std_logic_vector(DATA_WIDTH-1 downto 0);
        borrow_out       : out std_logic;
        mod_pronto       : out std_logic
    );
end DataPathMod;

architecture behavioral of DataPathMod is
    signal current     : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sub_a       : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sub_ext     : std_logic_vector(DATA_WIDTH downto 0);
    signal borrow      : std_logic;
    signal modulo_prev : std_logic;
begin
    sub_a   <= reg_k_out when acionar_mod = '0' else current;
    sub_ext <= std_logic_vector(unsigned('0' & sub_a) - unsigned('0' & subtraendo));
    borrow  <= sub_ext(DATA_WIDTH);

    borrow_out <= borrow;
    mod_pronto <= borrow and modulo_prev;
    resto <= current;

    process(clk, rst)
    begin
        if rst = '1' then
            current     <= (others => '0');
            modulo_prev <= '0';
        elsif rising_edge(clk) then
            modulo_prev <= acionar_mod;
            if acionar_mod = '1' and modulo_prev = '0' then
                current <= minuendo;
            elsif acionar_mod = '1' and borrow = '0' then
                current <= sub_ext(DATA_WIDTH-1 downto 0);
            end if;
        end if;
    end process;
end behavioral;
