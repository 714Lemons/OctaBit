library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pkg_processor is

-- ALU op_code_in
    constant op_add : std_logic_vector(3 downto 0) := "0000";  -- Addition (opA = opA + opB)
    constant op_nop : std_logic_vector(3 downto 0) := "0000";  --NoOperation. wird als add implementiert. ergebnis wird nicht gespeichert
    constant op_sub : std_logic_vector(3 downto 0) := "0001";  -- Subtraction
    constant op_or : std_logic_vector(3 downto 0) := "0010";  -- bitwise OR

    --my own op code defines
    constant op_adc     : std_logic_vector(3 downto 0) := "0011";               --ADC, ROL
    constant op_and     : std_logic_vector(3 downto 0) := "0100";               --bitwise and
    constant op_eor     : std_logic_vector(3 downto 0) := "0101";               --bitwise xor
    constant op_mov     : std_logic_vector(3 downto 0) := "0110";               --copy registerA to registerB
    constant op_brbs    : std_logic_vector(3 downto 0) := "0111";               --Branch when bit set
    constant op_brbc    : std_logic_vector(3 downto 0) := "1000";               --Branch when bit clear
    constant op_asr     : std_logic_vector(3 downto 0) := "1001";               --arithmatic shift right
    constant op_com     : std_logic_vector(3 downto 0) := "1010";               --one complement
    constant op_lsr     : std_logic_vector(3 downto 0) := "1011";               --logical shift right 
  
  
  --------------------------------------------------------------------------------
  
  -- All Op Codes (does not go in the ALU)
    constant op_ldi     : std_logic_vector(7 downto 0) := "0001" & "0000";      -- Load signal
    constant op_st      : std_logic_vector(7 downto 0) := "0010" & "0000";      -- store
    constant op_ld      : std_logic_vector(7 downto 0) := "0011" & "0000";      -- load
    constant op_sec     : std_logic_vector(7 downto 0) := "0100" & "0000";      -- Set Carry bit
    constant op_clc     : std_logic_vector(7 downto 0) := "0101" & "0000";      -- Clear Carry bit
    constant op_rjmp    : std_logic_vector(7 downto 0) := "0110" & "0000";      -- relative jump 
    constant op_push    : std_logic_vector(7 downto 0) := "0111" & "0000";      -- push register on stack
    constant op_pop     : std_logic_vector(7 downto 0) := "1000" & "0000";      -- pop a value from stack to register file
    constant op_ret     : std_logic_vector(7 downto 0) := "1001" & "0000";      -- return from subroutine
    constant op_rcall   : std_logic_vector(7 downto 0) := "1010" & "0000";      -- relative call of subroutine
    
        -- IO Flags
    constant PORT_D_IN_ADDRES         : STD_LOGIC_VECTOR (9 downto 0) := STD_LOGIC_VECTOR(to_unsigned(16#30#,10)); --0x30
    constant PORT_C_IN_ADDRES         : STD_LOGIC_VECTOR (9 downto 0) := STD_LOGIC_VECTOR(to_unsigned(16#33#,10)); --0x33
    constant PORT_B_IN_ADDRES         : STD_LOGIC_VECTOR (9 downto 0) := STD_LOGIC_VECTOR(to_unsigned(16#36#,10)); --0x36
    constant PORT_C_OUT_ADDRES        : STD_LOGIC_VECTOR (9 downto 0) := STD_LOGIC_VECTOR(to_unsigned(16#35#,10)); --0x35
    constant PORT_B_OUT_ADDRES        : STD_LOGIC_VECTOR (9 downto 0) := STD_LOGIC_VECTOR(to_unsigned(16#38#,10)); --0x38
    constant SEGMENT_ENABLE_ADDRES    : STD_LOGIC_VECTOR (9 downto 0) := STD_LOGIC_VECTOR(to_unsigned(16#40#,10)); --0x40
    constant SEGMENT_0_ADDRES         : STD_LOGIC_VECTOR (9 downto 0) := STD_LOGIC_VECTOR(to_unsigned(16#41#,10)); 
    constant SEGMENT_1_ADDRES         : STD_LOGIC_VECTOR (9 downto 0) := STD_LOGIC_VECTOR(to_unsigned(16#42#,10)); 
    constant SEGMENT_2_ADDRES         : STD_LOGIC_VECTOR (9 downto 0) := STD_LOGIC_VECTOR(to_unsigned(16#43#,10)); 
    constant SEGMENT_3_ADDRES         : STD_LOGIC_VECTOR (9 downto 0) := STD_LOGIC_VECTOR(to_unsigned(16#44#,10)); 
    
    --SEGMENT STATE
    constant SEGMENT_ALL_OFF    : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant SEGMENT_0          : STD_LOGIC_VECTOR(3 downto 0) := "0001";
    constant SEGMENT_1          : STD_LOGIC_VECTOR(3 downto 0) := "0010";
    constant SEGMENT_2          : STD_LOGIC_VECTOR(3 downto 0) := "0100";
    constant SEGMENT_3          : STD_LOGIC_VECTOR(3 downto 0) := "1000";

end pkg_processor;
