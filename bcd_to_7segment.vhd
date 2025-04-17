--==============================================================================
-- File: bcd_to_7segment.vhd
-- Description: Converts a BCD digit (0–9) to the corresponding 7‑segment display
--              pattern (active‑low segments).
--==============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bcd_to_7segment is
    port(
        bcd : in  integer range 0 to 9;          -- BCD input digit
        seg : out std_logic_vector(6 downto 0)   -- 7‑segment outputs (a…g)
    );
end bcd_to_7segment;

architecture Behavioral of bcd_to_7segment is
begin
    process(bcd)
    begin
        case bcd is
            when 0 => seg <= "1000000"; -- display '0': segments a–f on, g off
            when 1 => seg <= "1111001"; -- display '1': segments b, c on
            when 2 => seg <= "0100100"; -- display '2': segments a, b, d, e, g on
            when 3 => seg <= "0110000"; -- display '3': segments a, b, c, d, g on
            when 4 => seg <= "0011001"; -- display '4': segments b, c, f, g on
            when 5 => seg <= "0010010"; -- display '5': segments a, c, d, f, g on
            when 6 => seg <= "0000010"; -- display '6': segments a, c, d, e, f, g on
            when 7 => seg <= "1111000"; -- display '7': segments a, b, c on
            when 8 => seg <= "0000000"; -- display '8': all segments on
            when 9 => seg <= "0010000"; -- display '9': segments a, b, c, f, g on
            when others => seg <= "1111111"; -- invalid: all segments off
        end case;
    end process;
end Behavioral;
