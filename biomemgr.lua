amgmt = amgmt or {}
amgmt.biome = amgmt.biome or {}

amgmt.biome.list = {}
function amgmt.biome.add(p)
	amgmt.biome.list[#amgmt.biome.list+1] = {
		name = p.name,
		mint = p.mint,			-- min temperature
		maxt = p.maxt,			-- max temperature
		minh = p.minh or 0,		-- min humidity
		maxh = p.maxh or 100,	-- max humidity
		-- okay to spawn here?
		-- Note: player will be spawned at base, make
		-- sure the block at "base" is solid
		spawn_here = p.spawn_here or false,
		trees = p.trees or {{"nil",1024}},
		get_block = p.get_block
	}
end

function amgmt.biome.clear()
	-- reset
	amgmt.biome.list = {}
end

function amgmt.biome.get_by_temp_humi(t,h)
	t = math.min(math.abs(t), 2)
	h = math.min(math.abs(h), 100)
	local bl = amgmt.biome.list
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

function amgmt.biome.get_block_by_temp_humi(temp,humi,base,wl,y,x,z)
	temp = math.min(math.abs(temp), 2)
	humi = math.min(math.abs(humi), 100)
	base = math.min(base, 255)
	return amgmt.biome.list[
		amgmt.biome.get_by_temp_humi(temp,humi)[1]
	].get_block(temp,humi,base,wl,y,x,z) or 0
end

dofile(minetest.get_modpath(minetest.get_current_modname()).."/biome.lua")
