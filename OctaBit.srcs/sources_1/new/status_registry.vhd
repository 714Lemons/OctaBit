----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.03.2023 16:19:08
-- Design Name: 
-- Module Name: status_registry - Behavioral
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

entity status_registry is
  Port (
    clk             : in std_logic;
    reset           : in std_logic;
    w_e_sreg        : in std_logic_vector (7 downto 0);
    override        : in std_logic;
    override_value  : in std_logic_vector (7 downto 0);
    status_in       : in std_logic_vector (7 downto 0);
    
    status_out : out std_logic_vector(7 downto 0) := (others => '0')
  );
end status_registry;

architecture Behavioral of status_registry is

begin
    write_status: process(clk) is
    begin
        if (rising_edge(clk)) then
            if(override='1') then
                for i in 7 downto 0 loop
                    if(w_e_sreg(i) = '1') then
                        status_out(i) <= override_value(i);
                    end if;
                end loop;
            else
                for i in 7 downto 0 loop -- always nessecary?
                    if(w_e_sreg(i) = '1') then
                        status_out(i) <= status_in(i);
                    end if;
                end loop;
            end if;
        end if;
    end process;

end Behavioral;
