---------------------------------------------------------------------------------
-- Module : SPI Slave
-- This module is an SPI Slave, which interfaces with to SPI Master and SPI to 
-- UART port expander
-- cs_n   : Active low chip selects, which selects the SPI to UART interface
-- rst_n  : Active low system reset, resets whoe system to default configuration
-- slck   : SPI Slave clock, driven by SPI Master
-- mosi   : Master Out Slave In, data line from SPI master
-- miso   : Master In Slave out, Data line from SPI Slave(This interface)
-- uart_mode_valid : Active high mode valid input to SPI to UART expander. 
-- uart_data_valid : Active high data valid input to SPI to UART expander. 
-- address : adress input to SPI to UART port expander module. 
-- mode : Mode input to SPI to UART port expander module, which is valid 
-- for active  uart_mode_valid 
-- data_out : Configuration/Data lines to SPI to UART expander, which is 
-- valid for active  uart_data_valid 
-- data_in : Status/Data lines from SPI to UART expander
---------------------------------------------------------------------------------   

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.spi_uart_package.all;


entity spi_slave is    
    port ( 
        cs_n            : in std_logic;
        sclk            : in std_logic;
        rst_n           : in std_logic;
        mosi            : in std_logic;
        miso            : out std_logic;  
        uart_data_valid : out std_logic; 
        uart_mode_valid : out std_logic;       
        data_in         : in std_logic_vector(UART_DATA_WIDTH - 1 downto 0);
        data_out        : out std_logic_vector(UART_DATA_WIDTH - 1 downto 0); 
        address         : out std_logic_vector(UART_ADDR_WIDTH - 1 downto 0);
        mode            : out std_logic_vector(UART_MODE_WIDTH - 1 downto 0)
   );
end spi_slave;

architecture rtl of spi_slave is
	
    signal count, count1 : integer range 0 to 32;
    signal mode_out_tmp  : std_logic_vector(UART_ADDR_WIDTH to UART_MODE_WIDTH + UART_ADDR_WIDTH - 1);
    signal data_out_tmp  : std_logic_vector(UART_MODE_WIDTH + UART_ADDR_WIDTH to UART_DATA_WIDTH + UART_MODE_WIDTH + UART_ADDR_WIDTH - 1);
    signal data_in_tmp   : std_logic_vector(UART_MODE_WIDTH + UART_ADDR_WIDTH to UART_DATA_WIDTH + UART_MODE_WIDTH + UART_ADDR_WIDTH - 1);
    signal address_tmp   : std_logic_vector(0 to UART_ADDR_WIDTH - 1);
    signal spi_data_valid_0 : std_logic;
begin

 
    process(rst_n, sclk)		-- Reading at positive edge
        variable count_var : integer range 0 to 15;
    begin
		if (rst_n = '0') then
		    count <= 0;
		    data_out_tmp <= (others => '1');
		    mode_out_tmp <= (others => '0');
		    address_tmp  <= (others => '0');
		    uart_mode_valid <= '0';
        elsif (sclk = '1' and sclk'event) then
            if (cs_n = '0') then 
                count_var := count;
                if (count_var >= 0 and count_var < UART_ADDR_WIDTH) then
                    -- Record Address
                    address_tmp(conv_integer(count_var)) <= mosi;
                    uart_mode_valid <= '0';
count <= count_var + 1;
                elsif (count_var >= UART_ADDR_WIDTH and count_var < UART_MODE_WIDTH + UART_ADDR_WIDTH) then
                    -- Record Mode
                    mode_out_tmp(count_var) <= mosi;
                    if (count_var = UART_MODE_WIDTH + UART_ADDR_WIDTH - 1) then 
                        uart_mode_valid <= '1';
                    end if;
count <= count_var + 1;
                else 
                    -- Record Data/Configuration
                    uart_mode_valid <= '0';
                    data_out_tmp(count_var) <= mosi;
                if count = 15 then 
                    count <= 0;
                else 
                    count <= count_var + 1;
                end if;
                end if;
            end if;
        end if;
    end process;
    
    process(rst_n, sclk)       --spi data valid 
    begin
        if (rst_n = '0') then
            spi_data_valid_0 <= '0';
            uart_data_valid <= '0';
        elsif (sclk = '0' and sclk'event) then
            if count = 15 then 
                spi_data_valid_0 <= '1';
            else 
                spi_data_valid_0 <= '0';
            end if;
            uart_data_valid <= spi_data_valid_0;
        end if;
    end process;
    
    address <= address_tmp;
    data_out <= data_out_tmp;
    mode <= mode_out_tmp; 

    data_in_tmp <= data_in;
    
    process(rst_n, sclk, cs_n)       --writing at neg edge edge
        variable count_var : integer range 0 to 15;
    begin
        if (rst_n = '0' or cs_n = '1') then
            count1 <= 0;
            miso <= '1';
        elsif (sclk = '0' and sclk'event) then
            if cs_n = '0' then 
            count_var := count1;
            -- First 5 bits are Dont Cares. Rest 11 Bits are data
            if (count_var > UART_MODE_WIDTH + UART_ADDR_WIDTH - 1) then
                miso <= data_in_tmp(conv_integer(count_var));
            else
                miso <= '1';
            end if;
            if count1 = 15 then 
                count1 <= 0;
            else 
                count1 <= count_var + 1;
            end if;
            end if;
        end if;
    end process;
end architecture rtl;


