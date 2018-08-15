
--[[===============================================================================================

GUI Utilities
---------------------------------------------------------------------------------------------------
Functions that are loaded from the EventSheet.

=================================================================================================]]

-- Imports
local ChoiceWindow = require('core/gui/general/window/ChoiceWindow')
local NumberWindow = require('core/gui/general/window/NumberWindow')
local DialogueWindow = require('core/gui/general/window/DialogueWindow')
local GUI = require('core/gui/GUI')
local ShopGUI = require('core/gui/shop/ShopGUI')

local util = {}

---------------------------------------------------------------------------------------------------
-- Auxiliary
---------------------------------------------------------------------------------------------------

-- Creates an empty GUI for the sheet if not already created.
local function openGUI(sheet)
  if not sheet.gui then
    sheet.gui = GUI()
    sheet.gui.dialogues = {}
    GUIManager:showGUI(sheet.gui)
  end
end

---------------------------------------------------------------------------------------------------
-- Shop
---------------------------------------------------------------------------------------------------

-- Opens the ShopGUI.
-- @param(args.items : table) Array of items.
-- @param(args.sell : boolean) Sell enabling.
function util.openShop(sheet, event, args)
  GUIManager:showGUIForResult(ShopGUI(args.items, args.sell))
end

---------------------------------------------------------------------------------------------------
-- Dialogue
---------------------------------------------------------------------------------------------------

-- General parameters:
-- @param(args.id : number) ID of the dialogue window.

-- Opens a new dialogue window and stores in the given ID.
-- @param(args.width : number) Width of the window (optional).
-- @param(args.height : number) Height of the window (optional).
-- @param(args.x : number) Pixel x of the window (optional).
-- @param(args.y : number) Pixel y of the window (optional).
function util.openDialogueWindow(sheet, event, args)
  openGUI(sheet)
  local dialogues = sheet.gui.dialogues
  local window = dialogues[args.id]
  if window then
    window:resize(args.width, args.height)
    window:setXYZ(args.x, args.y)
  else
    window = DialogueWindow(sheet.gui, 
      args.width, args.height, args.x, args.y)
    dialogues[args.id] = window
  end
  window:show()
  sheet.gui:setActiveWindow(window)
end
-- Shows a dialogue in the given window.
-- @param(args.portrait : table) Character face.
-- @param(args.message : string) Dialogue text.
function util.showDialogue(sheet, event, args)
  assert(sheet.gui, 'You must open a GUI first.')
  local window = sheet.gui.dialogues[args.id]
  sheet.gui:setActiveWindow(window)
  assert(window, 'You must open window ' .. args.id .. ' first.')
  window:showDialogue(args.message, args.portrait, args.name)
end
-- Closes and deletes a dialogue window.
function util.closeDialogueWindow(sheet, event, args)
  if sheet.gui and sheet.gui.dialogues then
    local window = sheet.gui.dialogues[args.id]
    if window then
      window:hide()
      window:removeSelf()
      window:destroy()
      sheet.gui.dialogues[args.id] = nil
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

-- Open a choice window and waits for player choice before closing and deleting.
function util.openChoiceWindow(sheet, event, args)
  openGUI(sheet)
  local window = ChoiceWindow(sheet.gui, args)
  window:show()
  sheet.gui:setActiveWindow(window)
  local result = sheet.gui:waitForResult()
  window:hide()
  window:removeSelf()
  window:destroy()
  sheet.gui.choice = result
end
-- Open a password window and waits for player choice before closing and deleting.
function util.openNumberWindow(sheet, event, args)
  openGUI(sheet)
  local window = NumberWindow(sheet.gui, args)
  window:show()
  sheet.gui:setActiveWindow(window)
  local result = sheet.gui:waitForResult()
  window:hide()
  window:removeSelf()
  window:destroy()
  sheet.gui.number = result
end
-- Open a text window and waits for player choice before closing and deleting.
function util.openStringWindow(sheet, event, args)
  -- TODO
end

return util