-- Top file

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity kria_zynq is
end kria_zynq;

architecture rtl of kria_zynq is
begin

  u_zynq_wrapper : entity work.zynq_wrapper;
  -- empty port map for now

end rtl;