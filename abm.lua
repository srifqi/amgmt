-- seaweed growing
minetest.register_abm({
	nodenames = {"amgmt:seaweed"},
	neighbors = {"group:sand"},
	interval = 50,
	chance = 20,
	action = function(pos, node)
		pos.y = pos.y-1
		local name = minetest.get_node(pos).name
		if minetest.get_item_group(name, "sand") ~= 0 then
			pos.y = pos.y+1
			local height = 0
			while minetest.get_node(pos).name == "amgmt:seaweed" and height < 4 do
				height = height+1
				pos.y = pos.y+1
			end
			if height < 4 then
				if minetest.get_node(pos).name == "default:water_source" then
					minetest.set_node(pos, {name="amgmt:seaweed"})
				end
			end
		end
	end,
})
