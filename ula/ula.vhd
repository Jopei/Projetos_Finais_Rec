library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity ula is
    Port (
        a_in : in std_logic_vector(7 Downto 0);
        b_in : in std_logic_vector(7 Downto 0);
        c_in : in std_logic;
        op_sel : in std_logic_vector(3 Downto 0);
        r_out : out std_logic_vector(7 Downto 0);
        c_out : out std_logic;
        z_out : out std_logic;
        v_out : out std_logic
        );
end entity;

architecture ULA of ula is
    signal ponto : std_logic_vector(7 Downto 0);
    signal aux : std_logic_vector(8 Downto 0);
    signal aux2 : std_logic_vector(4 Downto 0);
    constant Zero : std_logic_vector(7 Downto 0) := "00000000";
    constant Um : std_logic_vector(7 Downto 0) := "00000001";
    constant OP_SRL : std_logic_vector (3 Downto 0) := "0000";
    constant OP_SRA : std_logic_vector (3 Downto 0) := "0001";
    constant OP_SLL : std_logic_vector (3 Downto 0) := "0010";
    constant PASS_B : std_logic_vector (3 Downto 0) := "0011";
    constant OP_RR : std_logic_vector (3 Downto 0) := "0100";
    constant OP_RL : std_logic_vector (3 Downto 0) := "0101";
    constant OP_RRC : std_logic_vector (3 Downto 0) := "0110";
    constant OP_RLC : std_logic_vector (3 Downto 0) := "0111";
    constant OP_ADD : std_logic_vector (3 Downto 0) := "1000";
    constant OP_SUB : std_logic_vector (3 Downto 0) := "1001";
    constant OP_ADDC : std_logic_vector (3 Downto 0) := "1010";
    constant OP_SUBC : std_logic_vector (3 Downto 0) := "1011";
    constant OP_OR : std_logic_vector (3 Downto 0) := "1100";
    constant OP_AND : std_logic_vector (3 Downto 0) := "1101";
    constant OP_XOR : std_logic_vector (3 Downto 0) := "1110";
    constant OP_NOT : std_logic_vector (3 Downto 0) := "1111";
		
begin 
    -- Restante do c�digo...

    WITH op_sel SELECT
        c_out <= a_in(7) WHEN OP_SLL,
                 a_in(0) WHEN OP_SRA,
                 a_in(0) WHEN OP_SRL,
                 a_in(7) WHEN OP_RL,
                 a_in(0) WHEN OP_RR,
                 aux(8) WHEN OP_ADDC,
                 aux(8) WHEN OP_ADD,
                 NOT aux(8) WHEN OP_SUB,
                 NOT aux(8) WHEN OP_SUBC,
                 a_in(7) WHEN OP_RLC,
                 a_in(0) WHEN OP_RRC,
                 '0' WHEN OTHERS;	

    -- Verifica��o para v_out (op_sel igual a OP_ADD ou OP_SUB)
    v_out <= '1' WHEN op_sel = OP_ADD or op_sel = OP_SUB ELSE '0';
    
    
end architecture ULA;

