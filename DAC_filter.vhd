library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.athena_package.all;

entity DAC_filter is
Port(
	CLK_4X		:	in  std_logic;
	Reset		:	in  std_logic;
	sig_in		:	in  signed(Size_DAC-1 downto 0);
	sig_out		:	out signed(Size_DAC-1 downto 0)
);
end DAC_filter;

architecture Behavioral of DAC_filter is
type coeffs is array (0 to order-1) of signed(Size_coeff-1 downto 0);
type inputs is array (0 to order-1) of signed(Size_DAC-1 downto 0);
type outputs is array (0 to order-1) of signed(Size_DAC+Size_coeff-1 downto 0);
signal input : inputs;
signal output : outputs;
signal output_sum : outputs;
signal output_trunc : signed(Size_DAC+Size_coeff-1 downto 0):= (others=>'0');
constant coeff : coeffs :=
(
"00000000100111011110",
"00000001101010111101",
"00000010011011010001",
"00000010000100000110",
"11111111111100011001",
"11111101001111011101",
"11111100000011010111",
"11111110010011100011",
"00000011001100100001",
"00000111001000101101",
"00000101101011001110",
"11111101110001000000",
"11110100000010110001",
"11110001011001100000",
"11111101000110110111",
"00010110111001000111",
"00110101000101010101",
"01001001011001100000",
"01001001011001100000",
"00110101000101010101",
"00010110111001000111",
"11111101000110110111",
"11110001011001100000",
"11110100000010110001",
"11111101110001000000",
"00000101101011001110",
"00000111001000101101",
"00000011001100100001",
"11111110010011100011",
"11111100000011010111",
"11111101001111011101",
"11111111111100011001",
"00000010000100000110",
"00000010011011010001",
"00000001101010111101",
"00000000100111011110"
);
begin

input(0) <= sig_in;

Shift_input : for i in 1 to order-1 generate
	S_input : process(Reset, CLK_4X)
	begin
		if Reset='1' then
			input(i) <= (others=>'0');
		else
			if rising_edge(CLK_4X) then
				input(i) <= input(i-1);			
			end if;
		end if;		
	end process S_input;
end generate Shift_input;


Prod : for i in 0 to order-1 generate
	prod_process : process(Reset, CLK_4X)
	begin
		if Reset='1' then
			output(i) <= (others=>'0');
		else
			if rising_edge(CLK_4X) then
				output(i) <= coeff(i)*input(i);
			end if;
		end if;		
	end process prod_process;
end generate Prod;

output_sum(0) <= output(0);
Sum : for i in 1 to order-1 generate
	output_sum(i) <= output_sum(i-1) + output(i);
end generate Sum;

output_trunc <= output_sum(order-1);
sig_out <= output_trunc(Size_DAC+Size_coeff-1) & output_trunc(Size_DAC+Size_coeff-2 downto Size_coeff);

end Behavioral;