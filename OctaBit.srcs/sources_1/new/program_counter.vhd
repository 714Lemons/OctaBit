----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.03.2023 14:27:23
-- Design Name: 
-- Module Name: program_counter - Behavioral
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
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity program_counter is
    Port (
    clk             : in std_logic;
    reset           : in std_logic;
    override_enable : in std_logic;
    offset          : in std_logic_vector(11 downto 0);
    hold            : in std_logic;
    
    addr            : out std_logic_vector(8 downto 0)
    );
end program_counter;

architecture Behavioral of program_counter is
    signal PC_CNT : std_logic_vector(8 downto 0) := (others => '0');

begin
    count : process (clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                PC_CNT <= (others => '0');
            else
                if override_enable = '1' then
                    -- TODO: signed problem?
                    PC_CNT <= std_logic_vector(signed(PC_CNT) + signed(offset(8 downto 0)) + 1);
                elsif hold = '0' then
                    PC_CNT <= std_logic_vector(unsigned(PC_CNT) + 1);
                end if;
            end if;
        end if;
    end process count;
    
    addr <= PC_CNT;           

end Behavioral;
