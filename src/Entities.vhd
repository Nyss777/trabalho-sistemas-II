library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity modulo is
    generic (
        DATA_WIDTH  : integer := 8;
        ADDR_WIDTH  : integer := 8
    );
    port (
        clk              : in std_logic;
        rst              : in std_logic;
        modulo           : in std_logic;
        k                : in std_logic_vector(DATA_WIDTH-1 downto 0);
        mux_upper_left_b : in std_logic_vector(DATA_WIDTH-1 downto 0);
        AdderB           : in std_logic_vector(DATA_WIDTH-1 downto 0);
        mux_upper_right  : out std_logic_vector(DATA_WIDTH-1 downto 0);
        kMenorTextSize   : out std_logic;
        modPronto        : out std_logic
    );
end modulo;

architecture arch of modulo is
    signal current     : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sub_a       : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sub_ext     : std_logic_vector(DATA_WIDTH downto 0);
    signal borrow      : std_logic;
    signal modulo_prev : std_logic;
begin

    -- single subtractor used for both modes
    sub_a   <= k when modulo = '0' else current;
    sub_ext <= std_logic_vector(unsigned('0' & sub_a) - unsigned('0' & AdderB));
    borrow  <= sub_ext(DATA_WIDTH);

    kMenorTextSize  <= borrow;
    modPronto       <= borrow and modulo_prev;
    mux_upper_right <= current;

    process(clk, rst)
    begin
        if rst = '1' then
            current     <= (others => '0');
            modulo_prev <= '0';
        elsif rising_edge(clk) then
            modulo_prev <= modulo;
            if modulo = '1' and modulo_prev = '0' then
                current <= mux_upper_left_b;
            elsif modulo = '1' and borrow = '0' then
                current <= sub_ext(DATA_WIDTH-1 downto 0);
            end if;
        end if;
    end process;

end arch;
