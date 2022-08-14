package = "luacov-summary"
version = "dev-1"
description = {
  summary = "LuaCov Summary Reporter",
  license = "MIT"
}
source = {
   url = "git://github.com/dwenegar/luacov-summary"
}
dependencies = {
   "lua >= 5.1",
   "luacov > 0.5",
}
build = {
   type = "builtin",
   modules = {
      ['luacov.reporter.summary'] = "src/luacov/reporter/summary.lua"
   }
}
