----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.03.2023 11:28:29
-- Design Name: 
-- Module Name: z_address - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity z_address is
  Port (
    clk         : in std_logic;
    reset       : in std_logic;
    rf_addr_r30 : in std_logic;
    rf_addr_r31 : in std_logic;
    z_addr_value  : in std_logic_vector(7 downto 0);
    
    z_addr_out  : out std_logic_vector(9 downto 0)
  );
end z_address;

architecture Behavioral of z_address is
    signal R31 : std_logic_vector(1 downto 0) := (others=>'0');
    signal R30 : std_logic_vector(7 downto 0) := (others=>'0');
begin

    main: process(clk)
    begin
        if(rising_edge(clk)) then
            if(reset ='0') then
                --R31
                if(rf_addr_R31 = '1') then
                    R31 <= z_addr_value(1 downto 0);
                end if;

                --R30
                if(rf_addr_r30 = '1') then
                    R30 <= z_addr_value;
                end if;
            else
                R30 <= (others => '0');
                R31 <= (others => '0');
            end if;
        end if;
    end process;

    z_addr_out <= R31 & R30;

end Behavioral;
