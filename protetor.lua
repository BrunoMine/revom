--[[
	Mod Spawn para Minetest
	Copyright (C) 2019 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Demarcador de casas
  ]]

-- Tradutor de texto
local S = revom.S

-- Verificar e remover demarcadores invalidos
local check_demarcador = function(pos)
	local meta = minetest.get_meta(pos)
	local dono = meta:get_string("dono")
	
	if revom.bd.verif("casas", dono) == false then
		minetest.remove_node(pos)
		return
	end
	
	if minetest.pos_to_string(revom.bd.pegar("casas", dono).pos) ~= minetest.pos_to_string(pos) then
		minetest.remove_node(pos)
		return
	end
end

---
-- Caixa de Area
------
-- Registro das entidades
minetest.register_entity("revom:display_casa", {
	visual = "mesh",
	visual_size = {x=1,y=1},
	mesh = "revom_cubo.b3d",
	textures = {"revom_display_casa.png"},
	collisionbox = {0,0,0, 0,0,0},
	timer = 0,
	
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer >= 5 then
			self.object:remove()
		end
	end,
})

-- Colocação de uma caixa
display_territorio = function(pos, dist, name)
	
	-- Remove caixas proximas para evitar colisão
	for  _,obj in ipairs(minetest.get_objects_inside_radius(pos, 13)) do
		local ent = obj:get_luaentity() or {}
		if ent and ent.name == name then
			obj:remove()
		end
	end
	
	-- Cria o objeto
	local obj = minetest.add_entity({x=pos.x, y=pos.y, z=pos.z}, name)
	local obj2 = minetest.add_entity({x=pos.x, y=pos.y, z=pos.z}, name)
	obj2:set_properties({visual_size = {x=6, y=6}})
	
	-- Pega a entidade
	local ent = obj:get_luaentity()
	
	-- Redimensiona para o tamanho da area
	if tonumber(dist) == 1 then
		obj:set_properties({visual_size = {x=15, y=15}})
	elseif tonumber(dist) == 2 then
		obj:set_properties({visual_size = {x=25, y=25}})
	elseif tonumber(dist) == 3 then
		obj:set_properties({visual_size = {x=35, y=35}})
	elseif tonumber(dist) == 4 then
		obj:set_properties({visual_size = {x=45, y=45}})
	elseif tonumber(dist) == 5 then
		obj:set_properties({visual_size = {x=55, y=55}})
	elseif tonumber(dist) == 6 then
		obj:set_properties({visual_size = {x=65, y=65}})
	elseif tonumber(dist) == 7 then -- Na pratica isso serve para verificar area um pouco maior que as de largura 13
		obj:set_properties({visual_size = {x=75, y=75}})
	elseif tonumber(dist) == 8 then -- Na pratica isso serve para verificar area um pouco maior que as de largura 13
		obj:set_properties({visual_size = {x=85, y=85}})
	end
	return true
	
end
-------
-----
---

-- Demarcador de territorio
minetest.register_node("revom:demarcador_casa", {
	description = S("Demarcador de Casa"),
	tiles = {
		"revom_marcador_lados.png", 
		"revom_marcador_lados.png", 
		"revom_marcador_frente.png", 
		"revom_marcador_frente.png", 
		"revom_marcador_frente.png", 
		"revom_marcador_frente.png", 
	},
	groups = {cracky = 1, level = 2},
	sounds = default.node_sound_metal_defaults(),
	walkable = true,
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {-0.5,-0.5,-0.5,0.5,0.5,0.5},
	},
	
	on_place = function(itemstack, placer, pointed_thing)
		
		-- Verifica se node acerta tem interação
		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local def = minetest.registered_nodes[node.name]
		if def and def.on_rightclick and
			not (placer and placer:is_player() and
			placer:get_player_control().sneak) then
			return def.on_rightclick(under, node, placer, itemstack,
				pointed_thing) or itemstack
		end
		
		local name = placer:get_player_name()
		
		-- Verifica nivel do jogador
		if xpro and xpro.get_player_lvl(name) < revom.level_to_house then
			minetest.chat_send_player(name, S("Precisa atingir nivel @1", revom.level_to_house))
			return itemstack 
		end
		
		-- Verifica pos
		if pointed_thing == nil or pointed_thing.above == nil then
			return itemstack
		end
		local pos = pointed_thing.above
		
		-- Verificar se já está protegido
		for x=-1, 1 do
			for y=-1, 1 do
				for z=-1, 1 do
					if minetest.is_protected({x=pos.x+(5*x), y=pos.y+(5*x), z=pos.z+(5*x)}, name) == true then
						minetest.chat_send_player(name, S("Area protegida nas proximidades"))
						return itemstack 
					end
				end
			end
		end
		
		if not minetest.item_place(itemstack, placer, pointed_thing) then
			return itemstack
		end
		
		-- Remove item do inventario
		itemstack:take_item()

		return itemstack
	end,
	
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local name = placer:get_player_name()
		
		-- Pega coordenada antiga
		local oldpos = nil
		if revom.bd.verif("casas", name) == true then
			oldpos = revom.bd.pegar("casas", name).pos
		end
		
		-- Define novo demarcador
		revom.bd.salvar("casas", name, {pos=pos})
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Casa de @1", name))
		meta:set_string("dono", name)
		
		-- Nova ocupação
		local x, z = revom.zonas.get_malha(pos)
		revom.zonas.ocupar(x, z, "casa", pos, name)
		
		-- Verfica no que está na posição anterior
		if oldpos then
			check_demarcador(oldpos)
			
			-- Remove ocupação antiga (caso todos os dados sejam validos inclusive nome)
			local oldx, oldz = revom.zonas.get_malha(oldpos)
			revom.zonas.desocupar(oldx, oldz, "casa", oldpos, name)
		end
		
	end,
	
	can_dig = function(pos, player)
		local name = player:get_player_name()
		local meta = minetest.get_meta(pos)
		
		if meta:get_string("dono") == name then
			return true
		end
		
		return false
	end,
	
	on_punch = function(pos, node, puncher)
		display_territorio({x=pos.x, y=pos.y, z=pos.z}, 5, "revom:display_casa")
	end,
	
	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		local dono = meta:get_string("dono")
		
		-- Pega coordenada do banco de dados
		local bdpos = nil
		if revom.bd.verif("casas", dono) == true then
			bdpos = revom.bd.pegar("casas", dono).pos
		end
		
		-- Verifica se é o node atual do dono
		if bdpos and bdpos.x == pos.x and bdpos.y == pos.y and bdpos.z == pos.z then 
					
			revom.bd.remover("casas", dono)
			
			-- Remove ocupação antiga (caso todos os dados sejam validos inclusive nome)
			local bdx, bdz = revom.zonas.get_malha(bdpos)
			revom.zonas.desocupar(bdx, bdz, "casa", bdpos, dono)
		end
	end,
})
-- Receita 
minetest.register_craft({
	output = 'revom:demarcador_casa',
	recipe = {
		{'default:coal_lump', 'default:steel_ingot', 'default:coal_lump'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:coal_lump', 'default:steel_ingot', 'default:coal_lump'},
	}
})

-- LBM para verificar nodes inativos
minetest.register_lbm({
	name = "revom:update_demarcador_casa_lbm",
	nodenames = {"revom:demarcador_casa"},
	run_at_every_load = true,
	action = function(pos, node)
		check_demarcador(pos)
	end,
})

-- Verifica se a coordenada 'pos' é protegida contra o jogador 'name'
local new_is_protected = function(pos, name)
	if name == "" or name == nil then return nil end
	
	-- Node demarcador dentro da area de risco (não deve existir mais de 1)
	if minetest.find_node_near(pos, 5, "revom:demarcador_casa") then
	
		local meta = minetest.get_meta(pos)
		if meta:get_string("dono") == name then
			return false
		else
			return true
		end
	else
		return nil -- Indefinido, repassa para o proximo mod verificar
	end
end

-- Sobreescreve metodo de proteção
local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
	local r = new_is_protected(pos, name)
	if r ~= nil then
		return r
	end
	return old_is_protected(pos, name)
end

