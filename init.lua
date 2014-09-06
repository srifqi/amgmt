amgmt = amgmt or {}
amgmt.seed = nil

minetest.register_on_mapgen_init(function(mgparams)
	minetest.set_mapgen_params({mgname="singlenode"})
	amgmt.seed = mgparams.seed
end)

--param?
DEBUG = true -- turn this off if your debug.txt is too full
wl = 0
HMAX = 500
HMIN = -10000
BEDROCK = -4999
BEDROCK2 = -9999

amgmt.biome = {}
amgmt.tree = {}
dofile(minetest.get_modpath(minetest.get_current_modname()).."/nodes.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/trees.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/biomemgr.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/oremgr.lua")

function amgmt.debug(text)
	if DEBUG == true then print("[amgmt]:"..(text or "")) end
end

local function get_perlin_map(seed, octaves, persistance, scale, minp, maxp)
	local sidelen = maxp.x - minp.x +1
	local pm = minetest.get_perlin_map(
		{offset=0, scale=1, spread={x=scale, y=scale, z=scale}, seed=seed, octaves=octaves, persist=persistance},
		{x=sidelen, y=sidelen, z=sidelen}
	)
	return pm:get2dMap_flat({x = minp.x, y = minp.z, z = 0})
end

-- noiseparam
np = {
--	s = seed, o = octaves, p = persistance, c = scale
	b = {s = 1234, o = 6, p = 0.5, c = 512},
	m = {s = 4321, o = 6, p = 0.5, c = 256},
	t = {s = 5678, o = 7, p = 0.5, c = 512},
	h = {s = 8765, o = 7, p = 0.5, c = 512},
	c1 = {s = 1111, o = 7, p = 0.5, c = 512},
	d1 = {s = 2222, o = 7, p = 0.5, c = 512},
	c2 = {s = 3333, o = 7, p = 0.5, c = 512},
	d2 = {s = 4444, o = 7, p = 0.5, c = 512},
	l = {s = 125, o = 6, p = 0.5, c = 256},
}

--node id?
local gci = minetest.get_content_id
local c_air = gci("air")
local c_bedrock = gci("amgmt:bedrock")
local c_stone = gci("default:stone")
local c_dirt = gci("default:dirt")
local c_dirt_grass = gci("default:dirt_with_grass")
local c_dirt_snow = gci("default:dirt_with_snow")
local c_dirt_savanna = gci("amgmt:dirt_at_savanna")
local c_sand = gci("default:sand")
local c_sandstone = gci("default:sandstone")
local c_water = gci("default:water_source")
local c_lava_source = gci("default:lava_source")

local function distance2(x1,y1,x2,y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5
end

local function distance3(x1,y1,z1,x2,y2,z2)
	return ((x2-x1)^2+(y2-y1)^2+(z2-z1)^2)^0.5
end

local function build_cave_segment(x, y, z, data, area, shape, radius, deletednodes)
	if shape == 1 then --sphere
		for zz = -radius, radius do
		for yy = -radius, radius do
		for xx = -radius, radius do
			local vi = area:index(x+xx,y+yy,z+zz)
			if data[vi] == deletednodes and distance3(x,y,z,x+xx,y+yy,z+zz) <= radius then 
				data[vi] = c_air
			end
		end
		end
		end
	elseif shape == 2 then --cube
		for zz = -radius, radius do
		for yy = -radius, radius do
		for xx = -radius, radius do
			local vi = area:index(x+xx,y+yy,z+zz)
			if data[vi] == deletednodes then 
				data[vi] = c_air
			end
		end
		end
		end
	elseif shape == 3 then --tube
		for zz = -radius, radius do
		for xx = -radius, radius do
			if distance2(x,z,x+xx,z+zz) <= radius then
				for yy = -radius, radius do
					local vi = area:index(x+xx,y+yy,z+zz)
					if data[vi] == deletednodes then 
						data[vi] = c_air
					end
				end
			end
		end
		end
	end
end

local function amgmt_generate(minp, maxp, seed, vm, emin, emax)
	local t1 = os.clock()
	local pr = PseudoRandom(seed)
	amgmt.debug(minp.x..","..minp.y..","..minp.z)
	local area = VoxelArea:new{
		MinEdge={x=emin.x, y=emin.y, z=emin.z},
		MaxEdge={x=emax.x, y=emax.y, z=emax.z},
	}
	local data = vm:get_data()
	local sidelen = maxp.x - minp.x + 1
	local base = get_perlin_map(np.b.s, np.b.o, np.b.p, np.b.c, minp, maxp) -- base height
	local moun = get_perlin_map(np.m.s, np.m.o, np.m.p, np.m.c, minp, maxp) -- addition
	local temp = get_perlin_map(np.t.s, np.t.o, np.t.p, np.t.c, minp, maxp) -- temperature (0-2)
	local humi = get_perlin_map(np.h.s, np.h.o, np.h.p, np.h.c, minp, maxp) -- humidity (0-100)
	local lake = get_perlin_map(np.l.s, np.l.o, np.l.p, np.l.c, minp, maxp) -- lake
	local cav1 = get_perlin_map(np.c1.s, np.c1.o, np.c1.p, np.c1.c, minp, maxp) -- cave1
	local dep1 = get_perlin_map(np.d1.s, np.d1.o, np.d1.p, np.d1.c, minp, maxp) -- deep1
	local cav2 = get_perlin_map(np.c2.s, np.c2.o, np.c2.p, np.c2.c, minp, maxp) -- cave2
	local dep2 = get_perlin_map(np.d2.s, np.d2.o, np.d2.p, np.d2.c, minp, maxp) -- deep2
	local fissure = minetest.get_perlin(3456, 6, 0.5, 360) -- fissure
	local nizx = 0
	for z = minp.z, maxp.z do
	for x = minp.x, maxp.x do
		nizx = nizx + 1
		local base_ = math.ceil((base[nizx] * -50) + wl + 16.67 + (moun[nizx] * 15))
		local temp_ = 0
		local humi_ = 0
		if base_ > 95 then
			temp_ = 0.1
			humi_ = 90
		else
			temp_ = math.abs(temp[nizx] * 2)
			humi_ = math.abs(humi[nizx] * 100)
		end
		--amgmt.debug(x..","..z.." : "..temp_)
		for y_ = minp.y, maxp.y do
			local vi = area:index(x,y_,z)
			-- world height limit :(
			if y_ < HMIN or y_ > HMAX then
				data[vi] = c_air
			elseif y_ == BEDROCK or y_ == BEDROCK2 then
				data[vi] = c_bedrock
			--
			-- fissure
			elseif math.abs(fissure:get3d({x=x,y=y_,z=z})) < 0.0045 then
				data[vi] = c_air
			--]]
			-- biome
			else
				--data[vi] = c_air
				data[vi] = amgmt.biome.get_block_by_temp_humi(temp_, humi_, base_, wl, y_, x, z)
			end
		end
	end
	end
	amgmt.debug("terrain generated")
	
	--ore generation
	amgmt.ore.generate(minp, maxp, data, area, seed)
	amgmt.debug("ore generated")
	
	--cave forming
	local nizx = 0
	for z = minp.z, maxp.z do
	for x = minp.x, maxp.x do
		nizx = nizx + 1
		local cav1_ = math.abs(cav1[nizx])
		local dep1_ = dep1[nizx] * 30 + 5
		local cav2_ = math.abs(cav2[nizx])
		local dep2_ = dep2[nizx] * 50 - 25
		local base_ = math.ceil((base[nizx] * -50) + wl + 16.67 + (moun[nizx] * 15))
		--amgmt.debug(x..","..z..":"..cav1_..","..dep1_..","..cav2_..","..dep2_)
		
		if cav1_ < 0.015 or cav1_ > 1-0.015 then
			local y = math.floor(wl + dep1_ + 0.5)
			local shape = (base_%3) + 1
			build_cave_segment(x, y, z, data, area, shape, 1, c_stone)
			build_cave_segment(x, y, z, data, area, shape, 1, c_dirt)
			build_cave_segment(x, y, z, data, area, shape, 1, c_dirt_grass)
			build_cave_segment(x, y, z, data, area, shape, 1, c_dirt_snow)
			build_cave_segment(x, y, z, data, area, shape, 1, c_dirt_savanna)
			--amgmt.debug("cave generated at:"..x..","..y..","..z)
		end
		
		if cav2_ < 0.015 or cav2_ > 1-0.015 then
			local y = math.floor(wl - dep2_ - 0.5)
			local shape = (base_%3) + 1
			build_cave_segment(x, y, z, data, area, shape, 1, c_stone)
			build_cave_segment(x, y, z, data, area, shape, 1, c_dirt)
			build_cave_segment(x, y, z, data, area, shape, 1, c_dirt_grass)
			build_cave_segment(x, y, z, data, area, shape, 1, c_dirt_snow)
			build_cave_segment(x, y, z, data, area, shape, 1, c_dirt_savanna)
			--amgmt.debug("cave generated at:"..x..","..y..","..z)
		end
	end
	end
	amgmt.debug("cave generated")
	
	--forming lake
	local chulen = (maxp.x - minp.x + 1) / 16
	local nizx = 0
	for cz = 0, chulen-1 do
	for cx = 0, chulen-1 do
	local nizx = cz*chulen*16 + cx*16
	local found_lake = false
	for z = minp.z + cz*16, minp.z + (cz+1)*16 do
	if found_lake == true then break end
	for x = minp.x + cx*16, minp.x + (cx+1)*16 do
		if found_lake == true then break end
		nizx = nizx + 1
		local base_ = math.ceil((base[nizx] * -50) + wl + 16.67 + (moun[nizx] * 15))
		local lake_ = math.abs(lake[nizx])
		if lake_ < 0.0005 then
			--amgmt.debug("lake found! "..x..","..base_..","..z.." ("..lake_..")")
			found_lake = true
			for u = -2, 2 do
			for i = -2, 2 do
				local vi = area:index(x+u,base_-2,z+i)
				if pr:next(1,3) >= 2 then
					data[vi] = c_sandstone
				elseif data[vi] ~= c_air then
					data[vi] = c_stone
				end
			for o = -1, 0 do
				local vi = area:index(x+u,base_+o,z+i)
				if u > -2 and u < 2 and i > -2 and i < 2 and o == 0 then
					data[vi] = c_water
				else
					data[vi] = c_sand
				end
			end
			end
			end
			
			for ii = 1, 10 do
				local xx = pr:next(-1,1)
				local zz = pr:next(-1,1)
				
				local vi = area:index(x+xx,base_-1,z+zz)
				data[vi] = c_water
			end
		end
	end
	end
	end
	end
	amgmt.debug("lake formed")
	
	--tree planting
	local nizx = 0
	for z = minp.z, maxp.z do
	for x = minp.x, maxp.x do
		nizx = nizx + 1
		local base_ = math.ceil((base[nizx] * -50) + wl + 16.67 + (moun[nizx] * 15))
		local temp_ = 0
		local humi_ = 0
		if base_ > 95 then
			temp_ = 0.10
			humi_ = 90
		else
			temp_ = math.abs(temp[nizx] * 2)
			humi_ = math.abs(humi[nizx] * 100)
		end
		local biome__ = amgmt.biome.list[amgmt.biome.get_by_temp_humi(temp_,humi_)[1]]
		local tr = biome__.trees
		local filled = false
		for i = 1, #tr do
			if filled == true then break end
			local tri = amgmt.tree.registered[tr[i][1]] or amgmt.tree.registered["nil"]
			local chance = tr[i][2] or 1024
			if
				pr:next(1,chance) == 1 and
				base_+1 >= tri.minh and base_+1 <= tri.maxh and
				data[area:index(x,base_,z)] == gci(tri.grows_on)
			then
				amgmt.tree.spawn({x=x,y=base_+1,z=z},tr[i][1],data,area,seed,minp,maxp,pr)
				filled = true
				--[[
				amgmt.debug(
					"spawned "..tr[i][1]..
					" at "..x..","..(base_+1)..","..z..
					" in "..biome__.name.." biome"
				)
				--]]
			end
		end
	end
	end
	amgmt.debug("tree planted")
	
	amgmt.debug("applying map data")
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:update_liquids()
	vm:calc_lighting()
	vm:write_to_map(data)
	local chugent = math.ceil((os.clock() - t1) * 100000)/100
	amgmt.debug("Done in "..chugent.."ms")
end

minetest.register_on_generated(function(minp, maxp, seed)
	if minp.y > HMAX or maxp.y < HMIN then return end
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	amgmt_generate(minp, maxp, seed, vm, emin, emax)
end)

dofile(minetest.get_modpath(minetest.get_current_modname()).."/hud.lua")

print("[amgmt] (Another Map Generator for Minetest) Loaded")

print("[amgmt]:"..amgmt.tree.count.." tree(s) registered")
print("[amgmt]:"..(#amgmt.biome.list-1).." biome(s) registered") -- do not count NIL biome!
print("[amgmt]:"..#amgmt.ore.registered.." ore(s) registered")