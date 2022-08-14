local M = {}

local ipairs = ipairs
local print = print
local require = require
local setmetatable = setmetatable

local tbl_concat = table.concat
local math_max = math.max

local _ENV = M

local reporter = require 'luacov.reporter'

local DefaultReporter = reporter.DefaultReporter
local ConsoleReporter = setmetatable({}, DefaultReporter)
ConsoleReporter.__index = ConsoleReporter

local ColorEscapes = {
  reset = '\27[0m',
  low = '\27[31m', -- red
  fair = '\27[33m', -- yellow
  good = '\27[37m', -- white
  very_good = '\27[32m' -- green
}

local Marks = {low = ' !!', fair = ' !'}

local function get_coverage_quality(coverage, low, fair, good)
  if coverage < low then
    return 'low'
  elseif coverage < fair then
    return 'fair'
  elseif coverage < good then
    return 'good'
  end
  return 'very_good'
end

local function coverage_to_string(coverage)
  return ("%.2f%%"):format(100 * coverage)
end

local function calculate_coverage(hits, missed)
  local total = hits + missed
  return total == 0 and 0 or hits / total
end

local function print_ruler(length)
  print(('─'):rep(length))
end

function ConsoleReporter:print_summary()

  local cfg = self:config()
  if cfg then
    cfg = cfg.summary or cfg.console
  end

  local use_color = not not (cfg and cfg.use_color)

  local low_th, fair_th, good_th = 0.20, 0.65, 0.80
  if cfg and cfg.thresholds then
    local thresholds = cfg.thresholds
    low_th = thresholds.low and thresholds.low or low_th
    fair_th = thresholds.fair and thresholds.fair or fair_th
    good_th = thresholds.good and thresholds.good or good_th
  end

  local lines = {{"Filename", "Coverage"}}

  for _, filename in ipairs(self:files()) do
    local summary = self._summary[filename]
    if summary then
      local coverage = calculate_coverage(summary.hits, summary.miss)
      lines[#lines + 1] = {
        quality = get_coverage_quality(coverage, low_th, fair_th, good_th),
        filename,
        coverage_to_string(coverage)
      }
    end
  end

  local max_column_lengths = {}
  for _, line in ipairs(lines) do
    for i, column in ipairs(line) do
      max_column_lengths[i] = math_max(max_column_lengths[i] or -1, #column)
    end
  end

  local table_width = #max_column_lengths - 1
  for _, column_length in ipairs(max_column_lengths) do
    table_width = table_width + column_length
  end

  local column_format_strings = {}
  for i, max_column_length in ipairs(max_column_lengths) do
    if i == 1 then
      column_format_strings[i] = ('%%-%ds'):format(max_column_length)
    else
      column_format_strings[i] = (' %%%ds'):format(max_column_length)
    end
  end

  for i, line in ipairs(lines) do
    if i == 2 then
      print_ruler(table_width)
    end

    local buf = {}
    for j, column in ipairs(line) do
      if j == #line and use_color then
        buf[#buf + 1] = ColorEscapes[line.quality]
      end
      buf[#buf + 1] = column_format_strings[j]:format(column)
      if j == #line then
        buf[#buf + 1] = use_color and ColorEscapes.reset or Marks[line.quality]
      end
    end

    print(tbl_concat(buf))
  end
end

function ConsoleReporter:on_end()
  DefaultReporter.on_end(self)
  self:print_summary()
end

function report()
  reporter.report(ConsoleReporter)
end

return M
