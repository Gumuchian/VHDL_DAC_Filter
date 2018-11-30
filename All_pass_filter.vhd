library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.athena_package.all;

entity All_pass_filter is
Generic 
( 		
	Coeff		:	signed(Size_coeff-1 downto 0)
);
Port 
(
	CLK_4X		:	in  std_logic;
	ENABLE		:	in  std_logic;
	Reset		:	in  std_logic;
	sig_in		:	in  signed(Size_DAC-1 downto 0);
	sig_out		:	out signed(Size_DAC-1 downto 0)
);
end All_pass_filter;

architecture Behavioral of All_pass_filter is

type t_inputs_ARRAY is array (0 to 3) of signed(Size_DAC-1 downto 0);
type t_outputs_ARRAY is array (0 to 5) of signed(Size_DAC-1 downto 0);
type t_product_ARRAY is array (0 to 2) of signed(Size_DAC+Size_coeff-1 downto 0);
signal input : t_inputs_ARRAY;
signal output : t_outputs_ARRAY;
signal prod : t_product_ARRAY;
signal sum_prod : signed(Size_DAC+Size_coeff-1 downto 0):=(others=>'0');

begin

input(0) <= sig_in;

Shift_input : for i in 1 to 3 generate
	S_input : process(Reset, CLK_4X)
	begin
		if Reset='1' then
			input(i) <= (others=>'0');
		else
			if rising_edge(CLK_4X) then
				if (ENABLE ='1') then
					input(i) <= input(i-1);
				end if;	
			end if;
		end if;
	end process S_input;
end generate Shift_input;

Shift_output : for i in 1 to 5 generate
	S_output : process(Reset, CLK_4X)
	begin
		if Reset='1' then
			output(i) <= (others=>'0');
		else
			if rising_edge(CLK_4X) then
				if (ENABLE ='1') then
					output(i) <= output(i-1);
				end if;			
			end if;
		end if;
	end process S_output;
end generate Shift_output;

process(Reset, CLK_4X)
begin
	if Reset='1' then
		prod(0) <= (others=>'0');
	else
		if rising_edge(CLK_4X) then
			if (ENABLE ='1') then
				prod(0) <= Coeff*input(0);
			end if;			
		end if;
	end if;
end process;

process(Reset, CLK_4X)
begin
	if Reset='1' then
		prod(1) <= (others=>'0');
	else
		if rising_edge(CLK_4X) then
			if (ENABLE ='1') then
				prod(1) <= - Coeff*output(1);
			end if;			
		end if;
	end if;
end process;

sum_prod <= prod(0) + prod(1);
output(0) <= (sum_prod(Size_DAC+Size_coeff-1) & sum_prod(Size_DAC+Size_coeff-3 downto Size_coeff-1)) + input(3);
sig_out <= output(0);

end Behavioral;