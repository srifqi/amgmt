amgmt = amgmt or {}
amgmt.biome = amgmt.biome or {}
local gci = minetest.get_content_id
local badd = amgmt.biome.add
local wl = amgmt.wl

-- node id?
local c_air = gci("air")
local c_water = gci("default:water_source")
local c_ice = gci("default:ice")
local c_stone = gci("default:stone")
local c_gravel = gci("default:gravel")
local c_dirt = gci("default:dirt")
local c_dirt_grass = gci("default:dirt_with_grass")
local c_dirt_snow = gci("default:dirt_with_snow")
local c_dirt_savanna = gci("amgmt:dirt_at_savanna")
local c_sand = gci("default:sand")
local c_sandstone = gci("default:sandstone")
local c_clay = gci("default:clay")

local c_bakedclayred = gci("amgmt:bakedclay_red")
local c_bakedclayorange = gci("amgmt:bakedclay_orange")
local c_bakedclayblue = gci("amgmt:bakedclay_blue")
local c_bakedclaycyan = gci("amgmt:bakedclay_cyan")
-- bakedclay mod by TenPlus1 WTFPL
if minetest.get_modpath("bakedclay") then
	local c_bakedclayred = gci("bakedclay:red")
	local c_bakedclayorange = gci("bakedclay:orange")
	local c_bakedclayblue = gci("bakedclay:blue")
	local c_bakedclaycyan = gci("bakedclay:cyan")
end

--generated structures
badd({
	name = "Frozen River",
	mint = 0,
	maxt = 0.2,
	minh = 47.5,
	maxh = 52.5,
	get_block = function(temp, humi, base, wl, y)
		--local base = wl - math.ceil(math.abs(base_ - wl) * 1/3) - 1
		if y > base and y > wl then
			return c_air
		elseif y > base and y < wl then
			return c_water
		elseif y > base and y == wl then
			return c_ice
		elseif y < base - 2 then
			return c_stone
		elseif y < base and y >= base - 3 then
			return c_sandstone
		else
			return c_sand
		end
	end
})
badd({
	name = "River",
	mint = 0.2,
	maxt = 2.0,
	minh = 47.5,
	maxh = 52.5,
	get_block = function(temp, humi, base, wl, y)
		--local base = wl - math.ceil(math.abs(base_ - wl) * 1/3) - 1
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			return c_water
		elseif y < base - 2 then
			return c_stone
		elseif y < base and y >= base - 3 then
			return c_sandstone
		else
			return c_sand
		end
	end
})

--listing biome from cold to hot

-- cold
badd({
	name = "Ice Plains",
	mint = 0,
	maxt = 0.2,
	minh = 30,
	maxh = 50,
	spawn_here = true,
	trees = {{"pine",225}},
	get_block = function(temp, humi, base, wl, y)
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl - 1 then
				return c_water
			elseif base < wl then
				return c_ice
			elseif base >= wl then
				return c_air
			end
		elseif y < base - 2 then
			return c_stone
		elseif y < base and y >= base - 3 then
			return c_dirt
		else
			if y < wl then
				return c_dirt
			else
				return c_dirt_snow
			end
		end
	end
})
badd({
	name = "Cold Mesa",
	mint = 0,
	maxt = 0.2,
	minh = 0,
	maxh = 30,
	spawn_here = true,
	trees = {},
	get_block = function(temp, humi, base, wl, y)
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl then
				return c_water
			elseif base >= wl then
				return c_air
			end
		elseif y <= base then
			if math.floor(y / 4) * 4 == y then
				return c_bakedclaycyan
			else
				return c_bakedclayblue
			end
		else
			return c_stone
		end
	end
})
badd({
	name = "Ice Plains Spikes",
	mint = 0,
	maxt = 0.2,
	minh = 50,
	maxh = 70,
	spawn_here = true,
	trees = {{"ice_spike",25}},
	get_block = function(temp, humi, base, wl, y)
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl - 1 then
				return c_water
			elseif base < wl then
				return c_ice
			elseif base >= wl then
				return c_air
			end
		elseif y < base - 2 then
			return c_stone
		elseif y < base and y >= base - 3 then
			return c_dirt
		else
			if y < wl then
				return c_dirt
			else
				return c_dirt_snow
			end
		end
	end
})
badd({
	name = "Cold Taiga",
	mint = 0,
	maxt = 0.2,
	minh = 70,
	maxh = 100,
	spawn_here = true,
	trees = {{"pine_cold",25}},
	get_block = function(temp, humi, base, wl, y)
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl - 1 then
				return c_water
			elseif base < wl then
				return c_ice
			elseif base >= wl then
				return c_air
			end
		elseif y < base - 2 then
			return c_stone
		elseif y < base and y >= base - 3 then
			return c_dirt
		else
			if y < wl then
				return c_dirt
			else
				return c_dirt_snow
			end
		end
	end
})
badd({
	name = "Gravel Plain",
	mint = 0.2,
	maxt = 0.4,
	minh = 40,
	maxh = 60,
	spawn_here = true,
	get_block = function(temp, humi, base, wl, y)
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl then
				return c_water
			elseif base >= wl then
				return c_air
			end
		elseif y <= base and y>-175 then
			if
				(base -y)%12 == 1
				or (base -y)%12 == 4
				or (base -y)%12 == 8
				or (base -y)%12 == 11
			then
				return c_stone
			else
				return c_gravel
			end
		else
			return c_stone
		end
	end
})
badd({
	name = "Stone Plain",
	mint = 0.2,
	maxt = 0.4,
	spawn_here = true,
	get_block = function(temp, humi, base, wl, y)
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl then
				return c_water
			elseif base >= wl then
				return c_air
			end
		elseif y <= base then
			return c_stone
		end
	end
})
badd({
	name = "Extreme Hills",
	mint = 0.4,
	maxt = 0.7,
	trees = {{"grass_extreme",30}},
	get_block = function(temp, humi, base_, wl, y)
		local base = base_ + math.ceil(math.abs(base_ - wl) * 1/5)
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl then
				return c_water
			elseif base >= wl then
				return c_air
			end
		elseif y < base - 2 then
			return c_stone
		elseif y < base and y >= base - 3 then
			return c_dirt
		else
			if y < wl then
				return c_dirt
			elseif y >= 95 then
				return c_dirt_snow
			else
				return c_dirt_grass
			end
		end
	end
})
badd({
	name = "Taiga",
	mint = 0.7,
	maxt = 1.0,
	spawn_here = true,
	trees = {{"pine_taiga",25}},
	get_block = function(temp, humi, base, wl, y)
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl then
				return c_water
			elseif base >= wl then
				return c_air
			end
		elseif y < base - 2 then
			return c_stone
		elseif y < base and y >= base - 3 then
			return c_dirt
		else
			if y < wl then
				return c_dirt
			else
				return c_dirt_grass
			end
		end
	end
})
-- medium/lush
badd({
	name = "Flower Plains",
	mint = 1.0,
	maxt = 1.2,
	minh = 40,
	maxh = 60,
	spawn_here = true,
	trees = {{"flowers",5},{"flowers",5},{"flowers",5}},
	get_block = function(temp, humi, base, wl, y)
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl then
				return c_water
			elseif base >= wl then
				return c_air
			end
		elseif y < base - 2 then
			return c_stone
		elseif y < base and y >= base - 3 then
			return c_dirt
		else
			if y < wl then
				return c_dirt
			else
				return c_dirt_grass
			end
		end
	end
})
badd({
	name = "Plains",
	mint = 1.0,
	maxt = 1.2,
	minh = 0,
	maxh = 100,
	spawn_here = true,
	trees = {{"grass14",30}, {"grass35",5},{"papyrus",15},{"flowers",15}},
	get_block = function(temp, humi, base, wl, y)
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl then
				return c_water
			elseif base >= wl then
				return c_air
			end
		elseif y < base - 2 then
			return c_stone
		elseif y < base and y >= base - 3 then
			return c_dirt
		else
			if y < wl then
				return c_dirt
			else
				if temp > 1 and (base == wl or base == wl+1) then
					return c_sand
				else
					return c_dirt_grass
				end
			end
		end
	end
})
badd({
	name = "Swampland",
	mint = 1.2,
	maxt = 1.4,
	minh = 35,
	maxh = 65,
	trees = {{"normal",27},{"grass14",16},{"seaweed",256}},
	get_block = function(temp, humi, base_, wl, y)
		local base = base_
		if base_ < 5 and base_ > -1 then base = base % 2 - 1 end
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl then
				return c_water
			elseif base >= wl then
				return c_air
			end
		elseif y < base - 2 then
			return c_stone
		elseif y < base and y >= base - 3 then
			return c_dirt
		else
			if y < wl then
				return c_dirt
			else
				if (temp > 1.6 and base == wl) or (base < wl-15) then
					return c_sand
				else
					return c_dirt_grass
				end
			end
		end
	end
})
badd({
	name = "Forest",
	mint = 1.2,
	maxt = 1.4,
	minh = 0,
	maxh = 100,
	spawn_here = true,
	trees = {{"normal",19},{"grass14",60},{"grass35",5},{"papyrus",16},{"flowers",18},{"seaweed",128}},
	get_block = function(temp, humi, base, wl, y)
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl then
				return c_water
			elseif base >= wl then
				return c_air
			end
		elseif y < base - 2 then
			return c_stone
		elseif y < base and y >= base - 3 then
			return c_dirt
		else
			if y < wl then
				if base < wl-15 then
					return c_sand
				else
					return c_dirt
				end
			else
				return c_dirt_grass
			end
		end
	end
})
badd({
	name = "Jungle",
	mint = 1.4,
	maxt = 1.6,
	minh = 0,
	maxh = 100,
	spawn_here = true,
	trees = {{"jungle",16},{"jungle_grass",5},{"papyrus",20},{"flowers",20},{"seaweed",256}},
	get_block = function(temp, humi, base, wl, y)
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl then
				return c_water
			elseif base >= wl then
				return c_air
			end
		elseif y < base - 2 then
			return c_stone
		elseif y < base and y >= base - 3 then
			return c_dirt
		else
			if y < wl then
				if base < wl-15 then
					return c_sand
				else
					return c_dirt
				end
			else
				return c_dirt_grass
			end
		end
	end
})
-- dry
badd({
	name = "Savanna",
	mint = 1.6,
	maxt = 1.8,
	spawn_here = true,
	trees = {{"savanna",225},{"grass35",4}},
	get_block = function(temp, humi, base, wl, y)
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl then
				return c_water
			elseif base >= wl then
				return c_air
			end
		elseif y < base - 2 then
			return c_stone
		elseif y < base and y >= base - 3 then
			return c_dirt
		else
			if y < wl then
				return c_dirt
			else
				if temp > 1.6 and base == wl then
					return c_sand
				else
					return c_dirt_savanna
				end
			end
		end
	end
})
-- hot
badd({
	name = "Mesa",
	mint = 1.8,
	maxt = 2,
	minh = 10,
	maxh = 50,
	spawn_here = true,
	get_block = function(temp, humi, base, wl, y)
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl then
				return c_water
			elseif base >= wl then
				return c_air
			end
		elseif y < base then
			if math.floor(y / 4) * 4 == y then
				return c_bakedclayorange
			else
				return c_bakedclayred
			end
		elseif y == base then
			if math.floor((y + 2) / 4) * 4 == (y + 2) then
				return c_clay
			elseif math.floor(y / 4) * 4 == y then
				return c_bakedclayorange
			else
				return c_bakedclayred
			end
		else
			return c_stone
		end
	end
})
badd({
	name = "Desert",
	mint = 1.8,
	maxt = 2,
	spawn_here = true,
	trees = {{"cactus",50},{"dry_shrub",50},{"seaweed",256}},
	get_block = function(temp, humi, base, wl, y)
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			if base < wl then
				return c_water
			elseif base >= wl then
				return c_air
			end
		elseif y < base - 2 then
			return c_sandstone
		elseif y < base and y >= base - 3 then
			return c_sand
		else
			return c_sand
		end
	end
})
