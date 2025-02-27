local mod = assert(placement_preview)

local string_ascii_iequals = assert(foundation.com.string_ascii_iequals)
local string_split = assert(foundation.com.string_split)
local cast_boolean = assert(mod.cast_boolean)

local function toggle_placement_preview(name, args)
  local player = mod.PlayerService:get_player(name)

  local arg1 = fields[1]
  local bool_arg1 = cast_boolean()

  if bool_arg1 == true then
    player.disabled = false
    minetest.chat_send_player(
      name,
      minetest.colorize("cyan", "placement_preview has been enable")
    )
  elseif bool_arg1 == false then
    player.disabled = true
    minetest.chat_send_player(
      name,
      minetest.colorize("cyan", "placement_preview has been disabled")
    )
  elseif string_ascii_iequals(arg1, "help") then
    minetest.chat_send_player(
      name,
      minetest.colorize("cyan",
        table.concat({
          "list of commands: \n",
          "\t [true|false] \n",
          "\t smooth [true|false] \n",
          "\t only_stairs_slabs [true|false] \n",
        })
      )
    )
  else
    minetest.chat_send_player(
      name,
      minetest.colorize(
        "red",
        "You may be brain dead.. example: \n\t /placement_preview help \n\t or \n\t /pp help"
      )
    )
  end
end

local function chat_command(name, param)
  local args = string_split(param, " ")
  local argc = #fields

  if argc == 1 then
    toggle_placement_preview(name, args)
  elseif argc > 1 then
    local player = mod.PlayerService:get_player(name)
    local option = fields[1]
    local value = cast_boolean(fields[2])
    if string_ascii_iequals(option, "smooth") then
      if value == true then
        player.smooth = true
      elseif value == false then
        player.smooth = false
      else
        minetest.chat_send_player(name,
          minetest.colorize("red", "You may be brain dead.. example: \t /placement_preview help"))
        return
      end
      minetest.chat_send_player(
        name,
        minetest.colorize("cyan", string.format("pp smooth is now: " .. value))
      )
    elseif string_ascii_iequals(option, "only_stairs_slabs") then
      if value == true then
        player.only_stairs_slabs = true
      elseif value == false then
        player.only_stairs_slabs = false
      else
        minetest.chat_send_player(name,
          minetest.colorize("red", "You may be brain dead.. example: \t /placement_preview help"))
        return
      end
      minetest.chat_send_player(
        name,
        minetest.colorize("cyan", string.format("pp only_stairs_slabs os now: " .. value))
      )
    else
      minetest.chat_send_player(
        name,
        minetest.colorize("red", "You may be brain dead.. example: \t /placement_preview help")
      )
    end
  end
end

local cmd = {
  params = "help",
  -- params = "[on|off] or [enable|disable] or [true|false]",
  description = "disable or enable the placement preview",
  privs = {},
  func = chat_command,
}

minetest.register_chatcommand("placement_preview", cmd)
minetest.register_chatcommand("pp", cmd)
