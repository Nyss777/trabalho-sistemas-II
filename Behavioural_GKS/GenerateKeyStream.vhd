-------------------------------------------------------------------------
--  Estevão, Nycolas, Breno,
--------------------------------------------------------------------------

library IEEE;						
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity GenerateKeyStream is
	generic(
		ADDR_WIDTH	: integer := 8;
        DATA_WIDTH  : integer := 8
	);
	port (
		clk		    : in std_logic;
        rst         : in std_logic;
		data_av		: in std_logic;   
        done		: out std_logic;
        data_out    : out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);
		
end GenerateKeyStream;

architecture structural of GenerateKeyStream is  
    
    -- Memory interface signals     
    signal mem_ce, mem_wr: std_logic;
    signal mem_addr: std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal mem_data_in, mem_data_out: std_logic_vector(DATA_WIDTH - 1 downto 0);
    
begin
    
    -- Behavioral FSM (replaces ControlPath + DataPath)
	FSMD: entity work.Behavioral
		generic map (
			DATA_WIDTH	=> DATA_WIDTH,
            ADDR_WIDTH  => ADDR_WIDTH
		)
		port map (
			clk		        => clk,
			rst		        => rst,
            data_ok         => data_av,                -- Control signal: data available
            srcAddr         => (others => '0'),        -- Start address (adjust if needed)
            stateSize       => std_logic_vector(to_unsigned(256, ADDR_WIDTH)),  -- RC4 uses 256-byte state
            data_out        => data_out,               -- Keystream output
            done            => done,                   -- FSM completion flag
            
            -- Memory interface
            mem_ce          => mem_ce,
            mem_wr          => mem_wr,
            mem_addr        => mem_addr,
            mem_data_in     => mem_data_in,
            mem_data_out    => mem_data_out
        );
    
    -- Memory for state array (RC4 state table)
    MEMORY: entity work.Memory
        generic map (
            DATA_WIDTH  => DATA_WIDTH,
            ADDR_WIDTH  => ADDR_WIDTH,
            imageFileName => "keyStreamImage.txt"
        )
        port map (
            clock   => clk,
            ce      => mem_ce,
            wr      => mem_wr,
            address => mem_addr,
            data_i  => mem_data_in,
            data_o  => mem_data_out
        );
		
end structural;
