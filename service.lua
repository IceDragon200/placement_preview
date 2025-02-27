local mod = assert(placement_preview)

local string_ascii_icontains = assert(foundation.com.string_ascii_icontains)

--(not great on servers)smooth preview movement, otherwise snaps. players default to the this setting but can individually set it.
local g_smooth = false
local g_only_stairs_slabs = false --only wanna preview nodes with special placement

mod.PlayerService = {
  data = {},
}

function mod.PlayerService:add_player(name)
  assert(type(name) == "string", "expected a player name")

  local entry = {
    player_name = name,
    ghost_object = nil,
    ghost_object_params = {
      delta = 1,
    },
    rotation = { x = 0, y = 0, z = 0 },
    disabled = false,
    node_paramtype2 = nil,
    double_slab = nil,
    smooth = g_smooth,
    only_stairs_slabs = g_only_stairs_slabs,
    grow = false,
    remove_preview = function (obj)
      if obj.ghost_object ~= nil then
        obj.ghost_object:remove()
        obj.ghost_object = nil
      end
    end,
  }
  self.data[name] = entry
  return entry
end

function mod.PlayerService:remove_player(name)
  self.data[name] = nil
end

---@alias data table

---@return data
function mod.PlayerService:get_player(name)
  return self.data[name] or self:add_player(name)
end

function mod.PlayerService:update(dt)
  for _player_name, p in pairs(self.data) do
    if p.ghost_object ~= nil then
      if p.grow == true then
        local size = { x = 0.1, y = 0.1, z = 0.1 }
        p.ghost_object:set_properties({ visual_size = size })
        p.grow = false
      end

      local size = p.ghost_object:get_properties().visual_size
      local amount = 0

      if p.ghost_object_params.delta > 0 then
        if size.x < 0.5 then
          amount = 0.5
        elseif size.x < 0.6 then
          amount = 0.008
        else
          p.ghost_object_params.delta = -1
        end
      else
        if size.x < 0.58 then
          p.ghost_object_params.delta = 1
        else
          amount = -0.008
        end
      end

      p.ghost_object_params.t = t

      local new_size = {
        x = size.x + amount * dt,
        y = size.y + amount * dt,
        z = size.z + amount * dt
      }

      p.ghost_object:set_properties({ visual_size = new_size })
    end
  end
end

---@type number
local reach_distance = 3.0          --this should actaully just be the player's reach distance

-- Function to perform raycast and handle the result
function mod.PlayerService:perform_raycast(dt)
  local players = minetest.get_connected_players()
  if #players > 0 then
    for _, p in pairs(players) do
      local p_name = p:get_player_name()
      local p_data = self:get_player(p_name)

      --check if player has feature disabled
      if p_data.disabled == true then
        p_data:remove_preview()
        goto continue
      end

      local hand_item = p:get_wielded_item()
      local item_name = hand_item:get_name()

      local this_node = minetest.registered_nodes[hand_item:get_name()]

      if hand_item:is_empty() == true then
        p_data:remove_preview()
      else
        if this_node ~= nil then
          p_data.node_paramtype2 = this_node.paramtype2
        end
        if this_node == nil then
          p_data:remove_preview()
          goto continue
        end
      end

      if hand_item:is_empty() == true then
        goto continue
      end

      if p_data.only_stairs_slabs == true then
        if string_ascii_icontains(this_node.description, "stairs") ~= nil or
           string_ascii_icontains(this_node.name, "stairs") ~= nil then
        else
          p_data:remove_preview()
          goto continue
        end
      end

      local eye_height = p:get_properties().eye_height
      local player_look_dir = p:get_look_dir()
      local pos = p:get_pos():add(player_look_dir)
      local player_pos = { x = pos.x, y = pos.y + eye_height, z = pos.z }
      local player_reach_distance = reach_distance
      if core.get_modpath("mcl_gamemode") and mcl_gamemode then
        local player_gamemode = mcl_gamemode.get_gamemode(p)
        -- core.log("gamemode: "..player_gamemode)
        if core.get_modpath("mcl_meshhand") and mcl_meshhand then
          if player_gamemode == "creative" then
            player_reach_distance = tonumber(minetest.settings:get("mcl_hand_range_creative")) or 9.5
          else
            player_reach_distance = tonumber(minetest.settings:get("mcl_hand_range")) or 3.5
          end

        end
      end
      local new_pos = p:get_look_dir():multiply(player_reach_distance):add(player_pos)
      local raycast_result = minetest.raycast(player_pos, new_pos, false, false):next()

      if raycast_result then
        local hit_pos = raycast_result.above
        local under = raycast_result.under
        local point = raycast_result.intersection_point
        -- local pointed_node = minetest.registered_nodes[minetest.get_node(under).name]
        local pointed_node = minetest.get_node(under)
        -- local pointed_face = raycast_result.intersection_normal
        if hit_pos ~= nil then
          if p_data.ghost_object == nil then
            p_data.ghost_object = minetest.add_entity(hit_pos, mod.ghost_object_name)
          end
          p_data.ghost_object:set_properties({ visual = "item" })


          local new_rot = { x = 0, y = 0, z = 0 }

          -- PREVIEW TWO SLABS INTO ONE
          if string_ascii_icontains(item_name, "SLAB") ~= nil then
            if string_ascii_icontains(pointed_node.name, item_name) ~= nil then
              p_data.double_slab = under

              local param2 = pointed_node.param2

              --VERTICAL
              if mod.calc_distance(point.x, point.y, point.z, under.x, under.y, under.z) < 0.3 then
                if p:get_player_control()["sneak"] == true then
                  goto skip_this
                end
                if param2 == 8 then
                  new_rot = { x = math.rad(90), y = math.rad(180), z = new_rot.z }
                  hit_pos = under
                  goto override
                end
                if param2 == 17 then
                  new_rot = { x = math.rad(90), y = math.rad(90), z = new_rot.z }
                  hit_pos = under
                  goto override
                end
                if param2 == 6 then
                  new_rot = { x = math.rad(90), y = math.rad(360), z = new_rot.z }
                  hit_pos = under
                  goto override
                end
                if param2 == 15 then
                  new_rot = { x = math.rad(90), y = math.rad(270), z = new_rot.z }
                  hit_pos = under
                end
              end

              if hit_pos.x == under.x then
                if hit_pos.z == under.z then
                  if mod.calc_distance(point.x, point.y, point.z, under.x, under.y, under.z) < 0.4 then
                    if hit_pos.y > under.y then
                      hit_pos = under
                      new_rot = { x = math.rad(180), y = new_rot.y, z = new_rot.z }
                      goto skip_this
                    end
                    hit_pos = under
                    new_rot = { x = math.rad(0), y = new_rot.y, z = new_rot.z }
                    goto got_angle
                  end
                  goto skip_this
                end
              end
              if hit_pos.y - 0.5 > under.y - 1 then
                goto skip_this
              end
            end
          else
            p_data.double_slab = nil
          end
          ::skip_this::

          if string_ascii_icontains(this_node.description, "slab") ~= nil then
            if point.y >= hit_pos.y then
              new_rot = { x = math.rad(180), y = 0, z = 0 }
            end
            if this_node.paramtype2 == "facedir" then
              if p:get_player_control()["sneak"] == true then
                new_rot = { x = math.rad(90), y = 0, z = 0 }
              end
            end

            goto got_angle
          end

          if this_node.paramtype2 == "facedir" then
            if string_ascii_icontains(this_node.description, "stair") ~= nil or
               string_ascii_icontains(this_node.name, "stair") ~= nil then
              --THIS TAKES CARE OF CORNER-type STAIRS..
              if string_ascii_icontains(this_node.description, "inner") ~= nil or
                 string_ascii_icontains(this_node.description, "outer") ~= nil then
                local y = math.rad(0)
                local elsey = math.rad(270)
                new_rot = { x = 0, y = 0, z = 0 }
                if point.y >= hit_pos.y then
                  new_rot = { x = math.rad(180), y = 0, z = 0 }
                  y = math.rad(270)
                  elsey = math.rad(180)
                end
                local facing = math.deg(mod.quantize_direction(p:get_look_horizontal()))
                if facing == 0 then
                  if hit_pos.x >= point.x then
                    new_rot = { x = new_rot.x, y = y, z = 0 }
                  else
                    new_rot = { x = new_rot.x, y = elsey, z = 0 }
                  end
                  goto got_angle
                end
                if facing == 90 then
                  if hit_pos.z >= point.z then
                    new_rot = { x = new_rot.x, y = y, z = 0 }
                  else
                    new_rot = { x = new_rot.x, y = elsey, z = 0 }
                  end
                  goto got_angle
                end
                if facing == 180 then
                  if hit_pos.x <= point.x then
                    new_rot = { x = new_rot.x, y = y, z = 0 }
                  else
                    new_rot = { x = new_rot.x, y = elsey, z = 0 }
                  end
                  goto got_angle
                end
                if facing == 270 then
                  if hit_pos.z <= point.z then
                    new_rot = { x = new_rot.x, y = y, z = 0 }
                  else
                    new_rot = { x = new_rot.x, y = elsey, z = 0 }
                  end
                end
                goto got_angle
              end

              --*normal stairs
              if point.y >= hit_pos.y then
                new_rot = { x = math.rad(90), y = 0, z = 0 }
              end
              if p:get_player_control()["sneak"] == true then
                local facing = math.deg(mod.quantize_direction(p:get_look_horizontal()))
                if facing == 0 then
                  if hit_pos.x >= point.x then
                    new_rot = { x = 0, y = 0, z = math.rad(90) }
                  else
                    new_rot = { x = 0, y = 0, z = math.rad(270) }
                  end
                  goto got_angle
                end
                if facing == 180 then
                  if hit_pos.x <= point.x then
                    new_rot = { x = 0, y = 0, z = math.rad(90) }
                  else
                    new_rot = { x = 0, y = 0, z = math.rad(270) }
                  end
                  goto got_angle
                end
                if facing == 90 then
                  if hit_pos.z >= point.z then
                    new_rot = { x = 0, y = 0, z = math.rad(90) }
                  else
                    new_rot = { x = 0, y = 0, z = math.rad(270) }
                  end
                  goto got_angle
                end
                if facing == 270 then
                  if hit_pos.z <= point.z then
                    new_rot = { x = 0, y = 0, z = math.rad(90) }
                  else
                    new_rot = { x = 0, y = 0, z = math.rad(270) }
                  end
                end
              end
              goto got_angle
            end
            if string_ascii_icontains(this_node.description, "pumpkin") ~= nil or
               string_ascii_icontains(this_node.description, "observer") ~= nil or
               string_ascii_icontains(this_node.description, "dispenser") ~= nil or
               string_ascii_icontains(this_node.description, "dropper") ~= nil then
              --uses the same logic as wallmounted
              if p:get_player_control()["sneak"] == true then
                new_rot = { x = 0, y = 0, z = 0 }
              else
                if under.x == hit_pos.x and under.z == hit_pos.z then
                  if under.y >= hit_pos.y then
                    new_rot = { x = math.rad(90), y = 0, z = 0 }
                    goto got_angle
                  end
                  new_rot = { x = math.rad(-90), y = 0, z = 0 }
                else
                end
              end
              goto got_angle
            end
            -- if string_ascii_icontains(this_node.description, "table") ~= nil or
            --    string_ascii_icontains(this_node.description, "chest") ~= nil or
            --    string_ascii_icontains(this_node.description, "barrel") ~= nil or
            --    string_ascii_icontains(this_node.description, "crate") ~= nil or
            --    string_ascii_icontains(this_node.description, "furnace") ~= nil or
            --    string_ascii_icontains(this_node.description, "door") ~= nil or
            --    string_ascii_icontains(this_node.description, "bench") ~= nil then
            --  --lets not get chests all funky looking
            --  goto got_angle
            -- end
            if string_ascii_icontains(this_node.description, "lantern") ~= nil then
              new_rot = { x = math.rad(-90), y = 0, z = 0 }
              goto got_angle
            end
            if under.x == hit_pos.x and under.z == hit_pos.z then
              if under.y >= hit_pos.y then
                new_rot = { x = math.rad(180), y = 0, z = 0 }
              else
                new_rot = { x = math.rad(0), y = 0, z = 0 }
              end
            end
            if under.y == hit_pos.y then
              new_rot = { x = math.rad(90), y = 0, z = 0 }
            end
            goto got_angle
            -- end
          end


          if this_node.paramtype2 == "wallmounted" then
            if under.x == hit_pos.x and under.z == hit_pos.z then
              if under.y >= hit_pos.y then
                new_rot = { x = math.rad(90), y = 0, z = 0 }
                goto got_angle
              end
              new_rot = { x = math.rad(-90), y = 0, z = 0 }
            else
            end
            goto got_angle
          end

          if this_node.drawtype == "raillike" then
            if under.x == hit_pos.x and under.z == hit_pos.z then
              if under.y >= hit_pos.y then
                goto got_angle
              end
              new_rot = { x = math.rad(-90), y = 0, z = 0 }
            else
              new_rot = { x = math.rad(-45), y = 0, z = 0 }
            end
            goto got_angle
          end

          if this_node.drawtype == "plantlike" then
            -- p_data.ghost_object:set_properties({ visual = "sprite"})
            -- if under.x == hit_pos.x and under.z == hit_pos.z then
            --  if under.y >= hit_pos.y then
            --    goto got_angle
            --  end
            --  new_rot = { x = math.rad(-90), y = 0, z = 0 }
            -- else
            --    new_rot = { x = math.rad(-45), y = 0, z = 0 }
            -- end
            goto got_angle
          end
          ::got_angle::


          if this_node.paramtype2 == "facedir" or
             this_node.paramtype2 == "4dir" or
             this_node.paramtype2 == "wallmounted" or
             this_node.drawtype == "raillike" then
            local p_rot = mod.quantize_direction(p:get_look_horizontal())
            new_rot = { x = new_rot.x, y = p_rot + new_rot.y, z = new_rot.z }
          end
          ::override::

          p_data.rotation = new_rot
          p_data.ghost_object:set_rotation(new_rot)

          local buildable = minetest.registered_nodes[pointed_node.name].buildable_to
          if buildable ~= nil then
            if buildable == true then
              hit_pos = under
            end
          end

          if p_data.stairslike_only == true then
            if string_ascii_icontains(this_node.name, "stairs") == nil or
               string_ascii_icontains(this_node.name, "stairs") == nil then
              p_data:remove_preview()
              goto continue
            end
          end

          if p_data.smooth == true then
            p_data.ghost_object:move_to(hit_pos)
          else
            p_data.ghost_object:set_pos(hit_pos)
          end

          if this_node.drawtype == "plantlike" then
            if p_data.ghost_object:get_properties().visual ~= "sprite" then
              p_data.ghost_object:set_properties({ visual = "sprite" })
            end
            if p_data.ghost_object:get_properties().textures ~= this_node.tiles then
              p_data.ghost_object:set_properties({ textures = this_node.tiles })
              -- p_data.ghost_object:set_properties({ textures = { this_node.tiles[1] .. "^[opacity:160" } })
            end
          else
            p_data.ghost_object:set_properties({ wield_item = item_name })
          end
        end
      else
        p_data:remove_preview()
      end
      ::continue::
    end
  end
end
