--[[
	Mod Revom para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Node demarcador de casa
  ]]


-- Verificar e remover demarcadores invalidos
local check_demarcador = function(pos)
	local meta = minetest.get_meta(pos)
	local dono = meta:get_string("dono")
	
	if revom.bd.verif("casas", dono) == false then
		minetest.remove_node(pos)
		return
	end
	
	if minetest.pos_to_string(revom.bd.pegar("casas", dono).pos) ~= minetest.pos_t_string(pos) then
		minetest.remove_node(pos)
		return
	end
end

-- Demarcador de territorio
minetest.register_node("revom:demarcador_casa", {
	description = "Demarcador de Casa",
	tiles = {
		"default_steel_block.png", 
		"default_steel_block.png", 
		"default_steel_block.png", 
		"default_steel_block.png", 
		"default_steel_block.png", 
		"default_steel_block.png", 
	},
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_wood_defaults(),
	walkable = true,
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {-0.5,-0.5,-0.5,0.5,0.5,0.5},
	},
	
	on_place = function(itemstack, placer, pointed_thing)
		local name = placer:get_player_name()
		local grupo = manipulus.get_player_grupo(name)
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
						minetest.chat_send_player(name, "Area protegida nas proximidades")
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
		
		revom.bd.salvar("casas", name, {pos=pos})
		
		-- Define demarcador
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Casa de "..name)
		meta:set_string("dono", name)
	end,
	
	can_dig = function(pos, player)
		local name = placer:get_player_name()
		
		-- Verifica se grupo existe ainda
		local meta = minetest.get_meta(pos)
		if meta:get_string("dono") == name then
			return true
		end
		
		return false
	end,
	
	on_punch = function(pos, node, puncher)
		manipulus.display_territorio({x=pos.x, y=pos.y, z=pos.z}, 5, "manipulus:display_territorio")
	end,
	
	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		local dono = meta:get_string("dono")
		
		revom.bd.remover("casas", dono)
	end,
})
-- Receita 
minetest.register_craft({
	output = 'revom:demarcador_casa',
	recipe = {
		{'group:stick', 'default:bronze_ingot', 'group:stick'},
		{'default:bronze_ingot', 'default:steelblock', 'default:bronze_ingot'},
		{'group:stick', 'default:bronze_ingot', 'group:stick'},
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
	local n = minetest.find_node_near(pos, 5, "revom:demarcador_casa")
	if n then
	
		local meta = minetest.get_meta(pos)
		if meta:get_string("dono") == name then
			return false
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

---
-- Caixa de Area
------
-- Registro das entidades
minetest.register_entity("revom:display_territorio", {
	visual = "mesh",
	visual_size = {x=1,y=1},
	mesh = "revom_cubo.b3d",
	textures = {"revom_display_territorio.png"},
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
revom.display_territorio = function(pos, dist, name)
	
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



