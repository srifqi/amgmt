minetest.register_node("amgmt:bedrock", {
	description = "amgmt's BEDROCK (How you get this?)",
	tiles ={"default_cobble.png"},
	groups = {unbreakable = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("amgmt:dirt_at_savanna", {
	description = "Dirt with Grass at Savanna",
	tiles = {"amgmt_savanna_grass.png", "default_dirt.png", "default_dirt.png^amgmt_savanna_grass_side.png"},
	is_ground_content = true,
	groups = {crumbly=3,soil=1},
	drop = 'default:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.25},
	}),
})

local tree_add = {
	{"savanna","Savanna"},
	{"pine","Pine"},
}

for i=1, #tree_add do
	minetest.register_node("amgmt:"..tree_add[i][1].."_tree", {
		description = tree_add[i][2].." Tree",
		tiles = {
			"default_tree_top.png",
			"default_tree_top.png",
			"default_tree.png",
		},
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
		sounds = default.node_sound_wood_defaults(),
		on_place = minetest.rotate_node
	})
	
	minetest.register_node("amgmt:"..tree_add[i][1].."_sapling", {
		description = tree_add[i][2].." Sapling",
		drawtype = "plantlike",
		visual_scale = 1.0,
		tiles = {"amgmt_"..tree_add[i][1].."_sapling.png"},
		inventory_image = "amgmt_"..tree_add[i][1].."_sapling.png",
		wield_image = "amgmt_"..tree_add[i][1].."_sapling.png",
		paramtype = "light",
		walkable = false,
		is_ground_content = true,
		selection_box = {
			type = "fixed",
			fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
		},
		groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
		sounds = default.node_sound_leaves_defaults(),
	})
	
	minetest.register_node("amgmt:"..tree_add[i][1].."_leaves", {
		description = tree_add[i][2].." Leaves",
		trunk = "amgmt:"..tree_add[i][1].."_tree",
		drawtype = "allfaces_optional",
		waving = 1,
		visual_scale = 1.3,
		tiles = {"amgmt_"..tree_add[i][1].."_leaves.png"},
		paramtype = "light",
		is_ground_content = false,
		groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
		drop = {
			max_items = 1,
			items = {
				{
					-- player will get sapling with 1/20 chance
					items = {'amgmt:'..tree_add[i][1]..'_sapling'},
					rarity = 20,
				},
				{
					-- player will get leaves only if he get no saplings,
					-- this is because max_items is 1
					items = {'amgmt:'..tree_add[i][1]..'_leaves'},
				}
			}
		},
		sounds = default.node_sound_leaves_defaults(),
	})
	
	minetest.register_abm({
		nodenames = {"amgmt:"..tree_add[i][1].."_sapling"},
		interval = 10,
		chance = 50,
		action = function(pos, node)
			local nu =  minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
			local is_soil = minetest.get_item_group(nu, "soil")
			if is_soil == 0 then
				return
			end
			
			minetest.log("action", "A "..tree_add[i][1].." sapling grows into a tree at "..minetest.pos_to_string(pos))
			local vm = minetest.get_voxel_manip()
			local minp, maxp = vm:read_from_map({x=pos.x-16, y=pos.y, z=pos.z-16}, {x=pos.x+16, y=pos.y+16, z=pos.z+16})
			local area = VoxelArea:new{MinEdge=minp, MaxEdge=maxp}
			local data = vm:get_data()
			amgmt.tree[tree_add[i][1].."_tree"](
				pos, data, area, (amgmt.seed or i), minp, maxp, PseudoRandom(os.clock())
			)
			vm:set_data(data)
			vm:write_to_map(data)
			vm:update_map()
		end
	})
end