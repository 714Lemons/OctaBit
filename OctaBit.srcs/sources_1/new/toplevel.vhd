----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.03.2023 10:59:50
-- Design Name: 
-- Module Name: toplevel - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity toplevel is
    -- global ports
    Port (
    clk  : in STD_LOGIC;
    sw   : in std_logic_vector(15 downto 0);
    btnU : in STD_LOGIC;
    btnD : in STD_LOGIC;
    btnL : in STD_LOGIC;
    btnR : in STD_LOGIC;
    btnC : in std_logic;
    
    
    led  : out std_logic_vector(15 downto 0) := (others => '1');
    seg  : out std_logic_vector(6 downto 0) := (others => '1');
    an   : out std_logic_vector(3 downto 0) := (others => '0');
    dp   : out std_logic := '1'
         );
         
end toplevel;

architecture Behavioral of toplevel is

-- _________________________________________ SIGNALS _________________________________________________

-- CPU
signal cpu_reset: std_logic;

-- Program Counter (PC)
signal pc_pm_addr: std_logic_vector(8 downto 0); -- addresss for program memory instruction

-- Program Memory (PM)
signal pm_instr_out: std_logic_vector(15 downto 0); -- instruction for decoder

-- Decoder
signal dec_rf_addr_opA          : std_logic_vector(4 downto 0);
signal dec_rf_addr_opB          : std_logic_vector(4 downto 0);
signal dec_alu_op_code          : std_logic_vector(3 downto 0);
signal dec_rf_write_enable      : std_logic;
signal dec_sreg_write_enable    : std_logic_vector(7 downto 0);
signal dec_rf_immediate         : std_logic;
signal dec_alu_immediate        : std_logic;
signal dec_immediate_value      : std_logic_vector(7 downto 0);
signal dec_dm_write_enable      : std_logic;
signal dec_mux_select_alu_dm    : std_logic;
signal dec_pc_override_enable   : std_logic;
signal dec_pc_override_offset   : std_logic_vector(11 downto 0);
signal dec_sreg_override_enable : std_logic;
signal dec_sreg_override_value  : std_logic_vector(7 downto 0);
signal dec_sp_op                : std_logic;
signal dec_sp_enable            : std_logic;
signal dec_br_instr             : std_logic_vector(15 downto 0);
signal dec_br_enable            : std_logic;

-- decoder pipeline
signal pip_dec_rf_addr_opA          : std_logic_vector(4 downto 0);
signal pip_dec_rf_addr_opB          : std_logic_vector(4 downto 0);
signal pip_dec_alu_op_code          : std_logic_vector(3 downto 0);
signal pip_dec_rf_write_enable      : std_logic;
signal pip_dec_sreg_write_enable    : std_logic_vector(7 downto 0);
signal pip_dec_rf_immediate         : std_logic;
signal pip_dec_alu_immediate        : std_logic;
signal pip_dec_immediate_value      : std_logic_vector(7 downto 0);
signal pip_dec_dm_write_enable      : std_logic;
signal pip_dec_mux_select_alu_dm    : std_logic;
signal pip_dec_pc_override_enable   : std_logic;
signal pip_dec_pc_override_offset   : std_logic_vector(11 downto 0);
signal pip_dec_sreg_override_enable : std_logic;
signal pip_dec_sreg_override_value  : std_logic_vector(7 downto 0);
signal pip_dec_sp_op                : std_logic;
signal pip_dec_sp_enable            : std_logic;
-- br 
signal pip_br_dm_value             : std_logic_vector(7 downto 0);
signal pip_br_sp_op                : std_logic;
signal pip_br_sp_enable            : std_logic;
signal pip_mux_br_sp_enable        : std_logic;
signal pip_br_mux_alu_dm_select    : std_logic;
signal pip_br_sp_op_code : std_logic;
signal pip_br_mux_rf_br_enable       : std_logic;

signal pip_br_mux_z_br_value : std_logic_vector(7 downto 0);
signal pip_br_mux_select_alu_dm : std_logic;

-- Register File (RF)
signal rf_alu_opA : std_logic_vector(7 downto 0);
signal rf_alu_opB : std_logic_vector(7 downto 0);

-- Arithmetic Logical Unit (ALU)
signal alu_mux_dm_out   : std_logic_vector(7 downto 0);
signal alu_sreg_status  : std_logic_vector(7 downto 0);

-- Status Register (SREG)
signal sreg_alu_status : std_logic_vector(7 downto 0);

-- Branch Controller 
signal br_pc_offset             : std_logic_vector(11 downto 0); -- 7?
signal br_pc_override_enable    : std_logic;
signal br_pc_hold               : std_logic;
signal br_mux_z_br_value        : std_logic_vector(7 downto 0);
signal br_mux_select_alu_dm     : std_logic;

-- mx_rf_br
-- for controlling if rf or pc from branch controller
signal br_mux_rf_br_enable       : std_logic;

signal mux_br_sp_enable : std_logic;
signal br_sp_enable : std_logic;
signal br_sp_op_code : std_logic;


-- Z-Address
signal dm_z_addr                    : std_logic_vector(9 downto 0);
signal z_data_src_bus               : std_logic_vector(1 downto 0);
signal z_addr_r31_we, z_addr_r30_we : std_logic := '0';
signal z_addr_out                   : std_logic_vector (9 downto 0);
signal z_data_in                    : std_logic_vector (7 downto 0);

-- Stackpointer
signal sp_dm_addr : std_logic_vector(9 downto 0);

-- Data Memory (DM)
signal dm_mux_data_out : std_logic_vector(7 downto 0);

-- Memeory Mapped Input/Output
signal io_ser           : std_logic_vector(7 downto 0);
signal io_seg0          : std_logic_vector(7 downto 0);
signal io_seg1          : std_logic_vector(7 downto 0);
signal io_seg2          : std_logic_vector(7 downto 0);
signal io_seg3          : std_logic_vector(7 downto 0);
signal port_for_btns    : std_logic_vector(7 downto 0);

-- MUX ALU-DM
signal mux_alu_dm_data : std_logic_vector(7 downto 0);

-- MUX Immediate RF
signal mux_im_rf_data : std_logic_vector(7 downto 0);

-- MUX RF-DEC 
signal mux_rf_dec_alu_opB : std_logic_vector(7 downto 0);

-- MUX BR-RF to dm
signal mux_rf_br_dm : std_logic_vector(7 downto 0);

-- MUX BR-DEC to sp 
signal mux_dec_br_sp_enable : std_logic;
signal mux_dec_br_sp_op_code : std_logic;


-- Pipelines
-- PIP Fetch 
signal pip_fetch_pm_out : std_logic_vector(15 downto 0);

-- PIP Decode 

-- PIP Execute 

-- _________________________________________ COMPONENTS _________________________________________________

component program_counter is
    port (
    reset           : in std_logic;
    clk             : in std_logic;
    override_enable : in std_logic;
    offset          : in std_logic_vector(11 downto 0);
    hold            : in std_logic;
    
    addr            : out std_logic_vector(8 downto 0)
    );
end component;

component program_memory is 
    port (
    addr    : in std_logic_vector(8 downto 0);
    
    instr   : out std_logic_vector(15 downto 0)
    );
end component;

component pip_fetch is
    port (
    clk     : in std_logic;
    reset   : in std_logic;
    pm_in   : in std_logic_vector(15 downto 0);
    
    pip_pm_out : out std_logic_vector(15 downto 0) 
    );
end component;

component decoder is
    port (
    instr               : in std_logic_vector(15 downto 0);
    
    addr_opa            : out std_logic_vector(4 downto 0);
    addr_opb            : out std_logic_vector(4 downto 0);
    alu_op_code         : out std_logic_vector(3 downto 0);
    w_e_rf              : out std_logic;
    w_e_sreg            : out std_logic_vector(7 downto 0);
    rf_immediate        : out std_logic;
    alu_immediate       : out std_logic;
    immediate_value     : out std_logic_vector(7 downto 0) := (others => '0');
    w_e_dm              : out std_logic;
    mux_alu_dm_select   : out std_logic;
    
    sreg_override       : out std_logic;
    sreg_override_value : out std_logic_vector(7 downto 0);
    sp_op               : out std_logic;
    sp_addr_enable      : out std_logic;
    
    dbg_op_code         : out std_logic_vector(7 downto 0);
    
    -- branching 
    br_instr    : out std_logic_vector(15 downto 0);
    br_enable   : out std_logic
    );
end component;

component pip_decode is
    port (
    -- after: br, decoder
    -- before: sreg, dm, rf, memory_mapped, seg_view_controller, sp, alu 
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
    dec_pc_override_enable   : in std_logic;
    dec_pc_override_offset   : in std_logic_vector(11 downto 0);
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
    pip_dec_pc_override_enable   : out std_logic;
    pip_dec_pc_override_offset   : out std_logic_vector(11 downto 0);
    pip_dec_sreg_override_enable : out std_logic;
    pip_dec_sreg_override_value  : out std_logic_vector(7 downto 0);
    pip_dec_sp_op                : out std_logic;
    pip_dec_sp_enable            : out std_logic;
    
    -- br:
    -- dm_value, enable_mux_rf_pc -> mux_rf_br_dm
    -- override_enable, offset, hold_pc -> feed forward? direct?
    -- sp_op, sp_enable, br_sp_enable, mux_alu_dm_select
    pip_br_mux_z_br_value        : in std_logic_vector(7 downto 0);
    pip_br_mux_select_alu_dm     : in std_logic;
    pip_br_mux_rf_br_enable      : in std_logic;
    pip_mux_br_sp_enable         : in std_logic;
    pip_br_sp_op_code            : in std_logic;
    pip_br_sp_enable             : in std_logic
        
    );

end component;

component register_file is
    port (
    clk         : in std_logic;
    addr_opa    : in std_logic_vector(4 downto 0);
    addr_opb    : in std_logic_vector(4 downto 0);
    write_addr  : in std_logic_vector(4 downto 0);
    w_e_rf      : in std_logic;
    data_in     : in std_logic_vector(7 downto 0);
    
    data_opa    : out std_logic_vector(7 downto 0);
    data_opb    : out std_logic_vector(7 downto 0)
    );
end component;

component alu is 
    port (
    opcode     : in std_logic_vector(3 downto 0);
    opa        : in std_logic_vector(7 downto 0);
    opb        : in std_logic_vector(7 downto 0);
    status_in  : in std_logic_vector(7 downto 0);
    
    res        : out std_logic_vector(7 downto 0);
    status_out : out std_logic_vector(7 downto 0);
    branch_test_result : out std_logic
    );
end component;

component status_registry is
    port (
    clk             : in std_logic;
    reset           : in std_logic;
    w_e_sreg        : in std_logic_vector(7 downto 0);
    status_in       : in std_logic_vector(7 downto 0);
    override        : in std_logic;
    override_value  : in std_logic_vector(7 downto 0);
    
    status_out      : out std_logic_vector(7 downto 0)
    );
end component;

component branch_controller is
    port (
    clk             : in std_logic;
    reset           : in std_logic;
    sreg_status     : in std_logic_vector(7 downto 0);
    branch_instr    : in std_logic_vector(15 downto 0); -- from decoder
    branch_enable   : in std_logic;
    current_pc      : in std_logic_vector(8 downto 0);
   -- rf_data_opa     : in std_logic_vector(7 downto 0); -- for ret
    
    dm_data         : in std_logic_vector(7 downto 0);
    
    -- out to pc
    override_enable     : out std_logic; 
    offset              : out std_logic_vector(11 downto 0);
    dm_value            : out std_logic_vector(7 downto 0);
    hold_pc             : out std_logic;
    enable_mux_rf_pc    : out std_logic;
    sp_op               : out std_logic;
    sp_enable           : out std_logic;
    
    --rf_enable           : out std_logic;
    mux_alu_dm_select   : out std_logic;
    
    -- mux sp 
    br_sp_enable : out std_logic
    );
end component;


component z_address is
    port (
    clk             : in std_logic;
    reset           : in std_logic;
    rf_addr_r30     : in std_logic;
    rf_addr_r31     : in std_logic;
    z_addr_value    : in std_logic_vector(7 downto 0);
    
    z_addr_out      : out std_logic_vector(9 downto 0)
    );
end component;

component stackpointer is
    port (
    clk         : in std_logic;
    reset       : in std_logic;
    op_code     : in std_logic;
    enable_sp   : in std_logic;
    
    addr        : out std_logic_vector(9 downto 0)
    );
end component;


component data_memory_1024B is 
    port (
    clk          : in std_logic;
    write_enable : in std_logic;
    z_addr       : in std_logic_vector(9 downto 0);
    z_data_in    : in std_logic_vector(7 downto 0);
    
    data         : out std_logic_vector(7 downto 0) 
    );
end component;

component mem_mapped_io
    port (
    clk             : in std_logic;
    write_enable    : in std_logic;
    data            : in std_logic_vector(7 downto 0);
    z_addr          : in std_logic_vector(9 downto 0);
    pinb_in         : in std_logic_vector(7 downto 0);
    pinc_in         : in std_logic_vector(7 downto 0);
    pind_in         : in std_logic_vector(7 downto 0);
    
    portb           : out std_logic_vector(7 downto 0);
    portc           : out std_logic_vector(7 downto 0);
    io_addr         : out std_logic;
    ser             : out std_logic_vector(7 downto 0);
    seg0            : out std_logic_vector(7 downto 0);
    seg1            : out std_logic_vector(7 downto 0);
    seg2            : out std_logic_vector(7 downto 0);
    seg3            : out std_logic_vector(7 downto 0)
    );
end component;

component seg_view_controller
    Port ( 
    clk     : in std_logic;
    reset   : in std_logic;
    ser     : in std_logic_vector(7 downto 0);
    seg0    : in std_logic_vector(7 downto 0);
    seg1    : in std_logic_vector(7 downto 0);
    seg2    : in std_logic_vector(7 downto 0);
    seg3    : in std_logic_vector(7 downto 0);
    
    seg     : out std_logic_vector(6 downto 0);
    an      : out std_logic_vector(3 downto 0);
    db      : out std_logic 
);
end component;

-- _________________________________________ Port Mapping _________________________________________________

begin

pc: program_counter
port map(
    -- in:
    reset               => cpu_reset,
    clk                 => clk,
    override_enable     => br_pc_override_enable,
    offset              => br_pc_offset,
    hold                => br_pc_hold,
    
    -- out: 
    addr => pc_pm_addr
);

pm: program_memory
port map(
    -- in:
    addr => pc_pm_addr,
    
    -- out:
    instr => pm_instr_out
);

pip_fetch_reg: pip_fetch
port map(
    clk => clk,
    reset => cpu_reset,
    pm_in => pm_instr_out,
    
    pip_pm_out => pip_fetch_pm_out
);

dec: decoder
port map(
    -- in:
    instr => pip_fetch_pm_out,
    
    -- out:
    addr_opa            => dec_rf_addr_opA,
    addr_opb            => dec_rf_addr_opB,
    alu_op_code         => dec_alu_op_code,
    w_e_rf              => dec_rf_write_enable,
    w_e_sreg            => dec_sreg_write_enable,
    rf_immediate        => dec_rf_immediate,
    alu_immediate       => dec_alu_immediate,
    immediate_value     => dec_immediate_value,
    w_e_dm              => dec_dm_write_enable,
    mux_alu_dm_select   => dec_mux_select_alu_dm,
    sreg_override       => dec_sreg_override_enable,
    sreg_override_value => dec_sreg_override_value,

    sp_op               => dec_sp_op,
    sp_addr_enable      => dec_sp_enable,
    dbg_op_code         => open,
    
    -- branching
    br_instr            => dec_br_instr,
    br_enable           => dec_br_enable
    
);

pip_dec: pip_decode
port map(
    -- in:
    clk => clk,
    dec_rf_addr_opA          => dec_rf_addr_opA,
    dec_rf_addr_opB          => dec_rf_addr_opB,
    dec_alu_op_code          => dec_alu_op_code,
    dec_rf_write_enable      => dec_rf_write_enable,
    dec_sreg_write_enable    => dec_sreg_write_enable, 
    dec_rf_immediate         => dec_rf_immediate,
    dec_alu_immediate        => dec_alu_immediate,
    dec_immediate_value      => dec_immediate_value,
    dec_dm_write_enable      => dec_dm_write_enable,
    dec_mux_select_alu_dm    => dec_mux_select_alu_dm,
    dec_pc_override_enable   => dec_pc_override_enable,
    dec_pc_override_offset   => dec_pc_override_offset,
    dec_sreg_override_enable => dec_sreg_override_enable,
    dec_sreg_override_value  => dec_sreg_override_value,
    dec_sp_op                => dec_sp_op,
    dec_sp_enable            => dec_sp_enable,
    
    -- br:
    -- dm_value, enable_mux_rf_pc -> mux_rf_br_dm
    -- override_enable, offset, hold_pc -> feed forward? direct?
    -- sp_op, sp_enable, br_sp_enable, mux_alu_dm_select
    br_mux_z_br_value        => br_mux_z_br_value,
    br_mux_select_alu_dm     => br_mux_select_alu_dm,
    br_mux_rf_br_enable      => br_mux_rf_br_enable,
    mux_br_sp_enable         => mux_br_sp_enable,
    br_sp_op_code            => br_sp_op_code,
    br_sp_enable             => br_sp_enable,
	
	-- out:
    -- out  
    pip_dec_rf_addr_opA          => pip_dec_rf_addr_opA,
    pip_dec_rf_addr_opB          => pip_dec_rf_addr_opB,
    pip_dec_alu_op_code          => pip_dec_alu_op_code,
    pip_dec_rf_write_enable      => pip_dec_rf_write_enable,
    pip_dec_sreg_write_enable    => pip_dec_sreg_write_enable,
    pip_dec_rf_immediate         => pip_dec_rf_immediate,
    pip_dec_alu_immediate        => pip_dec_alu_immediate,
    pip_dec_immediate_value      => pip_dec_immediate_value,
    pip_dec_dm_write_enable      => pip_dec_dm_write_enable,
    pip_dec_mux_select_alu_dm    => pip_dec_mux_select_alu_dm,
    pip_dec_pc_override_enable   => pip_dec_pc_override_enable,
    pip_dec_pc_override_offset   => pip_dec_pc_override_offset,
    pip_dec_sreg_override_enable => pip_dec_sreg_override_enable,
    pip_dec_sreg_override_value  => pip_dec_sreg_override_value,
    pip_dec_sp_op                => pip_dec_sp_op,
    pip_dec_sp_enable            => pip_dec_sp_enable,
    
    -- br:
    -- dm_value, enable_mux_rf_pc -> mux_rf_br_dm
    -- override_enable, offset, hold_pc -> feed forward? direct?
    -- sp_op, sp_enable, br_sp_enable, mux_alu_dm_select

    pip_br_mux_z_br_value        => pip_br_mux_z_br_value,
    pip_br_mux_select_alu_dm     => pip_br_mux_select_alu_dm,
    pip_mux_br_sp_enable    => pip_mux_br_sp_enable,
	pip_br_sp_op_code  => pip_br_sp_op_code,
	pip_br_sp_enable => pip_br_sp_enable,
	pip_br_mux_rf_br_enable => pip_br_mux_rf_br_enable
);

rf: register_file
port map(
    -- in:
    clk         => clk,
    addr_opa    => dec_rf_addr_opA,
    addr_opb    => dec_rf_addr_opB,
    write_addr  => dec_rf_addr_opA,
    w_e_rf      => dec_rf_write_enable,
    data_in     => mux_im_rf_data,
    
    -- out:
    data_opa => rf_alu_opA,
    data_opb => rf_alu_opB
);


alu0: alu
port map(
    -- in:
    opcode      => dec_alu_op_code,
    opa         => rf_alu_opA,
    opb         => mux_rf_dec_alu_opB,
    status_in   => sreg_alu_status,
    
    
    -- out:
    res         => alu_mux_dm_out,
    status_out  => alu_sreg_status
    -- branch_test_result => open
);

sreg: status_registry
port map(
    -- in:
    clk             => clk,
    reset           => cpu_reset,
    w_e_sreg        => dec_sreg_write_enable,
    status_in       => alu_sreg_status,
    override        => dec_sreg_override_enable,
    override_value  => dec_sreg_override_value, 
    
    -- out:
    status_out => sreg_alu_status
);

br_controller: branch_controller
port map(
    -- in
    clk             => clk,
    reset           => cpu_reset,
    sreg_status     => sreg_alu_status,
    branch_instr    => dec_br_instr,
    branch_enable   => dec_br_enable,
    current_pc      => pc_pm_addr,
    --rf_data_opa     => rf_alu_opA,
    
    dm_data => mux_alu_dm_data,
    
    -- out 
    override_enable => br_pc_override_enable,
    offset => br_pc_offset,
    dm_value => br_mux_z_br_value,
    hold_pc => br_pc_hold,
    enable_mux_rf_pc => br_mux_rf_br_enable,

    
    --rf_enable => dec_rf_write_enable,
    mux_alu_dm_select => br_mux_select_alu_dm,
    
    br_sp_enable => mux_br_sp_enable,
    sp_op => br_sp_op_code,
    sp_enable => br_sp_enable

);

z_addr: z_address
port map(
    -- in:
    clk             => clk,
    reset           => cpu_reset,
    rf_addr_r30     => z_addr_r30_we,
    rf_addr_r31     => z_addr_r31_we,
    z_addr_value    => z_data_in,
    
    -- out:
    z_addr_out => z_addr_out
);

sp: stackpointer
port map(
    clk     => clk,
    reset   => cpu_reset,
    op_code => mux_dec_br_sp_op_code,     
    enable_sp  => mux_dec_br_sp_enable,
    addr    => sp_dm_addr
);

dm: data_memory_1024B
port map(
    clk             => clk,        
    write_enable    => dec_dm_write_enable,
    z_addr          => dm_z_addr,
    z_data_in       => mux_rf_br_dm, --rf_alu_opA,
    data            => dm_mux_data_out
);

mem_mapped_io0: mem_mapped_io
port map (
    clk         => clk,   
    write_enable => dec_dm_write_enable,
    data        => rf_alu_opA,
    z_addr      => z_addr_out,
    portb       => led(7 downto 0),
    portc       => led(15 downto 8),
    io_addr     => open,
    ser         => io_ser,
    seg0        => io_seg0,
    seg1        => io_seg1,
    seg2        => io_seg2,
    seg3        => io_seg3,
    pinb_in     => sw(7 downto 0),
    pinc_in     => sw(15 downto 8),
    pind_in     => port_for_btns
);

seg_view_controller0: seg_view_controller
port map(
    clk     => clk,
    reset   => cpu_reset,  
    ser     => io_ser,
    seg0    => io_seg0,
    seg1    => io_seg1,
    seg2    => io_seg2,
    seg3    => io_seg3,
    seg     => seg,
    an      => an,
    db      => dp
);

-- Reseting the CPU
cpu_reset <= btnC AND btnD AND btnU;

-- z-addr logic: the src of the z_addr can be immdiate_values (LDI), Data memory Load (LD), MOV and the result of an ALU op
z_data_src_bus  <= dec_rf_immediate & dec_mux_select_alu_dm;        -- need to figure out the source of the data
--z_addr_r31_we   <= '1' when ((dec_rf_addr_opA(4) AND dec_rf_addr_opA(3) AND dec_rf_addr_opA(2) AND dec_rf_addr_opA(1) AND dec_rf_addr_opA(0) = '1') AND dec_rf_we = '1') else '0';
z_addr_r31_we   <= dec_rf_addr_opA(4) AND dec_rf_addr_opA(3) AND dec_rf_addr_opA(2) AND dec_rf_addr_opA(1) AND dec_rf_addr_opA(0) AND dec_rf_write_enable;
--z_addr_r30_we   <= '1' when (dec_rf_addr_opA = "11110" AND dec_rf_we = '1') else '0';
z_addr_r30_we   <= dec_rf_addr_opA(4) AND dec_rf_addr_opA(3) AND dec_rf_addr_opA(2) AND dec_rf_addr_opA(1) AND NOT dec_rf_addr_opA(0) AND dec_rf_write_enable;
--z_data_in       <= dec_im_val when z_data_src_bus = "10" else
--                rf_alu_data_a when z_data_src_bus = "00" else
--                mux_alu_dm_data when z_data_src_bus = "01" else (others => '0');
z_data_in       <= mux_im_rf_data;
dm_z_addr <= sp_dm_addr when dec_sp_enable = '1' else z_addr_out;


--IO
port_for_btns <= "000"&btnR&btnU&btnD&btnL&btnC;

--MUXing the data going out of the writeback stage: mux the result of the Writeback between ALU result and DM Result
--mux_alu_dm_data <= alu_mux_dm_out when dec_mux_select_alu_dm = '0' or br_mux_select_alu_dm = '0' else dm_mux_data_out;
mux_alu_dm_data <= dm_mux_data_out;

--MUXing the data going into the rf
mux_im_rf_data <= mux_alu_dm_data when dec_rf_immediate = '0' else dec_immediate_value;

--MUXing ALU's data_b between rf_data_b and decoder_immediate_Value
mux_rf_dec_alu_opB <= rf_alu_opB when dec_alu_immediate = '0' else dec_immediate_value;

--MUXing branching controller and z_addr 
mux_rf_br_dm <= br_mux_z_br_value when br_mux_rf_br_enable = '1' else rf_alu_opA;

-- SP
-- MUXing between dec and br for sp
mux_dec_br_sp_enable <= dec_sp_enable when mux_br_sp_enable = '0' else br_sp_enable;
mux_dec_br_sp_op_code <= dec_sp_op when mux_br_sp_enable = '0' else br_sp_op_code;

end Behavioral;
