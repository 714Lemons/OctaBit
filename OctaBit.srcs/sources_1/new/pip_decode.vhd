----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.03.2023 14:37:38
-- Design Name: 
-- Module Name: pip_decode - Behavioral
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

entity pip_decode is
    Port (
    clk                 : in std_logic;
    
    dec_rf_addr_opA          : in std_logic_vector(4 downto 0);
    dec_rf_addr_opB          : in std_logic_vector(4 downto 0);
    dec_alu_op_code          : in std_logic_vector(3 downto 0);
    dec_rf_write_enable      : in std_logic;
    dec_sreg_write_enable    : in std_logic_vector(7 downto 0);
    dec_rf_immediate         : in std_logic;
    dec_alu_immediate        : in std_logic;
    dec_immediate_value      : in std_logic_vector(7 downto 0);
    dec_dm_write_enable      : in std_logic;
    dec_mux_select_alu_dm    : in std_logic;
    dec_sreg_override_enable : in std_logic;
    dec_sreg_override_value  : in std_logic_vector(7 downto 0);
    dec_sp_op                : in std_logic;
    dec_sp_enable            : in std_logic;
    
    -- br:
    -- dm_value, enable_mux_rf_pc -> mux_rf_br_dm
    -- override_enable, offset, hold_pc -> feed forward? direct?
    -- sp_op, sp_enable, br_sp_enable, mux_alu_dm_select

    br_mux_z_br_value        : in std_logic_vector(7 downto 0);
    br_mux_select_alu_dm     : in std_logic;
    br_mux_rf_br_enable      : in std_logic;
    mux_br_sp_enable         : in std_logic;
    br_sp_op_code            : in std_logic;
    br_sp_enable             : in std_logic;
    
    -- out  
    pip_dec_rf_addr_opA          : out std_logic_vector(4 downto 0);
    pip_dec_rf_addr_opB          : out std_logic_vector(4 downto 0);
    pip_dec_alu_op_code          : out std_logic_vector(3 downto 0);
    pip_dec_rf_write_enable      : out std_logic;
    pip_dec_sreg_write_enable    : out std_logic_vector(7 downto 0);
    pip_dec_rf_immediate         : out std_logic;
    pip_dec_alu_immediate        : out std_logic;
    pip_dec_immediate_value      : out std_logic_vector(7 downto 0);
    pip_dec_dm_write_enable      : out std_logic;
    pip_dec_mux_select_alu_dm    : out std_logic;
    pip_dec_sreg_override_enable : out std_logic;
    pip_dec_sreg_override_value  : out std_logic_vector(7 downto 0);
    pip_dec_sp_op                : out std_logic;
    pip_dec_sp_enable            : out std_logic;
    
    -- br:
    -- dm_value, enable_mux_rf_pc -> mux_rf_br_dm
    -- override_enable, offset, hold_pc -> feed forward? direct?
    -- sp_op, sp_enable, br_sp_enable, mux_alu_dm_select
    pip_br_mux_z_br_value        : out std_logic_vector(7 downto 0);
    pip_br_mux_select_alu_dm     : out std_logic;
    pip_br_mux_rf_br_enable      : out std_logic;
    pip_mux_br_sp_enable         : out std_logic;
    pip_br_sp_op_code            : out std_logic;
    pip_br_sp_enable             : out std_logic
    );
end pip_decode;

architecture Behavioral of pip_decode is

begin
    pipeline : process(clk)
        begin
            pip_dec_rf_addr_opA          <= dec_rf_addr_opA;
            pip_dec_rf_addr_opB          <= dec_rf_addr_opB;
            pip_dec_alu_op_code          <= dec_alu_op_code;
            pip_dec_rf_write_enable      <= dec_rf_write_enable;
            pip_dec_sreg_write_enable    <= dec_sreg_write_enable;
            pip_dec_rf_immediate         <= dec_rf_immediate;
            pip_dec_alu_immediate        <= dec_alu_immediate;
            pip_dec_immediate_value      <= dec_immediate_value;
            pip_dec_dm_write_enable      <= dec_dm_write_enable;
            pip_dec_mux_select_alu_dm    <= dec_mux_select_alu_dm;
        
            pip_dec_sreg_override_enable <= dec_sreg_override_enable;
            pip_dec_sreg_override_value  <= dec_sreg_override_value;
            pip_dec_sp_op                <= dec_sp_op;
            pip_dec_sp_enable            <= dec_sp_enable;
            
            -- br:
            -- dm_value; enable_mux_rf_pc -> mux_rf_br_dm
            -- override_enable; offset; hold_pc -> feed forward? direct?
            -- sp_op; sp_enable; br_sp_enable; mux_alu_dm_select
        
            pip_br_mux_z_br_value       <= br_mux_z_br_value;
            pip_br_mux_select_alu_dm    <= br_mux_select_alu_dm;
            pip_mux_br_sp_enable        <= mux_br_sp_enable;
            pip_br_sp_op_code           <= br_sp_op_code;
            pip_br_sp_enable            <= br_sp_enable;
            pip_br_mux_rf_br_enable     <= br_mux_rf_br_enable; 
    end process pipeline;

end Behavioral;
