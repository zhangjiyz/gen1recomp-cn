-- Gold's START-menu descriptions live in item.desc tables rather than direct
-- Strings() calls.  Keep the two rendered lines reachable through the shared
-- catalog so an untranslated "Contains items" cannot regress unnoticed.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
love = require("tests.love_stub")

require("src.core.Logger").warn = function() end

local drawn = {}
package.loaded["src.render.Font"] = {
  draw = function(text, x, y) drawn[#drawn + 1] = { text = text, x = x, y = y } end,
  drawCode = function() end,
  drawBox = function() end,
  width = function() return 0 end,
}

local Strings = require("src.core.Strings")
local StartMenu = require("src.ui.gen2.StartMenu")

local game = {
  save = { party = {}, inventory = {}, engineFlags = {}, options = {} },
  input = {},
}

local function descriptionLines()
  local out = {}
  for _, row in ipairs(drawn) do
    if row.x == 0 and (row.y == 14 * 8 or row.y == 16 * 8) then
      out[#out + 1] = row.text
    end
  end
  return out
end

Strings.load({})
Strings.setAppCatalogEnabled(true)
local menu = StartMenu.new(game, { save = game.save, unlocked = { pack = true } })
menu.list.index = 1 -- PACK is the first unlocked conditional row.
menu:draw()
local lines = descriptionLines()
T.eq(lines[1], "装有", "the built-in catalog translates Contains")
T.eq(lines[2], "道具", "and translates items")

drawn = {}
Strings.load({ strings = { Contains = "MOD-LINE-1", items = "MOD-LINE-2" } })
menu:draw()
lines = descriptionLines()
T.eq(lines[1], "MOD-LINE-1", "a translation mod stays above the built-in fallback")
T.eq(lines[2], "MOD-LINE-2", "for both description lines")

Strings.load({})
Strings.setAppCatalogEnabled(false)
T.finish("gen2_start_menu_description_translation_test")
