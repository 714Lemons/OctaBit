----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.03.2023 22:18:47
-- Design Name: 
-- Module Name: branch_controller - Behavioral
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

entity branch_controller is
    Port (
    clk             : in std_logic;
    reset           : in std_logic;
    sreg_status     : in std_logic_vector(7 downto 0);
    branch_instr    : in std_logic_vector(15 downto 0);
    branch_enable   : in std_logic;
    current_pc      : in std_logic_vector(8 downto 0);
    
    -- direct read in from mux_dm 
    dm_data         : in std_logic_vector(7 downto  0);
    
    override_enable : out std_logic;
    offset          : out std_logic_vector(11 downto 0);
    dm_value        : out std_logic_vector(7 downto 0); -- value that gets pushed on stack, controlled by mux_rf_br_dm
    hold_pc         : out std_logic := '0';
    enable_mux_rf_pc : out std_logic := '0';
    
    -- cotrol stack pointer
    sp_op : out std_logic;
    sp_enable : out std_logic := '0';
    
    -- control mux
    br_sp_enable : out std_logic := '0';
    
    -- control mux 
    mux_alu_dm_select : out std_logic := '0'

    );
end branch_controller;

architecture Behavioral of branch_controller is

signal await_ret : std_logic := '0';
signal stored_pc : std_logic_vector(8 downto 0) := (others => '0');
signal tmp : std_logic_vector(1 downto 0) := (others => '0');

begin
    prc : process(clk)
       variable flag : integer := 0;

    begin
        override_enable <= '0';
        offset <= (others => '0');
        dm_value <= (others => '0');
        sp_op <= '0';
        mux_alu_dm_select <= '0';

            case branch_instr(15 downto 12) is
                -- RCALL 
                when "1101" => 
                    sp_op <= '1';
                    -- step 1                 
                     if tmp = "00" then
                        -- enable sp write and store the pc
                        sp_enable <= '1';
                        br_sp_enable <= '1';
                        stored_pc <= current_pc;
                        enable_mux_rf_pc <= '1'; -- write enable for pc to stack 
                        -- write high byte
                        dm_value <= "0000000"&stored_pc(8);
                        hold_pc <= '1';

                        tmp <= std_logic_vector(unsigned(tmp) + 1);
                    -- step 2
                    elsif tmp = "01" then
                        tmp <= "10";
                        
                        -- write low byte
                        enable_mux_rf_pc <= '1';
                        dm_value <= stored_pc(7 downto 0);
                        
                        -- overwrite pc
                        override_enable <= '1';
                        offset <= branch_instr(11 downto 0);
                        
                        -- decrease sp 
                        sp_enable <= '1';
                        br_sp_enable <= '1';
                        tmp <= std_logic_vector(unsigned(tmp) + 1);
                        
                    -- step 3    
                    elsif tmp = "10" then
                        tmp <= "11";
                        -- keep writing low byte (needed?)
                        enable_mux_rf_pc <= '1';
                        dm_value <= stored_pc(7 downto 0);
                        hold_pc <= '0';
                        override_enable <= '1';
                        offset <= branch_instr(11 downto 0);
                    -- clear
                    else 
                        tmp <= "00";
                        sp_enable <= '0';
                        br_sp_enable <= '0';
                        enable_mux_rf_pc <= '0';
                        stored_pc <= (others => '0');
                        await_ret <= '1';
                    end if;
                
                -- RET
                when "1001" =>
                    -- step 1
                    if tmp = "00" and await_ret = '1' then
                        hold_pc <= '1';
                        -- write enable rf to store pc from dm 
                        -- rf_enable <= '1';
                        -- write dm instead of alu 
                        mux_alu_dm_select <= '1'; --(dec_mux_select_alu_dm)
                        -- sp_op increment
                        br_sp_enable <= '1';
                        sp_enable <= '1';
                        sp_op <= '0';
                                            
                        -- decoder opA sets the rf-address 
                        -- mux_alu_dm_data selects dm instead of alu
                        -- mux_im_rf_data selects previous mux instead of immediate (ddeafult good)

                        tmp <= std_logic_vector(unsigned(tmp) + 1);
                    -- step 2
                    elsif tmp = "01" then
                        tmp <= "10";
                        -- read dm low byte
                        mux_alu_dm_select <= '1';
                        stored_pc(7 downto 0) <= dm_data;
                        
                        -- decrease sp 
                        sp_enable <= '1';
                        br_sp_enable <= '1';
                        tmp <= std_logic_vector(unsigned(tmp) + 1);
                        
                    -- step 3    
                    elsif tmp = "10" then
                        tmp <= "11";
                        -- read dm high byte 
                        mux_alu_dm_select <= '1';
                        stored_pc(8) <= dm_data(0);
                        
                        hold_pc <= '0';
                        
                        -- overwrite pc with loaded pc 
                        override_enable <= '1';
                        offset <= std_logic_vector(resize(signed(stored_pc), 12) - resize(signed(current_pc), 12) );
                    -- clear
                    else 
                        tmp <= "00";
                        sp_enable <= '0';
                        br_sp_enable <= '0';
                        mux_alu_dm_select <= '0';
                        await_ret <= '0';
                    end if;
                
                -- RJMP
                when "1100" =>
                    override_enable <= '1';
                    offset <= branch_instr(11 downto 0);
                                      
                -- BRBS, BRBC    
                when "1111" =>
                    flag := to_integer(unsigned(sreg_status));
                    
                        case branch_instr(11 downto 10) is
                            -- BRBS 
                            when "00" =>
                                if branch_enable = '1' and to_integer(unsigned(branch_instr(2 downto 0))) = flag then
                                    override_enable <= '1';
                                    offset <= "00000"&branch_instr(9 downto 3);
                                end if;
                            when "01" => 
                                if not branch_enable = '1' and to_integer(unsigned(branch_instr(2 downto 0))) = flag then
                                    override_enable <= '1';
                                    offset <= "00000"&branch_instr(9 downto 3);                               
                                end if;                                                          
                            when others => null;
                        end case;
                when others => null;
            end case;
        
       -- end if;		
    end process prc;   

end Behavioral;
