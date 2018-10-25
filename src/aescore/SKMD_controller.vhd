library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity SKMD_controller is
	port(
			CLK, rst_n  			: in std_logic;
	--INPUTS
			--FROM CAP
			valid_from_PC			: in std_logic;
			ready_to_send			: in std_logic;
			--FROM CBC
			done0, done1			: in std_logic;
			datacrypt0,
			datacrypt1				: in std_logic_vector(127 downto 0);
			session0, session1	: in std_logic_vector(7 downto 0);
			enc0, enc1				: in std_logic;
			ready_for_input0,
			ready_for_input1		: in std_logic;
			
			
	-- OUTPUT
						
			--TO CAP
			datacrypt_out			: out std_logic_vector(127 downto 0);
			session_out				: out std_logic_vector(7 downto 0);
			enc_out					: out std_logic;
			valid_to_serial		: out std_logic;
			ready_get_PC			: out std_logic;
			-- TO CBC
			resetCBC					: out std_logic;
			valid0, valid1			: out std_logic
			
	);
end SKMD_controller;

architecture arc of SKMD_controller is


	type statetype is (	INIT0,
								WAIT0, WAIT1, WAIT2, WAIT3,
								LOAD0, LOAD1, 
								WRITE0, WRITE1,
								RESETD);
	signal state, nextstate : statetype;
	
	--SELECTION SIGNALS
	signal sel_enc, sel_session, sel_datacrypt : std_logic;
	
	
begin


--CONTROL UNIT

	state <= 	INIT0	when rst_n = '0' else nextstate when rising_edge(CLK);
	
	process (state, valid_from_PC, ready_to_send, done0, done1, ready_for_input0, ready_for_input1)
	begin
	
		case state is
			when INIT0 =>
			
				if( valid_from_PC ='1' and ready_for_input0 = '1') then
					nextstate <= LOAD0;
				else
					nextstate <= INIT0;
				end if;
				
			when LOAD0 =>
			
				if( valid_from_PC ='0') then
					nextstate <= WAIT0;
				else
					nextstate <= LOAD0;
				end if;
			
			when WAIT0 =>
			
				if( valid_from_PC ='1' and ready_for_input1 = '1') then
					nextstate <= LOAD1;
				else
					nextstate <= WAIT0;
				end if;
			when LOAD1 =>
			
				if( valid_from_PC ='0') then
					nextstate <= WAIT1;
				else
					nextstate <= LOAD1;
				end if;
			
			when WAIT1 =>
			
				if( ready_to_send ='1' and done0 ='1') then
					nextstate <= WRITE0;
				else
					nextstate <= WAIT1;
				end if;
				
			when WRITE0 =>
			
				if( ready_to_send ='0') then
					nextstate <= WAIT2;
				else
					nextstate <= WRITE0;
				end if;
				
			when WAIT2 =>
			
				if( ready_to_send ='1' and done1	 ='1') then
					nextstate <= WRITE1;
				else
					nextstate <= WAIT2;
				end if;
				
			when WRITE1 =>
			
				if( ready_to_send ='0') then
					nextstate <= WAIT3;
				else
					nextstate <= WRITE1;
				end if;
				
			when WAIT3 =>
			
				if( ready_to_send ='1' ) then
					nextstate <= RESETD;
				else
					nextstate <= WAIT3;
				end if;
			when RESETD => 
				nextstate <= INIT0;
				
			when others =>
				nextstate <= INIT0;
		end case;
	end process;
	
	--SELECTION SIGNALS
	sel_enc 				<= '0' when state=WRITE0 or state=WAIT2 else '1';
	sel_session			<= '0' when state=WRITE0 or state=WAIT2 else '1';
	sel_datacrypt		<= '0' when state=WRITE0 or state=WAIT2 else '1';
	
	--CONTROL OUTPUT
	valid_to_serial	<=	'1' when state=WRITE0 or state=WRITE1 else '0';
	resetCBC				<=	'0' when state=RESETD or rst_n = '0' else '1';
	valid0				<= '1' when state=LOAD0 else '0';
	valid1				<= '1' when state=LOAD1 else '0';
	ready_get_PC		<= '1' when state=INIT0 or state =LOAD0 or state=LOAD1 or state=WAIT1 else '0';
	
	
--DATAPATH
	
	--ENC
	enc_out 				<= enc0 when sel_enc='0' else enc1;
	datacrypt_out		<= datacrypt0 when sel_datacrypt='0' else datacrypt1;
	session_out			<= session0 when sel_session='0' else session1;


end arc;

