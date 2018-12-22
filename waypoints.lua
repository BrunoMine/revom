--[[
	Mod Spawn para Minetest
	Copyright (C) 2019 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Marcadores
  ]]

-- Tradutor de texto
local S = revom.S

-- Tabela de marcadores dos jogadores
local waypoints = {}

-- Atualiza marcadores de zonas
revom.atualizar_waypoints = function(player, loop)
	if not player then return end
	local pos = player:get_pos()
	if not pos then return end
	local name = player:get_player_name()
	
	-- Zona atual
	local x, z = revom.zonas.get_malha(pos) 
	
	-- Zonas proximas
	local z1 = {
		{x-1, z+1}, {x, z+1}, {x+1, z+1},
		{x-1, z  },           {x+1, z  },
		{x-1, z-1}, {x, z-1}, {x+1, z-1}
	}
	
	-- Zonas distantes
	local z2 = {
		{x-2, z+2}, {x-1, z+2}, {x, z+2}, {x+1, z+2}, {x+2, z+2},
		{x-2, z+1},                                   {x+2, z+1},
		{x-2, z  },                                   {x+2, z  },
		{x-2, z-1},                                   {x+2, z-1},
		{x-2, z-2}, {x-1, z-2}, {x, z-2}, {x+1, z-2}, {x+2, z-2}
	}
	
	-- Tabela de waypoints do jogador
	waypoints[name] = waypoints[name] or {}
	
	-- Remove marcadores anteriores
	for _,w in ipairs(waypoints[name]) do
		player:hud_remove(w)
	end
	
	-- Zera tabela
	waypoints[name] = {}
	
	-- Insere marcadores da zona atual
	do
		if revom.zonas.ocupada(x, z) == true then
			-- Casas
			local tb = revom.bd.pegar("zonas_ocupadas", x.." "..z)
			for _,d in ipairs(tb.casa or {}) do
				local w = player:hud_add({
					hud_elem_type = "waypoint",
					name = S("Casa de @1", d.name),
					number = "205",
					world_pos = d.pos
				})
				table.insert(waypoints[name], w)
			end
		end
	end
	
	-- Insere marcadores das zonas proximas
	do
		for _,m in ipairs(z1) do
			if revom.zonas.ocupada(m[1], m[2]) == true then
				-- Casas
				local tb = revom.bd.pegar("zonas_ocupadas", m[1].." "..m[2])
				for _,d in ipairs(tb.casa or {}) do
					local w = player:hud_add({
						hud_elem_type = "waypoint",
						name = S("Casa de @1", d.name),
						number = "205",
						world_pos = d.pos
					})
					table.insert(waypoints[name], w)
				end
			end
		end
	end
	
	-- Insere marcadores das zonas distantes
	do
		for _,m in ipairs(z2) do
			if revom.zonas.ocupada(m[1], m[2]) == true then
				-- Casas
				local tb = revom.bd.pegar("zonas_ocupadas", m[1].." "..m[2])
				for _,d in ipairs(tb.casa or {}) do
					local w = player:hud_add({
						hud_elem_type = "waypoint",
						name = S("Casa de @1", d.name),
						number = "205",
						world_pos = d.pos
					})
					table.insert(waypoints[name], w)
				end
			end
		end
	end
	
	-- Reinicia loop de atualização
	if loop == true then
		minetest.after(revom.waypoints_update_time, revom.atualizar_waypoints, player, true)
	end
end

-- Atualiza waypoints de jogadores proximos de uma zona
revom.atualizar_waypoints_zona = function(x, z)
	
	-- Pega jogadores que estao nas zonas afetadas
	for _,player in ipairs(minetest.get_connected_players()) do
		local xi, zi = revom.zonas.get_malha(player:get_pos())
		if xi >= x-1 and xi <= x+1 and zi >= z-1 and zi <= z+1 then
			revom.atualizar_waypoints(player)
		end
	end
end

-- Inicia loop ao conectar
minetest.register_on_joinplayer(function(player)
	revom.atualizar_waypoints(player)
end)


