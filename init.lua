amgmt = amgmt or {}
amgmt.seed = nil

minetest.register_on_mapgen_init(function(mgparams)
	minetest.set_mapgen_params({mgname="singlenode"})
	amgmt.seed = mgparams.seed
end)

--param?
wl = 0
HMAX = 300
HMIN = -6000
BEDROCK = -5000
BEDROCK2 = -6000

biome = {}
tree = {}
dofile(minetest.get_modpath(minetest.get_current_modname()).."/nodes.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/trees.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/biomemgr.lua")

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
	s1 = {s = 125, o = 6, p = 0.5, c = 256},
}

--node id?
local gci = minetest.get_content_id
local c_air = gci("air")
local c_bedrock = gci("amgmt:bedrock")
local c_sand = gci("default:sand")
local c_sandstone = gci("default:sandstone")
local c_water = gci("default:water_source")
local c_lava_source = gci("default:lava_source")

local function amgmt_generate(minp, maxp, seed, vm, emin, emax)
	local t1 = os.clock()
	local pr = PseudoRandom(seed)
	print("[amgmt]:"..minp.x..","..minp.y..","..minp.z)
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
	local spc1 = get_perlin_map(np.h.s, np.h.o, np.h.p, np.h.c, minp, maxp) -- special1
	local cave = minetest.get_perlin(3456, 6, 0.5, 360) -- cave
	--local laca = minetest.get_perlin(1278, 6, 0.5, 360) -- lava cave
	print("[amgmt]:terrain generation")
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
		--print(x..","..z.." : "..temp_)
		for y_ = minp.y, maxp.y do
			local vi = area:index(x,y_,z)
			-- world height limit :(
			if y_ < HMIN or y_ > HMAX then
				data[vi] = c_air
			elseif y_ == BEDROCK or y_ == BEDROCK2 then
				data[vi] = c_bedrock
			--
			-- cave
			elseif math.abs(cave:get3d({x=x,y=y_,z=z})) < 0.005 then
				data[vi] = c_air
			--]]
			--[[
			-- lava cave
			elseif math.abs(laca:get3d({x=x,y=y_,z=z})) > 350 and y_ < wl * 2/3 then
				data[vi] = c_lava_source
			--]]
			-- biome
			else
				data[vi] = c_air
				--data[vi] = biome.get_block_by_temp_humi(temp_, humi_, base_, wl, y_, x, z)
			end
		end
		
	end
	end
	
	--forming lake
	print("[amgmt]:forming lake")
	local found_lake = false
	local chulen = (maxp.x - minp.x + 1) / 16
	for cz = 0, chulen-1 do
	for cx = 0, chulen-1 do
	local nizx = 0
	for z = minp.z + cz*16, minp.z + (cz+1)*16 do
	if found_lake == true then break end
	for x = minp.x + cx*16, minp.x + (cx+1)*16 do
		if found_lake == true then break end
		nizx = nizx + 1
		local base_ = math.ceil((base[nizx] * -50) + wl + 16.67 + (moun[nizx] * 15))
		local lake_ = math.abs(spc1[nizx])
		if lake_ < 0.001 then
			print("[amgmt] lake found! "..x..","..base_..","..z.."("..lake_..")")
			found_lake = true
			for u = -2, 2 do
			for i = -2, 2 do
				local vi = area:index(x+u,base_-2,z+i)
				data[vi] = c_sandstone
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
	
	--ore generation
	--print("[amgmt]:generating ore")
	
	--tree planting
	print("[amgmt]:planting tree")
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
		local biome__ = biome.list[biome.get_by_temp_humi(temp_,humi_)[1]]
		local tr = biome__.trees
		local filled = false
		--print("done. "..biome__.name.." Biome. spawning "..#tr.." type of floras ...")
		for i = 1, #tr do
			if filled == true then break end
			local tri = tree.registered[tr[i][1]] or tree.registered["nil"]
			local chance = tr[i][2] or 1024
			--[[
			print(
				"try to spawn "..tr[i][1]..
				" at "..x..","..(base_+1)..","..z..
				" in "..biome__.name.." biome"
			)
			--]]
			if
				pr:next(1,chance) == 1 and
				base_+1 >= tri.minh and base_+1 <= tri.maxh and
				data[area:index(x,base_,z)] == gci(tri.grows_on)
			then
				tree.spawn({x=x,y=base_+1,z=z},tr[i][1],data,area,seed,minp,maxp,pr)
				filled = true
				--[[
				print(
					"spawned "..tr[i][1]..
					" at "..x..","..(base_+1)..","..z..
					" in "..biome__.name.." biome"
				)
				--]]
			end
		end
	end
	end
	
	print("[amgmt]:applying map data")
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:update_liquids()
	vm:calc_lighting()
	vm:write_to_map(data)
	local chugent = math.ceil((os.clock() - t1) * 100000)/100
	print("[amgmt]:Done in "..chugent.."ms")
end

minetest.register_on_generated(function(minp, maxp, seed)
	if minp.y > HMAX or maxp.y < HMIN then return end
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	amgmt_generate(minp, maxp, seed, vm, emin, emax)
end)

dofile(minetest.get_modpath(minetest.get_current_modname()).."/hud.lua")

print("[amgmt] (Another Map Generator for Minetest) Loaded")