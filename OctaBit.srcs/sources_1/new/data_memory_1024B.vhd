----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.03.2023 11:37:11
-- Design Name: 
-- Module Name: data_memory_1024B - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity data_memory_1024B is
  Port (
    clk             : in std_logic;
    write_enable    : in std_logic;
    z_addr          : in std_logic_vector(9 downto 0);
    z_data_in       : in std_logic_vector(7 downto 0);
    
    data            : out std_logic_vector(7 downto 0)
  );
end data_memory_1024B;

architecture Behavioral of data_memory_1024B is
  type regs is array(1023 downto 0) of std_logic_vector(7 downto 0); 
  signal DATA_MEM: regs;
begin

    data_write: process(clk)
    begin
        if(rising_edge(clk)) then
            if write_enable = '1' then
                    DATA_MEM(to_integer(unsigned(z_addr))) <= z_data_in;
            end if;
        end if;
    end process;
    
    data <= DATA_MEM(to_integer(unsigned(z_addr)));
end Behavioral;
