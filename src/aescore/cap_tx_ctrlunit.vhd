library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity cap_tx_ctrlunit is

	port(
		CLK, rst_n 									: in std_logic;
		
	--INPUTS
		--FROM DATAPATH
		COUNTER										: in std_logic_vector(5 downto 0);
		ENC											: in std_logic;
		
		--from CIPHER
		valid_from_cipher							: in std_logic;
		
		--from SERIAL
		TX_DONE  									: in std_logic;
		
		
	--OUTPUTS
		--TO DATAPATH
		reset_reg, load_COUNTER, load_ENC, 
		load_SESSION,  load_DATA, 
		reset_COUNTER								: out std_logic;
		sel_DATA										: out std_logic;
		sel_TOPC										: out std_logic_vector(1 downto 0);
		
		
		--TO SERIAL
		SEND 											: out std_logic;
		--TO CIPHER
		ready_to_send								: out std_logic
		
	);

end cap_tx_ctrlunit;

architecture arc of cap_tx_ctrlunit is


	type statetype is (	INIT1,
								WAIT4,
								LOADDATA,
								WRITEDATA0, WRITEDATA1, WRITEDATA2, WRITEDATA3);
	signal state, nextstate : statetype;
	
	

begin

	state <= INIT1 when rst_n = '0' else nextstate when rising_edge(CLK);

	process (state, TX_DONE, COUNTER, valid_from_cipher, ENC)
	begin
	
		case state is

			when INIT1 =>
			
				if(valid_from_cipher = '1' ) then 
					nextstate <= LOADDATA;
				else
					nextstate <= INIT1;
				end if;
				
			when LOADDATA =>
			
				if(ENC = '1' ) then 
					nextstate <= WRITEDATA0;
				else
					nextstate <= WRITEDATA1;
				end if;
				
			when WRITEDATA0 =>
			
				if(TX_DONE = '0' ) then 
					nextstate <= WRITEDATA0;
				else
					nextstate <= WRITEDATA2;
				end if;
				
			when WRITEDATA1 =>
			
				if(TX_DONE = '0' ) then 
					nextstate <= WRITEDATA1;
				else
					nextstate <= WRITEDATA2;
				end if;
				
			when WRITEDATA2 =>
			
				if(TX_DONE = '0' ) then 
					nextstate <= WRITEDATA2;
				else
					nextstate <= WRITEDATA3;
				end if;
				
			when WRITEDATA3 =>
				
				if (COUNTER ="010000") then
					nextstate <= INIT1;
				elsif(TX_DONE = '0' ) then  --16
					nextstate <= WAIT4;
				else
					nextstate <= WRITEDATA3;
				end if;
			
				
			when WAIT4 =>
			
				if(TX_DONE = '0' ) then  --16
					nextstate <= WAIT4;
				else
					nextstate <= WRITEDATA3;
				end if;
			
				
			when others =>
				nextstate <= INIT1;
		end case;
	end process;
	
	reset_reg		<= '0' when rst_n ='0' or state=INIT1 else 
							'1';
							
	reset_COUNTER 	<= '0' when rst_n ='0' or state=INIT1 or state=WRITEDATA2 else 
							'1';
							
	load_COUNTER	<= '1' when state=WRITEDATA3 else
							'0';
							
	load_ENC			<= '1' when state=LOADDATA else
							'0';
							
	load_SESSION	<= '1' when state=LOADDATA else
							'0';
							
							
							
	load_DATA		<= '1' when state=LOADDATA	or (state=WRITEDATA3 and COUNTER/="000000") else
							'0';
							
							
	sel_DATA			<= '1' when state=LOADDATA else
							'0';				
	
	sel_TOPC			<= "00" when state=WRITEDATA0 else
							"01" when state=WRITEDATA1 else
							"10" when state=WRITEDATA2 else
							"11";
	
	SEND				<= '1' when state=WRITEDATA0 or state=WRITEDATA1 or state=WRITEDATA2 or state=WRITEDATA3 or state=WAIT4 else 
							'0';
							
	ready_to_send 	<= '1' when state=INIT1 else '0';

end arc;