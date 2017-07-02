
--[[===============================================================================================

Script
---------------------------------------------------------------------------------------------------
A base for dynamic scripts that rely on rule database.
Must override the init method to create the rules.

=================================================================================================]]

-- Imports
local ArtificialInteligence = require('core/battle/ai/ArtificialInteligence')

-- Alias
local readFile = love.filesystem.read
local writeFile = love.filesystem.write

local Script = class(ArtificialInteligence)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function Script:init(key)
  self.key = key
  self.rules = self:createRules()
end

-- Creates the set of rules of this script.
function Script:createRules()
  return nil -- Abstract.
end

function Script:__tostring()
  return 'Dynamic Script: ' .. self.key
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- Generates the ActionInput from the rule and executes it.
-- @param(user : Character)
-- @param(id : number)
-- @ret(number) the time cost of the action, or nil if rule could not execute
function Script:executeRule(user, id)
  local rule = self.rules[id]
  return rule:execute(user)
end

---------------------------------------------------------------------------------------------------
-- Script Data
---------------------------------------------------------------------------------------------------

-- Loads the file from AI data folder and decodes from JSON.
-- @ret(unknown) the data in the file
function Script:loadJsonData(sufix)
  local data = self:loadData(sufix)
  if data then
    return JSON.decode(data)
  else
    return nil
  end
end

-- Encodes the data as JSON saves in AI data folder.
-- @param(data : unknown) the data to write
function Script:saveJsonData(data, sufix)
  self:saveData(JSON.encode(data), sufix)
end

-- Loads the file from AI data folder.
-- @ret(string) the data in the file
function Script:loadData(sufix)
  return readFile(self.key .. (sufix or '') .. '.json')
end

-- Saves the data in AI data folder.
-- @param(data : string) the data to write
function Script:saveData(data, sufix)
  writeFile(self.key .. (sufix or '')  .. '.json', data)
end

return Script