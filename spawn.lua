--[[
	Mod Spawn para Minetest
	Copyright (C) 2019 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Spawna jogadores
  ]]

-- Spawna jogador
local spawn_player = function(player)
	if not player then return end
	
	local x, z = revom.zonas.get_spawn()
	local min, max = revom.zonas.get_limits(x, z)
	local pos = {x=math.random(min.x, max.x), y=10, z=math.random(min.z, max.z)}
	
	player:set_pos(pos)
end

minetest.register_on_respawnplayer(function(player)
	minetest.after(0.01, spawn_player, player)
	return true
end)

minetest.register_on_newplayer(function(player)
	minetest.after(0.01, spawn_player, player)
end)
