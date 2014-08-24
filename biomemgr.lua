biome = biome or {}

biome.list = {}
function biome.add(p)
	biome.list[#biome.list+1] = {
		name = p.name,
		mint = p.mint, -- min temperature
		maxt = p.maxt, -- max
		minh = p.minh or 0, -- min humidity
		maxh = p.maxh or 100, -- max
		trees = p.trees or {{"nil",1024}},
		get_block = p.get_block
	}
end

-- testing purpose only!
biome.add({
	name = "NIL (Biome?)",
	mint = -5,
	maxt = -3,
	get_block = function() return minetest.get_content_id("air") end
})
--]]

function biome.get_by_temp_humi(t,h)
	t = math.min(t, 2)
	h = math.min(h, 100)
	local bl = biome.list
	local found = {}
	for i = 1, #bl do
		if t >= bl[i].mint and t <= bl[i].maxt then
			found[#found+1] = {i,bl[i].name}
		end
	end
	for i = 1, #found do
		local u = found[i][1]
		local o = found[i][2]
		if h >= bl[u].minh and h <= bl[u].maxh then
			return {u,bl[u].name}
		end
	end
	return {0,"NIL (Biome?)"}
end

function biome.get_block_by_temp_humi(temp,humi,base,wl,y,x,z)
	temp = math.min(temp, 2)
	humi = math.min(humi, 100)
	base = math.min(base, 255)
	return biome.list[biome.get_by_temp_humi(temp,humi)[1]].get_block(temp,humi,base,wl,y,x,z) or 0
end

dofile(minetest.get_modpath(minetest.get_current_modname()).."/biome.lua")