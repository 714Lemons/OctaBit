----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.03.2023 14:49:50
-- Design Name: 
-- Module Name: pip_fetch - Behavioral
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

entity pip_fetch is
    Port (
    clk : in std_logic;
    reset : in std_logic;
    pm_in : in std_logic_vector(15 downto 0);
    
    pip_pm_out : out std_logic_vector(15 downto 0)
    );
end pip_fetch;

architecture Behavioral of pip_fetch is

begin
    pipline : process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                pip_pm_out <= (others => '0');
            else
                pip_pm_out <= pm_in;
            end if;
        end if;
    end process pipline;  


end Behavioral;
