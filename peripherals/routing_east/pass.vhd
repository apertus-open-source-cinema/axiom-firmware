
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_bit.all;

entity top is
    port (
	n_spi_en : out std_logic;
	n_sck : out std_logic;
	n_sdo : out std_logic;
	n_sdi : in std_logic;
	--
	e_en : out std_logic;
	e_sck : out std_logic;
	e_sdi : out std_logic;
	e_sdo : out std_logic;
	--
	jx1_05_p : in std_logic;
	jx1_05_n : in std_logic;
	jx2_04_p : in std_logic;
	jx2_04_n : out std_logic;
	--
	jx1_se_0 : in std_logic;
	--
	loop_in : in std_logic;
	loop_out : out std_logic;
	--
	fan : out std_logic
    );
end entity top;

architecture RTL of top is
begin
	n_spi_en <= jx1_05_p;
	n_sck <= jx1_05_n;
	n_sdo <= jx2_04_p;
	jx2_04_n <= n_sdi;

	e_en <= jx1_se_0;
	e_sck <= '0';
	e_sdo <= '0';
	e_sdi <= jx1_05_p;

	loop_out <= loop_in;

	fan <= '1';
end RTL;
