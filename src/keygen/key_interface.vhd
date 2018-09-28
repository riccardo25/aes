library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity key_interface is

port(
	CLK, rst_n		: in std_logic;
	
	--INPUT FRO TOPLEVEL
	key				: in std_logic_vector( 255 downto 0);
	key_len			: in std_logic_vector( 1 downto 0);
	ROUND				: in std_logic_vector( 3 downto 0);	
	enc				: in std_logic;
	
	--INPUT FROM STORE
	
	R0in, R1in, R2in, R3in, R4in, 
	R5in, R6in, R7in, R8in, R9in, 
	R10in, R11in, R12in, R13in, R14in	: in std_logic_vector(128 downto 0);
	
	
	--OUTPUT TO GEN AND STORE
	reset				: out std_logic;
	key_out			: out std_logic_vector( 255 downto 0);
	key_len_out		: out std_logic_vector( 1 downto 0);
	
	
	--OUTPUT TO TOPLEVEL
	valid				: out std_logic;
	
	data_out 		: out std_logic_vector( 127 downto 0)
);
end key_interface;

architecture arc of key_interface is

	component reg is
		generic( N : integer);
		port (CLK, rst_n : in std_logic; load : in std_logic; D : in std_logic_vector(N-1 downto 0); Q : out std_logic_vector(N-1 downto 0));
	end component;
	
	
	component mix_columns is
		port (

		--INPUT
			enc 							: in std_logic;
			cell_num 					: in std_logic_vector (3 downto 0);
			s0c, s1c, s2c, s3c		: in std_logic_vector (7 downto 0);
			
		--OUTPUT
			Q								: out std_logic_vector (7 downto 0)
			);
	end component;


	signal 	debug_dataout				: std_logic_vector( 128 downto 0);
	signal	load_KEY, load_KEYLEN	: std_logic;
	signal 	KEY_int						: std_logic_vector( 255 downto 0);
	signal 	KEY_LEN_int					: std_logic_vector( 1 downto 0);
	signal 	inv_data_out 				: std_logic_vector( 127 downto 0);
	
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
	debug_dataout <= R0in  when ROUND = "0000" else
				R1in  when ROUND = "0001" else
				R2in  when ROUND = "0010" else
				R3in  when ROUND = "0011" else
				R4in  when ROUND = "0100" else
				R5in  when ROUND = "0101" else
				R6in  when ROUND = "0110" else
				R7in  when ROUND = "0111" else
				R8in  when ROUND = "1000" else
				R9in  when ROUND = "1001" else
				R10in when ROUND = "1010" else 
				R11in when ROUND = "1011" else 
				R12in when ROUND = "1100" else 
				R13in when ROUND = "1101" else 
				R14in when ROUND = "1110" else
				R0in;
				
	valid		<= debug_dataout(128) and rst_n;
	data_out <= debug_dataout (127 downto 0) when 	enc='1' or 
																	ROUND = X"0" or
																	(enc='0' and ROUND=X"A" and KEY_LEN_int="00") or
																	(enc='0' and ROUND=X"C" and KEY_LEN_int="01") or
																	(enc='0' and ROUND=X"E" and KEY_LEN_int="10") else
					inv_data_out;
	
	-- row 0
	MIX0	: mix_columns port map(cell_num => X"0", s0c => debug_dataout(31 downto 24), s1c => debug_dataout(23 downto 16), s2c => debug_dataout(15 downto 8), s3c => debug_dataout(7 downto 0), Q=> inv_data_out(31 downto 24), enc => '0');
	MIX1	: mix_columns port map(cell_num => X"1", s0c => debug_dataout(63 downto 56), s1c => debug_dataout(55 downto 48), s2c => debug_dataout(47 downto 40), s3c => debug_dataout(39 downto 32), Q=> inv_data_out(63 downto 56), enc => '0');	
	MIX2	: mix_columns port map(cell_num => X"2", s0c => debug_dataout(95 downto 88), s1c => debug_dataout(87 downto 80), s2c => debug_dataout(79 downto 72), s3c => debug_dataout(71 downto 64), Q=> inv_data_out(95 downto 88), enc => '0');	
	MIX3	: mix_columns port map(cell_num => X"3", s0c => debug_dataout(127 downto 120), s1c => debug_dataout(119 downto 112), s2c => debug_dataout(111 downto 104), s3c => debug_dataout(103 downto 96), Q=> inv_data_out(127 downto 120), enc => '0');	
	-- row 1
	MIX4	: mix_columns port map(cell_num => X"4", s0c => debug_dataout(31 downto 24), s1c => debug_dataout(23 downto 16), s2c => debug_dataout(15 downto 8), s3c => debug_dataout(7 downto 0), Q=> inv_data_out(23 downto 16), enc => '0');
	MIX5	: mix_columns port map(cell_num => X"5", s0c => debug_dataout(63 downto 56), s1c => debug_dataout(55 downto 48), s2c => debug_dataout(47 downto 40), s3c => debug_dataout(39 downto 32), Q=> inv_data_out(55 downto 48), enc => '0');	
	MIX6	: mix_columns port map(cell_num => X"6", s0c => debug_dataout(95 downto 88), s1c => debug_dataout(87 downto 80), s2c => debug_dataout(79 downto 72), s3c => debug_dataout(71 downto 64), Q=> inv_data_out(87 downto 80), enc => '0');	
	MIX7	: mix_columns port map(cell_num => X"7", s0c => debug_dataout(127 downto 120), s1c => debug_dataout(119 downto 112), s2c => debug_dataout(111 downto 104), s3c => debug_dataout(103 downto 96), Q=> inv_data_out(119 downto 112), enc => '0');	
	-- row 2
	MIX8	: mix_columns port map(cell_num => X"8", s0c => debug_dataout(31 downto 24), s1c => debug_dataout(23 downto 16), s2c => debug_dataout(15 downto 8), s3c => debug_dataout(7 downto 0), Q=> inv_data_out(15 downto 8), enc => '0');
	MIX9	: mix_columns port map(cell_num => X"9", s0c => debug_dataout(63 downto 56), s1c => debug_dataout(55 downto 48), s2c => debug_dataout(47 downto 40), s3c => debug_dataout(39 downto 32), Q=> inv_data_out(47 downto 40), enc => '0');	
	MIX10	: mix_columns port map(cell_num => X"A", s0c => debug_dataout(95 downto 88), s1c => debug_dataout(87 downto 80), s2c => debug_dataout(79 downto 72), s3c => debug_dataout(71 downto 64), Q=> inv_data_out(79 downto 72), enc => '0');	
	MIX11	: mix_columns port map(cell_num => X"B", s0c => debug_dataout(127 downto 120), s1c => debug_dataout(119 downto 112), s2c => debug_dataout(111 downto 104), s3c => debug_dataout(103 downto 96), Q=> inv_data_out(111 downto 104), enc => '0');	
	-- row 3
	MIX12	: mix_columns port map(cell_num => X"C", s0c => debug_dataout(31 downto 24), s1c => debug_dataout(23 downto 16), s2c => debug_dataout(15 downto 8), s3c => debug_dataout(7 downto 0), Q=> inv_data_out(7 downto 0), enc => '0');
	MIX13	: mix_columns port map(cell_num => X"D", s0c => debug_dataout(63 downto 56), s1c => debug_dataout(55 downto 48), s2c => debug_dataout(47 downto 40), s3c => debug_dataout(39 downto 32), Q=> inv_data_out(39 downto 32), enc => '0');	
	MIX14	: mix_columns port map(cell_num => X"E", s0c => debug_dataout(95 downto 88), s1c => debug_dataout(87 downto 80), s2c => debug_dataout(79 downto 72), s3c => debug_dataout(71 downto 64), Q=> inv_data_out(71 downto 64), enc => '0');	
	MIX15	: mix_columns port map(cell_num => X"F", s0c => debug_dataout(127 downto 120), s1c => debug_dataout(119 downto 112), s2c => debug_dataout(111 downto 104), s3c => debug_dataout(103 downto 96), Q=> inv_data_out(103 downto 96), enc => '0');	

end arc;

