local mod = assert(placement_preview)
local string_ascii_icontains = assert(foundation.com.string_ascii_icontains)

local function on_placenode(pos, newnode, placer, oldnode, itemstack, pointed_thing)
  local p_data = mod.PlayerService:get_player(placer:get_player_name())

  p_data.grow = true

  -- newnode.param2 = minetest.dir_to_facedir(p_data.rotation, true)
  -- minetest.swap_node(pos, newnode)
  -- goto all_done

  if p_data.only_stairs_slabs == true then
    if string_ascii_icontains(newnode.name, "stair") or string_ascii_icontains(newnode.name, "slab") then
      --
    else
      return
    end
  end

  if p_data.node_paramtype2 == nil or
     p_data.node_paramtype2 == "wallmounted" or
     p_data.node_paramtype2 == "none" then
    return
  end
  -- if string_ascii_icontains(newnode.name, "door") ~= nil then
  --  return
  -- end

  if p_data.node_paramtype2 == "facedir" then
    -- if string_ascii_icontains(newnode.name, "STAIR") ~= nil or string_ascii_icontains(newnode.name, "STAIRS") ~= nil then
    local face = 0

    local amount = 90

    local vert_slab = false

    if string_ascii_icontains(newnode.name, "stair") ~= nil then
      --support for inner and outer stairs
      if string_ascii_icontains(newnode.name, "inner") ~= nil or string_ascii_icontains(newnode.name, "outer") ~= nil then
        local rot = p_data.rotation
        -- minetest.debug(string.format("rotation: %s,%s,%s", math.deg(rot.x), math.deg(rot.y), math.deg(rot.z)))
        if math.deg(p_data.rotation.y) == 360 then
          if math.deg(p_data.rotation.x) == 0 then
            face = 0
          else
            face = 22
          end
        end
        if math.deg(p_data.rotation.y) == 270 then
          if math.deg(p_data.rotation.x) == 0 then
            face = 1
          else
            face = 21
          end
        end
        if math.deg(p_data.rotation.y) == 540 then
          if math.deg(p_data.rotation.x) == 0 then
            face = 2
          else
            face = 20
          end
        end
        if math.deg(p_data.rotation.y) == 450 then
          if math.deg(p_data.rotation.x) == 0 then
            face = 3
          else
            face = 23
          end
        end
        if math.deg(p_data.rotation.y) == 90 then
          if math.deg(p_data.rotation.x) == 0 then
            face = 3
          else
            face = 20
          end
        end
        if math.deg(p_data.rotation.y) == 180 then
          if math.deg(p_data.rotation.x) == 0 then
            face = 2
          else
            face = 20
          end
        end
        goto done
      end
    end



    if math.deg(p_data.rotation.y) == 0 then
      face = 0
    end
    if math.deg(p_data.rotation.y) == 270 then
      face = 1
    end
    if math.deg(p_data.rotation.y) == 180 then
      face = 2
    end
    if math.deg(p_data.rotation.y) == 90 then
      face = 3
    end


    if placer:get_player_control()["sneak"] == true then
      --if sneaking leave at previous amount.. we are making walls
      if string_ascii_icontains(newnode.name, "SLAB") ~= nil then
        vert_slab = true
      else
        -- if string_ascii_icontains(newnode.name, "STAIR") ~= nil or string_ascii_icontains(newnode.name, "STAIRS") ~= nil then
        if math.deg(p_data.rotation.y) == 270 and math.deg(p_data.rotation.z) == 270 then
          face = 5
          goto done
        end
        if math.deg(p_data.rotation.y) == 270 and math.deg(p_data.rotation.z) == 90 then
          face = 9
          goto done
        end
        if math.deg(p_data.rotation.y) == 90 and math.deg(p_data.rotation.z) == 90 then
          face = 7
          goto done
        end
        if math.deg(p_data.rotation.y) == 90 and math.deg(p_data.rotation.z) == 270 then
          face = 12
          goto done
        end
        if math.deg(p_data.rotation.y) == 0 and math.deg(p_data.rotation.z) == 90 then
          face = 12
          goto done
        end
        if math.deg(p_data.rotation.y) == 0 and math.deg(p_data.rotation.z) == 270 then
          face = 9
          goto done
        end
        if math.deg(p_data.rotation.y) == 180 and math.deg(p_data.rotation.z) == 90 then
          face = 18
          goto done
        end
        if math.deg(p_data.rotation.y) == 180 and math.deg(p_data.rotation.z) == 270 then
          face = 7
          goto done
        end
      end
    end

    if vert_slab == false then
      if string_ascii_icontains(newnode.name, "SLAB") ~= nil then
        amount = 180
      end
    end

    if math.deg(p_data.rotation.x) == amount and math.deg(p_data.rotation.y) == 0 then
      if vert_slab == true then
        face = 8
      elseif string_ascii_icontains(newnode.name, "SLAB") ~= nil then
        face = 20
      else
        face = 8
      end
      goto done
    end
    if math.deg(p_data.rotation.x) == amount and math.deg(p_data.rotation.y) == 90 then
      if vert_slab == true then
        face = 15
      elseif string_ascii_icontains(newnode.name, "SLAB") ~= nil then
        face = 21
      else
        face = 15
      end
      goto done
    end
    if math.deg(p_data.rotation.x) == amount and math.deg(p_data.rotation.y) == 180 then
      if vert_slab == true then
        face = 6
      elseif string_ascii_icontains(newnode.name, "SLAB") ~= nil then
        face = 22
      else
        face = 6
      end
      goto done
    end
    if math.deg(p_data.rotation.x) == amount and math.deg(p_data.rotation.y) == 270 then
      if vert_slab == true then
        face = 17
      elseif string_ascii_icontains(newnode.name, "SLAB") ~= nil then
        face = 23
      else
        face = 17
      end
    end
    if math.deg(p_data.rotation.x) == -90 then
      face = 4
      goto done
    end

    ::done::
    newnode.param2 = face
    minetest.swap_node(pos, newnode)
  else
    return
  end
  ::all_done::
end

minetest.register_on_placenode(on_placenode)

local tick = 0.0
local TICK_RATE = 1 / 30

local function on_step(dtime)
  tick = tick + dtime
  mod.PlayerService:perform_raycast(dtime)
  if tick >= TICK_RATE then
    mod.PlayerService:update(dtime)
    tick = tick - TICK_RATE
  end
end

if nokore_proxy then
  nokore_proxy.register_globalstep("placement_preview:on_step", on_step)
else
  minetest.register_globalstep(on_step)
end

minetest.register_on_leaveplayer(function(obj, timed_out)
  --remove the object when the player leaves
  mod.PlayerService:remove_player(obj:get_player_name())
end)

core.register_on_punchnode(function(pos, node, puncher, pointed_thing)
  core.log("what is this"..dump(node))
end)
