library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity cap_controlunit is

	port(
		CLK, rst_n 									: in std_logic;
	--INPUTS
		--FROM DATAPATH
		COUNTER										: in std_logic_vector(5 downto 0);
		ENC											: in std_logic;
		--from CIPHER
		ready_for_data								: in std_logic;
		ready_for_key								: in std_logic;
		valid_from_cipher							: in std_logic;
		
		--from SERIAL
		RX_FRAMEERR, RX_DATAVALID, TX_DONE  : in std_logic;
		data_from_pc								: in std_logic_vector(7 downto 0);
		
	--OUTPUTS
		--TO DATAPATH
		reset_reg, load_COUNTER, load_ENC, 
		load_SESSION, load_KEY_LEN, 
		load_KEY, load_DATA, reset_COUNTER	: out std_logic;
		sel_KEY_LEN, sel_DATA					: out std_logic;
		sel_TOPC										: out std_logic_vector(1 downto 0);
		--TO CIPHER
		data_valid, key_valid					: out std_logic;
		
		--TO SERIAL
		SEND 											: out std_logic
		
	);

end cap_controlunit;

architecture arc of cap_controlunit is


	type statetype is (	INIT0,
								READDATA1, READDATA2, READDATA3, READDATA4, READDATA5,READDATA6, READDATA7, READDATA8,
								WAIT1, WAIT2, WAIT3, WAIT4,
								
								USELESS1, USELESS2,
								CIPHERLOAD, LOADDATA,
								WRITEDATA0, WRITEDATA1, WRITEDATA2, WRITEDATA3,
								TERMINATE);
	signal state, nextstate : statetype;
	
	
	signal data_arrived	: std_logic;

begin

	state <= INIT0 when rst_n = '0' else nextstate when rising_edge(CLK);

	process (state, data_arrived, TX_DONE, data_from_PC, COUNTER, ready_for_data, ready_for_key, valid_from_cipher, ENC)
	begin
	
		case state is

			when INIT0 =>
			
				if(data_arrived = '1' and data_from_PC = X"01" ) then 
					nextstate <= READDATA1;
				elsif(data_arrived = '1' and data_from_PC = X"02" ) then 
					nextstate <= READDATA2;
				else
					nextstate <= INIT0;
				end if;
				
			when READDATA1 =>
				
				if(data_arrived = '1') then 
					nextstate <= READDATA3;
				else
					nextstate <= READDATA1;
				end if;
				
			when READDATA2 =>
				
				if(data_arrived = '1') then 
					nextstate <= READDATA3;
				else
					nextstate <= READDATA2;
				end if;
				
			when READDATA3 =>
				
				if(data_arrived = '1' and data_from_PC = X"00" ) then 
					nextstate <= READDATA4;
				elsif(data_arrived = '1' and data_from_PC = X"01" ) then 
					nextstate <= READDATA5;
				elsif(data_arrived = '1' and data_from_PC = X"02" ) then 
					nextstate <= READDATA6;
				elsif(data_arrived = '1') then 
					nextstate <= INIT0;
				else
					nextstate <= WAIT1;
				end if;
				
			when WAIT1 =>
				
				if(data_arrived = '1' and data_from_PC = X"00" ) then 
					nextstate <= READDATA4;
				elsif(data_arrived = '1' and data_from_PC = X"01" ) then 
					nextstate <= READDATA5;
				elsif(data_arrived = '1' and data_from_PC = X"02" ) then 
					nextstate <= READDATA6;
				elsif(data_arrived = '1') then 
					nextstate <= INIT0;
				else
					nextstate <= WAIT1;
				end if;
				
			when READDATA4 =>
			
				if(data_arrived = '1') then 
					nextstate <= READDATA7;
				else
					nextstate <= READDATA4;
				end if;
				
			when READDATA5 =>
			
				if(data_arrived = '1') then 
					nextstate <= READDATA7;
				else
					nextstate <= READDATA5;
				end if;
				
			when READDATA6 =>
			
				if(data_arrived = '1') then 
					nextstate <= READDATA7;
				else
					nextstate <= READDATA6;
				end if;
				
			when READDATA7 =>
			
				if(data_arrived = '1' and COUNTER = "100000" ) then --20 HEX = 32 DEC
					nextstate <= READDATA8;
				elsif(data_arrived = '1') then 
					nextstate <= READDATA7;
				else
					nextstate <= WAIT2;
				end if;
				
			when WAIT2 =>
				
				if(data_arrived = '1' and COUNTER = "100000" ) then --20 HEX = 32 DEC
					nextstate <= READDATA8;
				elsif(data_arrived = '1') then 
					nextstate <= READDATA7;
				else
					nextstate <= WAIT2;
				end if;
				
			when READDATA8 =>
			
				if( COUNTER = "101111" ) then -- 47 DEC
					nextstate <= USELESS1;
				elsif(data_arrived = '1') then 
					nextstate <= READDATA8;
				else
					nextstate <= WAIT3;
				end if;
				
			when WAIT3 =>
				
				if(data_arrived = '1' ) then 
					nextstate <= READDATA8;
				else
					nextstate <= WAIT3;
				end if;
				
			when USELESS1 => 
			
				if(ready_for_data = '1' and ready_for_key = '1' ) then
					nextstate <= CIPHERLOAD;
				else
					nextstate <= USELESS1;
				end if;
				
			when CIPHERLOAD => 
			
				if(ready_for_data = '1' or ready_for_key = '1' ) then 
					nextstate <= CIPHERLOAD;
				else
					nextstate <= USELESS2;
				end if;
				
			when USELESS2 =>
			
				if(valid_from_cipher = '1' ) then 
					nextstate <= LOADDATA;
				else
					nextstate <= USELESS2;
				end if;
				
			when LOADDATA =>
			
				if(ENC = '0' ) then 
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
					nextstate <= INIT0;
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
			
				
			when TERMINATE =>
			
				nextstate <= TERMINATE;
				
			when others =>
				nextstate <= INIT0;
		end case;
	end process;
	
	data_arrived 	<= '1' when RX_DATAVALID = '1' and RX_FRAMEERR = '0' else '0';
	
	reset_reg		<= '0' when rst_n ='0' or state=INIT0 else 
							'1';
							
	reset_COUNTER 	<= '0' when rst_n ='0' or state=INIT0 or state=WRITEDATA2 else 
							'1';
							
	load_COUNTER	<= '1' when state=READDATA7 or state=READDATA8 or state=WRITEDATA3 else
							'0';
							
	load_ENC			<= '1' when state=READDATA1 else
							'0';
							
	load_SESSION	<= '1' when state=READDATA3 else
							'0';
							
	load_KEY_LEN	<= '1' when state=READDATA5 or state=READDATA6 else
							'0';
							
	sel_KEY_LEN		<= '0' when state=READDATA5 else
							'1';
							
	load_KEY			<= '1' when state=READDATA7 else
							'0';
							
	load_DATA		<= '1' when state=READDATA8 or state=LOADDATA or (state=WRITEDATA3 and COUNTER/="000000") else
							'0';
							
	data_valid		<= '1' when state=CIPHERLOAD else
							'0';
							
	key_valid		<= '1' when state=CIPHERLOAD else
							'0';
							
	sel_DATA			<= '1' when state=LOADDATA else
							'0';				
	
	sel_TOPC			<= "00" when state=WRITEDATA0 else
							"01" when state=WRITEDATA1 else
							"10" when state=WRITEDATA2 else
							"11";
	
	SEND				<= '1' when state=WRITEDATA0 or state=WRITEDATA1 or state=WRITEDATA2 or state=WRITEDATA3 or state=WAIT4 else 
							'0';

end arc;

