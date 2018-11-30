library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.athena_package.all;

entity test_dac_filter is
end test_dac_filter;

architecture test_DAC of test_dac_filter is

signal CLK_4X		: std_logic:='0';
signal ENABLE_CLK_1X	: std_logic:='0';
signal ENABLE		: std_logic:='1';
signal ENABLE_2X	: std_logic:='0';
signal Reset          	: std_logic:='1';
signal START_STOP    	: std_logic:='0';
signal sequencer      	: unsigned(1 downto 0);
signal increment      	: unsigned(counter_size-1 downto 0):="01101000010000000000";
signal phi_delay      	: unsigned(Size_dds_phi-1 downto 0):="00000000";
signal phi_rotate     	: unsigned(Size_dds_phi-1 downto 0):="00000000";
signal phi_initial    	: unsigned(Size_dds_phi_ini-1 downto 0):="000000000000";
signal bias_amplitude 	: unsigned(Size_bias_amplitude-1 downto 0):="11111111";
signal bias           	: signed(Size_DDS_Sine_Out-1 downto 0);
signal demoduI        	: signed(Size_DDS_Sine_Out-1 downto 0);
signal demoduQ        	: signed(Size_DDS_Sine_Out-1 downto 0);
signal remoduI        	: signed(Size_DDS_Sine_Out-1 downto 0);
signal remoduQ        	: signed(Size_DDS_Sine_Out-1 downto 0);
signal input		: signed(Size_DAC-1 downto 0);
signal output		: signed(Size_DAC-1 downto 0);
signal sig_in		: signed(Size_DAC-1 downto 0);
signal sig_out		: signed(Size_DAC-1 downto 0);
signal inc 		: unsigned(1 downto 0):="00";
signal n_inc		: unsigned(15 downto 0):="0000000000000000";
signal sig		: signed(Size_DAC-1 downto 0):="0000000000000001";
signal inc_enable	: std_logic:='0';

--component sine_generator
--port(
--	CLK_4X		: in std_logic;
--	ENABLE_CLK_1X	: in std_logic;
--	Reset          	: in std_logic;
--	START_STOP    	: in std_logic;
--	sequencer      	: in unsigned(1 downto 0);
--	increment      	: in unsigned(counter_size-1 downto 0);
--	phi_delay      	: in unsigned(Size_dds_phi-1 downto 0);
--	phi_rotate     	: in unsigned(Size_dds_phi-1 downto 0);
--	phi_initial    	: in unsigned(Size_dds_phi_ini-1 downto 0);
--	bias_amplitude 	: in unsigned(Size_bias_amplitude-1 downto 0);
--	bias           	: out signed(Size_DDS_Sine_Out-1 downto 0);
--	demoduI        	: out signed(Size_DDS_Sine_Out-1 downto 0);
--	demoduQ        	: out signed(Size_DDS_Sine_Out-1 downto 0);
--	remoduI        	: out signed(Size_DDS_Sine_Out-1 downto 0);
--	remoduQ        	: out signed(Size_DDS_Sine_Out-1 downto 0));
--end component;

component Two_path_filter
--component DAC_filter
port(
	CLK_4X		:	in  std_logic;
	Reset		:	in  std_logic;
	ENABLE		:	in  std_logic;
	input		:	in  signed(Size_DAC-1 downto 0);
	output		:	out signed(Size_DAC-1 downto 0));
end component;

--component Double_Two_path_filter
--port(
--	CLK_4X		:	in  std_logic;
--	ENABLE_4X	:	in  std_logic;
--	ENABLE_2X	:	in  std_logic;
--	Reset		:	in  std_logic;
--	input		:	in  signed(Size_DAC-1 downto 0);
--	output		:	out signed(Size_DAC-1 downto 0));
--end component;

begin

--Generation : sine_generator port map(CLK_4X,ENABLE_CLK_1X,Reset,START_STOP,sequencer,increment,phi_delay,phi_rotate,phi_initial,bias_amplitude,bias,demoduI,demoduQ,remoduI,remoduQ);
--Filter	: DAC_filter port map(CLK_4X,Reset,sig_in,sig_out);
Filter	: Two_path_filter port map(CLK_4X,Reset,ENABLE,input,output);
--Filter	: Double_Two_path_filter port map(CLK_4X,ENABLE,ENABLE_2X,Reset,input,output);

process
begin
	CLK_4X <= '0'; wait for 6.25 ns;
	CLK_4X <= '1'; wait for 6.25 ns;
end process;


process(CLK_4X)
begin
if rising_edge(CLK_4X) then
	inc_enable <= not inc_enable;
	if (inc_enable='1') then
		ENABLE_2X <= not ENABLE_2X;
	end if;
	inc <= inc + "01";
	if inc = "01" then
		ENABLE_CLK_1X <= '1';
	else
		ENABLE_CLK_1X <= '0';
	end if;
end if;
end process;

process(CLK_4X,Reset)
begin
if Reset = '1' then
	sig <= "0000000000000000";
else
	if rising_edge(CLK_4X) then
		--if (ENABLE_CLK_1X = '1') then
			n_inc <= n_inc + "000000000000001";
			if (n_inc="1111111111111111") then
				sig <= "0000100000000000";
			else
				sig <= "0000000000000000";
			end if;
		--end if;
	end if;	
end if;
end process;

sequencer <= inc;
Reset <= '0';
START_STOP <= '1';
--input <= bias(Size_DDS_Sine_Out-1 downto Size_DDS_Sine_Out-Size_DAC);
--sig_in <= sig;
input <= sig;

end test_DAC;