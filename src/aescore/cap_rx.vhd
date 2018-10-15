library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity cap_rx is
    port(
	--INPUTS
		CLK, rst_n						: in std_logic;
		
		--from CIPHER
		ready_for_data					: in std_logic;
		ready_for_key					: in std_logic;
		
		--from SERIAL
		RX_FRAMEERR, RX_DATAVALID	: in std_logic;
		data_from_pc					: in std_logic_vector(7 downto 0);
		
	--OUTPUTS
		--to TOPLEVEL
		KEY								: out std_logic_vector(255 downto 0);
		ENC								: out std_logic;
		KEY_LEN							: out std_logic_vector(1 downto 0);
		SESSION							: out std_logic_vector(7 downto 0);
		DATA								: out std_logic_vector(127 downto 0);
		data_valid, key_valid		: out std_logic
		
	);
end cap_rx;

architecture arc of cap_rx is


	component cap_rx_ctrlunit is

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

	end component;
	
	
	component cap_rx_datapath is

		port(
			CLK, rst_n 									: in std_logic;
		--INPUTS
			--from CONTROL UNIT
			reset_reg, load_COUNTER, load_ENC, 
			load_SESSION, load_KEY_LEN, 
			load_KEY, load_DATA, reset_COUNTER	: in std_logic;
			sel_KEY_LEN									: in std_logic;
				
			--from SERIAL
			data_from_pc								: in std_logic_vector(7 downto 0);
		--OUTPUTS
			--to control unit
			COUNTER										: out std_logic_vector(5 downto 0);
			
			--to toplevel
			KEY											: out std_logic_vector(255 downto 0);
			ENC											: out std_logic;
			KEY_LEN										: out std_logic_vector(1 downto 0);
			SESSION										: out std_logic_vector(7 downto 0);
			DATA											: out std_logic_vector(127 downto 0)
			
			--to serial
		
		);
	end component;
	
	
	
	
	signal 	reset_reg, load_COUNTER, load_ENC, 
				load_SESSION, load_KEY_LEN, 
				load_KEY, load_DATA, reset_COUNTER	: std_logic;
	signal 	sel_KEY_LEN									: std_logic;
	signal	COUNTER										: std_logic_vector(5 downto 0);
	

begin



	CTRLUNIT:	cap_rx_ctrlunit port map(	CLK => CLK, rst_n => rst_n,
														COUNTER => COUNTER,
														ready_for_data => ready_for_data,
														ready_for_key => ready_for_key,
														RX_FRAMEERR => RX_FRAMEERR, RX_DATAVALID => RX_DATAVALID,
														data_from_pc => data_from_pc,
														reset_reg => reset_reg, load_COUNTER => load_COUNTER, load_ENC => load_ENC, 
														load_SESSION => load_SESSION, load_KEY_LEN => load_KEY_LEN, 
														load_KEY => load_KEY, load_DATA => load_DATA, reset_COUNTER	 => reset_COUNTER,
														sel_KEY_LEN => sel_KEY_LEN,
														data_valid => data_valid, key_valid	=> key_valid );
	
	DATAPATH:	cap_rx_datapath port map( 	CLK => CLK, rst_n => rst_n,
														reset_reg => reset_reg, load_COUNTER => load_COUNTER, load_ENC => load_ENC,
														load_SESSION => load_SESSION, load_KEY_LEN => load_KEY_LEN, 
														load_KEY => load_KEY, load_DATA => load_DATA, reset_COUNTER	 => reset_COUNTER,
														sel_KEY_LEN => sel_KEY_LEN,
														data_from_pc => data_from_pc,
														COUNTER => COUNTER,
														KEY => KEY,
														ENC => ENC,
														KEY_LEN => KEY_LEN,
														SESSION => SESSION,
														DATA => DATA );

end arc;

