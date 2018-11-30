library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.athena_package.all;

entity Two_path_filter is
port(
	CLK_4X		:	in  std_logic;
	ENABLE		:	in  std_logic;	
	Reset		:	in  std_logic;
	input		:	in  signed(Size_DAC-1 downto 0);
	output		:	out signed(Size_DAC-1 downto 0)
);
end Two_path_filter;

architecture Behavioral of Two_path_filter is
signal input_tf1 : signed(Size_DAC-1 downto 0):=(others=>'0');
signal input_bf1 : signed(Size_DAC-1 downto 0):=(others=>'0');
signal output_tf1 : signed(Size_DAC-1 downto 0):=(others=>'0');
signal output_bf1 : signed(Size_DAC-1 downto 0):=(others=>'0');
signal output_tf2 : signed(Size_DAC-1 downto 0):=(others=>'0');
signal output_bf2 : signed(Size_DAC-1 downto 0):=(others=>'0');
signal output_trunc : signed(Size_DAC downto 0):=(others=>'0');
begin

TF1	: entity work.All_pass_filter
Generic map
(
	Coeff		=> "00001010001110100010"
)
Port map
(
	CLK_4X		=> CLK_4X,
	ENABLE		=> ENABLE,
	Reset		=> Reset,
	sig_in		=> input_tf1,
	sig_out		=> output_tf1
);

TF2	: entity work.All_pass_filter
Generic map
(
	Coeff		=> "01000101110011000110"
)
Port map
(
	CLK_4X		=> CLK_4X,
	ENABLE		=> ENABLE,
	Reset		=> Reset,
	sig_in		=> output_tf1,
	sig_out		=> output_tf2
);

BF1	: entity work.All_pass_filter
Generic map
(
	Coeff		=> "00100100010100111001"
)
Port map
(
	CLK_4X		=> CLK_4X,
	ENABLE		=> ENABLE,
	Reset		=> Reset,
	sig_in		=> input_bf1,
	sig_out		=> output_bf1
);

BF2	: entity work.All_pass_filter
Generic map
(
	Coeff		=> "01101010110011011010"
)
Port map
(
	CLK_4X		=> CLK_4X,
	ENABLE		=> ENABLE,
	Reset		=> Reset,
	sig_in		=> output_bf1,
	sig_out		=> output_bf2
);

process(Reset, CLK_4X)
begin
	if Reset='1' then
		input_tf1 <= (others=>'0');
		input_bf1 <= (others=>'0');
	else
		if rising_edge(CLK_4X) then
			if (ENABLE ='1') then
				input_tf1 <= input;
				input_bf1 <= input_tf1;
			end if;
		end if;
	end if;
end process;


output_trunc <= resize(output_bf2,Size_DAC+1) + resize(output_tf2,Size_DAC+1);
output <= output_trunc(Size_DAC downto 1);

end Behavioral;