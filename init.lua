-- Another Map Generator for Minetest [amgmt] by srifqi
-- License: CC0 1.0 Universal
-- Dependencies: default, flowers

amgmt = {}
print("[amgmt] (Another Map Generator for Minetest)")

--param?
DEBUG = false -- set to false if your debug.txt is too full
wl = 0 -- water level
HMAX = 500
HMIN = -30000
BEDROCK = -29999 -- bedrock level

function amgmt.debug(text)
	if DEBUG == true then print("[amgmt]:"..(text or "")) end
end

amgmt.biome = {}
amgmt.tree = {}
dofile(minetest.get_modpath(minetest.get_current_modname()).."/nodes.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/trees.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/biomemgr.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/oremgr.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/mineshaft.lua")

minetest.register_on_mapgen_init(function(mgparams)
	amgmt.seed = mgparams.seed
	minetest.set_mapgen_params({mgname="singlenode", flags="nolight"})
end)

local function get_perlin_map(np, minp, maxp)
	local sidelen = maxp.x - minp.x +1
	local pm = minetest.get_perlin_map(
		{offset=0, scale=1, spread={x=np.c, y=np.c, z=np.c}, seed=np.s, octaves=np.o, persist=np.p},
		{x=sidelen, y=sidelen, z=sidelen}
	)
	return pm:get2dMap_flat({x = minp.x, y = minp.z, z = 0})
end

-- noiseparam
amgmt.np = {
--	s = seed, o = octaves, p = persistance, c = scale
	b = {s = 1234, o = 6, p = 0.5, c = 512}, -- base terrain
	p = {s = 3333, o = 5, p = 0.5, c = 256}, -- plateau (flat at top)
	t = {s = 5678, o = 3, p = 0.5, c = 512}, -- temperature
	h = {s = 8765, o = 3, p = 0.5, c = 512}, -- humidity
	l = {s = 1667, o = 6, p = 0.5, c = 256}, -- lake
	c = {s = 1024, o = 7, p = 0.5, c = 512}, -- cave
	d = {s = 2048, o = 7, p = 0.5, c = 512}, -- cave deepness
}

local np = amgmt.np -- copy of noiseparam

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

function get_base(base, temp, humi, plat)
	if base < wl then return math.ceil(base) end
	local base_ = base
	local bwl = base - wl
	local plat = plat+1
	local opt = 1/10 -- one per ten LOL
	
	--river
	if humi <= 52.5 and humi >= 47.5 then
		if humi >= 50 then
			base_ = wl-(1-(humi-50)/2.5)*(base%3+1)-1
		elseif humi <= 50 then
			base_ = wl-(1-(50-humi)/2.5)*(base%3+1)-1
		end
	--riverbank
	elseif humi < 55 and humi > 45 then
		if plat > 0.25 and plat < 0.45 then
			if humi >= 50 then
				base_ = wl+((humi-52.5)/2.5)*25
			elseif humi <= 50 then
				base_ = wl+((47.5-humi)/2.5)*25
			end

		else
			if humi >= 50 then
				base_ = wl+((humi-52.5)/2.5)*bwl
			elseif humi <= 50 then
				base_ = wl+((47.5-humi)/2.5)*bwl
			end
		end
	--plateau
	elseif plat > 0.25 and plat < 0.45 then
		base_ = wl+25+(bwl/4%2)
	--plateau edge
	elseif plat > 0.25-opt and plat < 0.45+opt then
		if plat >= 0.35 then
			base_ = math.max(wl+(1-(plat-0.45)/opt)*25,base)
		elseif plat <= 0.35 then
			base_ = math.max(wl+(1-(0.25-plat)/opt)*25,base)
		end
	else
		base_ = base
	end
	
	return math.ceil(base_)
end

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
			local via = area:index(x+xx,y+yy+1,z+zz)
			if
				data[vi] == deletednodes and
				distance3(x,y,z,x+xx,y+yy,z+zz) <= radius and
				data[via] == deletednodes 
			then
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
			local via = area:index(x+xx,y+yy+1,z+zz)
			if data[vi] == deletednodes and data[via] == deletednodes then
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
					local via = area:index(x+xx,y+yy+1,z+zz)
					if data[vi] == deletednodes and data[via] == deletednodes then
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
	
	--noise
	local t2 = os.clock()
	local base = get_perlin_map(np.b, minp, maxp) -- base height
	local plat = get_perlin_map(np.p, minp, maxp) -- plateau
	local temp = get_perlin_map(np.t, minp, maxp) -- temperature (0-2)
	local humi = get_perlin_map(np.h, minp, maxp) -- humidity (0-100)
	local lake = get_perlin_map(np.l, minp, maxp) -- lake
	
	--
	local cave = {} -- list of caves
	local deep = {} -- list of cave deepness
	for o = 1, 5 do
		local cnp = np.c
		cnp.s = cnp.s + o
		cave[o] = get_perlin_map(cnp, minp, maxp)
		local dnp = np.d
		dnp.s = dnp.s + o
		deep[o] = get_perlin_map(dnp, minp, maxp)
	end
	--]]
	
	local sidelen = maxp.x - minp.x +1
	local t3 = math.ceil((os.clock() - t2) * 100000)/100
	amgmt.debug("noise calculated - "..t3.."ms")
	
	--terraforming
	local t2 = os.clock()
	local nizx = 0
	local nizyx = 0
	for z = minp.z, maxp.z do
	for x = minp.x, maxp.x do
		nizx = nizx + 1
		nizyx = nizyx + 1
		local base_ = math.ceil((base[nizx] * 25) + wl)
		local plat_ = plat[nizx]
		local temp_ = math.abs(temp[nizx] * 2)
		local humi_ = math.abs(humi[nizx] * 100)
		base_ = get_base(base_, temp_, humi_, plat_)
		for y_ = minp.y, maxp.y do
			nizyx = nizyx + sidelen
			local vi = area:index(x,y_,z)
			-- world height limit :(
			if y_ < HMIN or y_ > HMAX then
				-- air
			elseif y_ == BEDROCK then
				data[vi] = c_bedrock
			-- biome
			else
				local node = amgmt.biome.get_block_by_temp_humi(temp_, humi_, base_, wl, y_, x, z)
				if node ~= c_air then
					data[vi] = node
				end
			end
		end
		nizyx = nizyx - (sidelen * sidelen)
	end
	end
	local t3 = math.ceil((os.clock() - t2) * 100000)/100
	amgmt.debug("terrain generated - "..t3.."ms")
	
	--
	--ore generation
	local t2 = os.clock()
	amgmt.ore.generate(minp, maxp, data, area, seed)
	local t3 = math.ceil((os.clock() - t2) * 100000)/100
	amgmt.debug("ore generated - "..t3.."ms")
	--]]
	
	--
	--mineshaft construction
	local t2 = os.clock()
	amgmt.mineshaft.generate(minp, maxp, data, area, seed, pr, plat)
	local t3 = math.ceil((os.clock() - t2) * 100000)/100
	amgmt.debug("mineshaft constructed - "..t3.."ms")
	--]]
	
	--
	--cave forming
	local t2 = os.clock()
	local nizx = 0
	for z = minp.z, maxp.z do
	for x = minp.x, maxp.x do
		nizx = nizx + 1
		local base_ = math.ceil((base[nizx] * 25) + wl)
		
		for o = 1, 5 do
			local cave_ = (cave[o][nizx]+1)/2
			local deep_ = deep[o][nizx] * 45 - 25
			
			if cave_ > 1-0.001 then
				local y = math.floor(wl + deep_)
				local shape = (base_%3) + 1
				build_cave_segment(x, y, z, data, area, shape, 1, c_stone)
				build_cave_segment(x, y, z, data, area, shape, 1, c_dirt)
				build_cave_segment(x, y, z, data, area, shape, 1, c_dirt_grass)
				build_cave_segment(x, y, z, data, area, shape, 1, c_dirt_snow)
				build_cave_segment(x, y, z, data, area, shape, 1, c_dirt_savanna)
				build_cave_segment(x, y, z, data, area, shape, 1, c_sandstone)
				build_cave_segment(x, y, z, data, area, shape, 1, c_sand)
				--amgmt.debug("cave generated at:"..x..","..y..","..z)
			end
		end
	end
	end
	local t3 = math.ceil((os.clock() - t2) * 100000)/100
	amgmt.debug("cave generated - "..t3.."ms")
	--]]
	
	--
	--forming lake
	local t2 = os.clock()
	local chulen = (maxp.x - minp.x + 1) / 16
	local nizx = 0
	for cz = 0, chulen-1 do
	for cx = 0, chulen-1 do
	-- for every chunk do
	nizx = (cz*chulen + cx) * 16
	local found_lake = false
	for z = minp.z + cz*16 +3, minp.z + (cz+1)*16 -3 do -- +-3 for lake borders
	if found_lake == true then break end
	for x = minp.x + cx*16 +3, minp.x + (cx+1)*16 -3 do -- +-3 for lake borders
		if found_lake == true then break end
		nizx = nizx + 1
		local base_ = math.ceil((base[nizx] * 25) + wl)
		local plat_ = plat[nizx]
		local temp_ = math.abs(temp[nizx] * 2)
		local humi_ = math.abs(humi[nizx] * 100)
		base_ = get_base(base_, temp_, humi_, plat_)
		local lake_ = math.abs(lake[nizx])
		if lake_ < 0.0005 and base_ > 5 then
			--amgmt.debug("lake found! "..x..","..base_..","..z.." ("..lake_..")")
			found_lake = true
			for u = -2, 2 do
			for i = -2, 2 do
				local vi = area:index(x+u,base_-2,z+i)
				if pr:next(1,3) >= 2 then
					data[vi] = c_sandstone
				else
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
			for o = 1, 2 do
				local vi = area:index(x+u,base_+o,z+i)
				data[vi] = c_air
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
	local t3 = math.ceil((os.clock() - t2) * 100000)/100
	amgmt.debug("lake formed - "..t3.."ms")
	--]]
	
	--
	--tree planting
	local t2 = os.clock()
	local nizx = 0
	for z = minp.z, maxp.z do
	for x = minp.x, maxp.x do
		nizx = nizx + 1
		local base_ = math.ceil((base[nizx] * 25) + wl)
		local plat_ = plat[nizx]
		local temp_ = math.abs(temp[nizx] * 2)
		local humi_ = math.abs(humi[nizx] * 100)
		base_ = get_base(base_, temp_, humi_, plat_)
		local biome__ = amgmt.biome.list[ amgmt.biome.get_by_temp_humi(temp_,humi_)[1] ]
		local tr = biome__.trees
		local filled = false
		for i = 1, #tr do
			if filled == true then break end
			local tri = amgmt.tree.registered[ tr[i][1] ] or amgmt.tree.registered["nil"]
			local chance = tr[i][2] or 1024
			if
				pr:next(1,chance) == 1 and
				base_+1 >= tri.minh and base_+1 <= tri.maxh and
				data[area:index(x,base_,z)] == gci(tri.grows_on)
			then
				amgmt.tree.spawn({x=x,y=base_+1,z=z},tr[i][1],data,area,seed,minp,maxp,pr)
				filled = true
			end
		end
	end
	end
	local t3 = math.ceil((os.clock() - t2) * 100000)/100
	amgmt.debug("tree planted - "..t3.."ms")
	--]]
	
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

local function amgmt_regenerate(pos, name)
	minetest.chat_send_all("Regenerating "..name.."'s map chunk...")
	local minp = {x = 80*math.floor((pos.x+32)/80)-32,
			y = 80*math.floor((pos.y+32)/80)-32,
			z = 80*math.floor((pos.z+32)/80)-32}
	local maxp = {x = minp.x+79, y = minp.y+79, z = minp.z+79}
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(minp, maxp)
	local data = {}
	for i = 1, (maxp.x-minp.x+1)*(maxp.y-minp.y+1)*(maxp.z-minp.z+1) do
		data[i] = c_air
	end
	vm:set_data(data)
	vm:write_to_map()
	amgmt_generate(minp, maxp, amgmt.seed or os.clock(), vm, emin, emax)
	
	minetest.chat_send_player(name, "Regenerating done, fixing lighting. This may take a while...")
	-- Fix lighting
	local nodes = minetest.find_nodes_in_area(minp, maxp, "air")
	local nnodes = #nodes
	local p = math.floor(nnodes/5)
	local dig_node = minetest.dig_node
	for _, pos in ipairs(nodes) do
		dig_node(pos)
		if _%p == 0 then
			minetest.chat_send_player(name, math.floor(_/nnodes*100).."%")
		end
	end
	minetest.chat_send_all("Done")
end

minetest.register_chatcommand("amgmt_regenerate", {
	privs = {server = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player then
			local pos = player:getpos()
			amgmt_regenerate(pos, name)
		end
	end,
})

local function amgmt_fixlight(pos, name)
	minetest.chat_send_player(name, "Fixing lightning. This may take a while...")
	local minp = {x = 80*math.floor((pos.x+32)/80)-32,
			y = 80*math.floor((pos.y+32)/80)-32,
			z = 80*math.floor((pos.z+32)/80)-32}
	local maxp = {x = minp.x+79, y = minp.y+79, z = minp.z+79}
	
	-- Fix lighting
	local nodes = minetest.find_nodes_in_area(minp, maxp, "air")
	local nnodes = #nodes
	local p = math.floor(nnodes/5)
	local dig_node = minetest.dig_node
	for _, pos in ipairs(nodes) do
		dig_node(pos)
		if _%p == 0 then
			minetest.chat_send_player(name, math.floor(_/nnodes*100).."%")
		end
	end
	minetest.chat_send_all("Done")
end

minetest.register_chatcommand("amgmt_fixlight", {
	privs = {server = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player then
			local pos = player:getpos()
			amgmt_fixlight(pos, name)
		end
	end,
})

dofile(minetest.get_modpath(minetest.get_current_modname()).."/hud.lua")

print("[amgmt]:"..amgmt.tree.count.." tree(s) registered")
print("[amgmt]:"..(#amgmt.biome.list-1).." biome(s) registered") -- do not count NIL biome!
print("[amgmt]:"..#amgmt.ore.registered.." ore(s) registered")