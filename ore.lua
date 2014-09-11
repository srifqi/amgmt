local aor = amgmt.ore.register
local aors = amgmt.ore.register_sheet

aor({
	ore				= "default:stone_with_coal",
	wherein			= "default:stone",
	clust_num		= 3,
	ore_per_clust	= 12,
	minh			= -31000,
	maxh			= 256,
})

aor({
	ore				= "default:stone_with_iron",
	wherein			= "default:stone",
	clust_num		= 3,
	ore_per_clust	= 2,
	minh			= 16,
	maxh			= 128,
})

aor({
	ore				= "default:stone_with_iron",
	wherein			= "default:stone",
	clust_num		= 3,
	ore_per_clust	= 4,
	minh			= -15,
	maxh			= 15,
})

aor({
	ore				= "default:stone_with_iron",
	wherein			= "default:stone",
	clust_num		= 3,
	ore_per_clust	= 6,
	minh			= -63,
	maxh			= -16,
})

aor({
	ore				= "default:stone_with_iron",
	wherein			= "default:stone",
	clust_num		= 5,
	ore_per_clust	= 10,
	minh			= -31000,
	maxh			= -64,
})

aor({
	ore				= "default:stone_with_mese",
	wherein			= "default:stone",
	clust_num		= 2,
	ore_per_clust	= 3,
	minh			= -31000,
	maxh			= -256,
})

aor({
	ore				= "default:mese",
	wherein			= "default:stone",
	clust_num		= 1,
	ore_per_clust	= 2,
	minh			= -31000,
	maxh			= -1024,
})

aor({
	ore				= "default:stone_with_gold",
	wherein			= "default:stone",
	clust_num		= 2,
	ore_per_clust	= 3,
	minh			= -255,
	maxh			= -64,
})

aor({
	ore				= "default:stone_with_gold",
	wherein			= "default:stone",
	clust_num		= 3,
	ore_per_clust	= 5,
	minh			= -31000,
	maxh			= -256,
})

aor({
	ore				= "default:stone_with_diamond",
	wherein			= "default:stone",
	clust_num		= 3,
	ore_per_clust	= 4,
	minh			= -255,
	maxh			= -128,
})

aor({
	ore				= "default:stone_with_diamond",
	wherein			= "default:stone",
	clust_num		= 3,
	ore_per_clust	= 6,
	minh			= -31000,
	maxh			= -256,
})

aor({
	ore				= "default:stone_with_copper",
	wherein			= "default:stone",
	clust_num		= 3,
	ore_per_clust	= 4,
	minh			= -63,
	maxh			= -16,
})

aor({
	ore				= "default:stone_with_copper",
	wherein			= "default:stone",
	clust_num		= 3,
	ore_per_clust	= 6,
	minh			= -31000,
	maxh			= -64,
})

aor({
	ore				= "default:dirt",
	wherein			= "default:stone",
	clust_num		= 3,
	ore_per_clust	= 12,
	minh			= -500,
	maxh			= 0,
})

aors({
	ore			= "default:clay",
	wherein		= "default:sand",
	clust_num	= 1,
	clust_size	= 10,
	vertical	= "no",
	minh		= -10,
	maxh		= 1,
})

aors({
	ore			= "default:gravel",
	wherein		= "default:stone",
	clust_num	= 1,
	clust_size	= 10,
	vertical	= "yes",
	minh		= -3100,
	maxh		= 16,
})

aors({
	ore			= "default:gravel",
	wherein		= "default:stone",
	clust_num	= 1,
	clust_size	= 3,
	vertical	= "maybe",
	minh		= -2500,
	maxh		= -1,
})

-- moreores mod
if minetest.get_modpath("moreores") then
	amgmt.debug("Mod detected: moreores, 5 ore(s) added!")
	aor({
		ore				= "moreores:mineral_silver",
		wherein			= "default:stone",
		clust_num		= 11,
		ore_per_clust	= 4,
		minh			= -31000,
		maxh			= -2
	})
	
	aor({
		ore				= "moreores:mineral_tin",
		wherein			= "default:stone",
		clust_num		= 7,
		ore_per_clust	= 3,
		minh			= -31000,
		maxh			= 8
	})
	
	aor({
		ore				= "moreores:mineral_copper",
		wherein			= "default:stone",
		clust_num		= 8,
		ore_per_clust	= 8,
		minh			= -31000,
		maxh			= 64
	})
	
	aor({
		ore				= "moreores:mineral_gold",
		wherein			= "default:stone",
		clust_num		= 14,
		ore_per_clust	= 4,
		minh			= -31000,
		maxh			= -64
	})
	
	aor({
		ore				= "moreores:mineral_mithril",
		wherein			= "default:stone",
		clust_num		= 11,
		ore_per_clust	= 1,
		minh			= -31000,
		maxh			= -512
	})
end