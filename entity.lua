local mod = assert(placement_preview)

local glow_amount = 4

mod.ghost_object_name = mod:make_name("ghost_object")

minetest.register_entity(mod.ghost_object_name, {
  initial_properties = {
    visual = "item",
    wield_item = "default:cobble",
    visual_size = { x = 0.6, y = 0.6, z = 0.6 },
    collisionbox = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 }, -- default
    glow = glow_amount,
    static_save = false,
    physical = false,
    pointable = false,
    shaded = true,
    backface_culling = false,
    use_texture_alpha = true,
  },
})
