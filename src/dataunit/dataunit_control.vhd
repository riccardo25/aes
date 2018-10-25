library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity dataunit_control is

	port (
		CLK, rst_n 							: in std_logic;

		-- data inputs
		--STT									: in std_logic_vector (7 downto 0);
		ROUND									: in std_logic_vector (3 downto 0);
		key_lenght							: in std_logic_vector (1 downto 0);
		enc									: in std_logic;
		key_valid							: in std_logic;
		
		-- data outputs
		loading								: out std_logic;
		sel_state, sel_round				: out std_logic_vector (2 downto 0);
		reset_reg							: out std_logic;
		br0_sel, br1_sel, 
		br2_sel, br3_sel					: out std_logic_vector (1 downto 0);
		load_round, load_state			: out std_logic;
		valid_out							: out std_logic
	);

end dataunit_control;

architecture arc of dataunit_control is


	type statetype is (	INIT, LOAD0, LOAD1, LOAD2, LOAD3, LOAD3dec,
								PREPARE0, PREPARE1, PREPARE2,
								PRELOADenc, PRELOADdec,
								SUBSHIFT0, SUBSHIFT1, SUBSHIFT2, SUBSHIFT3, SUBSHIFT4, SUBSHIFT5,
								MIXADD, FINALSTEP, MIXADDdec,
								UNLOAD0, UNLOAD1, UNLOAD2, UNLOAD3,
								USELESS0);
	signal state, nextstate : statetype;

begin

	--FSM
	state <= 	INIT 	when rst_n = '0' else nextstate when rising_edge(CLK);
	
	process (state, ROUND, key_lenght, key_valid, enc)
	begin
	
		case state is

			when INIT =>
				nextstate <=USELESS0;
			when USELESS0 =>
				
				if( enc = '1' ) then 
					nextstate <= PRELOADenc;
				elsif( key_lenght = "00") then
					nextstate <= PREPARE0;
				elsif( key_lenght = "01") then
					nextstate <= PREPARE1;
				else
					nextstate <= PREPARE2;
				end if;
			when PREPARE0 =>
			
				if(key_valid = '1') then
					nextstate <= PRELOADdec;
				else
					nextstate <= PREPARE0;
				end if;
				
			when PREPARE1 =>
			
				if(key_valid = '1') then
					nextstate <= PRELOADdec;
				else
					nextstate <= PREPARE1;
				end if;
			when PREPARE2 =>
			
				if(key_valid = '1') then
					nextstate <= PRELOADdec;
				else
					nextstate <= PREPARE2;
				end if;
				
			when PRELOADenc =>
				nextstate <= LOAD0;
			when PRELOADdec =>
				nextstate <= LOAD0;
			when LOAD0 =>
				nextstate <= LOAD1;
			when LOAD1 =>
				nextstate <= LOAD2;
			when LOAD2 =>
				nextstate <= LOAD3;				
			when LOAD3 =>
				nextstate <= SUBSHIFT0;
			when LOAD3dec =>
				nextstate <= SUBSHIFT0;
			when SUBSHIFT0 =>
				nextstate <= SUBSHIFT1;
			when SUBSHIFT1 =>
				nextstate <= SUBSHIFT2;
			when SUBSHIFT2 =>
				nextstate <= SUBSHIFT3;
			when SUBSHIFT3 =>
				nextstate <= SUBSHIFT4;
			when SUBSHIFT4 =>
				nextstate <= SUBSHIFT5;
			when SUBSHIFT5 =>
			
				if(key_lenght = "00" and ROUND = "1010" and enc='1') then --10
					nextstate <= FINALSTEP;
				elsif (key_lenght = "01" and ROUND = "1100" and enc='1') then --12
					nextstate <= FINALSTEP;
				elsif (key_lenght = "10" and ROUND = "1110" and enc='1') then --14
					nextstate <= FINALSTEP;
				elsif ( enc='1' ) then
					nextstate <= MIXADD;
				elsif ( ROUND = "0000" ) then
					nextstate <= FINALSTEP;
				else
					nextstate <= MIXADD;
				end if;
			
			when MIXADD =>
				nextstate <= SUBSHIFT0;
			when MIXADDdec =>
				nextstate <= SUBSHIFT0;
			when FINALSTEP =>
				nextstate <= UNLOAD0;
			when UNLOAD0 =>
				nextstate <= UNLOAD1;
			when UNLOAD1 =>
				nextstate <= UNLOAD2;
			when UNLOAD2 =>
				nextstate <= UNLOAD3;
			when UNLOAD3 =>
				nextstate <= INIT;
			when others =>
				nextstate <= INIT;
		end case;
	end process;
	
		loading 		<= '1' when state=PRELOADdec or state=PRELOADenc or state=LOAD0 or state=LOAD1 or state=LOAD2 or state=LOAD3 else 
							'0';
	
		reset_reg	<= '0' when state=INIT or rst_n = '0' else
							'1';
							
--		sel_mix		<= "00" when state=LOAD3 else
--							"01" when state=MIXADD else
--							"10";
							
		sel_round	<= "000" when state=PREPARE0 else
							"001" when state=PREPARE1 else
							"010" when state=PREPARE2 or state=USELESS0 else
							"011" when enc = '0' else
							"101" when state=PRELOADenc else
							"100";
							
		sel_state	<= "000" when state=INIT or state=USELESS0 else
							"001" when state=LOAD0 or state=LOAD1 or state=LOAD2 or state=UNLOAD0 or state=UNLOAD1 or state=UNLOAD2 or state=UNLOAD3  else
							"010" when state=LOAD3 else
							"011" when state=MIXADD else
							"100" when state=FINALSTEP else
							"101";
		
--		sel_right	<= '0' when state=LOAD0 or state=LOAD1 or state=LOAD2 or state=UNLOAD0 or state=UNLOAD1 or state=UNLOAD2 or state=UNLOAD3 else
--							'1';
		
		load_round	<= '1' when state=INIT or state=USELESS0 or state=MIXADD  or state=LOAD3 or 
										state=PREPARE0 or state=PREPARE1 or state=PREPARE2 or state=PRELOADenc else
							'0';
		
		load_state	<=	'1';
		
		br0_sel 	<= "11" when state=SUBSHIFT3 and enc = '1' else
						"10" when state=SUBSHIFT4 and enc = '1' else
						"01" when state=SUBSHIFT5 and enc = '1' else
						"01" when state=SUBSHIFT3 else
						"10" when state=SUBSHIFT4 else
						"11" when state=SUBSHIFT5 else
						"00";
						
		br1_sel 	<= "00" when state=SUBSHIFT3 and enc = '1' else
						"11" when state=SUBSHIFT4 and enc = '1' else
						"10" when state=SUBSHIFT5 and enc = '1' else
						"10" when state=SUBSHIFT3 else
						"11" when state=SUBSHIFT4 else
						"00" when state=SUBSHIFT5 else
						"01";
		 
		br2_sel	<= "01" when state=SUBSHIFT3 and enc = '1' else
						"00" when state=SUBSHIFT4 and enc = '1' else
						"11" when state=SUBSHIFT5 and enc = '1' else
						"11" when state=SUBSHIFT3 else
						"00" when state=SUBSHIFT4 else
						"01" when state=SUBSHIFT5 else
						"10";
						
		br3_sel	<= "10" when state=SUBSHIFT3 and enc = '1' else
						"01" when state=SUBSHIFT4 and enc = '1' else
						"00" when state=SUBSHIFT5 and enc = '1' else
						"00" when state=SUBSHIFT3 else
						"01" when state=SUBSHIFT4 else
						"10" when state=SUBSHIFT5 else
						"11";
						
		valid_out <= 	'1' when state=FINALSTEP or state=UNLOAD0 or state=UNLOAD1 or state=UNLOAD2 or state=UNLOAD3 else
							'0';

end arc;



