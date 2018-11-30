library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.athena_package.all;

entity Double_Two_path_filter is
port(
	CLK_4X		:	in  std_logic;
	ENABLE_4X	:	in  std_logic;
	ENABLE_2X	:	in  std_logic;		
	Reset		:	in  std_logic;
	input		:	in  signed(Size_DAC-1 downto 0);
	output		:	out signed(Size_DAC-1 downto 0)
);
end Double_Two_path_filter;


architecture Behavioral of Double_Two_path_filter is
signal output_2X : signed(Size_DAC-1 downto 0);
begin

filter_2X : entity work.Two_path_filter
Port map
(
	CLK_4X		=> CLK_4X,
	ENABLE		=> ENABLE_2X,
	Reset		=> Reset,
	input		=> input,
	output		=> output_2X
);

filter_4X : entity work.Two_path_filter
Port map
(
	CLK_4X		=> CLK_4X,
	ENABLE		=> ENABLE_4X,
	Reset		=> Reset,
	input		=> output_2X,
	output		=> output
);
end Behavioral;