--- @namespace placement_preview
local mod = assert(placement_preview)

local string_ascii_iequals = assert(foundation.com.string_ascii_iequals)

--- @spec cast_boolean(String): Boolean
function mod.cast_boolean(a)
  if string_ascii_iequals(a, "on") or
     string_ascii_iequals(a, "true") or
     string_ascii_iequals(a, "enabled") then
    return true
  elseif string_ascii_iequals(a, "off") or
     string_ascii_iequals(a, "false") or
     string_ascii_iequals(a, "disabled") then
    return false
  end
  return nil
end

function mod.calc_distance(x1, y1, z1, x2, y2, z2)
  local dx = x2 - x1
  local dy = y2 - y1
  local dz = z2 - z1
  return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function mod.quantize_direction(yaw)
  local angle = math.deg(yaw) % 360 -- Convert yaw to degrees and get its modulo 360
  if angle < 45 or angle >= 315 then
    return math.rad(0)             -- Facing North
  elseif angle >= 45 and angle < 135 then
    return math.rad(90)            -- Facing East
  elseif angle >= 135 and angle < 225 then
    return math.rad(180)           -- Facing South
  else
    return math.rad(270)           -- Facing West
  end
end
