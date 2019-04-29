
--[[===============================================================================================

DialoguePortrait
---------------------------------------------------------------------------------------------------
Indents the dialogue text to fit the speaker's portrait, shown above window.

-- Plugin parameters:
Use <indent> to fix an indentation length instead of using portrait's width.

=================================================================================================]]

-- Parameters
local indent = tonumber(args.indent)

-- Imports
local DialogueWindow = require('core/gui/general/window/DialogueWindow')
local EventSheet = require('core/fiber/EventSheet')
local SimpleImage = require('core/gui/widget/SimpleImage')

---------------------------------------------------------------------------------------------------
-- DialogueWindow
---------------------------------------------------------------------------------------------------

-- Shows the portrait of the speaker.
-- @param(icon : table) Table with id, col and row values.
--  It may also contain char and name values, which indicates a portrait of the given character.
function DialogueWindow:setPortrait(icon)
  if self.portrait then
    self.portrait:destroy()
    self.content:removeElement(self.portrait)
    self.portrait = nil
  end
  self.indent = 0
  local char = nil
  if icon and not icon.id and icon.char then
    char = icon.char
    icon = char.portraits[icon.name]
  end
  if icon and icon.id >= 0 then
    local portrait = ResourceManager:loadIcon(icon, GUIManager.renderer)
    if char then
      portrait:applyTransformation(char.data.transform)
    end
    local ox, oy = portrait.offsetX, portrait.offsetY
    portrait:setOffset(0, 0)
    local x, y, w, h = portrait:totalBounds()
    x = -self.width / 2 + x + w / 2 + self:paddingX() - ox
    y = self.height / 2 - h / 2 - self:paddingY() - oy
    portrait:setOffset(ox, oy)
    self.portrait = SimpleImage(portrait, x - w / 2, y - h / 2, 1)
    self.portrait:updatePosition(self.position)
    self.content:add(self.portrait)
    self.indent = w
  end
end
-- Override. Adjusts text position and width.
local DialogueWindow_rollText = DialogueWindow.rollText
function DialogueWindow:rollText(text)
  local x = self.portrait and (indent or self.indent) or 0
  self.dialogue:setMaxWidth(self.width - self:paddingX() * 2 - x)
  self.dialogue.relativePosition.x = x - self.width / 2 + self:paddingX()
  self.dialogue:updatePosition(self.position)
  DialogueWindow_rollText(self, text)
end
-- Shows a dialogue in the given window.
-- @param(args.portrait : table) Character face.
-- @param(args.message : string) Dialogue text.
function util.showDialogue(sheet, args)
  assert(sheet.gui, 'You must open a GUI first.')
  local window = sheet.gui.dialogues[args.id]
  sheet.gui:setActiveWindow(window)
  assert(window, 'You must open window ' .. args.id .. ' first.')
  local speaker = args.name ~= '' and { name = args.name, 
    x = args.nameX, y = args.nameY }
  window:showDialogue(args.message, args.align, speaker)
end

---------------------------------------------------------------------------------------------------
-- GUIEvents
---------------------------------------------------------------------------------------------------

local EventSheet_showDialogue = EventSheet.showDialogue
function EventSheet.showDialogue(sheet, args)
  assert(sheet.gui, 'You must open a GUI first.')
  local window = sheet.gui.dialogues[args.id]
  assert(window, 'You must open window ' .. args.id .. ' first.')
  if args.character then -- Change portrait
    local portrait = nil
    if args.character ~= '' then -- Change to other image
      local char = sheet:findCharacter(args.character)
      portrait = { char = char, name = args.portrait }
      args.name = args.name or char.name
    end
    window:setPortrait(portrait)
  elseif args.portrait then -- Change portrait
    local portrait = nil
    if args.portrait >= 0 then
      portrait = { id = args.portrait, col = args.portraitCol or 0, row = args.portraitRow or 0 }
    end
    window:setPortrait(portrait)
  end
  EventSheet_showDialogue(sheet, args)
end
