----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.03.2023 15:49:51
-- Design Name: 
-- Module Name: register_file - Behavioral
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

entity register_file is
  Port (
    clk         : in std_logic;
    addr_opa    : in std_logic_vector(4 downto 0);
    addr_opb    : in std_logic_vector(4 downto 0);
    write_addr  : in std_logic_vector(4 downto 0);
    w_e_rf      : in std_logic;
    data_in     : in std_logic_vector(7 downto 0);
    
    data_opa : out std_logic_vector(7 downto 0);
    data_opb : out std_logic_vector(7 downto 0)
  );
end register_file;

architecture Behavioral of register_file is
    -- 256 bit registry
    type regs is array(31 downto 0) of std_logic_vector(7 downto 0);
    
    --  signal register_speicher : regs := (others=>(others=>'0'));
    signal DATA : regs;
begin

  registerfile: process (clk)
  begin  -- process registerfile
    if clk'event and clk = '1' then
      if w_e_rf = '1' then
        DATA(to_integer(unsigned(write_addr))) <= data_in;
      end if;
    end if;
  end process registerfile;

  data_opa <= DATA(to_integer(unsigned(addr_opa)));
  data_opb <= DATA(to_integer(unsigned(addr_opb)));

end Behavioral;
