-- RG34XXSP / pickerless Linux: an already-installed ZIP left beside a second
-- archive must not permanently win the root-directory scan.  One Import press
-- skips the stale first archive and installs the next candidate.
package.path = "./?.lua;./?/init.lua;" .. package.path
if not _G.love then _G.love = require("tests.love_stub") end

local S = require("tests.harness").suite("pickerless Linux mod queue")
local eq = S.eq
local check = S.check

local RomImporter = require("src.import.RomImporter")
local HostShell = require("src.core.HostShell")
local savedKit = package.loaded["src.ui.kit.Kit"]

local saved = {
  getOS = love.system.getOS,
  getDirectoryItems = love.filesystem.getDirectoryItems,
  popen = HostShell.popen,
  pclose = HostShell.pclose,
}

love.system.getOS = function() return "Linux" end
love.filesystem.write("a-installed.zip", "PK\003\004 old")
love.filesystem.write("b-new.zip", "PK\003\004 new")
love.filesystem.getDirectoryItems = function(path)
  if path == "" then return { "a-installed.zip", "b-new.zip" } end
  return saved.getDirectoryItems(path)
end

-- RG34XXSP has neither zenity nor kdialog, so both picker probes return no
-- path and chooseMod falls through to the game-folder scan.
HostShell.popen = function()
  return { read = function() return "" end }
end
HostShell.pclose = function() end
-- Current upstream provides an in-launcher browser first.  This test keeps
-- covering the final game-folder fallback for a stripped handheld build where
-- that optional browser could not be loaded.
package.loaded["src.ui.kit.Kit"] = { FileBrowser = nil }

local attempts = {}
local ri = setmetatable({
  android = false,
  isNX = false,
  workState = nil,
  modNotice = nil,
  _installMod = function(self, name)
    attempts[#attempts + 1] = name
    if name == "a-installed.zip" then
      self.modNotice = { ok = false, text = "already installed" }
    else
      self.modNotice = { ok = true, text = "Installed second_mod" }
    end
  end,
}, RomImporter)

local ok, err = pcall(function() ri:chooseMod() end)
check(ok, "one Import action scans past the stale ZIP: " .. tostring(err))
eq(#attempts, 2, "both ZIP candidates were considered in one action")
eq(attempts[1], "a-installed.zip", "the stale installed ZIP was seen first")
eq(attempts[2], "b-new.zip", "the second ZIP was then installed")
check(love.filesystem.getInfo("a-installed.zip", "file") ~= nil,
  "the player-owned stale ZIP is not deleted after a failed reinstall")
check(love.filesystem.getInfo("b-new.zip", "file") == nil,
  "the successfully installed second ZIP is consumed")
check(ri.modNotice and ri.modNotice.ok,
  "the final notice reports the successful second install")

love.filesystem.remove("a-installed.zip")
love.filesystem.remove("b-new.zip")
love.system.getOS = saved.getOS
love.filesystem.getDirectoryItems = saved.getDirectoryItems
HostShell.popen = saved.popen
HostShell.pclose = saved.pclose
package.loaded["src.ui.kit.Kit"] = savedKit

S.finish()
