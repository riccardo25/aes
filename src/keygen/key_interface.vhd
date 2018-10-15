library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

	entity key_interface is
		port(
			CLK, rst_n									: in std_logic;
			
			--INPUT FROM TOPLEVEL
			key											: in std_logic_vector( 255 downto 0);
			key_len										: in std_logic_vector( 1 downto 0);
			ROUND0										: in std_logic_vector( 3 downto 0);	
			enc0											: in std_logic;
			ROUND1										: in std_logic_vector( 3 downto 0);	
			enc1											: in std_logic;
			
			--INPUT FROM STORE
			R0in, R1in, R2in, R3in, R4in, 
			R5in, R6in, R7in, R8in, R9in, 
			R10in, R11in, R12in, R13in, R14in	: in std_logic_vector(128 downto 0);
			
			--OUTPUT TO GEN AND STORE
			reset											: out std_logic;
			key_out										: out std_logic_vector( 255 downto 0);
			key_len_out									: out std_logic_vector( 1 downto 0);
			
			--OUTPUT TO TOPLEVEL
			valid0										: out std_logic;
			data_out0 									: out std_logic_vector( 127 downto 0);
			valid1										: out std_logic;
			data_out1 									: out std_logic_vector( 127 downto 0)
		);
	end key_interface;

architecture arc of key_interface is

	component reg is
		generic( N : integer);
		port (CLK, rst_n : in std_logic; load : in std_logic; D : in std_logic_vector(N-1 downto 0); Q : out std_logic_vector(N-1 downto 0));
	end component;
	
	
	component key_mix is
		port(
		--INPUT
			data_in 			: in std_logic_vector(127 downto 0);
		--OUTPUT
			data_inverted	: out std_logic_vector(127 downto 0)
		);
	end component;


	signal 	direct_dataout0, direct_dataout1		: std_logic_vector( 128 downto 0);
	signal	load_KEY, load_KEYLEN					: std_logic;
	signal 	KEY_int										: std_logic_vector( 255 downto 0);
	signal 	KEY_LEN_int									: std_logic_vector( 1 downto 0);
	signal 	inv_data_out0, inv_data_out1			: std_logic_vector( 127 downto 0);
	
	type statetype is (INIT0, WORKING);
	signal state, nextstate : statetype;
	

begin

--CONTROLUNIT

	state <= INIT0 	when rst_n = '0' else nextstate when rising_edge(CLK);
	
	process (state, key, key_len, KEY_int, KEY_LEN_int)
	begin
		
		case state is
			when INIT0 =>
				nextstate <= WORKING;
			when WORKING =>
			
				if( key /= KEY_int or key_len /= KEY_LEN_int) then
					nextstate <= INIT0;
				else
					nextstate <= WORKING;
				end if;
				
		end case;
	end process;


	load_KEY 		<= '1' when state=INIT0 else '0';
	load_KEYLEN 	<= '1' when state=INIT0 else '0';
	reset				<= '0' when state=INIT0 else '1';


--DATAPATH

	
	regKEY	: reg generic map(256) port map (CLK => CLK, rst_n => rst_n, load => load_KEY, D => key, Q => KEY_int);
	regKEYLEN: reg generic map(2) port map (CLK => CLK, rst_n => rst_n, load => load_KEYLEN, D => key_len, Q => KEY_LEN_int);

	key_out <= KEY_int;
	key_len_out <= KEY_LEN_int;
	
--TO TOPLEVEL
	
	-- OUT 0
	direct_dataout0 <= 	R0in  when ROUND0 = "0000" else
								R1in  when ROUND0 = "0001" else
								R2in  when ROUND0 = "0010" else
								R3in  when ROUND0 = "0011" else
								R4in  when ROUND0 = "0100" else
								R5in  when ROUND0 = "0101" else
								R6in  when ROUND0 = "0110" else
								R7in  when ROUND0 = "0111" else
								R8in  when ROUND0 = "1000" else
								R9in  when ROUND0 = "1001" else
								R10in when ROUND0 = "1010" else 
								R11in when ROUND0 = "1011" else 
								R12in when ROUND0 = "1100" else 
								R13in when ROUND0 = "1101" else 
								R14in when ROUND0 = "1110" else
								R0in;
				
	valid0		<= direct_dataout0(128) and rst_n;
	
	MIX0 : key_mix port map( data_in => direct_dataout0(127 downto 0), data_inverted =>inv_data_out0 );
	
	data_out0 	<= direct_dataout0(127 downto 0) when 	enc0='1' or 
																		ROUND0 = X"0" or
																		(enc0='0' and ROUND0=X"A" and KEY_LEN_int="00") or
																		(enc0='0' and ROUND0=X"C" and KEY_LEN_int="01") or
																		(enc0='0' and ROUND0=X"E" and KEY_LEN_int="10") else
						inv_data_out0;
	-- OUT 1
	direct_dataout1 <= 	R0in  when ROUND1 = "0000" else
								R1in  when ROUND1 = "0001" else
								R2in  when ROUND1 = "0010" else
								R3in  when ROUND1 = "0011" else
								R4in  when ROUND1 = "0100" else
								R5in  when ROUND1 = "0101" else
								R6in  when ROUND1 = "0110" else
								R7in  when ROUND1 = "0111" else
								R8in  when ROUND1 = "1000" else
								R9in  when ROUND1 = "1001" else
								R10in when ROUND1 = "1010" else 
								R11in when ROUND1 = "1011" else 
								R12in when ROUND1 = "1100" else 
								R13in when ROUND1 = "1101" else 
								R14in when ROUND1 = "1110" else
								R0in;
				
	valid1		<= direct_dataout1(128) and rst_n;
	
	MIX1 : key_mix port map( data_in => direct_dataout1(127 downto 0), data_inverted =>inv_data_out1 );
	
	data_out1 	<= direct_dataout1(127 downto 0) when 	enc1='1' or 
																		ROUND1 = X"0" or
																		(enc1='0' and ROUND1=X"A" and KEY_LEN_int="00") or
																		(enc1='0' and ROUND1=X"C" and KEY_LEN_int="01") or
																		(enc1='0' and ROUND1=X"E" and KEY_LEN_int="10") else
						inv_data_out1;
	
	
	
	
	
	
end arc;

