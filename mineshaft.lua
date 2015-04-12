amgmt = amgmt or {}
amgmt.mineshaft = {}

local gci = minetest.get_content_id
local c_air = gci("air")
local c_glass = gci("default:glass")
local c_plank = gci("default:wood")
local c_torch = gci("default:torch")

local function make_room(x, z, data, area, minp, pr)
	local ox, oz = 0, 0
	if minp.x < 0 then ox = 1 end
	if minp.z < 0 then oz = 1 end
	x = minp.x + ox + (x-1)*3
	z = minp.z + oz + (z-1)*3
	
	-- start from top left back position
	for xx = x, x+2 do
	for zz = z, z+2 do
		data[area:index(xx,-25,zz)] = c_air
		data[area:index(xx,-26,zz)] = c_air
		data[area:index(xx,-27,zz)] = c_air
		if pr:next(1,5) <= 2 then
			data[area:index(xx,-28,zz)] = c_plank
		end
	end
	end
	
	data[area:index(x+1,-24,z+1)] = c_glass -- place a glass to make it handplaced-like
	data[area:index(x+1,-25,z+1)] = c_torch -- the default position is on ceiling, no need to rotate
end

function amgmt.mineshaft.generate(minp, maxp, data, area, seed, pr, noise)
	if
		minp.y <= -27 and maxp.y >= -25
		and (noise[1] < -1 or noise[1] > 1) -- pick most-northwest noise
	then
		amgmt.debug("mineshaft is being constructed...")
		
		local chulen = math.floor((maxp.x - minp.x +1) / 16)
		for x_ = 0, chulen do
		for z_ = 0, chulen do
		for y_ = 0, chulen do
			-- per chunk do
			local xx = minp.x + x_*16
			local yy = minp.y + y_*16
			local zz = minp.z + z_*16
			local minp = {x = xx, z = zz}
			
			-- base room
			make_room(3, 3, data, area, minp, pr)
			
			-- make it random :)
			for rr = 0, math.abs(xx/16 + yy/16 + zz/16) do local rrr = pr:next(0,1) end
			
			-- generate corridors in 4 direction: East South West North
			
			-- East
			if pr:next(1,3) < 2 then
				make_room(4, 3, data, area, minp, pr)
				local n = pr:next(1,6)
				if n < 4 then
					make_room(5, 3, data, area, minp, pr)
				elseif n < 5 then
					make_room(5, 3, data, area, minp, pr)
					if pr:next(1,6) < 2 then
						local n = pr:next(1,3)
						if n == 1 then --left
							make_room(5, 2, data, area, minp, pr)
							if pr:next(1,12) < 2 then
								make_room(5, 1, data, area, minp, pr)
							end
						elseif n == 2 then --right
							make_room(5, 4, data, area, minp, pr)
							if pr:next(1,12) < 2 then
								make_room(5, 5, data, area, minp, pr)
							end
						end
					end
				end
			end
			
			-- South
			if pr:next(1,3) < 2 then
				make_room(3, 4, data, area, minp, pr)
				local n = pr:next(1,6)
				if n < 4 then
					make_room(3, 5, data, area, minp, pr)
				elseif n < 5 then
					make_room(3, 5, data, area, minp, pr)
					if pr:next(1,6) < 2 then
						local n = pr:next(1,3)
						if n == 1 then --left
							make_room(4, 5, data, area, minp, pr)
							if pr:next(1,12) < 2 then
								make_room(5, 5, data, area, minp, pr)
							end
						elseif n == 2 then --right
							make_room(2, 5, data, area, minp, pr)
							if pr:next(1,12) < 2 then
								make_room(1, 5, data, area, minp, pr)
							end
						end
					end
				end
			end
			
			-- West
			if pr:next(1,3) < 2 then
				make_room(2, 3, data, area, minp, pr)
				local n = pr:next(1,6)
				if n < 4 then
					make_room(1, 3, data, area, minp, pr)
				elseif n < 5 then
					make_room(1, 3, data, area, minp, pr)
					if pr:next(1,6) < 2 then
						local n = pr:next(1,3)
						if n == 1 then --left
							make_room(1, 4, data, area, minp, pr)
							if pr:next(1,12) < 2 then
								make_room(1, 5, data, area, minp, pr)
							end
						elseif n == 2 then --right
							make_room(1, 2, data, area, minp, pr)
							if pr:next(1,12) < 2 then
								make_room(1, 1, data, area, minp, pr)
							end
						end
					end
				end
			end
			
			-- North
			if pr:next(1,3) < 2 then
				make_room(3, 2, data, area, minp, pr)
				local n = pr:next(1,6)
				if n < 4 then
					make_room(3, 1, data, area, minp, pr)
				elseif n < 5 then
					make_room(3, 1, data, area, minp, pr)
					if pr:next(1,6) < 2 then
						local n = pr:next(1,3)
						if n == 1 then --left
							make_room(2, 1, data, area, minp, pr)
							if pr:next(1,12) < 2 then
								make_room(1, 1, data, area, minp, pr)
							end
						elseif n == 2 then --right
							make_room(4, 1, data, area, minp, pr)
							if pr:next(1,12) < 2 then
								make_room(5, 1, data, area, minp, pr)
							end
						end
					end
				end
			end
		end
		end
		end
	end
end
