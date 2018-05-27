
--[[===============================================================================================

Critical
---------------------------------------------------------------------------------------------------
Doubles damage for critical hits.

=================================================================================================]]

-- Imports
local Battler = require('core/battle/battler/Battler')
local Character = require('core/objects/Character')
local PopupText = require('core/battle/PopupText')
local SkillAction = require('core/battle/action/SkillAction')

-- Parameters
local attName = args.attName
local ratio = tonumber(args.ratio) or 2

---------------------------------------------------------------------------------------------------
-- Rate
---------------------------------------------------------------------------------------------------

-- Calculates critical hit rate.
local SkillAction_calculateEffectResults = SkillAction.calculateEffectResults
function SkillAction:calculateEffectResults(user, target)
  local results = SkillAction_calculateEffectResults(self, user, target)
   if self.tags.critical then
    local crit = user.att[attName]() -- Test 
    local rand = self.rand or love.math.random
    if rand() * 100 <= crit then
      results.critical = true
      for i = 1, #results.points do
        results.points[i].value = results.points[i].value * ratio
        results.points[i].critical = true
      end
    end
  end
  return results
end

---------------------------------------------------------------------------------------------------
-- Pop-up
---------------------------------------------------------------------------------------------------

-- Changes font and show text when critical.
local PopupText_addDamage = PopupText.addDamage
function PopupText:addDamage(points)  
  local crit = points.critical and '_crit' or ''
  local popupName = 'popup_dmg' .. points.key
  if points.critical then
    self:addLine(Vocab.critical, popupName, popupName) 
  end
  self:addLine(points.value, popupName, popupName .. crit)
end
-- Changes font and show text when critical.
local PopupText_addHeal = PopupText.addHeal
function PopupText:addHeal(points)
  local crit = points.critical and '_crit' or ''
  local popupName = 'popup_heal' .. points.key
  if points.critical then
    self:addLine(Vocab.critical, popupName, popupName) 
  end
  self:addLine(points.value, popupName, popupName .. crit)
end
