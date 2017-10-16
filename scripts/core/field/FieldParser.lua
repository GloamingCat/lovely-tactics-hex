
local FieldParser = {}

local function split(inputstr, sep)
  local t, i = {}, 1
  for str in inputstr:gmatch('([^' .. sep .. ']+)') do
    t[i] = str
    i = i + 1
  end
  return t
end

function FieldParser.loadGrid(field, layerData)
  local content = love.filesystem.read('data/fields/' .. field.id .. '.map')
  local ids = split(content, '%s')
  for l = 1, #layerData do
    local grid = {}
    for i = 1, field.sizeX do
      grid[i] = {}
      for j = 1, field.sizeY do
        local k = (l - 1) * field.sizeX * field.sizeY + (j - 1) * field.sizeX + i
        grid[i][j] = tonumber(ids[k])
      end
    end
    layerData[l].grid = grid
  end
end

return FieldParser