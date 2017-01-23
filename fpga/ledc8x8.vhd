--Autor: Jakub Svoboda
--Datum: 28.9.2016
--Login: xsvobo0z
--Email: xsvobo0z@stud.fit.vutbr.cz
	
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ledc8x8 is
	port ( 													-- Sem doplnte popis rozhrani obvodu.
		LED : out std_logic_vector (0 to 7);
		ROW : out std_logic_vector (0 to 7);
		RESET : in std_logic;							
		SMCLK : in std_logic							-- clock
	);
end ledc8x8;

architecture main of ledc8x8 is
    -- Sem doplnte definice vnitrnich signalu.
	signal radek: std_logic_vector (0 to 7) := "10000000";
	signal sloupec: std_logic_vector (0 to 7);
	signal pocitadlo: std_logic_vector (0 to 7);
	signal ce: std_logic := '0';
	signal switch: std_logic := '0' ;
	signal switch_counter: std_logic_vector (0 to 31); 
		
	begin
		 -- Sem doplnte popis funkce obvodu (zakladni konstrukce VHDL jako napr.
		 -- prirazeni signalu, multiplexory, dekodery, procesy...).
		 -- DODRZUJTE ZASADY PSANI SYNTETIZOVATELNEHO VHDL UVEDENE NA WEBU:
		 -- http://merlin.fit.vutbr.cz/FITkit/docs/navody/synth_templates.html
		 -- Nezapomente take doplnit mapovani signalu rozhrani na piny FPGA
		 -- v souboru ledc8x8.ucf.
		pricitani: process (RESET, SMCLK)
		begin
			if RESET = '1' then 
				pocitadlo <= "00000000";
				elsif SMCLK'event AND SMCLK='1' then	-- pokud nastupna hrana
					pocitadlo <= pocitadlo + 1;
					switch_counter <= switch_counter +1;
					if pocitadlo = "11111111" then 
						ce <= '1';
					else ce <='0';
					end if;	
					if ce = '1' then
						case radek is 
						when "10000000" => radek <= "01000000";	--posuvny registr pro radek
						when "01000000" => radek <= "00100000";	
						when "00100000" => radek <= "00010000";
						when "00010000" => radek <= "00001000";
						when "00001000" => radek <= "00000100";
						when "00000100" => radek <= "00000010";	
						when "00000010" => radek <= "00000001";
						when "00000001" => radek <= "10000000";	
						when others => NULL;
						end case;
					end if;	
					
					if switch_counter < "00000000011100001000000000000000" then --7372800
						switch <= '0';
					elsif switch_counter <	"00000000111000010000000000000000" then
						switch <= '1';
					else
						switch_counter <= "00000000000000000000000000000000";
					end if;		
			end if;
		end process;
		
		
		prevodnik: process (SMCLK,radek)					--prebod radku na prislusne led ve sloupci
		begin
			if SMCLK'event AND SMCLK='1' then
					if switch = '0' then
						case radek is
						when "10000000" => sloupec <= "11111110";		--pro pismeno J
						when "01000000" => sloupec <= "11111110";
						when "00100000" => sloupec <= "11111110";
						when "00010000" => sloupec <= "11111110";
						when "00001000" => sloupec <= "11111110";
						when "00000100" => sloupec <= "11111110";
						when "00000010" => sloupec <= "11101110";
						when "00000001" => sloupec <= "11110001";
						when others => NULL;
						end case;
						
					else 
						case radek is
						when "10000000" => sloupec <= "10001111";		--pro pismeno S
						when "01000000" => sloupec <= "01110111";
						when "00100000" => sloupec <= "01111111";
						when "00010000" => sloupec <= "10001111";
						when "00001000" => sloupec <= "11110111";
						when "00000100" => sloupec <= "11110111";
						when "00000010" => sloupec <= "01110111";
						when "00000001" => sloupec <= "10001111";
						when others => NULL;
						end case;
					end if;	
				end if;
		end process;		
			
		led_there_be_light: process(radek,sloupec)			--prirazeni do LED a ROW
		begin
			LED <= sloupec;
			ROW <= radek;
		end process;
		
end architecture main;
