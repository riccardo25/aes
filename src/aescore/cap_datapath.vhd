library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cap_datapath is

	port(
		CLK, rst_n 									: in std_logic;
	--INPUTS
		--from CONTROL UNIT
		reset_reg, load_COUNTER, load_ENC, 
		load_SESSION, load_KEY_LEN, 
		load_KEY, load_DATA, reset_COUNTER	: in std_logic;
		sel_KEY_LEN, sel_DATA					: in std_logic;
		sel_TOPC										: in std_logic_vector(1 downto 0);
		--FROM CIPHER
		data_from_cipher							: in std_logic_vector(127 downto 0);
			
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
		DATA											: out std_logic_vector(127 downto 0);
		
		--to serial
		data_to_pc									: out std_logic_vector(7 downto 0)
	
	);
end cap_datapath;

architecture arc of cap_datapath is

	component adder2input is
		generic (N: integer);
		port (
			I0 : in std_logic_vector(N-1 downto 0);
			I1 : in std_logic_vector(N-1 downto 0);
			Y : out std_logic_vector(N-1 downto 0)
		);
	end component;

	component mux2input is
		generic (N: integer);
		port (
			sel : in std_logic;
			I0 : in std_logic_vector(N-1 downto 0);
			I1 : in std_logic_vector(N-1 downto 0);
			Y : out std_logic_vector(N-1 downto 0)
		);
	end component;
	
	component mux4input is
		generic (N: integer);
		port (
			sel : in std_logic_vector(1 downto 0);
			I0 : in std_logic_vector(N-1 downto 0);
			I1 : in std_logic_vector(N-1 downto 0);
			I2 : in std_logic_vector(N-1 downto 0);
			I3 : in std_logic_vector(N-1 downto 0);
			Y : out std_logic_vector(N-1 downto 0)
		);
	end component;

	component reg is
		generic( N : integer);
		port (CLK, rst_n : in std_logic; load : in std_logic; D : in std_logic_vector(N-1 downto 0); Q : out std_logic_vector(N-1 downto 0));
	end component;


--	signal mux_DATAPC_out, DATAPC_in, DATAPC_out : std_logic_vector(15 downto 0);

	signal 	COUNTER_in, COUNTER_out 								: std_logic_vector(5 downto 0);
	signal 	ENC_out														: std_logic;
	signal 	SESSION_out													: std_logic_vector(7 downto 0);
	signal 	KEY_LEN_in, KEY_LEN_out									: std_logic_vector(1 downto 0);
	
	signal 	KEY0_out, KEY1_out, KEY2_out, KEY3_out, 
				KEY4_out, KEY5_out, KEY6_out, KEY7_out, 
				KEY8_out, KEY9_out, KEY10_out, KEY11_out, 
				KEY12_out, KEY13_out, KEY14_out, KEY15_out,
				KEY16_out, KEY17_out, KEY18_out, KEY19_out, 
				KEY20_out, KEY21_out, KEY22_out, KEY23_out, 
				KEY24_out, KEY25_out, KEY26_out, KEY27_out, 
				KEY28_out, KEY29_out, KEY30_out, KEY31_out		: std_logic_vector(7 downto 0);
	
	signal 	DATA0_out, DATA1_out, DATA2_out, DATA3_out, 
				DATA4_out, DATA5_out, DATA6_out, DATA7_out, 
				DATA8_out, DATA9_out, DATA10_out, DATA11_out, 
				DATA12_out, DATA13_out, DATA14_out, DATA15_out	: std_logic_vector(7 downto 0);
				
	signal 	mux0_out, mux1_out, mux2_out, mux3_out, 
				mux4_out, mux5_out, mux6_out, mux7_out, 
				mux8_out, mux9_out, mux10_out, mux11_out, 
				mux12_out, mux13_out, mux14_out, mux15_out	: std_logic_vector(7 downto 0);
begin


--COUNTER
	ADD1		: adder2input generic map(6) port map(I0 => "000001", I1 => COUNTER_out, Y => COUNTER_in);
	COUNT0	: reg generic map(6) port map (CLK => CLK, rst_n => reset_COUNTER, load => load_COUNTER, D => COUNTER_in, Q => COUNTER_out);
	COUNTER 		<= COUNTER_out;
	
--ENC
	ENC_out 		<= '0' when reset_reg='0' else '1' when rising_edge(CLK) and load_ENC='1';
	ENC <= ENC_out;
	
--SESSION
	SESSIO0	: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_SESSION, D => data_from_PC, Q => SESSION_out);
	SESSION <= SESSION_out;
--KEY_LEN
	MUXLEN	: mux2input generic map(2) port map(sel =>sel_KEY_LEN, I0 => "01", I1 => "10", Y => KEY_LEN_in);
	KEYLEN0	: reg generic map(2) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY_LEN, D => KEY_LEN_in, Q => KEY_LEN_out);
	KEY_LEN <= KEY_LEN_out;

--KEY
	KEY0		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => data_from_PC, Q => KEY0_out);
	KEY1		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY0_out, Q => KEY1_out);
	KEY2		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY1_out, Q => KEY2_out);
	KEY3		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY2_out, Q => KEY3_out);
	KEY4		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY3_out, Q => KEY4_out);
	KEY5		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY4_out, Q => KEY5_out);
	KEY6		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY5_out, Q => KEY6_out);
	KEY7		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY6_out, Q => KEY7_out);
	KEY8		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY7_out, Q => KEY8_out);
	KEY9		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY8_out, Q => KEY9_out);
	KEY10		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY9_out, Q => KEY10_out);
	KEY11		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY10_out, Q => KEY11_out);
	KEY12		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY11_out, Q => KEY12_out);
	KEY13		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY12_out, Q => KEY13_out);
	KEY14		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY13_out, Q => KEY14_out);
	KEY15		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY14_out, Q => KEY15_out);
	KEY16		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY15_out, Q => KEY16_out);
	KEY17		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY16_out, Q => KEY17_out);
	KEY18		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY17_out, Q => KEY18_out);
	KEY19		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY18_out, Q => KEY19_out);
	KEY20		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY19_out, Q => KEY20_out);
	KEY21		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY20_out, Q => KEY21_out);
	KEY22		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY21_out, Q => KEY22_out);
	KEY23		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY22_out, Q => KEY23_out);
	KEY24		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY23_out, Q => KEY24_out);
	KEY25		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY24_out, Q => KEY25_out);
	KEY26		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY25_out, Q => KEY26_out);
	KEY27		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY26_out, Q => KEY27_out);
	KEY28		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY27_out, Q => KEY28_out);
	KEY29		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY28_out, Q => KEY29_out);
	KEY30		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY29_out, Q => KEY30_out);
	KEY31		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_KEY, D => KEY30_out, Q => KEY31_out);
	
	KEY <= 	KEY31_out & KEY30_out & KEY29_out & KEY28_out & KEY27_out & KEY26_out & KEY25_out & 
				KEY24_out & KEY23_out & KEY22_out & KEY21_out & KEY20_out & KEY19_out & KEY18_out & 
				KEY17_out & KEY16_out &KEY15_out & KEY14_out & KEY13_out & KEY12_out & KEY11_out & KEY10_out & KEY9_out & 
				KEY8_out & KEY7_out & KEY6_out & KEY5_out & KEY4_out & KEY3_out & KEY2_out & 
				KEY1_out & KEY0_out;
				

--DATA
	MUX0		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => data_from_PC, I1 => data_from_cipher(7 downto 0), Y => mux0_out);
	DATA0		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux0_out, Q => DATA0_out);
	MUX1		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => DATA0_out, I1 => data_from_cipher(15 downto 8), Y => mux1_out);
	DATA1		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux1_out, Q => DATA1_out);
	MUX2		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => DATA1_out, I1 => data_from_cipher(23 downto 16), Y => mux2_out);
	DATA2		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux2_out, Q => DATA2_out);
	MUX3		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => DATA2_out, I1 => data_from_cipher(31 downto 24), Y => mux3_out);
	DATA3		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux3_out, Q => DATA3_out);
	MUX4		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => DATA3_out, I1 => data_from_cipher(39 downto 32), Y => mux4_out);
	DATA4		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux4_out, Q => DATA4_out);
	MUX5		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => DATA4_out, I1 => data_from_cipher(47 downto 40), Y => mux5_out);
	DATA5		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux5_out, Q => DATA5_out);
	MUX6		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => DATA5_out, I1 => data_from_cipher(55 downto 48), Y => mux6_out);
	DATA6		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux6_out, Q => DATA6_out);
	MUX7		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => DATA6_out, I1 => data_from_cipher(63 downto 56), Y => mux7_out);
	DATA7		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux7_out, Q => DATA7_out);
	MUX8		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => DATA7_out, I1 => data_from_cipher(71 downto 64), Y => mux8_out);
	DATA8		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux8_out, Q => DATA8_out);
	MUX9		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => DATA8_out, I1 => data_from_cipher(79 downto 72), Y => mux9_out);
	DATA9		: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux9_out, Q => DATA9_out);
	MUX10		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => DATA9_out, I1 => data_from_cipher(87 downto 80), Y => mux10_out);
	DATA10	: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux10_out, Q => DATA10_out);
	MUX11		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => DATA10_out, I1 => data_from_cipher(95 downto 88), Y => mux11_out);
	DATA11	: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux11_out, Q => DATA11_out);
	MUX12		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => DATA11_out, I1 => data_from_cipher(103 downto 96), Y => mux12_out);
	DATA12	: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux12_out, Q => DATA12_out);
	MUX13		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => DATA12_out, I1 => data_from_cipher(111 downto 104), Y => mux13_out);
	DATA13	: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux13_out, Q => DATA13_out);
	MUX14		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => DATA13_out, I1 => data_from_cipher(119 downto 112), Y => mux14_out);
	DATA14	: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux14_out, Q => DATA14_out);
	MUX15		: mux2input generic map(8) port map(sel =>sel_DATA, I0 => DATA14_out, I1 => data_from_cipher(127 downto 120), Y => mux15_out);
	DATA15	: reg generic map(8) port map (CLK => CLK, rst_n => reset_reg, load => load_DATA, D => mux15_out, Q => DATA15_out);
	DATA <= DATA15_out & DATA14_out & DATA13_out & DATA12_out & DATA11_out & DATA10_out & DATA9_out & DATA8_out & DATA7_out & DATA6_out & DATA5_out & DATA4_out & DATA3_out & DATA2_out & DATA1_out & DATA0_out;

--DATA_TO_PC

	MUXTOPC	: mux4input generic map(8) port map(sel => sel_TOPC, I0=> X"03", I1 => X"04", I2=>SESSION_out, I3 =>DATA15_out, Y => data_to_pc);

end arc;

