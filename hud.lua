amgmt = amgmt or {}
amgmt.hud = {}

local np = amgmt.np

minetest.register_globalstep(function(dtime)
	--if dtime < 0.1 then return end
	for _,player in ipairs(minetest.get_connected_players()) do
		local pos = player:getpos()
		local name = player:get_player_name()
		
		local temp = minetest.get_perlin(np.t.s, np.t.o, np.t.p, np.t.c):get2d({x=pos.x,y=pos.z})
		local humi = minetest.get_perlin(np.h.s, np.h.o, np.h.p, np.h.c):get2d({x=pos.x,y=pos.z})
		
		local biometext = amgmt.biome.get_by_temp_humi(math.abs(temp*2),math.abs(humi*100))[2]
		
		if not amgmt.hud[name] then
			amgmt.hud[name] = {}
			
			amgmt.hud[name].BiomeId = player:hud_add({
				hud_elem_type = "text",
				name = "Biome",
				number = 0xFFFFFF,
				position = {x=0, y=0.5},
				offset = {x=13, y=-20},
				direction = 0,
				text = "Biome: "..biometext,
				scale = {x=200, y=-60},
				alignment = {x=1, y=1},
			})
			
			amgmt.hud[name].oldBiome = biometext
			return
		elseif amgmt.hud[name].oldBiome ~= biometext then
			player:hud_change(amgmt.hud[name].BiomeId, "text",
				"Biome: "..biometext)
			amgmt.hud[name].oldBiome = biometext
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	amgmt.hud[player:get_player_name()] = nil
end)
