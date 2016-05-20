---------------------------------------------------------------------------------
-- Module : SPI to UART interface
-- This module interface SPI Master to a number of UARTs through SPI Slave
-- This module consists of SPI Slave and a port expander
-- clk_sys : System Clock 
-- cs_n : Active low chip selects, which selects the SPI to UART interface
-- rst_n : Active low system reset, resets whoe system to default configuration
-- slck   : SPI Slave clock, driven by SPI Master
-- mosi   : Master Out Slave In, data line from SPI master
-- miso   : Master In Slave out, Data line from SPI Slave(This interface)
-- uart_mode : Mode selection signals to UART 
-- uart_mx_data : Configuration/Data lines to UART, selected based on Mode. This data 
-- gets latched to UART at soon as all the data bits available
-- uart_dmx_data : Data/Status lines from UART. This data gets latched to SPI 
-- as soon as a valid mode signal available in SPI Slave.
---------------------------------------------------------------------------------      
        
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.spi_uart_package.all;


entity spi_uart_expander is    
    port ( 
        clk_sys         : in std_logic;
        rst_n           : in std_logic;
        cs_n            : in std_logic;
        sclk            : in std_logic;
        mosi            : in std_logic;
        miso            : out std_logic;          

        uart_mode       : out uart_spi_mode_type_n;
        uart_mx_data    : in uart_spi_data_type_n;
        uart_dmx_data   : out uart_spi_data_type_n
   );
end spi_uart_expander;

architecture structural of spi_uart_expander is
	
    component spi_mxdmx is
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
    end component;

    component spi_slave is    
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
    end component;

    signal spi_dmx_data            : std_logic_vector(UART_DATA_WIDTH - 1 downto 0); 
    signal spi_mx_data             : std_logic_vector(UART_DATA_WIDTH - 1 downto 0); 
    signal uart_address            : std_logic_vector(UART_ADDR_WIDTH - 1 downto 0);
    signal uart_mode_config        : std_logic_vector(UART_MODE_WIDTH - 1 downto 0);
    signal uart_data_valid         : std_logic; 
    signal uart_mode_valid         : std_logic;    

begin
    
    
    -- SPI to UART port expander instantiation
    spi_dmx_inst: spi_mxdmx 
        port map(
            clk_sys                 => clk_sys,
            rst_n                   => rst_n,
            spi_dmx_data            => spi_dmx_data,
            spi_mx_data             => spi_mx_data,
            uart_address            => uart_address,
            uart_mode_config        => uart_mode_config,
            uart_data_valid         => uart_data_valid,
            uart_mode_valid         => uart_mode_valid,
            uart_mode               => uart_mode,
            uart_mx_data            => uart_mx_data,
            uart_dmx_data           => uart_dmx_data
        );

    -- SPI Slave instantiation
    spi_slave_inst: spi_slave 
        port map ( 
            cs_n            => cs_n, 
            sclk            => sclk,
            rst_n           => rst_n,
            mosi            => mosi,
            miso            => miso,
            uart_data_valid         => uart_data_valid,
            uart_mode_valid         => uart_mode_valid,
            data_in         => spi_mx_data,
            data_out        => spi_dmx_data,
            address         => uart_address,
            mode            => uart_mode_config
        );
end architecture structural;

