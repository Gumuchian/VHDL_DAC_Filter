library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.athena_package.all;

entity All_pass is
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
end All_pass;

architecture Behavioral of All_pass is

type inputs is array (0 to 2) of signed(Size_DAC-1 downto 0);
type outputs is array (0 to 2) of signed(Size_DAC-1 downto 0);
signal input : inputs;
signal output : outputs;
signal prod : signed(Size_DAC+Size_coeff-1 downto 0):=(others=>'0');

begin

input(0) <= sig_in;

Shift_input : for i in 1 to 2 generate
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


Shift_output : for i in 1 to 2 generate
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

prod <= Coeff*input(0) - Coeff*output(2);
output(0) <= (prod(Size_DAC+Size_coeff-1) & prod(Size_DAC+Size_coeff-4 downto Size_coeff-1)) + input(2);
sig_out <= output(0);

end Behavioral;