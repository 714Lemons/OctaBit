library ieee;
use ieee.std_logic_1164.all;
-- ---------------------------------------------------------------------------------
-- Memory initialisation package
-- ---------------------------------------------------------------------------------
package pkg_instrmem is

	type t_instrMem   is array(0 to 512-1) of std_logic_vector(15 downto 0);
	constant PROGMEM : t_instrMem := (
		"0000000000000000",
		"1110010000000101",
		"1110010100010110",
		"1001001100001111",
		"1001001100011111",
		"1001000101001111",
		"1001000101011111",
		"0000000000000000",
		
		others => (others => '0')
	);

end package pkg_instrmem;
