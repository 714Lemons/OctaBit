----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.03.2023 15:08:08
-- Design Name: 
-- Module Name: decoder - Behavioral
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

library work;
use work.pkg_processor.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder is
  Port (
    instr : in std_logic_vector(15 downto 0);

    addr_opa    : out std_logic_vector(4 downto 0);   
    addr_opb    : out std_logic_vector(4 downto 0);  
    alu_op_code : out std_logic_vector(3 downto 0);   
    dbg_op_code : out std_logic_vector(7 downto 0);     -- debugging Port
    w_e_rf      : out std_logic;                     
    w_e_sreg    : out std_logic_vector(7 downto 0); 

    rf_immediate        : out std_logic;
    alu_immediate       : out std_logic;
    immediate_value     : out std_logic_vector(7 downto 0) := (others => '0');
    w_e_dm              : out std_logic;
    mux_alu_dm_select   : out std_logic;
    pc_override         : out std_logic;
    pc_override_offset  : out std_logic_vector(11 downto 0);
    sreg_override       : out std_logic;
    sreg_override_value : out std_logic_vector(7 downto 0);
    sp_op               : out std_logic;        --stackpointer operation type (increment(1) or decrement(0))
    sp_addr_enable      : out std_logic;
    
    br_instr    : out std_logic_vector(15 downto 0);
    br_enable   : out std_logic

   );
end decoder;

architecture Behavioral of decoder is
    signal OP_CODE : std_logic_vector(3 downto 0);
begin

    dec_mux: process (Instr)
    begin  -- process dec_mux

        -- Vorzuweisung der Signale, um Latches zu verhindern
        addr_opa <= "00000";
        addr_opb <= "00000";
        alu_op_code <= (others=>('0'));
        w_e_rf <= '0';
        w_e_SREG <= "00000000";
        rf_immediate <= '0';
        alu_immediate <= '0';
        dbg_op_code <= op_NOP&"0000";
        immediate_value <= (others => '0');
        w_e_dm <= '0';
        mux_alu_dm_select <= '0';
        pc_override_offset <= (others => '0');
        OP_CODE <= (others => '0');
        sreg_override <= '0';
        sreg_override_value <= (others => '0');
        pc_override <= '0';
        sp_op <= '0';
        sp_addr_enable <= '0';
        br_enable <= '0';
        br_instr <= (others => '0');

        --6bit codes
        case Instr(15 downto 10) is
            -- ADD, LSL
            when "000011" =>
                addr_opa <= Instr(8 downto 4);
                addr_opb <= Instr(9) & Instr (3 downto 0);
                alu_op_code <= op_add;
                w_e_rf <= '1';
                w_e_SREG <= "00111111";
                dbg_op_code <= "0000"&op_add;



            when others =>

                --16bits codes
                case Instr(15 downto 0) is
                    --SEC
                    when "1001010000001000" =>
                        sreg_override <= '1';
                        sreg_override_value <= "00000001";
                        w_e_SREG <= "00000001";
                        dbg_op_code <= op_sec;

                    --CLC
                    when "1001010010001000" =>
                        sreg_override <= '1';
                        sreg_override_value <= "00000000";
                        w_e_SREG <= "00000001";
                        dbg_op_code <= op_clc;

                    --RET    
                    when "1001010100001000" =>
                        dbg_op_code <= op_ret;
                        --w_e_dm <= '1';
                        --dbg_op_code <= op_push;
                        --sp_op <= '1';      --dec the stackpointer
                        --sp_addr_enable <= '1';
                        
                        
                        br_instr <= Instr(15 downto 0);
                        br_enable <= '1';
                        

                    when others => null;
                end case;

                --4bit codes
                case Instr(15 downto 12) is

                    -- SUB, CP, ROL, ADC
                    when "0001" =>
                        addr_opa <= Instr(8 downto 4);
                        addr_opb <= Instr(9) & Instr (3 downto 0);
                        case Instr(11 downto 10) is
                            --CP
                            when "01" =>
                                alu_op_code <= op_sub;
                                dbg_op_code <= "0000"&op_sub;
                            --SUB
                            when "10" =>
                                alu_op_code <= op_sub;
                                dbg_op_code <= "0000"&op_sub;
                            --ROLL, ADC
                            when "11" =>
                                alu_op_code <= op_adc;
                                dbg_op_code <= "0000"&op_adc;
                            when others => null;
                        end case;

                        --CP does not need to write to RF
                        if not(Instr(11 downto 10) = "01") then
                            w_e_rf <= '1';
                        end if;
                        w_e_SREG <= "00111111";


                    --bitwise logic: AND, OR, EOR. and MOV
                    when "0010" =>
                        addr_opa <= Instr(8 downto 4);
                        addr_opb <= Instr(9) & Instr (3 downto 0);
                        w_e_rf <= '1';

                        case Instr(11 downto 10) is
                            --AND
                            when "00" =>
                                alu_op_code <= op_and;
                                dbg_op_code <= "0000"&op_and;

                            --EOR
                            when "01" =>
                                alu_op_code <= op_eor;
                                dbg_op_code <= "0000"&op_eor;

                            --OR
                            when "10" =>
                                alu_op_code <= op_or;
                                dbg_op_code <= "0000"&op_or;

                            --MOV
                            when "11" =>
                                dbg_op_code <= "0000"&op_mov;
                                alu_op_code <= op_mov;


                            when others => null;
                        end case;

                        --SREG controll: AND, EOR and OR change the SREG and the RegFile. MOV changes the RegFile but not the SREG
                        if not (Instr(11 downto 10)="11") then
                            w_e_SREG <= "00011110"; --AND, EOR, OR
                        else
                            w_e_SREG <= "00000000"; --MOV
                        end if;

                    --LDI
                    when "1110" =>
                        addr_opa <= '1' & Instr(7 downto 4);
                        immediate_value <= Instr(11 downto 8) & Instr(3 downto 0);
                        w_e_rf <= '1';
                        dbg_op_code <= op_ldi;
                        rf_immediate <= '1';

                    --CPI
                    when "0011" =>
                        addr_opa <= '1' & Instr(7 downto 4);
                        immediate_value <= Instr(11 downto 8) & Instr(3 downto 0);
                        alu_immediate <= '1';
                        alu_op_code <= op_sub;
                        w_e_SREG <= "00111111";
                        dbg_op_code <= "0000"&op_sub;


                    --SUBI
                    when "0101" =>
                        addr_opa <= '1' & Instr(7 downto 4);
                        immediate_value <= Instr(11 downto 8) & Instr(3 downto 0);
                        alu_immediate <= '1';
                        alu_op_code <= op_sub;
                        w_e_SREG <= "00111111";
                        w_e_rf <= '1';
                        dbg_op_code <= "0000"&op_sub;

                    --ORI
                    when "0110" =>
                        addr_opa <= '1' & Instr(7 downto 4);
                        immediate_value <= Instr(11 downto 8) & Instr(3 downto 0);
                        alu_immediate <= '1';
                        alu_op_code <= op_or;
                        w_e_SREG <= "00011110";
                        w_e_rf <= '1';
                        dbg_op_code <= "0000"&op_or;

                    --ANDI
                    when "0111" =>
                        addr_opa <= '1' & Instr(7 downto 4);
                        immediate_value <= Instr(11 downto 8) & Instr(3 downto 0);
                        alu_immediate <= '1';
                        alu_op_code <= op_and;
                        w_e_SREG <= "00011110";
                        w_e_rf <= '1';
                        dbg_op_code <= "0000"&op_and;


                    --ST,LD (Store and Load)
                    when "1000" =>
                        case Instr(11 downto 9) is

                            --load
                            when "000" =>
                                dbg_op_code <= op_ld;
                                w_e_rf <= '1';
                                mux_alu_dm_select <= '1';
                                addr_opa <= Instr(8 downto 4);

                            -- store
                            when "001" =>
                                w_e_dm <= '1';
                                dbg_op_code <= op_st;
                                addr_opa <= Instr(8 downto 4);

                            when others => null;
                        end case;

                    -- BRBS, BRBC    
                    when "1111" =>
                        case Instr(11 downto 10) is
                            --BRBS
                            when "00" =>
                                alu_op_code <= op_nop;
                                OP_CODE <= op_nop;
                                
                                br_instr <= Instr(15 downto 0);
                                br_enable <= '1';

                            --BRBC
                            when "01" =>
                                dbg_op_code <= "0000"&op_brbc;
                                alu_op_code <= op_brbc;
                                OP_CODE <= op_brbc;
                                alu_immediate <= '1';
                                immediate_value <= "00000"&Instr(2 downto 0);    --00000sss  
                                pc_override_offset <= "00000"&Instr(9 downto 3);

                            when others => null;
                        end case;

                    --COM,ASR,DEC,INC,LSR,PUSH,POP        
                    when "1001" =>
                        case Instr(11 downto 9) is

                            --PUSH
                            when "001" =>
                                addr_opa <= Instr(8 downto 4);
                                w_e_dm <= '1';
                                dbg_op_code <= op_push;
                                sp_op <= '1';      --dec the stackpointer
                                sp_addr_enable <= '1';

                            --POP
                            when "000" =>
                                addr_opa <= Instr(8 downto 4);
                                dbg_op_code <= op_pop;
                                w_e_rf <= '1';
                                mux_alu_dm_select<= '1';
                                sp_op <= '0';      --inc the stackpointer
                                sp_addr_enable <= '1';


                            --COM, ASR, DEC, INC, LSR
                            when "010" =>
                                case Instr(3 downto 0) is
                                    --COM
                                    when "0000" =>
                                        addr_opa <= Instr(8 downto 4);
                                        alu_op_code <= op_com;
                                        dbg_op_code <= "0000"&op_com;
                                        w_e_SREG <= "00010111";
                                        w_e_rf <= '1';

                                    --ASR
                                    when "0101" =>
                                        addr_opa <= Instr(8 downto 4);
                                        alu_op_code <= op_asr;
                                        w_e_rf <= '1';
                                        w_e_SREG <= "00011111";
                                        dbg_op_code <= "0000"&op_asr;


                                    --DEC
                                    when "1010" =>
                                        addr_opa <= Instr(8 downto 4);
                                        alu_immediate <= '1';
                                        immediate_value <= "00000001";
                                        alu_op_code <= op_sub;
                                        w_e_rf <= '1';
                                        w_e_SREG <= "00011110";
                                        dbg_op_code <= "0000"&op_sub;

                                    --INC
                                    when "0011" =>
                                        addr_opa <= Instr(8 downto 4);
                                        alu_immediate <= '1';
                                        immediate_value <= "00000001";
                                        alu_op_code <= op_add;
                                        w_e_rf <= '1';
                                        w_e_SREG <= "00011110";
                                        dbg_op_code <= "0000"&op_add;


                                    --LSR
                                    when "0110" =>
                                        addr_opa <= Instr(8 downto 4);
                                        alu_op_code <= op_lsr;
                                        dbg_op_code <= "0000"&op_lsr;
                                        w_e_rf <= '1';
                                        w_e_SREG <= "00011111";

                                    when others => null;
                                end case;
                            when others => null;
                        end case;

                    --RJMP
                    when "1100" =>
                        --pc_override_offset <= Instr(11 downto 0);
                        --dbg_op_code <= op_rjmp;
                        --pc_override <= '1';
                        
                        br_instr <= Instr(15 downto 0);
                        br_enable <= '1';

                    --RCALL
                    when "1101" =>
                        --dbg_op_code <= op_nop;
                        --pc_override_offset <= Instr(11 downto 0);
                        --alu_op_code <= op_nop;
                        --OP_CODE <= op_nop;
                        
                        -- save pc + 1 on stack:
                        --addr_opa <= Instr(8 downto 4);
                        w_e_dm <= '1';
                        dbg_op_code <= op_push;
                        --sp_op <= '1';      --dec the stackpointer
                        sp_addr_enable <= '1';
                        
                        
                        br_instr <= Instr(15 downto 0);
                        br_enable <= '1';
                        
                    when others => null;
                end case;
        end case;
    end process dec_mux;

end Behavioral;
