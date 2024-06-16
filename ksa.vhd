library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ksa is
  port(
    CLOCK_50            : in  std_logic;  -- Clock pin
    KEY                 : in  std_logic_vector(3 downto 0);  -- push button switches
    SW                 : in  std_logic_vector(9 downto 0);  -- slider switches
    LEDR : out std_logic_vector(9 downto 0);  -- red lights
    HEX0 : out std_logic_vector(6 downto 0);
    HEX1 : out std_logic_vector(6 downto 0);
    HEX2 : out std_logic_vector(6 downto 0);
    HEX3 : out std_logic_vector(6 downto 0);
    HEX4 : out std_logic_vector(6 downto 0);
    HEX5 : out std_logic_vector(6 downto 0));
end ksa;

architecture rtl of ksa is
   COMPONENT SevenSegmentDisplayDecoder IS
    PORT
    (
        ssOut : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        nIn : IN STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
    END COMPONENT;

    COMPONENT ksa IS
    PORT
    (
        CLOCK_50 : IN STD_LOGIC;
        KEY : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        SW : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
        LEDR: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
        HEX5: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        HEX4: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        HEX3: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        HEX2: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        HEX1: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        HEX0: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
    );
    END COMPONENT;

   
    -- clock and reset signals  
	 signal clk, reset_n : std_logic;										

begin

    clk <= CLOCK_50;
    reset_n <= KEY(3);




end RTL;


