amgmt = amgmt or {}
amgmt.ore = amgmt.ore or {}

amgmt.ore.registered = {}
amgmt.ore.registered_sheet = {}

local seeddiff_count = 2

function amgmt.ore.register(def)
	-- registering ore per 16x16x16 block size
	amgmt.ore.registered[#amgmt.ore.registered+1] = {
		ore = def.ore,
		wherein = def.wherein or "default:stone",
		seeddiff = def.seeddiff or seeddiff_count,
		clust_num = def.clust_num or 1,
		ore_per_clust = def.ore_per_clust or 5,
		minh = def.minh or HMIN,
		maxh = def.maxh or MAXH
	}
	seeddiff_count = seeddiff_count +1
end

function amgmt.ore.register_sheet(def)
	-- registering ore sheet per 16x16x16 block size
	amgmt.ore.registered_sheet[#amgmt.ore.registered_sheet+1] = {
		ore = def.ore,
		wherein = def.wherein or "default:stone",
		seeddiff = def.seeddiff or seeddiff_count,
		clust_num = def.clust_num or 1,
		clust_size = def.clust_size or 5,
		vertical = def.vertical or "maybe",
		minh = def.minh or HMIN,
		maxh = def.maxh or MAXH
	}
	seeddiff_count = seeddiff_count +1
end


--[[
minetest.register_ore({
    ore_type       = "scatter",
    ore            = "default:stone_with_coal",
    wherein        = "default:stone",
    clust_scarcity = 8*8*8,
    clust_num_ores = 8,
    clust_size     = 3,
    height_min     = -31000,
    height_max     = 64,
})
--]]
--[[
function minetest.register_ore(def)
	amgmt.debug(def.ore.." added")
	if def.ore_type == "scatter" then
		def.wherein = def.wherein or "default:stone"
		
		local multiplier = 16*16*16 / clust_scarcity
		def.clust_num = def.clust_size * multiplier
		
		def.minh = def.height_min
		def.maxh = def.height_max
		
		amgmt.ore.register_ore(def)
	end
end
--]]

local function get_nearest_cube(n)
	for i=1, 16 do if i*i*i>=n then return i end end
	return 0
end

local function get_nearest_square(n)
	for i=1, 16 do if i*i>=n then return i end end
	return 0
end

local gci = minetest.get_content_id

function amgmt.ore.generate(minp, maxp, data, area, seed)
	local chulen = math.floor((maxp.x - minp.x +1) / 16)
	local ore = amgmt.ore.registered
	local ore_sheet = amgmt.ore.registered_sheet
	for x_ = 0, chulen do
	for z_ = 0, chulen do
	for y_ = 0, chulen do
		-- per chunk do
		local xx = minp.x + x_*16
		local yy = minp.y + y_*16
		local zz = minp.z + z_*16
		-- generate ore
		for ii = 1, #ore do
			local oi = ore[ii]
			if maxp.y >= oi.minh and minp.y <= oi.maxh then
				local pr = PseudoRandom(seed + oi.seeddiff)
				-- make it more random first
				for rr = 0, math.abs(xx/16 + yy/16 + zz/16) do local rrr = pr:next(0,1) end
				for oo = 1, oi.clust_num do
					local xx_ = xx + pr:next(0,16)
					local yy_ = yy + pr:next(0,16)
					local zz_ = zz + pr:next(0,16)
					local cubelen = get_nearest_cube(oi.ore_per_clust)
					local cubemin = math.ceil(cubelen/2) * -1
					local cubemax = math.floor(cubelen/2)
					for uu = 1, oi.ore_per_clust do
						local yyy = yy_ + pr:next(cubemin,cubemax)
						if yyy >= oi.minh and yyy <= oi.maxh then
							local xxx = xx_ + pr:next(cubemin,cubemax)
							local zzz = zz_ + pr:next(cubemin,cubemax)
							local vi = area:index(xxx,yyy,zzz)
							if data[vi] == gci(oi.wherein) then
								--amgmt.debug(oi.ore.." generated at:"..xxx..","..yyy..","..zzz)
								data[vi] = gci(oi.ore)
							end
						end
					end
				end
			end
		end
		-- generate ore sheet
		for ii = 1, #ore_sheet do
			local oi = ore_sheet[ii]
			local pr = PseudoRandom(seed + oi.seeddiff)
			for oo = 1, oi.clust_num do
				local xx_ = xx + pr:next(0,16)
				local yy_ = yy + pr:next(0,16)
				local zz_ = zz + pr:next(0,16)
				local vertical = nil
				if oi.vertical == "maybe" then
					vertical = pr:next(1,10) < 5
				elseif oi.vertical == "yes" then
					vertical = true
				elseif oi.vertical == "no" then
					vertical = false
				end
				local sqlen = get_nearest_square(oi.clust_size)
				local sqmin = math.ceil(sqlen/2) * -1
				local sqmax = math.floor(sqlen/2)
				local heading = pr:next(2,3)
				for uu = sqmin, sqmax do
				for pp = sqmin, sqmax do
					local xxx = nil
					local yyy = nil
					local zzz = nil
					if heading == 2 and vertical == true then -- x
						xxx = xx_ + uu
						yyy = yy_ + pp
						zzz = zz_
					elseif heading == 3 and vertical == true then -- z
						xxx = xx_
						yyy = yy_ + uu
						zzz = zz_ + pp
					elseif vertical == false then
						xxx = xx_ + uu
						yyy = yy_
						zzz = zz_ + pp
					end
					
					local vi = area:index(xxx,yyy,zzz)
					if
						yyy >= oi.minh and yyy <= oi.maxh and
						data[vi] == gci(oi.wherein)
					then
						--amgmt.debug(oi.ore.." generated at:"..xxx..","..yyy..","..zzz)
						data[vi] = gci(oi.ore)
					end
				end
				end
			end
		end
	end
	end
	end
end

dofile(minetest.get_modpath(minetest.get_current_modname()).."/ore.lua")