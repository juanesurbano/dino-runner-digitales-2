library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.all;
--use ieee.numeric_std.ALL;
use ieee.std_logic_arith.ALL;

entity draw_trex is
	generic(
		H_counter_size: natural:= 10;
		V_counter_size: natural:= 10
	);
	port(
		clk: in std_logic;
		jump: in std_logic;
		abajo: in std_logic;
		pixel_x: in integer;
		pixel_y: in integer;
		rgbDrawColor: out std_logic_vector(11 downto 0) := (others => '0');
		pausar_juego: in std_logic
	);
end draw_trex;

architecture arch of draw_trex is
	constant PIX : integer := 16;
	constant PIX_nube : integer := 32;
	constant COLS : integer := 40;
	constant T_FAC : integer := 100000;
	constant cactusSpeed : integer := 30;
	constant terodacSpeed : integer := 20;
	constant nubeSpeed: integer := 240;
	
	--nube
	signal nubeX_1: integer := 32;
	signal nubey_1: integer := 24;
	--terodactilo
	signal terodacX_1: integer := 16;
	signal terodacY_1: integer := 8;

	-- T-Rex
	signal trexX: integer := 8;
	signal trexY: integer := 24;
	signal saltando: std_logic := '0';
   signal agachado: std_logic := '0';
	signal colision: std_logic := '0';

	-- Cactus	
	signal cactusX_1: integer := 32;
	signal cactusY: integer := 24;


-- Sprites
type sprite_block is array(0 to 15, 0 to 15) of integer range 0 to 1;
type sprite_block_terodac is array(0 to 15, 0 to 15) of integer range 0 to 1;
type sprite_block_nube is array(0 to 15, 0 to 15) of integer range 0 to 1;
type sprite_block_estrella is array(0 to 15, 0 to 15) of integer range 0 to 1;
type sprite_block_luna is array(0 to 15, 0 to 15) of integer range 0 to 1;
constant luna: sprite_block_luna:=(          (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0), -- 0 
									                  (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0), -- 1 
									                  (0,0,0,1,1,1,1,0,1,1,1,1,1,0,0,0), -- 2
									                  (0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0), -- 3
									                  (0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0), -- 4
									                  (0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0), -- 5
									                  (1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,0), -- 6
									                  (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 7
									                  (1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1), -- 8
									                  (1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1), -- 9
									                  (0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0), -- 10
									                  (0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0), -- 11
									                  (0,0,1,1,1,1,1,0,1,1,1,1,1,1,0,0), -- 12
		 							                  (0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0), -- 13
									                  (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0), -- 14
									                  (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0));-- 15
															
constant estrella: sprite_block_estrella:=(  (0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0), -- 0 
									                  (0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0), -- 1 
									                  (0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0), -- 2
									                  (0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0), -- 3
									                  (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0), -- 4
									                  (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0), -- 5
									                  (0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0), -- 6
									                  (0,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0), -- 7
									                  (0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0), -- 8
									                  (0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0), -- 9
									                  (0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0), -- 10
									                  (0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0), -- 11
									                  (0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0), -- 12
		 							                  (0,1,1,1,1,1,1,0,0,1,1,1,1,1,1,0), -- 13
									                  (1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1), -- 14
									                  (1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1));-- 15
												  
constant nube: sprite_block_nube:=(   (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									           (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
									           (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 2
									           (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 3
									           (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 4
									           (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 5
									           (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 6
									           (0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0), -- 7
									           (0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0), -- 8
									           (0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 9
									           (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 10
									           (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 11
									           (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 12
		 							           (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 13
									           (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 14
									           (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));-- 15
												  
constant terodac: sprite_block_terodac:=(  (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									                (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
									                (0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0), -- 2
									                (0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0), -- 3
									                (0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0), -- 4
									                (0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0), -- 5
									                (0,0,0,0,1,0,0,0,1,1,1,1,1,0,0,0), -- 6
									                (0,0,0,1,1,1,0,0,1,1,1,1,0,1,0,0), -- 7
									                (0,0,1,0,1,1,1,0,1,1,1,1,1,1,0,0), -- 8
									                (0,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1), -- 9
									                (1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0), -- 10
									                (0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1), -- 11
									                (0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0), -- 12
		 							                (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 13
									                (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 14
									                (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));-- 15

constant trex_2: sprite_block:=((0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0), -- 0 
									     (0,0,0,0,0,0,0,1,1,0,1,1,1,1,1,1), -- 1 
									     (0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 2
									     (0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 3
									     (0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0), -- 4
									     (0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0), -- 5
									     (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0), -- 6
									     (1,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0), -- 7
									     (1,1,0,0,1,1,1,1,1,1,1,0,0,1,0,0), -- 8
									     (1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0), -- 9
									     (0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 10
									     (0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 11
									     (0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0), -- 12
		 							     (0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0), -- 13
									     (0,0,0,0,0,1,1,0,1,0,0,0,0,0,0,0), -- 14
									     (0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0));-- 15

constant trex_3: sprite_block:=((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									     (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
									     (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 2
									     (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 3
									     (0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0), -- 4
									     (0,0,0,0,0,0,0,1,1,0,1,1,1,1,1,1), -- 5
									     (0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 6
									     (0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1), -- 7
									     (0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0), -- 8
									     (0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0), -- 9
									     (0,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0), -- 10
									     (1,1,1,1,1,1,1,1,1,1,0,1,0,0,0,0), -- 11
									     (1,1,0,0,1,1,1,1,1,0,0,0,0,0,0,0), -- 12
		 							     (1,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0), -- 13
									     (1,0,0,0,0,1,1,0,1,0,0,0,0,0,0,0), -- 14
									     (0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0));-- 15											  

constant cactus: sprite_block :=((0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0), -- 0 
									      (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 1 
									      (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 2
									      (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 3
									      (0,0,0,0,0,1,0,1,1,1,0,1,0,0,0,0), -- 4
									      (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 5
									      (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 6      
									      (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 7
									      (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 8
									      (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0), -- 9
									      (0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0), -- 10
									      (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 11
									      (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 12
		 							      (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 13
									      (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 14
									      (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0));-- 15									

type color_arr is array(0 to 1) of std_logic_vector(11 downto 0);
type color_arr2 is array(0 to 1) of std_logic_vector(11 downto 0);
type color_arr3 is array(0 to 1) of std_logic_vector(11 downto 0);
type color_arr4 is array(0 to 1) of std_logic_vector(11 downto 0);											 
constant sprite_color : color_arr := ("000000000000", "000011110000");
constant sprite_color_terodac : color_arr2 := ("000000000000", "111101110000");
constant sprite_color_nubes : color_arr3 := ("000000000000", "110011001100");
constant sprite_color_estrella : color_arr4 := ("000000000000", "111111110000");
begin
	draw_objects: process(clk, pixel_x, pixel_y)	

	variable sprite_x : integer := 0;
	variable sprite_y : integer := 0;
	

	begin			
		if(clk'event and clk='1') then		
			-- Dibuja el fondo
			rgbDrawColor <= "0000" & "0000" & "0000";

			-- Dibuja el suelo
			if(pixel_y = 400 or pixel_y = 401) then
				rgbDrawColor <= "1100" & "1100" & "1100";		
			end if;

			sprite_x := pixel_x mod PIX;
			sprite_y := pixel_y mod PIX;
			
			
			-- nube
			if ((pixel_x / PIX = 0) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 2) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 4) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 6) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 8) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 10) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 12) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 14) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 16) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 18) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 20) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 22) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 24) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 26) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 28) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 30) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 32) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 34) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 36) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 38) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 40) and (pixel_y / PIX = 10)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			
			if ((pixel_x / PIX = nubeX_1) and (pixel_y / PIX = 11)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = nubeX_1 - 2) and (pixel_y / PIX = 9)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = nubeX_1 - 4) and (pixel_y / PIX = 11)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = nubeX_1 - 6) and (pixel_y / PIX = 9)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
				
			end if;
			if ((pixel_x / PIX = nubeX_1 - 8) and (pixel_y / PIX = 11)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = nubeX_1 - 10) and (pixel_y / PIX = 9)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = nubeX_1 - 12) and (pixel_y / PIX = 11)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = nubeX_1 - 14) and (pixel_y / PIX = 9)) then 
				rgbDrawColor <= sprite_color_nubes(nube(sprite_y, sprite_x));
			end if;
			
			--estrella
			if ((pixel_x / PIX = 0) and (pixel_y / PIX = 0)) then 
				rgbDrawColor <= sprite_color_nubes(luna(sprite_y, sprite_x));
			end if;
			
			if ((pixel_x / PIX = 6) and (pixel_y / PIX = 0)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			if ((pixel_x / PIX = 12) and (pixel_y / PIX = 0)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			if ((pixel_x / PIX = 18) and (pixel_y / PIX = 0)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			if ((pixel_x / PIX = 23) and (pixel_y / PIX = 0)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			if ((pixel_x / PIX = 28) and (pixel_y / PIX = 0)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			if ((pixel_x / PIX = 33) and (pixel_y / PIX = 0)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			if ((pixel_x / PIX = 38) and (pixel_y / PIX = 0)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			
			
			
			if ((pixel_x / PIX = 3) and (pixel_y / PIX = 2)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 9) and (pixel_y / PIX = 2)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 15) and (pixel_y / PIX = 2)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 21) and (pixel_y / PIX = 2)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 26) and (pixel_y / PIX = 2)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 31) and (pixel_y / PIX = 2)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			if ((pixel_x / PIX = 36) and (pixel_y / PIX = 2)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			
			
			if ((pixel_x / PIX = 0) and (pixel_y / PIX = 4)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			if ((pixel_x / PIX = 6) and (pixel_y / PIX = 4)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			if ((pixel_x / PIX = 12) and (pixel_y / PIX = 4)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			if ((pixel_x / PIX = 18) and (pixel_y / PIX = 4)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			if ((pixel_x / PIX = 23) and (pixel_y / PIX = 4)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			if ((pixel_x / PIX = 28) and (pixel_y / PIX = 4)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			if ((pixel_x / PIX = 33) and (pixel_y / PIX = 4)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			if ((pixel_x / PIX = 38) and (pixel_y / PIX = 4)) then 
				rgbDrawColor <= sprite_color_estrella(estrella(sprite_y, sprite_x));
			end if;
			
			
			

			-- terodactilo
			if ((pixel_x / PIX = terodacX_1) and (pixel_y / PIX = 20)) then 
				rgbDrawColor <= sprite_color_terodac(terodac(sprite_y, sprite_x));
			end if;
			
			-- Cactus1
			if ((pixel_x / PIX = cactusX_1) and (pixel_y / PIX = cactusY)) then 
				rgbDrawColor <= sprite_color(cactus(sprite_y, sprite_x));
			end if;				


			-- T-Rex
		 if (agachado = '0') then
			 if (saltando = '1') then
				 if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
					rgbDrawColor <= sprite_color(trex_2(sprite_y, sprite_x));			
				 end if;
			 else
				 if((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
					rgbDrawColor <= sprite_color(trex_2(sprite_y, sprite_x));			
				 end if;
			 end if;	 
		  else
			    if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
					rgbDrawColor <= sprite_color(trex_3(sprite_y, sprite_x));			
				 end if;
		 end if;
		
	 end if;	
		
end process;

	actions: process(clk, jump, abajo,pausar_juego,colision)	
	variable cactusCount: integer := 0;
	variable terodacCount: integer := 0;
	variable nubecount: integer := 0;
	begin		
if(clk'event and clk = '1') then
	--reiniciar el juego
	 if (cactusX_1 = trexX and cactusY = trexY) then
		   colision <= '1';
		
	 end if;
	 
	 if (terodacX_1 = trexX and trexY = 20 and agachado = '0' ) then
		   colision <= '1';
		
	 end if;
	 
	  -- agacharse
			if(abajo= '1') then
			   agachado <= '1';
				
				else
				agachado <= '0';
			end if;	
	    
		if (colision = '0')then
        
			-- Salto
			if(jump = '1') then
				saltando <= '1';
				if (trexY > 20) then
					trexY <= trexY - 1;
				else
					saltando <= '0';
				end if;
			else
			   saltando <= '0';
				if (trexY < 24) then
					trexY <= trexY + 1;
				end if;
			end if;	
		-- Movimiento de nube
			
			if (nubeCount >= T_FAC * nubeSpeed) then
				if (nubeX_1 <= 0) then
					nubeX_1 <= COLS;				
				else
					nubeX_1 <= nubeX_1 - 1;					
				end if;
				nubeCount := 0;
			end if;
			nubeCount := nubeCount + 1;

	

           		
			-- Movimiento de terodactilo
			
			if (terodacCount >= T_FAC * terodacSpeed) then
				if (terodacX_1 <= 0) then
					terodacX_1 <= COLS;				
				else
					terodacX_1 <= terodacX_1 - 1;					
				end if;
				terodacCount := 0;
			end if;
			terodacCount := terodacCount + 1;


	
			
			-- Movimiento del Cactus
			-- Cactus Movement
			if (cactusCount >= T_FAC * cactusSpeed) then
				if (cactusX_1 <= 0) then
					cactusX_1 <= COLS;				
				else
					cactusX_1 <= cactusX_1 - 1;					
				end if;
				cactusCount := 0;
			end if;
			cactusCount := cactusCount + 1;

        else
		  
		  TrexX <= 8;
		  TrexY <= 24;
		  cactusx_1 <= 32;
		  cactusY   <= 24;
		  terodacX_1 <= 38;
		  terodacY_1 <= 8;
		  
		  if (pausar_juego = '1') then
		   colision <= '0';
			end if;
		 end if; 
	end if;
	end process;

end arch;