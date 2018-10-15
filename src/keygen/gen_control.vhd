
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gen_control is
	port(
		CLK, rst_n : in std_logic;
	
-- INPUT
		key_len 									: in std_logic_vector (1 downto 0);
		curr_round 								: in std_logic_vector (3 downto 0);
		
-- OUTPUT
		valid 									: out std_logic;
		
-- CONTROL SIGNAL
		load_curr,
		sel_curr, sel_s, sel_t5, 
		sel_t7, sel_w6, sel_w7, 
		sel_rcon, sel_rconout				: out std_logic;
		sel_rotWord,  
		sel_t4, sel_t6, sel_w0, sel_w1, 
		sel_w2, sel_w3, sel_w4, sel_w5, 
		sel_dataround							: out std_logic_vector (1 downto 0);
		load_w0, load_w1, load_w2, 
		load_w3, load_w4, load_w5, 
		load_w6, load_w7, load_rcon		: out std_logic
		
	);
end gen_control;

architecture arc of gen_control is

	type statetype is (	USELESS, INIT0, INIT1, WORK0, WORK1, WORK2, WORK3, WORK4, WORK5,
									FINAL0, FINAL1, FINAL2, FINAL3, FINAL4, FINAL5, FINAL6,
									WAIT0, WAIT1, WAIT2, WAIT3, WAIT4, WAIT5, WAIT6, WAIT7, 
									WAIT8, WAIT9, WAIT10, WAIT11, WAIT12, WAIT13, WAIT14, 
									WAIT15, WAIT16, WAIT17, WAIT18, WAIT19, WAIT20, WAIT21, WAIT22);
									
	signal state, nextstate : statetype;

begin

	state <= 	USELESS when rst_n = '0' else nextstate when rising_edge(CLK);

	process (state, key_len, curr_round)
		begin
		
		case state is
			when USELESS =>
				nextstate <= INIT0;
			when INIT0 =>
				if key_len = "00" then
					nextstate <= WORK0;
				elsif key_len = "01" then
					nextstate <= WORK1;
				else
					nextstate <= INIT1;
				end if;
				
			when WAIT21 =>
				nextstate <= WAIT22;
			when WAIT22 =>
				nextstate <= WORK0;
			when WORK0 =>
				nextstate <= WAIT0;
			when WAIT0 =>
				nextstate <= WAIT1;
			when WAIT1 =>
				nextstate <= FINAL0;
			when WAIT2 =>
				nextstate <= WAIT2;
			when FINAL0 =>
				if curr_round = "1010" then
					nextstate <= WAIT2;
				else
					nextstate <= WORK0;
				end if;
			when WAIT14 =>
				nextstate <= WAIT15;
			when WAIT15 =>
				nextstate <= WAIT17;
			when WAIT17 =>
				nextstate <= WORK1;
			when WORK1 =>
				nextstate <= WAIT3;
			when WAIT3 =>
				nextstate <= WAIT4;
			when WAIT4 =>
				nextstate <= FINAL1;
			when FINAL1 =>
				nextstate <= FINAL2;
			when WAIT13 =>
				nextstate <= WAIT16;
			when WAIT16 =>
				nextstate <= FINAL2;
			when FINAL2 =>
				nextstate <= WORK2;
			when WORK2 =>
				nextstate <= WAIT5;
			when WAIT5 =>
				nextstate <= WAIT6;
			when WAIT6 =>
				nextstate <= FINAL3;
			when FINAL3 =>
				if curr_round = "1011" then
					nextstate <= WAIT2;
				else
					nextstate <= WORK3;
				end if;
			when WORK3 =>
				nextstate <= WAIT7;
			when WAIT7 =>
				nextstate <= WAIT8;
			when WAIT8 =>
				nextstate <= FINAL4;
			when FINAL4 =>
				nextstate <= FINAL2;
			when WAIT18 =>
				nextstate <= WAIT19;
			when WAIT19 =>
				nextstate <= WAIT20;
			when WAIT20 =>
				nextstate <= INIT1;
			when INIT1 =>
				nextstate <= WORK4;
			when WORK4 =>
				nextstate <= WAIT9;
			when WAIT9 =>
				nextstate <= WAIT10;
			when WAIT10 =>
				nextstate <= FINAL5;
			when FINAL5 =>
				nextstate <= WORK5;
			when WORK5 =>
				nextstate <= WAIT11;
			when WAIT11 =>
				nextstate <= WAIT12;
			when WAIT12 =>
				nextstate <= FINAL6;
			when FINAL6 =>
				if curr_round = "1110" then
					nextstate <= WAIT2;
				else
					nextstate <= WORK4;
				end if;
		end case;
	end process;


--CURR_ROUND

		sel_curr <= 	'0' when state= INIT0 else '1';
		load_curr <= 	'1' when state=FINAL0 or state=FINAL1 or state=FINAL2 or state=FINAL3 or state=FINAL4 or state=INIT1 or state=FINAL5 or state=FINAL6 else '0';
--SELECTION DATA
		sel_dataround <= 	"00" when state=WAIT14 or state=WAIT15 or state=WAIT17 or state=WAIT18 or state=WAIT19 or state=WAIT20 else
								key_len; --00 01 or 10
-- X1 BLOCK

		sel_rotWord <= "00" when state=WORK0 or state=WAIT0 or state=WAIT1 or state= INIT0 or state=WAIT21 or state=WAIT22 else
							"01" when state=FINAL3 or state=WORK3 or state=WAIT7 or state=WAIT8 else
							"10" when state=WORK4 or state=WAIT9 or state=WAIT10 or state=INIT1 or state=FINAL5 or state=WORK5 or state=WAIT11 or state=WAIT12 or state=FINAL6 else
							"11" when key_len= "01" and state/=FINAL3  and state/=WORK3 and state/=WAIT7 and state/=WAIT8  else
							"00";
							
		sel_s <= 		'0' when state=FINAL5 or state=WORK5 or state=WAIT11 or state=WAIT12 or state=FINAL6 else 
							'1' when state=WORK0 or state=WORK1 or state=WORK2 or state=WORK3 or state=WORK4 else
							'1';
		
								
-- T SECTION
		sel_t4 <= 	"00" when key_len="00" or key_len="10" or state=WAIT5 or state=WAIT6 or state=FINAL3 else
						"01" when state=WAIT4 or state=FINAL1 or state=WAIT13 else
						"10";
						
		sel_t5 <= 	'1' when state=WAIT4 or state=FINAL1 or state=WAIT13 else 
						'0';
		
		sel_t6 <= 	"00" when key_len="00" or key_len ="10" or state=WAIT16 or state=FINAL2 or state=WORK2 or state=WAIT5 or state=WAIT6 or state=FINAL3 or state=WORK3 else
						"01" when state=WAIT3 or state=WAIT4 or state=FINAL1 or state=WAIT13 else
						"10";
		
		sel_t7 <=	'1' when state=WAIT3 or state=WAIT4 or state=FINAL1 or state=WAIT13 else 
						'0' ;
		
-- W SECTION

		sel_w0 <= 	"00" when state=INIT0 or state=INIT1 or state=WORK1 or state=WAIT21 or state=WAIT22 or state=WAIT14 or state=WAIT15 or state=WAIT17 else
						"01" when state=FINAL0 else
						"10" when state=FINAL2 or state=FINAL3 or state=FINAL4 or state=FINAL5 or state=FINAL6 else
						"11" when state=FINAL1 else
						"10";
						
		sel_w1 <= 	"00" when state=INIT0 or state=INIT1 or state=WORK1 or state=WAIT21 or state=WAIT22 or state=WAIT14 or state=WAIT15 or state=WAIT17 else
						"01" when state=FINAL0 else
						"10" when state=FINAL2 or state=FINAL3 or state=FINAL4 or state=FINAL5 or state=FINAL6 else
						"11" when state=FINAL1 else
						"10";
						
		sel_w2 <=	"00" when state=INIT0 or state=INIT1 or state=WORK1 or state=WAIT21 or state=WAIT22 or state=WAIT14 or state=WAIT15 or state=WAIT17 else
						"01" when state=FINAL0 else
						"10" when state=FINAL1 or state=FINAL2 or state=FINAL3 or state=FINAL4 else
						"11" when state=FINAL5 or state=FINAL6 else
						"10";
						
		sel_w3 <= 	"00" when state=INIT0 or state=INIT1 or state=WORK1 or state=WAIT21 or state=WAIT22 or state=WAIT14 or state=WAIT15 or state=WAIT17 else
						"01" when state=FINAL0 else
						"10" when state=FINAL1 or state=FINAL2 or state=FINAL3 or state=FINAL4 else
						"11" when state=FINAL5 or state=FINAL6 else
						"10";
						
						
		sel_w4 <=	"00" when state=INIT0 or state=INIT1 or state=WORK1  or state=WAIT14 or state=WAIT15 or state=WAIT17 else
						"01" when state=FINAL1 or state=FINAL2 or state=FINAL3 or state=FINAL4 else
						"10" when state=FINAL5 or state=FINAL6 else
						"01";
						
		sel_w5 <= 	"00" when state=INIT0 or state=INIT1 or state=WORK1  or state=WAIT14 or state=WAIT15 or state=WAIT17 else
						"01" when state=FINAL1 or state=FINAL2 or state=FINAL3 or state=FINAL4 else
						"10" when state=FINAL5 or state=FINAL6 else
						"01";
						
		sel_w6 <=	'0' when state=INIT0 or state=INIT1 else 
						'1' when state=FINAL5 or state=FINAL6 else
						'1';
		
		sel_w7 <=	'0' when state=INIT0 or state=INIT1 else 
						'1' when state=FINAL5 or state=FINAL6 else
						'1';
						
						
-- LOAD						
		load_w0 <= 	'1' when state=INIT0  or state=WORK1 or state=FINAL0  or
									state=FINAL1 or state=FINAL2 or state=FINAL3 or state=FINAL4 or
									state=FINAL5 or state=FINAL6  else '0';
		
		load_w1 <= '1' when 	state=INIT0  or state=WORK1 or state=FINAL0 or
									state=FINAL1 or state=FINAL2 or state=FINAL3 or state=FINAL4 or
									state=FINAL5 or state=FINAL6  else '0';
									
		load_w2 <= '1' when 	state=INIT0  or state=WORK1 or state=FINAL0  or
									state=FINAL1 or state=FINAL2 or state=FINAL3 or state=FINAL4 or
									state=FINAL5 or state=FINAL6  else '0';
									
		load_w3 <= '1' when 	state=INIT0  or state=WORK1 or state=FINAL0  or
									state=FINAL1 or state=FINAL2 or state=FINAL3 or state=FINAL4 or
									state=FINAL5 or state=FINAL6  else '0';
									
									
		load_w4 <= '1' when state=INIT0  or state=WORK1 or
									state=FINAL1 or state=FINAL2 or state=FINAL3 or state=FINAL4 or
									state=FINAL5 or state=FINAL6  else '0';
									
		load_w5 <= '1' when state=INIT0  or state=WORK1 or
									state=FINAL1 or state=FINAL2 or state=FINAL3 or state=FINAL4 or
									state=FINAL5 or state=FINAL6 else '0';
									
		load_w6 <= '1' when state=INIT0 or state=FINAL5 or state=FINAL6 else '0';
		 
		load_w7 <= '1' when state=INIT0 or state=FINAL5 or state=FINAL6 else '0';
		
-- DATA VALID
		valid <= '0' when state=USELESS or state=INIT0 or state=FINAL0 or state=FINAL1 or state=FINAL3 or state=FINAL4 or
								state=FINAL5 or state=FINAL6 or state=INIT1 or state=WORK1 or state=WAIT3 or state=WAIT4 else '1';

-- RCON counter
		sel_rcon <= 	'0' when state= INIT0 else
							'1';
		load_rcon <=	'1' when state =FINAL0 or state =FINAL1 or state =FINAL3 or state = FINAL4 or state =FINAL5 else
							'0';
							
		sel_rconout <= '1' when state= WAIT12 or state=WAIT11 or state = FINAL6 or state=WORK5 else 
							'0';	
end arc;

