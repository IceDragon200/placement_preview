local mod = assert(placement_preview)

minetest.register_node(mod:make_name("dev_node_stairs"), {
  description = "dev stairs[get orientation]",
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      { -0.5, -0.5, -0.5, 0.5, 0.0, 0.5 },
      { -0.5, -0.0, -0.0, 0.5, 0.5, 0.5 },
    }

  },
  -- tiles = { "default_cobble.png" },
  paramtype2 = "facedir",
  place_param2 = 0,
  groups = { crumbly = 3, oddly_breakable_by_hand = 3 },

  on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
    node.param2 = node.param2 + 1
    if node.param2 >= 24 then
      node.param2 = 0
    end
    minetest.swap_node(pos, node)
    minetest.debug(minetest.colorize("cyan", string.format("[%s: %s]", node.name, node.param2)))
  end,
})

minetest.register_node(mod:make_name("dev_node_stairs_inner"), {
  description = "dev stairs inner [get orientation]",
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      { -0.5, -0.5, -0.5, 0.5, 0.0, 0.5 },
      { -0.5, -0.0, -0.0, 0.0, 0.5, 0.5 },
    }

  },
  -- tiles = { "default_cobble.png" },
  paramtype2 = "facedir",
  place_param2 = 0,
  groups = { crumbly = 3, oddly_breakable_by_hand = 3 },

  on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
    node.param2 = node.param2 + 1
    if node.param2 >= 24 then
      node.param2 = 0
    end
    minetest.swap_node(pos, node)
    -- minetest.debug(minetest.colorize("cyan", string.format("[%s: %s]", node.name, node.param2)))
  end,
})

minetest.register_node(mod:make_name("dev_node_slab"), {
  description = "dev slab[get orientation]",
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      { -0.5, -0.5, -0.5, 0.5, 0.0, 0.5 },
    }

  },
  -- tiles = { "default_cobble.png" },
  paramtype2 = "facedir",
  place_param2 = 0,
  groups = { crumbly = 3, oddly_breakable_by_hand = 3 },

  on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
    node.param2 = node.param2 + 1
    if node.param2 >= 24 then
      node.param2 = 0
    end
    minetest.swap_node(pos, node)
    -- minetest.debug(minetest.colorize("cyan", string.format("[%s: %s]", node.name, node.param2)))
  end,
})
