
--[[===============================================================================================

TextParser
---------------------------------------------------------------------------------------------------
Module to parse a rich text string to generate table of fragments.

Rich text codes:
{i} = set italic;
{b} = set bold;
{u} = set underlined;
{+x} = increases font size by x points;
{-x} = decreases font size by x points;
{fx} = set font (x must be a key in the global Fonts table);
{cx} = sets the color (x must be a key in the global Color table);
{sx} = shows an icon image (x must be a key in the Config.icons table).

=================================================================================================]]

-- Alias
local insert = table.insert
local max = math.max

local TextParser = {}

---------------------------------------------------------------------------------------------------
-- Fragments
---------------------------------------------------------------------------------------------------

-- Split raw text into an array of fragments.
-- @param(text : string) Raw text.
-- @ret(table) Array of fragments.
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
      elseif t == 'u' then
        insert(fragments, { type = 'underline' })
      elseif t == 'f' then
        insert(fragments, { type = 'font', value = Fonts[resourceKey:sub(2)] })
      elseif t == '+' then
        insert(fragments, { type = 'size', value = tonumber(resourceKey:sub(2)) })
      elseif t == '-' then
        insert(fragments, { type = 'size', value = -tonumber(resourceKey:sub(2)) })
      elseif t == 'c' then
        insert(fragments, { type = 'color', value = Color[resourceKey:sub(2)] })
      elseif t == 's' then
        insert(fragments, { type = 'sprite', value = Config.icons[resourceKey:sub(2)] })
      elseif t == '%' then
        local key = resourceKey:sub(2)
        assert(vars[key], 'Text variable ' .. key .. ' not found.')
        TextParser.parseFragment(fragments, tostring(vars[key]))
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
-- @param(fragments : table) Array of parsed fragments.
-- @param(textFragment : string) Unparsed (and unwrapped) text fragment. 
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

-- Creates line list. Each line is a table containing an array of fragments, a height and a width.
-- It also contains its length for character counting.
-- @param(fragments : table) Array of parsing fragments.
-- @ret(table) The array of lines.
function TextParser.createLines(fragments, initialFont, maxWidth)
  local currentFont = ResourceManager:loadFont(initialFont)
  local currentFontInfo = { unpack(initialFont) }
  local currentLine = { width = 0, height = 0, length = 0, { content = currentFont } }
  local lines = { currentLine, length = 0 }
	for i = 1, #fragments do
    local fragment = fragments[i]
		if type(fragment) == 'string' then -- Piece of text
      currentLine = TextParser.addTextFragment(lines, currentLine, fragment, 
        currentFont, maxWidth)
    elseif fragment.type == 'sprite' then
      local quad, texture = ResourceManager:loadIconQuad(fragment.value)
      local x, y, w, h = quad:getViewport()
      w = w * Fonts.scale
      h = h * Fonts.scale
      if currentLine.width + w > maxWidth * Fonts.scale then
        currentLine = TextParser.addTextFragment(lines, currentLine, '\n')
      end
      TextParser.insertFragment(lines, currentLine, { content = texture, quad = quad, 
          length = 1, width = w, height = h})
    elseif fragment.type == 'color' then
      insert(currentLine, { content = fragment.value })
    elseif fragment.type == 'underline' then
      insert(currentLine, { content = 'underline' })
    else
      if fragment.type == 'italic' then
        currentFontInfo[4] = not currentFontInfo[4]
      elseif fragment.type == 'bold' then
        currentFontInfo[5] = not currentFontInfo[5]
      elseif fragment.type == 'reset' then
        currentFontInfo[4] = false
        currentFontInfo[5] = false
      elseif fragment.type == 'font' then
        currentFontInfo = fragment.value
      elseif fragment.type == 'size' then
        currentFontInfo[3] = fragment.size + currentFontInfo[3]
      end
      currentFont = ResourceManager:loadFont(currentFontInfo)
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
-- @param(lines : table) The array of lines.
-- @param(currentLine : table) the line of the fragment.
-- @param(fragment : string) The text fragment.
-- @ret(table) The new current line.
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
-- @param(lines : table) The array of lines.
-- @param(currentLine : table) the line of the fragment.
-- @param(fragment : string) The text fragment.
-- @ret(table) The new current line.
function TextParser.wrapText(lines, currentLine, fragment, font, width)
  local x = currentLine.width
  local breakPoint = nil
  local nextBreakPoint = fragment:find(' ', 1, true) or #fragment + 1
  while nextBreakPoint ~= breakPoint do
    local nextx = x + font:getWidth(fragment:sub(1, nextBreakPoint - 1))
    if nextx > width then
      break
    end
    breakPoint = nextBreakPoint
    nextBreakPoint = fragment:find(' ', nextBreakPoint + 1, true) or #fragment + 1
  end
  if breakPoint and breakPoint ~= nextBreakPoint then
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
