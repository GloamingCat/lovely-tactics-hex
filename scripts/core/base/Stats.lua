
--[[===============================================================================================

Stats
---------------------------------------------------------------------------------------------------
Prints the number of lines in code and data files.

=================================================================================================]]

-- Alias
local listItems = love.filesystem.getDirectoryItems
local readFile = love.filesystem.read
local isFile = love.filesystem.isFile

local stats = {}

function stats.printStats()
  local codefiles, codelines = stats.countCode('scripts')
  print('Number of code files:', codefiles)
  print('Number of code lines:', codelines)
  local datafiles, datalines = stats.countData('data')
  print('Number of data files:', datafiles)
  print('Number of data lines:', datalines)
end

---------------------------------------------------------------------------------------------------
-- Code files
---------------------------------------------------------------------------------------------------

function stats.countCode(path)
  local files, lines = 0, 0
  local fileList = listItems(path)
  for i = 1, #fileList do
    local file = fileList[i]
    local path2 = path .. '/' .. file
    if isFile(path2) then 
      files = files + 1
      lines = lines + stats.countCodeLines(path2)
    else
      local files2, lines2 = stats.countCode(path2)
      files = files + files2
      lines = lines + lines2
    end
  end
  return files, lines
end

function stats.countCodeLines(path)
  local content = readFile(path)
  local blockComments = "(%-%-%[%[)(.-)*?(%]%])"
  local lineComments = "(%-%-)(.-)*?\n"
  content = content:gsub(blockComments, '')
  content = content:gsub(lineComments, '')
  content = content:gsub('(\n%s+\n)', '\n')
  local _, count = content:gsub('\n', '\n')
  return count
end

---------------------------------------------------------------------------------------------------
-- Data files
---------------------------------------------------------------------------------------------------

function stats.countData(path)
  local files, lines = 0, 0
  local fileList = listItems(path)
  for i = 1, #fileList do
    local file = fileList[i]
    local path2 = path .. '/' .. file
    if isFile(path2) then 
      files = files + 1
      lines = lines + stats.countDataLines(path2)
    else
      local files2, lines2 = stats.countData(path2)
      files = files + files2
      lines = lines + lines2
    end
  end
  return files, lines
end

function stats.countDataLines(path)
  local comments = "//.*?\n"
  local content = readFile(path)
  content = content:gsub(comments, '')
  content = content:gsub('(\n%s+\n)', '\n')
  local _, count = content:gsub('\n', '\n')
  return count
end

return stats
