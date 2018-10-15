library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

	entity cbc is

		port(
				CLK, rst_n 			: in std_logic;
				
			-- INPUT
				
				--from interface
				data_in				: in std_logic_vector (127 downto 0);
				enc_in				: in std_logic;
				session_in			: in std_logic_vector (7 downto 0);
				key_in				: in std_logic_vector (255 downto 0);
				key_len_in			: in std_logic_vector (1 downto 0);
				valid_input			: in std_logic;
				
				--from cipher
				cryptrounddata		: in std_logic_vector (31 downto 0);
				cryptround_valid	: in std_logic;
				loading				: in std_logic;
				
			-- OUTPUT
				--to DATA UNIT
				tocryptdata			: out std_logic_vector (31 downto 0);
				curr_enc				: out std_logic;
				reset_du				: out std_logic;
				
				--to CIPHER
				curr_key				: out std_logic_vector (255 downto 0);
				curr_key_len		: out std_logic_vector (1 downto 0);
				curr_session		: out std_logic_vector (7 downto 0);
				
				--to TOP LEVEL
				ready_for_input	: out std_logic;
				valid_out 			: out std_logic;
				data_out				: out std_logic_vector (127 downto 0)
			);
	end cbc;

architecture arc of cbc is

	component reg is
		generic( N : integer);
		port (CLK, rst_n : in std_logic; load : in std_logic; D : in std_logic_vector(N-1 downto 0); Q : out std_logic_vector(N-1 downto 0));
	end component;
	
	component mux4input is
		generic (N: integer);
		port (
			sel 	: in std_logic_vector(1 downto 0);
			I0 	: in std_logic_vector(N-1 downto 0);
			I1 	: in std_logic_vector(N-1 downto 0);
			I2 	: in std_logic_vector(N-1 downto 0);
			I3 	: in std_logic_vector(N-1 downto 0);
			Y 		: out std_logic_vector(N-1 downto 0)
		);
	end component;
	
	signal 	reset_reg 								: std_logic;
	signal 	load_D0, load_D1, 
				load_D2, load_D3						: std_logic;
	signal	sel_tocrypt								: std_logic_vector(1 downto 0);
	signal 	key_out									: std_logic_vector(255 downto 0);
	signal 	key_len_out								: std_logic_vector(1 downto 0);
	signal 	datain_out								: std_logic_vector(127 downto 0);
	signal 	session_out								: std_logic_vector(7 downto 0);
	signal 	enc_out									: std_logic;
	signal 	load_inputs								: std_logic;
				
				
	type statetype is (	INIT0, NOTREADY, WAIT0,
								ROUND0, ROUND1, ROUND2, ROUND3,
								LOAD0, LOAD1, LOAD2, LOAD3,
								PRINTOUT0);
	signal state, nextstate : statetype;
	
	

begin


--CONTROL UNIT

	state <= 	INIT0	when rst_n = '0' else nextstate when rising_edge(CLK);
	
	process (state, cryptrounddata, cryptround_valid, data_in, loading, enc_out, valid_input)
	begin
	
		case state is
			when INIT0 =>
			
				if( valid_input ='1') then
					nextstate <= NOTREADY;
				else
					nextstate <= INIT0;
				end if;
				
			when NOTREADY =>
			
				if( loading = '1') then
					nextstate <= LOAD0;
				else 
					nextstate <= WAIT0;
				end if;
				
			when WAIT0 =>
			
				if( loading = '1') then
					nextstate <= LOAD0;
				else 
					nextstate <= WAIT0;
				end if;
			
			when LOAD0=> 
				nextstate <= LOAD1;
			when LOAD1=>
				nextstate <= LOAD2;
			when LOAD2 =>
				nextstate <= LOAD3;
			when LOAD3 =>
			
				if( cryptround_valid = '1') then
					nextstate <=ROUND0;
				else
					nextstate <=LOAD3;
				end if;
				
			when ROUND0 => 
				nextstate <= ROUND1;
			when ROUND1 =>
				nextstate <= ROUND2;
			when ROUND2 =>
				nextstate <= ROUND3;
			when ROUND3 =>
				nextstate <= PRINTOUT0;
			when PRINTOUT0 =>
				nextstate <= PRINTOUT0;
			when others =>
				nextstate <= INIT0;
		end case;
	end process;

	
	reset_reg 			<= '0' 	when rst_n='0' or state=INIT0 else '1';
	load_inputs 		<= '1'	when state=NOTREADY else '0';
	
	load_D3				<=	'1' 	when state=ROUND0 else '0';
	load_D2				<=	'1' 	when state=ROUND1 else '0';
	load_D1				<=	'1' 	when state=ROUND2 else '0';
	load_D0				<=	'1' 	when state=ROUND3 else '0';
						
	sel_tocrypt 		<=	"00" 	when state=LOAD0 or state=INIT0  or state=NOTREADY or state=WAIT0 else
								"01" 	when state=LOAD1 else
								"10"	when state=LOAD2 else
								"11" 	when state=LOAD3 else
								"00";
						
	valid_out 			<= '1' 	when state=PRINTOUT0 else '0';
	
	ready_for_input 	<= '1' when state=INIT0 or state=NOTREADY  else
								'0';
								
	reset_du 			<= '0' when state=INIT0 or state=NOTREADY or state=PRINTOUT0 or rst_n ='0' else
								'1';
							
						

-- DATAPATH

	DATIN : reg generic map(128)	port map(CLK => CLK, rst_n => reset_reg, load => load_inputs, D => data_in, Q => datain_out);
	SESIN : reg generic map(8)	port map(CLK => CLK, rst_n => reset_reg, load => load_inputs, D => session_in, Q => session_out);
	KEYIN : reg generic map(256)	port map(CLK => CLK, rst_n => reset_reg, load => load_inputs, D => key_in, Q => key_out);
	KLEIN : reg generic map(2)	port map(CLK => CLK, rst_n => reset_reg, load => load_inputs, D => key_len_in, Q => key_len_out);
	enc_out <= '0'	when reset_reg='0' else enc_in when rising_edge(CLK) and load_inputs='1';
	
	D0		: reg generic map(32)	port map(CLK => CLK, rst_n => reset_reg, load => load_D0, D => cryptrounddata, Q => data_out (31 downto 0));
	D1		: reg generic map(32)	port map(CLK => CLK, rst_n => reset_reg, load => load_D1, D => cryptrounddata, Q => data_out (63 downto 32));
	D2		: reg generic map(32)	port map(CLK => CLK, rst_n => reset_reg, load => load_D2, D => cryptrounddata, Q => data_out (95 downto 64));
	D3		: reg generic map(32)	port map(CLK => CLK, rst_n => reset_reg, load => load_D3, D => cryptrounddata, Q => data_out (127 downto 96));


	MUX1 	: mux4input 	generic map(32) port map(sel => sel_tocrypt, I0 => datain_out(127 downto 96), I1 => datain_out(95 downto 64), I2 =>datain_out(63 downto 32), I3 => datain_out(31 downto 0), Y=>tocryptdata);
	
	
	--OUTPUTS
	curr_key 			<= key_out;
	curr_key_len 		<= key_len_out;
	curr_enc				<= enc_out;
	curr_session		<= session_out;
	
end arc;

