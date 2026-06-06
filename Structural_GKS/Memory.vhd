-------------------------------------------------------------------------
-- Design unit: Memory
-- Description: Parametrizable memory
--      Asynchronous read
--      Synchronous write
--      Bidirectional data bus
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.Util_package.all;


entity Memory is
    generic (
        DATA_WIDTH  : integer := 8;         -- Data bus width
        ADDR_WIDTH  : integer := 8;         -- Address bus width
        IMAGE       : string := "UNUSED"    -- Memory content to be loaded    (text file)
    );
    port (  
        clk         : in std_logic;
        rw          : in std_logic; -- rw = 0: READ; rw = 1: WRITE
        ce          : in std_logic;    -- Chip Enable
        address     : in std_logic_vector (ADDR_WIDTH-1 downto 0);
        data        : inout std_logic_vector (DATA_WIDTH-1 downto 0)
    );
end Memory;


architecture behavioral of Memory is

    type Memory is array (0 to (2**ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal memoryArray: Memory;    
            
    
    ----------------------------------------------------------------------------
    -- This procedure loads the memory array with the specified file in 
    -- the following format (ADDRESS DATA)
    --  
    --  00 40 
    --  01 80
    --  02 24 
    --  03 8B
    --    ...
    ----------------------------------------------------------------------------
    function MemoryLoad(IMAGE: in string) return Memory is
        
        file imageFile : TEXT open READ_MODE is IMAGE;
        variable memoryArray    : Memory;
        variable fileLine       : line;                -- Stores a read line from a text file
        variable data_str       : string(1 to DATA_WIDTH/4);        -- String used to read data from image file
        variable addr_str       : string(1 to ADDR_WIDTH/4);    -- String used to read address from image file         
        variable char           : character;        -- Stores a single character
        variable bool           : boolean;            -- 
        variable data_var       : std_logic_vector(DATA_WIDTH-1 downto 0);
        variable address_var    : std_logic_vector(ADDR_WIDTH-1 downto 0);
                
        begin
            
            -- Main loop to read the image file
            while NOT (endfile(imageFile)) loop    
                
                -- Read a file line into 'fileLine'
                readline(imageFile, fileLine);    
                    
                    -- Read address character by character and stores into 'addr_str'
                    for i in addr_str'range loop
                        read(fileLine, char, bool);
                        addr_str(i) := char;
                    end loop;
                    
                    -- Converts the address string  'addr_str' to std_logic_vector
                    address_var := StringToStdLogicVector(addr_str);
                    
                                    
                    -- Read the 1 blank between ADDRESS and DATA
                    read(fileLine, char, bool);
                    
                        
                    -- Read data character by character and stores into 'data_str'
                    for i in data_str'range loop
                        read(fileLine, char, bool);
                        data_str(i) := char;
                    end loop;
                    
                    -- Converts the data string 'data_str' to std_logic_vector
                    data_var := StringToStdLogicVector(data_str);
                    
                    
                    -- Stores the 'data' into the memoryArray
                    memoryArray(TO_INTEGER(UNSIGNED(address_var))) := data_var;
                    
            end loop;
            
            return memoryArray;
            
    end MemoryLoad;
    

begin

    -- Memory read
    data <= memoryArray(TO_INTEGER(UNSIGNED(address))) when rw = '0' and ce = '1' else (others=>'Z');

    
    -- Process to load the memory array and control the memory writing
    process(clk)
        variable memoryLoaded: boolean := false;    -- Indicates if the memory was already loaded
    begin        
        -- Memory initialization
        if not memoryLoaded then
            if IMAGE /= "UNUSED" then                
                memoryArray <= MemoryLoad(IMAGE);
            end if;
             
             memoryLoaded := true;
        end if;
        
        if rising_edge(clk) then    -- Memory writing        
            if rw = '1' then
                memoryArray(TO_INTEGER(UNSIGNED(address))) <= data; 
            end if;
        end if;
        
    end process;
        
end behavioral;