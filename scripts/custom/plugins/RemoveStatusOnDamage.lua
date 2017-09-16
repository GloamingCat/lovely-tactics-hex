
--[[===============================================================================================

RemoveStatusOnDamage
---------------------------------------------------------------------------------------------------
Provides the support for status that are removed 

=================================================================================================]]

local Status = require('core/battle/Status')

function Status:onSkillEffect(input, results)
  if results.damage and input.action.data.damageAnim then
    if self.tags.removeOnDamage or self.data.removeOnKO and self.battler.state.hp == 0 then
      self.battler.statusList:removeStatus(self)
    end
  end
end