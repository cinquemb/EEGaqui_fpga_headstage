-- Test Bench for SPI to UART Interface module
-- Use for RTL Simulation 

   library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;
   use ieee.std_logic_arith.all;

   use work.spi_uart_package.all; 

   entity spi_uart_expander_tb is
   end spi_uart_expander_tb;

   architecture tb_behave of spi_uart_expander_tb is
       component spi_uart_expander is    
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
       end component;
       
       signal        clk_sys             : std_logic := '0'; 
       signal        rst_n               : std_logic := '0'; 
       signal        cs_n                : std_logic := '1';
       signal        sclk                : std_logic := '0';
       signal        mosi                : std_logic;
       signal        miso                : std_logic; 
       signal        uart_mode           : uart_spi_mode_type_n;
       signal        uart_mx_data        : uart_spi_data_type_n;
       signal        uart_dmx_data       : uart_spi_data_type_n;
       
       type miso_data_type is array (integer range 0 to UART_NUMS - 1) of std_logic_vector(15 downto 0);
       signal        miso_data           : miso_data_type;
       
       type mosi_data_type is array (integer range 0 to UART_NUMS - 1) of std_logic_vector(15 downto 0);

       constant mosi_in : mosi_data_type       := ("0000000000011000", 
                                                   "0010100000110001",
                                                   "0101000001001010",
                                                   "0111100001100100",
                                                   "1000000000011000", 
                                                   "1010100000110001",
                                                   "1101000001001010"); 
       constant uart_out : uart_spi_data_type_n := ("00010101010", 
                                                    "01001010101",
                                                    "00100111100",
                                                    "01111000011",
                                                    "10010101010", 
                                                    "11001010101",
                                                    "10100111100"); 
   begin 
        spi_uart_expander_inst : spi_uart_expander 
        port map ( 
          clk_sys         => clk_sys,
          rst_n           => rst_n,
          cs_n            => cs_n,
          sclk            => sclk,
          mosi            => mosi,
          miso            => miso,
          uart_mode       => uart_mode,
          uart_mx_data    => uart_mx_data,
          uart_dmx_data   => uart_dmx_data 
        );
       clk_sys <= not clk_sys after 125 ns; 
       sclk    <= not sclk after 500 ns;
       rst_n   <= '1' after 999 ns;       
       
       wave_gen: process
       begin
           wait for 999 ns;

           for j in 0 to UART_NUMS - 1 loop
               cs_n <= '0';

               -- Data to be Transmitted to Host through MISO line
               if mosi_in(j)(12 downto 11) = "00" or mosi_in(j)(12 downto 11) = "01" then 
                   uart_mx_data(j) <= uart_out(j);
               else 
                   uart_mx_data(j) <= (others => '1');
               end if;

               for i  in 15 downto 0 loop 
                   mosi <= mosi_in(j)(i);  -- Master sends data through MOSI line
                   wait until sclk = '1';
                   wait for 1 ns;
                   miso_data(j)(i) <= miso; -- Read MISO line for Testing
               end loop;
               wait for 900 ns;
               cs_n <= '1'; 
               for i  in 3 downto 0 loop 
                   wait until sclk = '1';
                   wait for 1 ns;
               end loop;
               
           end loop;

           -- Verification 
           for j in 0 to UART_NUMS - 1 loop
               -- Mode checking
               assert mosi_in(j)(12 downto 11) = uart_mode(j) report "Mode Faild" severity warning;

               -- Data to UART, this is received from MOSI line. 
               if  uart_mode(j) = "10" or uart_mode(j) = "11" then 
                   assert (uart_dmx_data(j) = mosi_in(j)(10 downto 0)) 
                   report "UART Data write Failed" severity warning;
               else 
                   assert (uart_dmx_data(j) = "00000000000") 
                   report "UART Data write Failed" severity warning;
               end if;

               -- Data to Host, sent through MISO line
               if (j = 2 or j = 3) then 
                   assert (miso_data(j)(10 downto 0) = uart_out(1)) 
                   report "UART Data Read Failed" severity warning;
               elsif (j = 6) then 
                   assert (miso_data(j)(10 downto 0) = uart_out(5)) 
                   report "UART Data Read Failed" severity warning;
               else 
                   assert (miso_data(j)(10 downto 0) = uart_out(j)) 
                   report "UART Data Read Failed" severity warning;
               end if;
                   
               
           end loop; 
                  
           wait;    
           
       end process;
       
       
   end  tb_behave;
