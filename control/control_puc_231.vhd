LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY control_puc_231 IS
	PORT (
	----Entradas----
		nrst, clk : IN STD_LOGIC;
		opcode : IN STD_LOGIC_VECTOR(15 DOWNTO 8);
		c_flag : IN STD_LOGIC;
		z_flag : IN STD_LOGIC;
		v_flag : IN STD_LOGIC;
		int_req : IN STD_LOGIC;
	----Saidas----		
		reg_do_a_on_dext : OUT STD_LOGIC;
		dext_on_dint : OUT STD_LOGIC;
		alu_on_dint  : OUT STD_LOGIC;
		mux_sel : OUT STD_LOGIC;
		reg_wr_ena : OUT STD_LOGIC;
		flag_c_wr_ena : OUT STD_LOGIC;
		flag_z_wr_ena : OUT STD_LOGIC;
		flag_v_wr_ena : OUT STD_LOGIC;
		set_gie : OUT STD_LOGIC;
		clr_gie : OUT STD_LOGIC;
		ir_wr_ena : OUT STD_LOGIC;
		alu_op : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		stack_push : OUT STD_LOGIC;
		stach_pop : OUT STD_LOGIC;
		pc_ctrl : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		mem_wr_ena : OUT STD_LOGIC;
		mem_rd_ena : OUT STD_LOGIC;
		inp  : OUT STD_LOGIC;
		outp : OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE arch OF control_puc_231 IS
	TYPE state_type is (rst, fetch, fetch_dec_ex);
	SIGNAL pres_state	: state_type;
	SIGNAL next_state	: state_type;	
	
	constant ULA_OP_SRL : std_logic_vector (3 Downto 0) := "0000";
    constant ULA_OP_SRA : std_logic_vector (3 Downto 0) := "0001";
    constant ULA_OP_SLL : std_logic_vector (3 Downto 0) := "0010";
    constant ULA_OP_PASS_B : std_logic_vector (3 Downto 0) := "0011";
    constant ULA_OP_RR : std_logic_vector (3 Downto 0) := "0100";
    constant ULA_OP_RL : std_logic_vector (3 Downto 0) := "0101";
    constant ULA_OP_RRC : std_logic_vector (3 Downto 0) := "0110";
    constant ULA_OP_RLC : std_logic_vector (3 Downto 0) := "0111";
    constant ULA_OP_ADD : std_logic_vector (3 Downto 0) := "1000";
    constant ULA_OP_SUB : std_logic_vector (3 Downto 0) := "1001";
    constant ULA_OP_ADDC : std_logic_vector (3 Downto 0) := "1010";
    constant ULA_OP_SUBC : std_logic_vector (3 Downto 0) := "1011";
    constant ULA_OP_OR : std_logic_vector (3 Downto 0) := "1100";
    constant ULA_OP_AND : std_logic_vector (3 Downto 0) := "1101";
    constant ULA_OP_XOR : std_logic_vector (3 Downto 0) := "1110";
    constant ULA_OP_NOT : std_logic_vector (3 Downto 0) := "1111";
	
	--------Instruções de memória e E/S-------------------------------------------------
	CONSTANT OP_LDM : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
	CONSTANT OP_STM : STD_LOGIC_VECTOR (1 DOWNTO 0) := "01";
	CONSTANT OP_INP : STD_LOGIC_VECTOR (1 DOWNTO 0) := "10";
	CONSTANT OP_OUT : STD_LOGIC_VECTOR (1 DOWNTO 0) := "11";
	
	--------Instruções  ALU e dois registradores-----------------------------------------
    constant OP_ADD : std_logic_vector (2 Downto 0) := "000";
    constant OP_SUB : std_logic_vector (2 Downto 0) := "001";
    constant OP_ADDC : std_logic_vector (2 Downto 0) := "010";
    constant OP_SUBC : std_logic_vector (2 Downto 0) := "011";
    constant OP_OR : std_logic_vector (2 Downto 0) := "100";
    constant OP_AND : std_logic_vector (2 Downto 0) := "101";
    constant OP_XOR : std_logic_vector (2 Downto 0) := "110";
    constant OP_MOV : std_logic_vector (2 Downto 0) := "111";
    
    --------Instruções ALU e um valor imediato (Reg-Immed)--------------------------------
    constant OP_ADDI : std_logic_vector (2 Downto 0) := "000";
    constant OP_SUBI : std_logic_vector (2 Downto 0) := "001";
    constant OP_ADDIC : std_logic_vector (2 Downto 0) := "010";
    constant OP_SUBIC : std_logic_vector (2 Downto 0) := "011";
    constant OP_ORI : std_logic_vector (2 Downto 0) := "100";
    constant OP_ANDI : std_logic_vector (2 Downto 0) := "101";
    constant OP_XORI : std_logic_vector (2 Downto 0) := "110";
    constant OP_MOVI : std_logic_vector (2 Downto 0) := "111";
    
    --------Instruções  ALU e um registradores--------------------------------------------
    constant OP_SRL : std_logic_vector (2 Downto 0) := "000";
    constant OP_SRA : std_logic_vector (2 Downto 0) := "001";
    constant OP_SLL : std_logic_vector (2 Downto 0) := "010";
    constant OP_NOT : std_logic_vector (2 Downto 0) := "011";
    constant OP_RR : std_logic_vector (2 Downto 0) := "100";
    constant OP_RL : std_logic_vector (2 Downto 0) := "101";
    constant OP_RRC : std_logic_vector (2 Downto 0) := "110";
    constant OP_RLC : std_logic_vector (2 Downto 0) := "111";
    
    --------Instruções de desvio incondicional e chamada de sub-rotina---------------------
    CONSTANT OP_JMP : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
    CONSTANT OP_CALL : STD_LOGIC_VECTOR (1 DOWNTO 0) := "01";
    
    --------Instruções de salto condicional-----------------------------------------------------
    constant OP_SKC : std_logic_vector (3 Downto 0) := "1000";
    constant OP_SKZ : std_logic_vector (3 Downto 0) := "1001";
    constant OP_SKV : std_logic_vector (3 Downto 0) := "1010";
    
    --------Instruções de retorno-------------------------------------------------------------
    constant OP_RET : std_logic_vector (3 Downto 0) := "1100";
    constant OP_RETI : std_logic_vector (3 Downto 0) := "1101";
 Begin 
    PROCESS(nrst, clk)
	BEGIN
		IF nrst = '0' THEN --reset dos registradores
			pres_state <= rst;
		ELSIF RISING_EDGE(clk) THEN
			pres_state <= next_state;
		END IF;
	END PROCESS;
	
	PROCESS(nrst, pres_state, opcode, c_flag, z_flag, v_flag, int_req)
	BEGIN
	
		reg_do_a_on_dext <= '0';
		dext_on_dint <= '0';
		alu_on_dint  <= '0';
		mux_sel <= '0';
		reg_wr_ena <= '0';
		flag_c_wr_ena <= '0';
		flag_z_wr_ena <= '0';
		flag_v_wr_ena <= '0';
		set_gie <= '0';
		clr_gie <= '0';
		ir_wr_ena <= '0';
		stack_push <= '0';
		stach_pop <= '0';
		mem_wr_ena <= '0';
		mem_rd_ena <= '0';
		inp  <= '0';
		outp <= '0';
	--	CASE pres_state IS
		--	WHEN rst =>
			--	next_state <= fetch;
			
		--	WHEN fetch =>
			--	next_state <= fetch_dec_ex;	
		--	WHEN fetch_dec_ex =>
			--	next_state <= fetch_dec_ex;
				--CASE opcode(15 DOWNTO 14) IS
				--WHEN "01" =>
												
				--		CASE opcode(13 DOWNTO 11) IS
							
				--			WHEN OP_ADDI => --OP_ADDI
				--				reg_do_a_on_dext <= '1';
				--				dext_on_dint <= '0';
				--				alu_on_dint  <= '1';
				--				mux_sel <= '1';
				--				reg_wr_ena <= '0';
				--				flag_c_wr_ena <= '1';
				--				flag_z_wr_ena <= '1';
				--				mem_wr_ena <= '0';
				--				mem_rd_ena <= '1';
				--				inp  <= '1';
				--				outp <= '1';
				--				alu_op <= ULA_OP_ADD;
								
				--			WHEN OP_SUBI => --OP_SUBI
				--				reg_do_a_on_dext <= '1';
				--				dext_on_dint <= '0';
				--				alu_on_dint  <= '1';
				--				mux_sel <= '1';
				--				reg_wr_ena <= '0';
				--				flag_c_wr_ena <= '0';
				--				flag_z_wr_ena <= '1';
								
				--				mem_wr_ena <= '1';
				--				mem_rd_ena <= '1';
				--				inp  <= '0';
				--				outp <= '0';
				--				alu_op <= ULA_OP_SUB;
							
				--			WHEN OP_ADDIC => --OP_ADDIC
				--				reg_do_a_on_dext <= '1';
				--				dext_on_dint <= '0';
				--				alu_on_dint  <= '1';
				--				mux_sel <= '1';
				--				reg_wr_ena <= '1';
				--				flag_c_wr_ena <= '1';
				--				flag_z_wr_ena <= '1';
								--
				--				mem_wr_ena <= '0';
				--				mem_rd_ena <= '1';
				--				inp  <= '1';
				--				outp <= '1';
				--				alu_op <= ULA_OP_ADDC;
							
				--			WHEN OP_SUBIC => --OP_SUBIC
				--				reg_do_a_on_dext <= '1';
				--				dext_on_dint <= '1';
				--				alu_on_dint  <= '1';
				--				mux_sel <= '1';
				--				reg_wr_ena <= '1';
				--				flag_c_wr_ena <= '1';
				--				flag_z_wr_ena <= '1';
								
				--				mem_wr_ena <= '0';
				--				mem_rd_ena <= '0';
				--				inp  <= '1';
				--				outp <= '1';
				--				alu_op <= ULA_OP_SUBC;
								
				--			WHEN OP_ORI => --OP_ORI
				--				reg_do_a_on_dext <= '0';
				--				dext_on_dint <= '1';
				--				alu_on_dint  <= '1';
				--				mux_sel <= '1';
				--				reg_wr_ena <= '1';
				--				flag_c_wr_ena <= '1';
				--				flag_z_wr_ena <= '0';
								
				--				mem_wr_ena <= '0';
				--				mem_rd_ena <= '0';
				--				inp  <= '1';
				--				outp <= '1';
				--				alu_op 	 <= ULA_OP_OR;
								
				--			WHEN OP_ANDI => --OP_ANDI
				--				reg_do_a_on_dext <= '0';
				--				dext_on_dint <= '0';
				--				alu_on_dint  <= '1';
				--				mux_sel <= '1';
				--				reg_wr_ena <= '0';
				--				flag_c_wr_ena <= '0';
				--				flag_z_wr_ena <= '1';
								
				--				mem_wr_ena <= '0';
				--				mem_rd_ena <= '1';
				--				inp  <= '1';
				--				outp <= '1';
				--				alu_op   <= ULA_OP_AND;
								
				--			WHEN OP_XORI => --OP_XORI
				--				alu_op 	 <= ULA_OP_XOR;
									
				--			WHEN OP_MOVI => --OP_MOVI
				--				alu_op <= ULA_OP_PASS_B;
							
				--		END CASE;
						
					--------Instruções ALU e um registrador-------------------
				--	WHEN "10" =>
				--		alu_on_dint  <= '1';
				--		inp   <= '1';
						
				--		CASE opcode(13 DOWNTO 11) IS
						
				--			WHEN OP_SRL => --OP_SRL
				--				alu_op <= ULA_OP_SRL;
				--				
				--			WHEN OP_SRA => --OP_SRA
				--				alu_op <= ULA_OP_SRA;
							
				--			WHEN OP_SLL => --OP_SLL
				--				alu_op <= ULA_OP_SLL;
							
				--			WHEN OP_SLL => --OP_NOT
				--				alu_op <= ULA_OP_NOT;
													
				--			WHEN OP_RR => --OP_RR
				--				alu_op <= ULA_OP_RR;
							
				--			WHEN OP_RL => --OP_RL
				--				alu_op  <= ULA_OP_RL;
								
				--			WHEN OP_RRC => --OP_RRC
								
				--				alu_op <= ULA_OP_RRC;
							
				--			WHEN OP_RLC => --OP_RLC
												
				--				alu_op <= ULA_OP_RLC;							
								
				--		END CASE;
						
				--	WHEN "11" =>
					--	IF opcode(13) = '0' THEN
					--		IF opcode(12 DOWNTO 11) = OP_LDM THEN
								--OP_LDM				
					--			next_state <= fetch;
					--			dext_on_dint <= '1';
					--			alu_on_dint <= '1';
					--			mem_wr_ena <= '1';
					--			mem_rd_ena   <= '1';
					--			ir_wr_ena <= '1';
					--			inp <= '1';
								
					--		ELSIF opcode(12 DOWNTO 11) = OP_STM THEN
								--OP_STM					
					--			next_state <= fetch;
					--			dext_on_dint <= '1';
					--			alu_on_dint <= '1';
								
					--			mem_rd_ena   <= '1';
					--			ir_wr_ena <= '1';
					--			inp <= '1';
								
					--		ELSIF opcode(12 DOWNTO 11) = OP_INP THEN
								--OP_INP				
					--			inp    <= '1';
					--			next_state <= fetch;
					--			ir_wr_ena <= '1';
					--			inp <= '1';
					--			dext_on_dint <= '1';
									
					--		ELSIF opcode(12 DOWNTO 11) = OP_OUT THEN
							--OP_OUT				
					--			outp   <= '1';
				--				inp <= '1';
			--					dint_on_dext <= '1';
								
	--						END IF;
--						
		--				ELSE	
					--------Instrução NOP-----------------				
				--	IF opcode(15 DOWNTO 11) = OP_NOP THEN					
					--	inp <= '1';	
				--		flag_z_wr_ena <= '1';							
				--	END IF;	
  END PROCESS;
END arch;
	
	