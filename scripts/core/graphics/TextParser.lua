
--[[===============================================================================================

TextParser
---------------------------------------------------------------------------------------------------
Module to parse a rich text string to generate table of fragments.

=================================================================================================]]

-- Alias
local insert = table.insert
local max = math.max

local TextParser = {}

---------------------------------------------------------------------------------------------------
-- Fragments
---------------------------------------------------------------------------------------------------

-- Creates a list of text fragments (not wrapped).
function TextParser.parse(text)
  local vars = Config.variables
  local fragments = {}
	if text ~= '' then 
		for textFragment, resourceKey in text:gmatch('([^{]*){(.-)}') do
      TextParser.parseFragment(fragments, textFragment)
      local t = resourceKey:sub(1, 1)
      if t == 'i' then
        insert(fragments, { type = 'italic' })
      elseif t == 'b' then
        insert(fragments, { type = 'bold' })
      elseif t == 'r' then
        insert(fragments, { type = 'reset' })
      elseif t == 'f' then
        insert(fragments, { type = 'font', value = Fonts[resourceKey:sub(2)] })
      elseif t == '+' then
        insert(fragments, { type = 'size', value = tonumber(resourceKey:sub(2)) })
      elseif t == '-' then
        insert(fragments, { type = 'size', value = -tonumber(resourceKey:sub(2)) })
      elseif t == 'c' then
        insert(fragments, { type = 'color', value = Color[resourceKey:sub(2)] })
      elseif t == 's' then
        insert(fragments, { type = 'icon', value = Icon[resourceKey:sub(2)] })
      elseif t == '%' then
        local key = resourceKey:sub(2)
        assert(vars[key], 'Text variable ' .. key .. ' not found.')
        TextParser.parseFragment(fragments, '' .. vars[key])
      else
        error('Text command not identified: ' .. (t or 'nil'))
      end
		end
    text = text:match('[^}]+$')
    if text then
      TextParser.parseFragment(fragments, text)
    end
	end
  return fragments
end
-- Parse and insert new fragment(s).
function TextParser.parseFragment(fragments, textFragment)
	-- break up fragments with newlines
	local n = textFragment:find('\n', 1, true)
	while n do
		insert(fragments, textFragment:sub(1, n - 1))
		insert(fragments, '\n')
		textFragment = textFragment:sub(n + 1)
		n = textFragment:find('\n', 1, true)
	end
	insert(fragments, textFragment)
end

---------------------------------------------------------------------------------------------------
-- Lines
---------------------------------------------------------------------------------------------------

-- Creates line list. Each line contains a list of fragments, 
--  a height and a width.
-- @ret(table) the array of lines
function TextParser.createLines(fragments, initialFont, maxWidth)
  local currentFont = ResourceManager:loadFont(initialFont)
  local currentLine = { width = 0, height = 0, length = 0, { content = currentFont } }
  local lines = { currentLine, length = 0 }
  local font = { unpack(initialFont) }
	for i = 1, #fragments do
    local fragment = fragments[i]
		if type(fragment) == 'string' then -- Piece of text
      currentLine = TextParser.addTextFragment(lines, currentLine, fragment, 
        currentFont, maxWidth)
    elseif fragment.type == 'sprite' then
      -- TODO
    elseif fragment.type == 'color' then
      insert(currentLine, { content = fragment.value })
    else
      if fragment.type == 'italic' then
        font[4] = true
      elseif fragment.type == 'bold' then
        font[5] = true
      elseif fragment.type == 'reset' then
        font[4] = false
        font[5] = false
      elseif fragment.type == 'font' then
        font = fragment.value
      elseif fragment.type == 'size' then
        font[3] = fragment.size + font[3]
      end
      currentFont = ResourceManager:loadFont(font)
      insert(currentLine, { content = currentFont })
    end
	end
	return lines
end
-- Cuts the text in the given character index.
-- @param(lines : table) Array of parsed lines.
-- @param(point : number) The index of the last text character.
-- @ret(table) New array of parsed lines.
function TextParser.cutText(lines, point)
  local newLines = { length = 0 }
  for l = 1, #lines do
    if point < lines[l].length then
      local newLine = { width = 0, height = 0, length = 0 }
      for i = 1, #lines[l] do
        local fragment = lines[l][i]
        if fragment.length and point < fragment.length then
          local content = fragment.content:sub(1, point)
          TextParser.insertFragment(newLines, newLine, content, fragment.font)
          break
        else
          point = point - (fragment.length or 0)
          TextParser.insertFragment(newLines, newLine, fragment)
        end
      end
      insert(newLines, newLine)
      break
    else
      insert(newLines, lines[l])
      point = point - lines[l].length
    end
  end
  return newLines
end

---------------------------------------------------------------------------------------------------
-- Text Fragments
---------------------------------------------------------------------------------------------------

-- Inserts new text fragment to the given line (may have to add new lines).
-- @param(lines : table) the array of lines
-- @param(currentLine : table) the line of the fragment
-- @param(fragment : string) the text fragment
-- @ret(table) the new current line
function TextParser.addTextFragment(lines, currentLine, fragment, font, width)
  if fragment == '\n' then
    -- New line
    currentLine = { width = 0, height = 0, length = 0 }
    insert(lines, currentLine)
    return currentLine
  end
  if width then
    return TextParser.wrapText(lines, currentLine, fragment, font, width * Fonts.scale)
  else
    TextParser.insertFragment(lines, currentLine, fragment, font)
    return currentLine
  end
end
-- Wraps text fragment (may have to add new lines).
-- @param(lines : table) the array of lines
-- @param(currentLine : table) the line of the fragment
-- @param(fragment : string) the text fragment
-- @ret(table) the new current line
function TextParser.wrapText(lines, currentLine, fragment, font, width)
  local x = currentLine.width
  local breakPoint = nil
  local nextBreakPoint = fragment:find(' ', 1, true) or #fragment + 1
  while nextBreakPoint do
    local nextx = x + font:getWidth(fragment:sub(1, nextBreakPoint - 1))
    if nextx > width then
      break
    end
    breakPoint = nextBreakPoint
    nextBreakPoint = fragment:find(' ', nextBreakPoint + 1, true)
  end
  if breakPoint and nextBreakPoint then
    TextParser.insertFragment(lines, currentLine, fragment:sub(1, breakPoint - 1), font)
    currentLine = { width = 0, height = 0, length = 0 }
    insert(lines, currentLine)
    return TextParser.wrapText(lines, currentLine, fragment:sub(breakPoint + 1), font, width)
  else
    TextParser.insertFragment(lines, currentLine, fragment, font)
    return currentLine
  end
end
-- Inserts a new fragment into the line.
-- @param(lines : table) Array of all lines.
-- @param(currentLine : table) The line that the fragment will be inserted.
-- @param(fragment : table | string) The fragment to insert.
-- @param(font : Font) The font of the fragment's text (in case the fragment is a string).
function TextParser.insertFragment(lines, currentLine, fragment, font)
  if type(fragment) == 'string' then
    local fw = font:getWidth(fragment)
    local fh = font:getHeight(fragment) * font:getLineHeight()
    fragment = { content = fragment, width = fw, height = fh, length = #fragment, font = font }
  end
  currentLine.width = currentLine.width + (fragment.width or 0)
  currentLine.height = max(currentLine.height, (fragment.height or 0))
  currentLine.length = currentLine.length + (fragment.length or 0)
  insert(currentLine, fragment)
  lines.length = lines.length + (fragment.length or 0)
end

return TextParser