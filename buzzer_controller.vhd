library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity buzzer_controller is
    port (
        clk_50Mhz   : in  std_logic;                       
        rst         : in  std_logic;                        
        countdown   : in  integer range 0 to 9;             
        buzzer_out  : out std_logic;                        
        count       : out std_logic_vector(31 downto 0)    
    );
end entity buzzer_controller;

architecture Behavioral of buzzer_controller is
    signal cnt     : unsigned(31 downto 0) := (others => '0');
    signal out_reg : std_logic := '0';
begin
    counting_proc: process(clk_50Mhz, rst)
    begin
        if rst = '0' then
            cnt     <= (others => '0');
            out_reg <= '0';
        elsif rising_edge(clk_50Mhz) then
            cnt <= cnt + 1;  
            if countdown = 1 then
                out_reg <= cnt(10);
			   elsif countdown = 2 then
                out_reg <= cnt(20);
				elsif countdown = 3 then
                out_reg <= cnt(30);
            else
                out_reg <= '0';
            end if;
        end if;
    end process counting_proc;

    buzzer_out <= out_reg;
    count      <= std_logic_vector(cnt);

end architecture Behavioral;
