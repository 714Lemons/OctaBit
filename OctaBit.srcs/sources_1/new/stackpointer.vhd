----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.03.2023 11:32:13
-- Design Name: 
-- Module Name: stackpointer - Behavioral
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

entity stackpointer is
  Port (
    clk         : in std_logic;
    reset       : in std_logic;
    op_code     : in std_logic;
    enable_sp   : in std_logic;
    
    addr    : out std_logic_vector(9 downto 0)
  );
end stackpointer;

architecture Behavioral of stackpointer is
    signal CURR, LAST           : std_logic_vector(9 downto 0) := (others => '1');
begin

    calculate: process(clk) is
    begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                curr <= (others => '1');
                last <= (others => '1');
            else
                if(enable_sp = '1') then
                    case op_code is
                        when '1' =>
                            last <= curr; 
                            curr <= std_logic_vector(unsigned(last) - 1);
                        when '0' =>
                            last <= curr; 
                            curr <= std_logic_vector(unsigned(last) + 1);
                        when others => null;
                    end case;
                end if;
            end if;
        end if;
    end process;
  
    addr <= curr;

end Behavioral;
