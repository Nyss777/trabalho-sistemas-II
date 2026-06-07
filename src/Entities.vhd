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