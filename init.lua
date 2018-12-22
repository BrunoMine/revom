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
revom.largura_zona = tonumber(minetest.setting_get("revom_zone_width") or 200)

-- Limite de spawn por zona apta (de 1 a 20)
revom.limite_spawn_zona = tonumber(minetest.setting_get("revom_spawns_per_zone") or 10)

-- Nivel minimo para jogador colocar bloco de casa (mod xpro)
revom.level_to_house = tonumber(minetest.setting_get("revom_level_to_house") or 3)

-- Tempo para atualizar demarcadores
revom.waypoints_update_time = tonumber(minetest.setting_get("revom_waypoints_update_time") or 60)


local modpath = minetest.get_modpath("revom")

dofile(modpath.."/common.lua")
dofile(modpath.."/banco_de_dados.lua")
dofile(modpath.."/tradutor.lua")

dofile(modpath.."/zonas.lua")
dofile(modpath.."/spawn.lua")
dofile(modpath.."/protetor.lua")
dofile(modpath.."/waypoints.lua")
