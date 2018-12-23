--[[
	Mod Spawn para Minetest
	Copyright (C) 2019 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Spawna jogadores
  ]]

-- Desenterrar jogador
revom.desenterrar_jogador = function(player)
	if not player then return end
	local pos = player:get_pos()
	if not pos then return end
	
	local name = minetest.get_node({x=pos.x, y=pos.y, z=pos.z}).name
	
	if name == "air" or name == "default:water_source" or name == "default:river_water_source" then
		return
	end
	
	-- Teleporta para cima
	player:set_pos({x=pos.x, y=pos.y+3, z=pos.z})
	
	minetest.after(1, revom.desenterrar_jogador, player)
end

-- Spawna jogador
local spawn_player = function(player, count)
	if not player then return end
	
	local x, z = revom.zonas.get_spawn(count)
	local min, max = revom.zonas.get_limits(x, z)
	local pos = {x=math.random(min.x, max.x), y=1, z=math.random(min.z, max.z)}
	pos.y = minetest.get_spawn_level(pos.x, pos.z) or 1
	
	-- Verifica zona razoavel
	minetest.after(5, revom.verificar_zona_razoavel, {x=pos.x, y=1, z=pos.z})	
	
	player:set_pos(pos)
	
	minetest.after(1, revom.desenterrar_jogador, player)
end

minetest.register_on_respawnplayer(function(player)
	minetest.after(0.01, spawn_player, player, true)
	return true
end)

minetest.register_on_newplayer(function(player)
	minetest.after(0.01, spawn_player, player)
end)
