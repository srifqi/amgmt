biome = biome or {}
local gci = minetest.get_content_id
local badd = biome.add

-- node id?
local c_air = gci("air")
local c_water = gci("default:water_source")
local c_ice = gci("default:ice")
local c_stone = gci("default:stone")
local c_dirt = gci("default:dirt")
local c_dirt_grass = gci("default:dirt_with_grass")
local c_dirt_snow = gci("default:dirt_with_snow")
local c_sand = gci("default:sand")
local c_sandstone = gci("default:sandstone")

local c_dirt_savanna = gci("amgmt:dirt_at_savanna")

--listing biome from cold to hot
-- cold
badd({
	name = "Ice Plains",
	mint = 0,
	maxt = 0.2,
	minh = 0,
	maxh = 50,
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
		elseif y < base and y > base - 3 then
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
	name = "Ice Plains Spikes",
	mint = 0,
	maxt = 0.2,
	minh = 50,
	maxh = 100,
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
		elseif y < base and y > base - 3 then
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
	mint = 0.2,
	maxt = 0.4,
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
		elseif y < base and y > base - 3 then
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
	name = "Stone Plain",
	mint = 0.4,
	maxt = 0.5,
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
	mint = 0.5,
	maxt = 0.7,
	trees = {{"grass14",30}},
	get_block = function(temp, humi, base_, wl, y)
		local base = base_ + math.ceil(math.abs(base_ - wl) * 2/5)
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
		elseif y < base and y > base - 3 then
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
	maxt = 0.9,
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
		elseif y < base and y > base - 3 then
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
	name = "Plains",
	mint = 0.9,
	maxt = 1.15,
	minh = 0,
	maxh = 50,
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
		elseif y < base and y > base - 3 then
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
	name = "Flower Plains",
	mint = 0.9,
	maxt = 1.15,
	minh = 50,
	maxh = 100,
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
		elseif y < base and y > base - 3 then
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
	name = "River",
	mint = 1.15,
	maxt = 1.25,
	get_block = function(temp, humi, base_, wl, y)
		local base = wl - math.ceil(math.abs(base_ - wl) * 1/3) - 1
		if y > base and y > wl then
			return c_air
		elseif y > base and y <= wl then
			return c_water
		elseif y < base - 2 then
			return c_stone
		elseif y < base and y > base - 3 then
			return c_sandstone
		else
			return c_sand
		end
	end
})
badd({
	name = "Forest",
	mint = 1.25,
	maxt = 1.5,
	trees = {{"normal",15},{"grass14",60},{"grass35",5},{"papyrus",15},{"flowers",15}},
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
		elseif y < base and y > base - 3 then
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
-- dry
badd({
	name = "Savanna",
	mint = 1.5,
	maxt = 1.75,
	trees = {{"savanna",225},{"grass35",5}},
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
		elseif y < base and y > base - 3 then
			return c_dirt
		else
			if y < wl then
				return c_dirt
			else
				if temp > 1.7 and base == wl then
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
	name = "Desert",
	mint = 1.75,
	maxt = 2,
	trees = {{"cactus",50},{"dry_shrub",50}},
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
		elseif y < base and y > base - 3 then
			return c_sand
		else
			return c_sand
		end
	end
})