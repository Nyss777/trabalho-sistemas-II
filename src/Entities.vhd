library IEEE;
use IEEE.std_logic_1164.all;



entity Decoder_2to4 is
    port (
        A : in  STD_LOGIC_VECTOR(1 downto 0);
        Y : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Decoder_2to4;

architecture behavioral of Decoder_2to4 is
begin
    process(A)
    begin
        case A is
            when "00" => Y <= "0001";
            when "01" => Y <= "0010";
            when "10" => Y <= "0100";
            when "11" => Y <= "1000";
            when others => Y <= "0000";
        end case;
    end process;
end behavioral;


library IEEE;
use IEEE.std_logic_1164.all;


entity Sincronizador is
    port (
        clk           : in std_logic;
        data_av       : in std_logic;
        data_av_under : out std_logic
    );
end Sincronizador;

architecture arch of Sincronizador is

    signal FF1, FF0 : std_logic;
    signal and1, and2, xor1 : std_logic;

begin

    and1 <= '1' when (xor1 = '1' and data_av = '1') else '0';
    and2 <= '1' when (FF1 = '0' and FF0 = '0' and data_av = '1') else '0';
    xor1 <= '1' when (FF1 /= FF0) else '0';

    data_av_under <= '1' when (FF1 = '0' and FF0 = '1') else '0';

    process(clk)
    begin

        if rising_edge(clk) then
            FF0 <= and1;
            FF1 <= and2;
        end if;

    end process;

end arch;


library IEEE;
use IEEE.std_logic_1164.all;


entity FullAdder is
    port(
        A, B, Ci    : in std_logic;
        S, Co       : out std_logic
    );
end FullAdder;

architecture arch2 of FullAdder is

begin

    -- Gera a soma (S)
    S <= (A xor B) xor Ci;

    -- Gera carry out (Co)
    Co <= (A and B) or ((A xor B) and Ci);

end arch2;


library IEEE;
use IEEE.std_logic_1164.all;

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
        AdderB           : in std_logic;
        mux_upper_right  : out std_logic_vector(DATA_WIDTH-1 downto 0);
        kMenorTextSize   : out std_logic;
        modPronto        : out std_logic
    );
end modulo;

architecture arch of modulo is

    signal mux_upperleft : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mux_upperright : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mux_middle : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal AdderA, AdderOut : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal AdderCo : std_logic;
    signal FlipD : std_logic;
    signal registerOut: std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    FULLADDER: entity work.FullAdder
        port map (
            A  => AdderA,
            B  => AdderB,
            S  => AdderOut,
            Ci => '0',
            Co => AdderCo
        );

    MODREGISTER: entity work.RegisterNbits
        port map (
            clock => clk,
            reset => rst,
            d     => mux_upperleft,
            q     => registerOut,
            ce    => '1'
        );

    kMenorTextSize <= AdderCo;
    modPronto <= '1' when (AdderCo = '1' and FlipD = '1') else '0';
    mux_upperleft <= mux_upperright when (AdderCo = '0') else mux_upper_left_b;
    mux_middle <= k when (modulo= '0') else registerOut;
    mux_upperright <= AdderOut when (AdderCo = '0') else registerOut;
    mux_upper_right <= mux_upperright;
    AdderA <= mux_middle;

    process(clk, rst)
    begin

        if rst = '1' then
            FlipD <= '0';

        elsif rising_edge(clk) then
            FlipD <= modulo;

        end if;
    end process;

end arch;