amgmt = amgmt or {}

amgmt.spawn_at = {x = 0, y = 0, z = 0}
amgmt.spawn_found = false

local np = amgmt.np
function amgmt.spawnplayer(player)
	amgmt.spawn_radius = math.max(math.min(amgmt.spawn_radius, 30000), 100)
	local test = minetest.get_perlin(np.l.s, np.l.o, np.l.p, 128)
	local x = math.floor(test:get2d({x = 9, y = 0}) * amgmt.spawn_radius)
	local z = math.floor(test:get2d({x = 0, y = 9}) * amgmt.spawn_radius)
	amgmt.spawn_at = {x = x, y = z, z = z}
	while amgmt.spawn_found == false do
		local base = minetest.get_perlin(np.b.s, np.b.o, np.b.p, np.b.c):get2d(amgmt.spawn_at)
		local plat = minetest.get_perlin(np.p.s, np.p.o, np.p.p, np.p.c):get2d(amgmt.spawn_at)
		local temp = minetest.get_perlin(np.t.s, np.t.o, np.t.p, np.t.c):get2d(amgmt.spawn_at)
		local humi = minetest.get_perlin(np.h.s, np.h.o, np.h.p, np.h.c):get2d(amgmt.spawn_at)
		base = get_base(math.ceil((base * 25) + amgmt.wl), temp, humi, plat)
		
		local allowspawn = amgmt.biome.list[
			amgmt.biome.get_by_temp_humi(temp * 2, humi * 100)[1]
		].spawn_here
		
		if allowspawn == true and base > 0 then
			amgmt.spawn_at.y = base + 1
			player:setpos(amgmt.spawn_at)
			amgmt.spawn_found = true
		else
			local x = math.floor(temp * amgmt.spawn_radius)
			local z = math.floor(humi * amgmt.spawn_radius)
			amgmt.spawn_at = {x = x, y = z, z = z}
		end
	end
	
	return true
end


minetest.register_on_newplayer(amgmt.spawnplayer)
minetest.register_on_respawnplayer(amgmt.spawnplayer)