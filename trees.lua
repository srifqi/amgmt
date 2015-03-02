amgmt = amgmt or {}
amgmt.tree = {}
amgmt.tree.registered = {}
amgmt.tree.count = 0

function amgmt.tree.spawn(pos,name,data,area,seed,minp,maxp,pr)
	amgmt.tree.registered[name].grow(pos, data, area, seed, minp, maxp, pr)
end

function amgmt.tree.register(def)
	amgmt.tree.registered[def.name] = {
		chance = def.chance or 1024,
		minh = def.minh or 0,
		maxh = def.maxh or HMAX,
		grows_on = def.grows_on or "default:dirt_with_grass",
		grow = def.grow or function() return nil end
	}
	amgmt.tree.count = amgmt.tree.count + 1
end

function amgmt.tree.clear()
	amgmt.tree.registered = {}
	amgmt.tree.count = 0
	
	amgmt.tree.register({
		name = "nil",
		grow = function() end
	})
end

amgmt.tree.register({
	name = "nil",
	grow = function() end
})

local regtr = amgmt.tree.register

--node id?
local gci = minetest.get_content_id
local c_air = gci("air")
local c_ignore = gci("ignore")
local c_dirt_grass = gci("default:dirt_with_grass")
local c_tree = gci("default:tree")
local c_leaves = gci("default:leaves")
local c_apple = gci("default:apple")
local c_jungletree = gci("default:jungletree")
local c_jungleleaves = gci("default:jungleleaves")
local c_snow = gci("default:snow")

--add leaves function
local function add_leaves(data, vi, c_leaf, other)
	local other = other or c_leaf
	if data[vi]==c_air or data[vi]==c_ignore or data[vi] == other then
		data[vi] = c_leaf
	end
end

--normal tree
function amgmt.tree.normal_tree(pos, data, area, seed, minp, maxp, pr)
	local x, y, z = pos.x, pos.y, pos.z
	local is_apple_tree = false
	if pr:next(1,100) < 25 then
		is_apple_tree = true
	end
	local th = pr:next(4,5)
	
	for yy = y, y+th do
		local vi = area:index(x, yy, z)
		data[vi] = c_tree
	end
	
	local y = y + th - 1
	
	for xx = x-1, x+1 do
	for yy = y-1, y+1 do
	for zz = z-1, z+1 do
		if area:contains(xx,yy,zz) then
			local vi = area:index(xx, yy, zz)
			if pr:next(1,100) > 25 then
				add_leaves(data, vi, c_leaves)
			else
				if is_apple_tree == true then
					add_leaves(data, vi, c_apple)
				else
					add_leaves(data, vi, c_leaves)
				end
			end
		end
	end
	end
	end
	
	for ii = 1, 8 do
		local xx = x + pr:next(-2,2)
		local yy = y + pr:next(-1,2)
		local zz = z + pr:next(-2,2)
		for xxx = 0, 1 do
		for yyy = 0, 1 do
		for zzz = 0, 1 do
			if area:contains(xx+xxx, yy+yyy, zz+zzz) then
				local vi = area:index(xx+xxx, yy+yyy, zz+zzz)
				add_leaves(data, vi, c_leaves, c_leaves)
			end
		end
		end
		end
	end
end
regtr({
	name = "normal",
	chance = 15,
	minh = 1,
	maxh = 85,
	grows_on = "default:dirt_with_grass",
	grow = function(pos, data, area, seed, minp, maxp, pr)
		amgmt.tree.normal_tree(pos, data, area, seed, minp, maxp, pr)
		
		--amgmt.debug("normal tree spawned at:"..x..","..y..","..z)
	end
})

--jungle tree
function amgmt.tree.jungle_tree(pos, data, area, seed, minp, maxp, pr)
	local x, y, z = pos.x, pos.y, pos.z
	local th = pr:next(8,12)
	
	for zz = z-1, z+1,maxp.z do
	for xx = x-1, x+1,maxp.x do
		if pr:next(1,3) >= 2 and area:contains(xx,y,zz) then
			local vi = area:index(xx, y, zz)
			add_leaves(data, vi, c_jungletree)
		end
	end
	end
	
	for yy = y, y+th do
		local vi = area:index(x, yy, z)
		data[vi] = c_jungletree
	end
	
	local y = y + th - 1
	
	for xx = x-1, x+1 do
	for yy = y-1, y+1 do
	for zz = z-1, z+1 do
		if area:contains(xx,yy,zz) then
			local vi = area:index(xx, yy, zz)
			add_leaves(data, vi, c_jungleleaves)
		end
	end
	end
	end
	
	for ii = 1, 30 do
		local xx = x + pr:next(-3,3)
		local yy = y + pr:next(-2,2)
		local zz = z + pr:next(-3,3)
		for xxx = 0, 1 do
		for yyy = 0, 1 do
		for zzz = 0, 1 do
			if area:contains(xx+xxx, yy+yyy, zz+zzz) then
				local vi = area:index(xx+xxx, yy+yyy, zz+zzz)
				add_leaves(data, vi, c_jungleleaves, c_jungleleaves)
			end
		end
		end
		end
	end
end
regtr({
	name = "jungle",
	chance = 10,
	minh = 1,
	maxh = 85,
	grows_on = "default:dirt_with_grass",
	grow = function(pos, data, area, seed, minp, maxp, pr)
		amgmt.tree.jungle_tree(pos, data, area, seed, minp, maxp, pr)
		
		--amgmt.debug("jungle tree spawned at:"..x..","..y..","..z)
	end
})

--savanna tree
local c_savanna_tree = gci("amgmt:savanna_tree")
local c_savanna_leaves = gci("amgmt:savanna_leaves")
function amgmt.tree.savanna_tree(pos, data, area, seed, minp, maxp, pr)
	local x, y, z = pos.x, pos.y, pos.z
	local th = pr:next(7,11)
	
	for yy = y, y+th do
		local vi = area:index(x, yy, z)
		data[vi] = c_savanna_tree
	end
	y = y+th-1
	
	for xx = x-1, x+1 do
	for yy = y-1, y+1 do
	for zz = z-1, z+1 do
		if area:contains(xx,yy,zz) then
			local vi = area:index(xx, yy, zz)
			add_leaves(data, vi, c_savanna_leaves)
		end
	end
	end
	end
	
	for ii = 1, 12 do
		local xx = x + pr:next(-2,2)
		local yy = y + pr:next(-2,2)
		local zz = z + pr:next(-2,2)
		
		for xxx = 0, 1 do
		for yyy = 0, 1 do
		for zzz = 0, 1 do
			if area:contains(xx+xxx, yy+yyy, zz+zzz) then
				local vi = area:index(xx+xxx, yy+yyy, zz+zzz)
				add_leaves(data, vi, c_savanna_leaves, c_leaves)
			end
		end
		end
		end
	end
end
regtr({
	name = "savanna",
	chance = 225,
	minh = 1,
	maxh = 85,
	grows_on = "amgmt:dirt_at_savanna",
	grow = function(pos, data, area, seed, minp, maxp, pr)
		amgmt.tree.savanna_tree(pos, data, area, seed, minp, maxp, pr)
		
		--amgmt.debug("savanna tree spawned at:"..x..","..y..","..z)
	end
})

local c_pine_tree = gci("amgmt:pine_tree")
local c_pine_leaves = gci("amgmt:pine_leaves")
--pine tree at cold taiga
function amgmt.tree.pine_cold_tree(pos, data, area, seed, minp, maxp, pr)
	local x, y, z = pos.x, pos.y, pos.z
	local th = pr:next(8,9)
	
	for yy = y, y+th do
		local vi = area:index(x, yy, z)
		data[vi] = c_pine_tree
	end
	
	for xx = x-1, x+1 do
	for yy = 1, 3 do
	for zz = z-1, z+1 do
		if area:contains(xx, y+(yy*2)+1, zz) then
			local vi = area:index(xx, y+(yy*2)+1, zz)
			add_leaves(data, vi, c_pine_leaves)
			local vi = area:index(xx, y+(yy*2)+2, zz)
			add_leaves(data, vi, c_snow)
		end
	end
	end
	end
	
	local vi = area:index(x, y+th+1, z)
	add_leaves(data, vi, c_pine_leaves)
	local vi = area:index(x, y+th+2, z)
	add_leaves(data, vi, c_snow)
end
regtr({
	name = "pine_cold",
	chance = 40,
	minh = 1,
	maxh = 100,
	grows_on = "default:dirt_with_snow",
	grow = function(pos, data, area, seed, minp, maxp, pr)
		amgmt.tree.pine_cold_tree(pos, data, area, seed, minp, maxp, pr)
		
		--amgmt.debug("pine tree spawned at:"..x..","..y..","..z)
	end
})

--pine tree at taiga
function amgmt.tree.pine_tree(pos, data, area, seed, minp, maxp, pr)
	local x, y, z = pos.x, pos.y, pos.z
	local th = pr:next(8,9)
	
	for yy = y, y+th do
		local vi = area:index(x, yy, z)
		data[vi] = c_pine_tree
	end
	
	for xx = x-1, x+1 do
	for yy = 1, 3 do
	for zz = z-1, z+1 do
		if area:contains(xx, y+(yy*2)+1, zz) then
			local vi = area:index(xx, y+(yy*2)+1, zz)
			add_leaves(data, vi, c_pine_leaves)
		end
	end
	end
	end
	
	local vi = area:index(x, y+th+1, z)
	add_leaves(data, vi, c_pine_leaves)
end
regtr({
	name = "pine_taiga",
	chance = 40,
	minh = 1,
	maxh = 100,
	grows_on = "default:dirt_with_grass",
	grow = function(pos, data, area, seed, minp, maxp, pr)
		amgmt.tree.pine_tree(pos, data, area, seed, minp, maxp, pr)
		
		--amgmt.debug("pine tree spawned at:"..x..","..y..","..z)
	end
})

--decoration

local c_cactus = gci("default:cactus")
local c_dry_shrub = gci("default:dry_shrub")
local c_papyrus = gci("default:papyrus")
local c_junglegrass  = gci("default:junglegrass")
local c_grass_1  = gci("default:grass_1")
local c_grass_2  = gci("default:grass_2")
local c_grass_3  = gci("default:grass_3")
local c_grass_4  = gci("default:grass_4")
local c_grass_5  = gci("default:grass_5")
local c_grasses = {c_grass_1, c_grass_2, c_grass_3, c_grass_4, c_grass_5}

--dry shrub
regtr({
	name = "dry_shrub",
	chance = 50,
	minh = 1,
	maxh = 90,
	grows_on = "default:sand",
	grow = function(pos, data, area, seed, minp, maxp, pr)
		local x, y, z = pos.x, pos.y, pos.z
		local vi = area:index(x, y, z)
		if data[vi] == c_air or data[vi] == c_ignore then
			data[vi] = c_dry_shrub
		end
		
		--amgmt.debug("dry shrub spawned at:"..x..","..y..","..z)
	end
})

--cactus
regtr({
	name = "cactus",
	chance = 50,
	minh = 1,
	maxh = 90,
	grows_on = "default:sand",
	grow = function(pos, data, area, seed, minp, maxp, pr)
		local x, y, z = pos.x, pos.y, pos.z
		for yy = math.max(y,minp.y), math.min(y+pr:next(1,4),maxp.y) do
			data[area:index(x, yy, z)] = c_cactus
		end
		
		--amgmt.debug("cactus spawned at:"..x..","..y..","..z)
	end
})

--papyrus
regtr({
	name = "papyrus",
	chance = 10,
	minh = wl+1,
	maxh = wl+1,
	grows_on = "default:dirt_with_grass",
	grow = function(pos, data, area, seed, minp, maxp, pr)
		local x, y, z = pos.x, pos.y, pos.z
		for yy = math.max(y,minp.y), math.min(y+pr:next(2,4),maxp.y) do
			data[area:index(x, yy, z)] = c_papyrus
		end
		
		--amgmt.debug("papyrus spawned at:"..x..","..y..","..z)
	end
})

--grass at extreme hills
regtr({
	name = "grass_extreme",
	chance = 60,
	minh = 1,
	maxh = 500,
	grows_on = "default:stone",
	grow = function(pos, data, area, seed, minp, maxp, pr)
		local x, y, z = pos.x, pos.y, pos.z
		local base = y-1 + math.ceil(math.abs(y-1 - wl) * 1/5)
		local vi = area:index(x, base, z)
		if data[vi] == c_dirt_grass then
			local vi = area:index(x, base+1, z)
			data[vi] = c_grasses[pr:next(1,5)]
		end
		
		--amgmt.debug("grass spawned at:"..x..","..y..","..z)
	end
})

-- jungle grass
regtr({
	name = "jungle_grass",
	chance = 25,
	minh = 1,
	maxh = 85,
	grows_on = "default:dirt_with_grass",
	grow = function(pos, data, area, seed, minp, maxp, pr)
		local x, y, z = pos.x, pos.y, pos.z
		local vi = area:index(x, y, z)
		if data[vi] == c_air or data[vi] == c_ignore then
			data[vi] = c_junglegrass
		end
		
		--amgmt.debug("jungle grass spawned at:"..x..","..y..","..z)
	end
})

--grass 1-4
regtr({
	name = "grass14",
	chance = 60,
	minh = 1,
	maxh = 105,
	grows_on = "default:dirt_with_grass",
	grow = function(pos, data, area, seed, minp, maxp, pr)
		local x, y, z = pos.x, pos.y, pos.z
		local vi = area:index(x, y, z)
		if data[vi] == c_air or data[vi] == c_ignore then
			data[vi] = c_grasses[pr:next(1,4)]
		end
		
		--amgmt.debug("grass spawned at:"..x..","..y..","..z)
	end
})

--grass 3-5
regtr({
	name = "grass35",
	chance = 5,
	minh = 4,
	maxh = 105,
	grows_on = "default:dirt_with_grass",
	grow = function(pos, data, area, seed, minp, maxp, pr)
		local x, y, z = pos.x, pos.y, pos.z
		local vi = area:index(x, y, z)
		if data[vi] == c_air or data[vi] == c_ignore then
			data[vi] = c_grasses[pr:next(3,5)]
		end
		
		--amgmt.debug("grass spawned at:"..x..","..y..","..z)
	end
})


local c_dandelion_white = gci("flowers:dandelion_white")
local c_dandelion_yellow = gci("flowers:dandelion_yellow")
local c_geranium = gci("flowers:geranium")
local c_rose = gci("flowers:rose")
local c_tulip = gci("flowers:tulip")
local c_viola = gci("flowers:viola")
local c_flowers = {c_dandelion_white, c_dandelion_yellow, c_geranium, c_rose, c_tulip, c_viola}

--flower
regtr({
	name = "flowers",
	chance = 3,
	minh = 4,
	maxh = 90,
	grows_on = "default:dirt_with_grass",
	grow = function(pos, data, area, seed, minp, maxp, pr)
		local x, y, z = pos.x, pos.y, pos.z
		local vi = area:index(x, y, z)
		if data[vi] == c_air or data[vi] == c_ignore then
			data[vi] = c_flowers[pr:next(1,6)]
		end
		
		--amgmt.debug("flowers spawned at:"..x..","..y..","..z)
	end
})

local c_ice = gci("default:ice")

--ice spikes
regtr({
	name = "ice_spike",
	chance = 25,
	minh = 4,
	maxh = 120,
	grows_on = "default:dirt_with_snow",
	grow = function(pos, data, area, seed, minp, maxp, pr)
		local x, y, z = pos.x, pos.y, pos.z
		local vi = area:index(x, y, z)
		if data[vi] == c_air or data[vi] == c_ignore then
			local h = pr:next(4,7)
			for u = -1, 1 do
			for i = -1, 1 do
			local vi = area:index(x+u, y-1, z+i)
			if data[vi] ~= c_air or data[vi] ~= c_ignore then
				for o = 0, h do
					local vi = area:index(x+u, y+o, z+i)
					data[vi] = c_ice
				end
			end
			end
			end
			local j = h + pr:next(2,3)
			for u = 0, 1 do
			for i = -1, 0 do
			local vi = area:index(x+u, y-1, z+i)
			if data[vi] ~= c_air or data[vi] ~= c_ignore then
				for o = h, j do
					local vi = area:index(x+u, y+o, z+i)
					data[vi] = c_ice
				end
			end
			end
			end
			local vi = area:index(x, y+j, z)
			data[vi] = c_ice
		end
		
		--amgmt.debug("ice spikes spawned at:"..x..","..y..","..z)
	end
})