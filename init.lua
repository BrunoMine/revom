--[[
	Mod Revom para Minetest
	Copyright (C) 2019 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicialização de scripts
  ]]

-- Tabela Global
revom = {}

-- Largura de uma zona
revom.largura_zona = 200

-- Limite de spawn por zona apta (de 1 a 20)
revom.limite_spawn_zona = 10

--[[ Inscrever jogadores automaticamente para a batalha
battle.auto_join = true
if minetest.settings:get("battle_enable_auto_join_battle") == "false" then
	battle.auto_join = false
end]]

local modpath = minetest.get_modpath("revom")

dofile(modpath.."/common.lua")
dofile(modpath.."/banco_de_dados.lua")
--dofile(modpath.."/tradutor.lua")

dofile(modpath.."/zonas.lua")
dofile(modpath.."/spawn.lua")
dofile(modpath.."/protetor.lua")
dofile(modpath.."/waypoints.lua")
