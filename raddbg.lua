vim.g.raddbg_target = ""

vim.g.raddbg_launcher = "launch_raddbg.bat"

local IPC_DELAY_MS = 500

local function current_file_line()
  local file = vim.fn.expand("%:p")
  local line = vim.api.nvim_win_get_cursor(0)[1]
  return file, line
end

vim.g.raddbg_relbase = "buffer"

local function resolve_exe(exe)
  exe = vim.fn.expand(exe)
  if exe:match("^%a:[/\\]") or exe:match("^[/\\][/\\]") or exe:match("^[/\\]") then
    return vim.fn.fnamemodify(exe, ":p")
  end

  local base = (vim.g.raddbg_relbase == "buffer")
    and vim.fn.expand("%:p:h")
    or  vim.fn.getcwd()
  return vim.fn.fnamemodify(base .. "/" .. exe, ":p")
end

local function quote_token(token)
  if token:find("%s") and not token:match('^".*"$') then
    return '"' .. token .. '"'
  end
  return token
end

vim.api.nvim_create_user_command("RadDbgSetTarget", function(opts)
  if #opts.fargs == 0 then
    vim.notify("Usage: :RadDbgSetTarget <exe>", vim.log.levels.WARN)
    return
  end

  local exe = resolve_exe(opts.fargs[1])

  local argv = { quote_token(exe) }
  for i = 2, #opts.fargs do
    table.insert(argv, quote_token(opts.fargs[i]))
  end
  local target = table.concat(argv, " ")

  vim.g.raddbg_target = target
  vim.notify("RADDBG target set: " .. target)
end, { nargs = "+", complete = "file" })

vim.api.nvim_create_user_command("RadDbgTarget", function()
  if vim.g.raddbg_target then
    print("Current RADDBG target: " .. vim.g.raddbg_target)
  else
    print("No RADDBG target set")
  end
end, {})

local function start_raddbg()
  local launcher = vim.g.raddbg_launcher or "launch_raddbg.bat"
  local args = {}

  if vim.g.raddbg_target and #vim.g.raddbg_target > 0 then
    for a in string.gmatch(vim.g.raddbg_target, "%S+") do
      table.insert(args, a)
    end
  end

  local cmd = { "cmd.exe", "/c", launcher }
  for _, a in ipairs(args) do table.insert(cmd, a) end
  vim.fn.jobstart(cmd, { detach = true })
end

local function ipc(cmd_args)
  local cmd = { "raddbg.exe", "--ipc" }
  for _, a in ipairs(cmd_args) do table.insert(cmd, a) end
  vim.fn.jobstart(cmd, { detach = true })
end

vim.api.nvim_create_user_command("RadDbgRun", function()
  start_raddbg()

  if vim.g.raddbg_target and #vim.g.raddbg_target > 0 then
    local targ = {}
    for a in string.gmatch(vim.g.raddbg_target, "%S+") do
      table.insert(targ, a)
    end
    vim.defer_fn(function()
      ipc(vim.list_extend({ "select_target" }, targ))
    end, IPC_DELAY_MS)
  end
end, {})

vim.api.nvim_create_user_command("RadDbgRunHere", function()
  local file, line = current_file_line()
  if file == "" then
    vim.notify("No file", vim.log.levels.WARN)
    return
  end

  start_raddbg()

  vim.defer_fn(function()
    local loc = (file .. ":" .. tostring(line))

    if vim.g.raddbg_target and #vim.g.raddbg_target > 0 then
      local targ = {}
      for a in string.gmatch(vim.g.raddbg_target, "%S+") do
        table.insert(targ, a)
      end
      ipc(vim.list_extend({ "select_target" }, targ))
    end

    ipc({ "enable_breakpoint", loc })
    ipc({ "run_to_line", loc })
  end, IPC_DELAY_MS)
end, {})

