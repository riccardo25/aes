library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity cap_rx_ctrlunit is

	port(
		CLK, rst_n 									: in std_logic;
	--INPUTS
		--FROM DATAPATH
		COUNTER										: in std_logic_vector(5 downto 0);
		
		--from CIPHER
		ready_for_data								: in std_logic;
		ready_for_key								: in std_logic;
		
		--from SERIAL
		RX_FRAMEERR, RX_DATAVALID				: in std_logic;
		data_from_pc								: in std_logic_vector(7 downto 0);
		
	--OUTPUTS
		--TO DATAPATH
		reset_reg, load_COUNTER, load_ENC, 
		load_SESSION, load_KEY_LEN, 
		load_KEY, load_DATA, reset_COUNTER	: out std_logic;
		sel_KEY_LEN									: out std_logic;
		
		--TO CIPHER
		data_valid, key_valid					: out std_logic
		
		--TO SERIAL
		
	);

end cap_rx_ctrlunit;

architecture arc of cap_rx_ctrlunit is


	type statetype is (	INIT0,
								READDATA1, READDATA2, READDATA3, READDATA4, READDATA5,READDATA6, READDATA7, READDATA8,
								WAIT1, WAIT2, WAIT3,
								
								USELESS1,
								CIPHERLOAD, CIPHERLOAD2);
	signal state, nextstate : statetype;
	
	
	signal data_arrived	: std_logic;

begin

	state <= INIT0 when rst_n = '0' else nextstate when rising_edge(CLK);

	process (state, data_arrived, data_from_PC, COUNTER, ready_for_data, ready_for_key)
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
					nextstate <= CIPHERLOAD2;
			
			when CIPHERLOAD2 =>
			
				nextstate <= INIT0;

			when others =>
				nextstate <= INIT0;
		end case;
	end process;
	
	data_arrived 	<= '1' when RX_DATAVALID = '1' and RX_FRAMEERR = '0' else '0';
	
	reset_reg		<= '0' when rst_n ='0' or state=INIT0 else 
							'1';
							
	reset_COUNTER 	<= '0' when rst_n ='0' or state=INIT0 else 
							'1';
							
	load_COUNTER	<= '1' when state=READDATA7 or state=READDATA8  else
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
							
	load_DATA		<= '1' when state=READDATA8 else
							'0';
							
	data_valid		<= '1' when state=CIPHERLOAD or state=USELESS1 or state=CIPHERLOAD2 else
							'0';
							
	key_valid		<= '1' when state=CIPHERLOAD or state=USELESS1 or state=CIPHERLOAD2 else
							'0';
							

end arc;

