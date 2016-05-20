
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package spi_uart_package is

    constant UART_NUMS             : natural := 7; -- Number of UARTs supported for expansion
    constant UART_DATA_WIDTH       : natural := 11; -- UART data bus width for data in, data out

	-- FIFO and UART parameters
    constant WR_FIFO_DATA_WIDTH       : natural := 8; 
    constant RD_FIFO_DATA_WIDTH       : natural := 10;
    constant FIFO_ADDR_WIDTH          : natural := 4; 
    constant UART_ADDR_WIDTH          : natural := 3;
    constant UART_MODE_WIDTH          : natural := 2;

    type uart_spi_data_type_n is array (integer range 0 to UART_NUMS - 1) of std_logic_vector(UART_DATA_WIDTH - 1 downto 0);
    type uart_spi_mode_type_n is array (integer range 0 to UART_NUMS - 1) of std_logic_vector(UART_MODE_WIDTH - 1 downto 0);

	-- Note: There is no exact limit on how much frequency error can be tolerated by 
    -- the UART, since this depends on the baud rates, the precise frequencies used 
    -- by the two devices, the character length, the number of stop bits, and 
    -- whether a parity bit is used or not. However, most UARTs will work with a 
    -- frequency error less than 5 %. This is the theoretical limit based on 16× 
    -- sampling of the start bit, and 10-bit data format (one start bit, 8 data 
    -- bits, and one stop bit). If both connected devices have timing error, 
    -- then error budget should be reduced to +/-2.5%. %Error depends on accuracy 
    -- of the clock crystals used and clock divide factor. Make sure that clock 
    -- divide factor input through this package files is a factor of 16. 
    -- 
    -- The following example illustrates the calculation of the baud rate error:
    -- Example 1:
    --     SYS_FREQ = 4 MHz
    --     Desired Baud Rate = 9600bps
    --     Calculated Baud Rate = 4x10^6 / 0b000110100000 = 9615. 
    --     Error = (Calculated Baud Rate - Desired Baud Rate)/Desired Baud Rate
    --           = (9615 - 9600) / 9600
    --           = 0.16%
    -- Example 2:
    --     SYS_FREQ = 3.6864 MHz
    --     Desired Baud Rate = 115.2Kbps
    --     Calculated Baud Rate = 3.6864x10^6 / 32 = 115200. 
    --     Error = (Calculated Baud Rate - Desired Baud Rate)/Desired Baud Rate
    --           = (115200 - 115200) / 115200
    --           = 0% 
    -- However, note that %error dependent on frequency tolerance of crystal used. 

    constant SYS_FREQ              : natural := 4000000; -- 4 MHz
    -- Clock divider factor used for various baudrates. 
    -- Make sure that these constants are multiples of 16. These numbers are divied by 16 
    -- in order to 16xClock in UART Rx module.
    constant BAUD115P2K            : std_logic_vector(11 downto 0) := "000000100000"; --115.2kbps
    constant BAUD57P6K             : std_logic_vector(11 downto 0) := "000001000000";
    constant BAUD38P4K             : std_logic_vector(11 downto 0) := "000001100000";
    constant BAUD19P2K             : std_logic_vector(11 downto 0) := "000011000000";
    constant BAUD9600              : std_logic_vector(11 downto 0) := "000110100000"; -- 9600bps
    constant BAUD4800              : std_logic_vector(11 downto 0) := "001101000000";
    constant BAUD2400              : std_logic_vector(11 downto 0) := "011010000000";
    constant BAUD1200              : std_logic_vector(11 downto 0) := "110100000000"; -- 1.2Kbps


end package spi_uart_package;




















