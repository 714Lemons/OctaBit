----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.03.2023 13:13:21
-- Design Name: 
-- Module Name: pip_execute - Behavioral
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

entity pip_execute is
    Port (
    clk : in std_logic; 
    pip_dec_sreg_write_enable       : in std_logic_vector(7 downto 0);
    alu_sreg_status                 : in std_logic_vector(7 downto 0);
    pip_dec_sreg_override_enable    : in std_logic;
    pip_dec_sreg_override_value     : in std_logic_vector(7 downto 0);
    
    pip_exec_sreg_write_enable      : out std_logic_vector(7 downto 0);
    pip_exec_alu_sreg_status        : out std_logic_vector(7 downto 0);
    pip_exec_sreg_override_enable   : out std_logic;
    pip_exec_sreg_override_value    : out std_logic_vector(7 downto 0));
end pip_execute;

architecture Behavioral of pip_execute is

begin
    pipeline : process(clk)
    begin
        pip_exec_sreg_write_enable      <= pip_dec_sreg_write_enable;
        pip_exec_alu_sreg_status        <= alu_sreg_status;
        pip_exec_sreg_override_enable   <= pip_dec_sreg_override_enable;
        pip_exec_sreg_override_value    <= pip_dec_sreg_override_value;
    
    end process pipeline;

end Behavioral;
