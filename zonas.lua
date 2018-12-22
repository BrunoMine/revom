--[[
	Mod Revom para Minetest
	Copyright (C) 2019 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Controle de Zonas
	O mundo é dividido em zonas quadradas para que os jogadores spawnem 
	em torno do centro proximo a zonas recem povoadas
  ]]

-- Variavel global
revom.zonas = {}

-- Retorna numero da malha (x, z) de acordo com uma coordenada informada (pos)
revom.zonas.get_malha = function(pos)
	return math.floor(pos.x/revom.largura_zona), math.floor(pos.z/revom.largura_zona)
end

-- Retorna coordenadas limitrofes da zona
revom.zonas.get_limits = function(x, z)
	local min = {x=x*revom.largura_zona, z=z*revom.largura_zona}
	local max = {x=min.x+(revom.largura_zona-1), z=min.z+(revom.largura_zona-1)}
	return min, max
end

-- Verificar zona ocupada
revom.zonas.ocupada = function(x, z)
	return revom.bd.verif("zonas_ocupadas", x.." "..z)
end

-- Zonas aptas a serem ocupadas
local zonas_livres = {}
if revom.bd.verif("zonas_aptas", "tabela") == true then
	zonas_livres = revom.bd.pegar("zonas_aptas", "tabela")
else
	zonas_livres = {
		["0"] = {
			{-1,1}, {0,1}, {1,1}, {-1,0}, {0,0}, {1,0}, {-1,-1}, {0,-1}, {1,-1}
		},
		["1"] = {},
		["2"] = {},
		["3"] = {},
		["4"] = {},
		["5"] = {},
		["6"] = {},
		["7"] = {},
		["8"] = {},
		["9"] = {},
		["10"] = {},
		["11"] = {},
		["12"] = {},
		["13"] = {},
		["14"] = {},
		["15"] = {},
		["16"] = {},
		["17"] = {},
		["18"] = {},
		["19"] = {},
		["20"] = {}
	}
	revom.bd.salvar("zonas_aptas", "tabela", zonas_livres)
end

-- Adicionar zona apta
revom.zonas.add_apta = function(x, z, usos)
	table.insert(zonas_livres[tostring(usos or 0)], {x, z})
	revom.bd.salvar("zonas_aptas", "tabela", zonas_livres)
end

-- Remover zona apta
revom.zonas.rem_apta = function(x, z, usos)
	for n,tb in pairs(zonas_livres) do
		for i,m in ipairs(tb) do
			if x == m[1] and z == m[2] then
				table.remove(zonas_livres[n], i)
			end
		end
	end
	revom.bd.salvar("zonas_aptas", "tabela", zonas_livres)
end

-- contabiliza o uso da zona apta
revom.zonas.apta_usada = function(x, z, usos)
	-- Verifica se informou numero de usos
	if not usos then
		local _, usos = revom.zonas.apta(x, z)
	end
	
	-- Soma numero de usos
	usos = usos + 1
	
	-- Verifica limite de usos
	if usos >= revom.limite_spawn_zona then 
		-- Expande zonas aptas
		revom.zonas.expande_aptas(x, z)
		-- Registra como ocupada para impedir que seja apta no futuro
		revom.zonas.ocupar(x, z)
	end
	
	-- Remove registro antigo
	revom.zonas.rem_apta(x, z)
	
	if usos < revom.limite_spawn_zona then 
		-- Adiciona novo registro
		revom.zonas.add_apta(x, z, usos)
	end
end

-- Verificar se é zona apta
-- Retorna true/false, [numero de spawns]
revom.zonas.apta = function(x, z)
	for usos,tb in pairs(zonas_livres) do
		for _,m in ipairs(tb) do
			if x == m[1] and z == m[2] then
				return true, usos
			end
		end
	end
	return false
end

-- Expande limite de zonas livres
revom.zonas.expande_aptas = function(x, z)
	-- Verifica se era zona apta (principio de expanção apartir do centro)
	if revom.zonas.apta(x, z) == true then
		local b = {}
		-- Verifica quais zonas adjacentes estão livres para se tornarem aptas
		for _,m in ipairs({
			{x-1,z+1}, {x,z+1}, {x+1,z+1},
			{x-1,z}, {x+1,z},
			{x-1,-1}, {x,z-1}, {x+1,z-1}
		}) do
			if revom.zonas.ocupada(m[1], m[2]) == false -- Verifica se está ocupada
				and revom.zonas.apta(m[1], m[2]) == false-- Verifica se já é uma zona apta
			then
				table.insert(b, m)
				revom.zonas.add_apta(m[1], m[2])
			end
		end
	end
end

-- Salvar zona ocupada
revom.zonas.ocupar = function(x, z, tipo, pos, name)
	local dados = {}
	if revom.bd.verif("zonas_ocupadas", x.." "..z) == true then
		dados = revom.bd.pegar("zonas_ocupadas", x.." "..z)
	end
	
	-- Novos dados
	if tipo then
		if dados[tipo] == nil then dados[tipo] = {} end
		table.insert(dados[tipo], {pos=pos, name=name})
	end
	
	revom.bd.salvar("zonas_ocupadas", x.." "..z, dados)
	
	-- Expandir limite de zonas ocupadas
	revom.zonas.expande_aptas(x, z)
	
	-- Atualiza waypoints de jogadores proximos
	revom.atualizar_waypoints_zona(x, z)
end

-- Desocupar zona
revom.zonas.desocupar = function(x, z, tipo, pos, name)
	local dados = {}
	if revom.bd.verif("zonas_ocupadas", x.." "..z) == true then
		dados = revom.bd.pegar("zonas_ocupadas", x.." "..z)
	end
	-- Novos dados
	if tipo then
		if dados[tipo] == nil then dados[tipo] = {} end
		for i,d in ipairs(dados[tipo]) do
			if d.pos.x == pos.x and d.pos.y == pos.y and d.pos.z == pos.z and d.name == name then
				table.remove(dados[tipo], i)
			end
		end
	end
	
	revom.bd.salvar("zonas_ocupadas", x.." "..z, dados)
	
	-- Atualiza waypoints de jogadores proximos
	revom.atualizar_waypoints_zona(x, z)
end

-- Pegar zona apta para spawn
-- Retorna x, z
revom.zonas.get_spawn = function()
	
	for i=0, 20, 1 do
		local tb = zonas_livres[tostring(i)]
		if table.maxn(tb) > 0 then
			-- Sorteia uma zona
			local malha = tb[math.random(1, table.maxn(tb))]
			
			revom.zonas.apta_usada(malha[1], malha[2], i)
			return malha[1], malha[2]
		end
	end
	
	-- Nenhuma malha encontrada
	minetest.log("error", "Nenhuma zona apta para spawn encontrada, retornando zona 0,0")
end


