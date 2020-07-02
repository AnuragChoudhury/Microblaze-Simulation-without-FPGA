library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity testbench is
end entity testbench;

architecture my_testbench of testbench is
  signal clk   : std_logic := '0';
  signal clk_n   : std_logic := '1';
  signal rst_n : std_logic := '1';
  signal rst : std_logic := '0';
  signal rs232_uart_txd : std_logic := 'Z';
  signal rs232_uart_rxd : std_logic;

component design_101_wrapper is
  port (
    clk_in1_0 : in STD_LOGIC;
    reset : in STD_LOGIC;
    uart2_pl_rxd : in STD_LOGIC;
    uart2_pl_txd : out STD_LOGIC
  );
end component;

  signal character_state : std_logic_vector (2 downto 0) := "000";
  signal counter : std_logic_vector (31 downto 0) := x"00000000";
  signal number_of_bits_received : std_logic_vector (31 downto 0) := x"00000000";
  signal data_received : std_logic_vector (9 downto 0) := "0000000000";
  file output_file_stdout : text; 
  signal charbuffer : String (1 to 15);         -- this line is changed from signal charbuffer : String (1 to 80);
  signal charbuffer_index : integer := 1;
begin
    uut : design_101_wrapper port map (clk_in1_0 => clk,
                                       reset => rst,
                                       uart2_pl_rxd => rs232_uart_rxd,
                                       uart2_pl_txd => rs232_uart_txd);

  -- system input clock = 200MHz, half-period = 2.5ns
  -- UART Baud rate 115200. => 200M/115200 TB-clock-cycles.
  --    200M/115200 = 1736 = 0x6c8, half/mid = 868 = 0x364
  -- One symbol = 4.16us => 4.16u/5n = 832 = 0x340
  clk   <= not clk after 5 ns ;

  process
  begin
    file_open(output_file_stdout, "STD_OUTPUT", write_mode);
    rst_n <= '0';
    rst <= '1';
    wait for 80 ns;
    rst_n <= '1';
    rst <= '0';
    wait;
  end process;

  process
  begin
    wait for 10 ns;
    -- report "counter value is [" & integer'image (to_integer (unsigned (count))) & "]";
    wait for 10 ns;
  end process;

  process (clk)
    variable line1 : line;
  begin
    if rising_edge (clk) then
        if '0' = rst then
        counter <= std_logic_vector (unsigned (counter) + x"00000001");
        case character_state is
            when "000" => 
                if '0' = rs232_uart_txd then
                    character_state <= "001"; -- start bit '0' received.
                    counter <= x"00000000";
                end if;
            when "001" => -- start bit clock cycles
                if counter = x"00000364" then -- (200M/2400)/2 = 83333/2 = 41666 = 0xa2c2
                    character_state <= "010"; -- reached middle of start bit.
                    counter <= x"00000000";
                end if;
            when "010" => -- receiving characters
                if counter = x"000006c8" then -- goto next character
                    data_received(9) <= rs232_uart_txd;
                    data_received(8 downto 0) <= data_received(9 downto 1);
                    counter <= x"00000000";
                    if number_of_bits_received = x"00000007" then
                        number_of_bits_received <= x"00000000";
                        character_state <= "011";
                    else
                        number_of_bits_received <= std_logic_vector (unsigned (number_of_bits_received) + x"00000001");
                    end if;
                end if;
            when "011" =>
                if counter = x"000006c8" then -- middle of stop character
                    -- report "received " & integer'image (to_integer (unsigned (data_received(9 downto 2))));
                    -- write (line1, character'val(to_integer(unsigned(data_received(9 downto 2)))));
                    -- writeline (output_file_stdout, line1);
                    if (charbuffer_index = 14) then         -- this line is changed by Neelam from if (charbuffer_index = 79) then
                        charbuffer (1) <= character'val(to_integer(unsigned(data_received(9 downto 2))));
                        charbuffer_index <= 2;
                        write (line1, charbuffer, left);
                        writeline (output_file_stdout, line1);
                    elsif (10 = to_integer(unsigned(data_received(9 downto 2)))) then
                        charbuffer_index <= 1;
                        write (line1, charbuffer, left);
                        writeline (output_file_stdout, line1);
                    else
                        charbuffer(charbuffer_index) <= character'val(to_integer(unsigned(data_received(9 downto 2))));
                        charbuffer_index <= charbuffer_index + 1;
                    end if;
                    character_state <= "000";
                    counter <= x"00000000";
                end if;
            when others =>
                counter <= x"00000000";
                data_received <= "0000000000";
                number_of_bits_received <= x"00000000";
                character_state <= "000";
        end case;
        end if;
    end if;
  end process;

end architecture my_testbench;