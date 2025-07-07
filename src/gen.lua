--[[
  The bundler for kitaworks webpage.
  Requires: template.html, pages.lua
]]


--[[
  CONFIG
]]

local additional_indent = '    '


local script_dir = arg[0]:match('.*/') or '.'
local pages = dofile(script_dir .. '/pages.lua')

local function mk_local_path(pathname) return script_dir .. '/' .. pathname end
local function mk_target_path(pathname) return script_dir .. '/../' .. pathname end

--[[
  UTILS
]]

local function trim(str) return str:match('^%s*(.-)%s*$') end

local function read_file(pathname)
  local fp = io.open(pathname, 'r')
  if not fp then return nil end
  local text = fp:read('*a')
  fp:close()
  return text
end

local function write_file(pathname, content)
  local fp = io.open(pathname, 'w')
  if not fp then return nil end
  fp:write(tostring(content))
  fp:close()
  return true
end

local function cp_file(src_pathname, dst_pathname)
  local content = read_file(src_pathname)
  return write_file(dst_pathname, content)
end


--[[
  PRELOADS: TEMPLATE
]]

local template_text = read_file(mk_local_path '/template.html')


--[[
  MAIN LIB
]]

local _compile_current_name = nil

local function replace_template_chunk(name)
  name = trim(name)
  local chunk = pages[_compile_current_name][name] or ''
  local indent = chunk:match('^%s*\n(%s-)[^%s]') or chunk:match('^(%s*)[^%s]')
  chunk = chunk:gsub('^' .. indent, additional_indent):gsub('\n' .. indent, '\n' .. additional_indent)
  return chunk:gsub('(%s+)$', '') -- remove tailing spaces
end

local function compile_file_content(name)
  _compile_current_name = name
  local text = template_text:gsub('%{%{(.-)%}%}', replace_template_chunk)
  return text
end


--[[
  MAIN PROCEDURE
]]

local additional_files = {
  'styles.css'
}

for name in pairs(pages) do
  local text = compile_file_content(name)
  local pathname = mk_target_path(name .. '.html')
  write_file(pathname, text)
end

for i, filename in ipairs(additional_files) do
  cp_file(mk_local_path(filename), mk_target_path(filename))
end


print('DONE')


