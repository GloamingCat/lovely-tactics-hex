
local SkillAction = require('core/battle/action/CharacterOnlySkill')

local ItemAction = class(SkillAction)

function ItemAction:init(skillID, item)
  SkillAction.init(self, skillID)
  -- TODO
end

-- Converting to string.
-- @ret(string) a string with skill's ID and name
function ItemAction:__tostring()
  return 'ItemAction (' .. self.skillID .. ': ' .. self.data.name .. ')'
end

return ItemAction
