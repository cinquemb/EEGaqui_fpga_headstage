---------------------------------------------------------------------------------
-- Module : SPI to UART Port Expander module 
-- This module is an interface between SPI Slave and UARTs. 
-- Main function is to Multiplex data from UART to SPI Slave 
-- demultiplex data from SPI Slave to UARTs. 
-- cs_n : Active low chip selects, which selects the SPI to UART interface
-- rst_n : Active low system reset, resets whoe system to default configuration
-- clk_sys  : System Clock
-- spi_dmx_data : Configuration/Data lines from SPI Slave to UARTs, which is 
-- valid for active  uart_data_valid 
-- spi_mx_data : Data/Status lines from UARTs to SPI Slave
-- uart_address : adress input from SPI Slave. 
-- uart_mode_config : Mode input from SPI Slave module, which is valid 
-- for active  uart_mode_valid 

-- uart_mode_valid : Active high mode valid input to SPI to UART expander. 
-- uart_data_valid : Active high data valid input to SPI to UART expander. 

-- uart_mode : Mode selection signals to UART 
-- uart_dmx_data : Configuration/Data lines to UART, selected based on Mode. This data 
-- gets latched to UART at soon as all the data bits available
-- uart_mx_data : Data/Status lines from UART. This data gets latched to SPI 
-- as soon as a valid mode signal available in SPI Slave.
---------------------------------------------------------------------------------  


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.spi_uart_package.all;

entity spi_mxdmx is    
    port ( 
        clk_sys                 : in std_logic;
        rst_n                   : in std_logic;
        spi_dmx_data            : in std_logic_vector(UART_DATA_WIDTH - 1 downto 0); 
        spi_mx_data             : out std_logic_vector(UART_DATA_WIDTH - 1 downto 0); 
        uart_address            : in std_logic_vector(UART_ADDR_WIDTH - 1 downto 0);
        uart_mode_config        : in std_logic_vector(UART_MODE_WIDTH - 1 downto 0);
        uart_data_valid         : in std_logic;
        uart_mode_valid         : in std_logic;
        uart_mode               : out uart_spi_mode_type_n;
        uart_mx_data            : in uart_spi_data_type_n;
        uart_dmx_data           : out uart_spi_data_type_n
   );
end spi_mxdmx;

architecture rtl of spi_mxdmx is
	
begin
    process (clk_sys, rst_n)
    begin
        if (rst_n = '0') then 
            spi_mx_data <= (others => '0');
            for i in 0 to UART_NUMS - 1 loop
                uart_dmx_data(i) <= (others => '0');
            end loop;
            for i in 0 to UART_NUMS - 1 loop
                uart_mode(i) <= (others => '0');
            end loop;
        elsif clk_sys'event and clk_sys = '1' then 
            -- Read/Write from UARTs based on mode
            case uart_mode_config is 
                when "00" | "01" => 
                     -- Read happens as soon as a valid mode read data/status available
                     if uart_mode_valid = '1' then
                        spi_mx_data <= uart_mx_data(conv_integer(uart_address));
                        uart_mode(conv_integer(uart_address)) <= uart_mode_config;
                     end if;
                when "10" | "11" => 
                    -- Write configuration happens only after a valid data/configuration available
                    if uart_data_valid = '1' then 
                        uart_dmx_data(conv_integer(uart_address)) <= spi_dmx_data;
                        uart_mode(conv_integer(uart_address)) <= uart_mode_config;
                    end if;
                when others  => null;
            end case;
        end if;
    end process;
     

end architecture rtl;


