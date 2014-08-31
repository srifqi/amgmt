amgmt.hud = {}

minetest.register_globalstep(function(dtime)
	if dtime < 0.1 then return end
	for _,player in ipairs(minetest.get_connected_players()) do
		local pos = player:getpos()
		local name = player:get_player_name()
		
		local base = minetest.get_perlin(np.b.s, np.b.o, np.b.p, np.b.c):get2d({x=pos.x,y=pos.z})
		local moun = minetest.get_perlin(np.m.s, np.m.o, np.m.p, np.m.c):get2d({x=pos.x,y=pos.z})
		local base = math.ceil((base * -30) + wl + 10 + (moun * 15))
		local temp = 0
		local humi = 0
		if base > 95 then
			temp = 0.05
			humi = 0.9
		else
			temp = minetest.get_perlin(np.t.s, np.t.o, np.t.p, np.t.c):get2d({x=pos.x,y=pos.z})
			humi = minetest.get_perlin(np.h.s, np.h.o, np.h.p, np.h.c):get2d({x=pos.x,y=pos.z})
		end
		
		local biometext = biome.get_by_temp_humi(math.abs(temp*2),math.abs(humi*100))[2]
		
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