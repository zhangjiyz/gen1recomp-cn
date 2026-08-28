-- Gold/Silver screens historically mixed translated Strings(...) callsites
-- with raw labels passed straight to the shared tile renderer.  The renderer
-- is the last common boundary before Font.draw, so it must consult the same
-- catalog too: otherwise one missed menu callsite silently stays English.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
love = require("tests.love_stub")

local drawn = {}
package.loaded["src.render.Font"] = {
  draw = function(text, x, y)
    drawn[#drawn + 1] = { text = text, x = x, y = y }
    return 0
  end,
  width = function(text) return #tostring(text) * 8 end,
  drawCode = function() end,
  drawBox = function() end,
}

local Chrome = require("src.ui.gen2.Chrome")
local Strings = require("src.core.Strings")

Strings.setAppCatalogEnabled(false)
Strings.load(nil)
Chrome.print("Which BOX?", 1, 2)
T.eq(drawn[#drawn].text, "Which BOX?",
  "English scope preserves the raw renderer input")

Strings.setAppCatalogEnabled(true)
Chrome.print("Which BOX?", 1, 2)
T.eq(drawn[#drawn].text, "选择哪个盒子？",
  "the bundled catalog reaches an unwrapped Chrome.print label")

Chrome.printRight("NO CARD DATA", 19, 3)
T.eq(drawn[#drawn].text, "没有卡片数据",
  "right-aligned raw labels use the same draw boundary")

Strings.load({ strings = { ["Which BOX?"] = "MOD BOX" } })
Chrome.print("Which BOX?", 1, 2)
T.eq(drawn[#drawn].text, "MOD BOX",
  "a translation mod remains authoritative at the shared draw boundary")

Strings.load(nil)
Strings.setAppCatalogEnabled(false)

T.finish("gen2_chrome_translation_boundary_test")
