----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.03.2023 15:59:03
-- Design Name: 
-- Module Name: alu - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
  Port (
    opcode      : in std_logic_vector(3 downto 0);
    opa         : in std_logic_vector(7 downto 0);
    opb         : in std_logic_vector(7 downto 0);
    status_in   : in std_logic_vector(7 downto 0); 
    
    res                 : out std_logic_vector(7 downto 0);
    status_out          : out std_logic_vector(7 downto 0);
    branch_test_result  : out std_logic
  );
end alu;

architecture Behavioral of alu is
  signal Z      : std_logic := '0'; -- Zero Flag
  signal C      : std_logic := '0'; -- Carry Flag
  signal V      : std_logic := '0'; -- Overflow Flag
  signal N      : std_logic := '0'; -- negative flag
  signal S      : std_logic := '0'; -- sign flag
  signal ERG    : std_logic_vector(7 downto 0);
begin

  calc: process (opa, opb, opcode, status_in)
  begin
    ERG <= "00000000";  -- prevent latches
    branch_test_result <= '0';
    case opcode is
      -- ADD --> Addition
      when op_add =>
        ERG <= std_logic_vector(unsigned(opa) + unsigned(opb));
      -- SUB
      when op_sub =>
        ERG <= std_logic_vector(unsigned(opa) - unsigned(opb));
      -- OR
      when op_or =>
        ERG <= opa or opb;
      
      --ADC and ROL
      when op_adc =>
        ERG <= std_logic_vector(unsigned(opa) + unsigned(opb) + unsigned((status_in and "00000001")));
        
      when op_and =>
        ERG <= opa and opb;
        
      when op_eor =>
        ERG <= opa xor opb;
        
      when op_mov =>
        ERG <= opb;
        
      when op_brbs =>
        ERG <= status_in AND opb;
        branch_test_result <= (opb(7) AND status_in(7)) or 
                       (opb(6) AND status_in(6)) or 
                       (opb(5) AND status_in(5)) or 
                       (opb(4) AND status_in(4)) or 
                       (opb(3) AND status_in(3)) or 
                       (opb(2) AND status_in(2)) or 
                       (opb(1) AND status_in(1)) or 
                       (opb(0) AND status_in(0));
        
      when op_brbc =>
        ERG <= (not status_in) AND opb;
        branch_test_result <= (opb(7) AND not status_in(7)) or 
                       (opb(6) AND not status_in(6)) or 
                       (opb(5) AND not status_in(5)) or 
                       (opb(4) AND not status_in(4)) or 
                       (opb(3) AND not status_in(3)) or 
                       (opb(2) AND not status_in(2)) or 
                       (opb(1) AND not status_in(1)) or 
                       (opb(0) AND not status_in(0));
      
      when op_com =>
        ERG <= std_logic_vector(255 - unsigned(opa));
      
      when op_asr =>
        ERG <= std_logic_vector(shift_right(signed(opa), 1));
      
      when op_lsr =>
        ERG <= std_logic_vector(shift_right(unsigned(opa), 1));
      
      when others => null;
    end case;
  end process calc;


  CALC_SREG: process (opa, opb, OPCODE, ERG)
  begin
    Z <= (NOT ERG(7) AND NOT ERG(6) AND NOT ERG(5) AND NOT ERG(4) AND NOT ERG(3) AND NOT ERG(2) AND NOT ERG(1) AND NOT ERG(0));
    N <= ERG(7);

    C <= '0'; -- prevent latches
    V <= '0';
    
    case OPCODE is
      -- ADD
      when op_add =>
        C<=(opa(7) AND opb(7)) OR (opb(7) AND (not ERG(7))) OR ((not ERG(7)) AND opa(7));
        V<=(opa(7) AND opb(7) AND (not ERG(7))) OR ((not opa(7)) and (not opb(7)) and  ERG(7));

      -- SUB
      when op_sub =>
        C<=(not opa(7) and opb(7)) or (opb(7) and ERG(7)) or (not opa(7) and ERG(7));
        V<=(opa(7) and not opb(7) and not ERG(7)) or (not opa(7) and opb(7) and ERG(7));

      -- OR
      when op_or =>
        C<='0';
        V<='0';

      --ADC and ROL
      when op_adc =>
        --h?
        C <= (opa(7) and opb(7)) or (opb(7) and not ERG(7)) or (not ERG(7) and opa(7));
        V <= (opa(7) and opb(7) and not ERG(7)) or (not opa(7) and not opb(7) and ERG(7));
        
      when op_and =>
        V <= '0';
        
      when op_eor =>
        V <= '0';
      
      when op_com =>
        V <= '0';
        C <= '1';
      
      when op_asr =>
        C <= opa(0);
        V <= ERG(7) xor opa(0);    
      
      when op_lsr =>
        V <= '0' xor opa(0);
        C <= opa(0);
      
      when others => null;
    end case;
    
  end process CALC_SREG;  

  S <= V xor N;
  res <= ERG;
  status_out <= '0' & '0' & '0' & S & V & N & Z & C;

end Behavioral;
