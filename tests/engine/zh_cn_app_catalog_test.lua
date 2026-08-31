-- Simplified Chinese application catalog smoke checks.  These are ROM-free
-- and run with the engine tier so new editor chrome cannot silently fall back
-- to English after a source-string rename.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local eq = T.eq
local Strings = require("src.core.Strings")

Strings.setAppCatalogEnabled(true)

eq(Strings("Touch Controls"), "触摸控制布局", "touch editor title")
eq(Strings("On-screen controls"), "屏幕触控按键", "touch toggle label")
eq(Strings("Button size (%s)", Strings("Landscape")),
  "按键大小（横屏）", "formatted orientation label")
eq(Strings("%s (%d pages)", "example", 2),
  "example（2 页）", "skin page count")
eq(Strings("Export failed: %s", "bad zip"),
  "导出失败：bad zip", "export failure")
eq(Strings("Skin Studio"), "皮肤工作室", "skin studio title")
eq(Strings("BETA"), "测试", "beta feature badge")
eq(Strings("CURRENT SKIN"), "当前皮肤", "skin panel caption")
eq(Strings("Not set up"), "未设置", "sync initial status")
eq(Strings("Uploading saves..."), "正在上传存档……", "sync progress status")
eq(Strings("Detect this screen (%dx%d)", 1280, 720),
  "检测当前屏幕（1280x720）", "skin studio canvas detection")
eq(Strings("Selected: %s — drag to move; use blue handles to resize.", "GB A"),
  "已选择：GB A——拖动可移动，蓝色控制点可调整大小。",
  "skin studio editor hint")
eq(Strings("MAP CACHE\nNOT READY.\fBUILD NOW?"),
  "地图缓存\n尚未就绪。\f现在生成吗？", "PotatoVoxel boot cache prompt")
eq(Strings("BUILD %d/%d", 12, 34), "生成 12/34",
  "PotatoVoxel cache progress")
eq(Strings("Hi-Score   %4d Pt", 900), "最高分    900分",
  "Surfing Pikachu score row")
eq(Strings("PRESS START"), "按下START键", "Surfing Pikachu title prompt")
eq(Strings("EXIT GAME"), "关闭", "port-added title exit command")
eq(Strings("BATTLE LAYOUT"), "战斗布局", "port-added battle layout row")
eq(Strings("SHADER FX 2"), "着色器效果2", "port-added shader row")
eq(Strings("%d INSTALLED", 3), "已安装3个模组", "port-added mod count")
eq(Strings("%d OPTIONS", 4), "4 个选项", "grouped option count")
eq(Strings("BATTLE OPTIONS"), "战斗选项", "grouped battle options")
eq(Strings("Connected to the lobby."), "已连接到大厅。",
  "online lobby status")
eq(Strings("Host a battle"), "主持对战", "online host action")
eq(Strings("Waiting for the other trainer to pick"),
  "等待另一位训练家选择", "dynamic online trade stage")
eq(Strings("%d players online, %d open lobbies", 3, 2),
  "3 名玩家在线，2 个公开房间", "formatted online player counts")
eq(Strings("Link desync! %s differs. Are both games the same version and mods?",
  "rng"), "连接不同步！rng 存在差异。双方的游戏版本和模组是否一致？",
  "online desync error")
eq(Strings("VSYNC"), "垂直同步", "new video option")
eq(Strings(" AREA UNKNOWN"), " 地区不明", "town map unknown-area label")
eq(Strings("To"), "前往", "town map fly destination prefix")
eq(Strings("Select Mod (.zip)"), "选择模组（.zip）", "mod file picker title")
eq(Strings("Choose a\nPOKéMON BOX."), "请选择一个\n宝可梦盒子。",
  "box selection prompt")
eq(Strings("When you change a\nPOKéMON BOX, data\vwill be saved.\fIs that okay?"),
  "更换宝可梦盒子时，\n数据将会保存。\f可以吗？",
  "box save prompt preserves control markers")
eq(Strings("RETURN TO MAIN\nMENU?"), "返回主菜单？",
  "port-added launcher return prompt")
eq(Strings("DATE FORMAT"), "日期格式", "port-added date format row")
eq(Strings("Not a translated application string"),
  "Not a translated application string", "unknown strings fall through")

-- The built-in catalog remains the game fallback. A translation mod's own
-- Data.strings catalog has priority wherever it supplies an entry.
eq(Strings("NEW GAME"), "新游戏", "built-in catalog supplies game fallback text")
T.check(Strings.active(), "game scope keeps the built-in catalog active")

Strings.load({ strings = {
  ["NEW GAME"] = "MOD NEW GAME",
  ["Touch Controls"] = "MOD TOUCH CONTROLS",
} })
eq(Strings("NEW GAME"), "MOD NEW GAME", "translation mod still owns game text")
eq(Strings("Touch Controls"), "MOD TOUCH CONTROLS",
  "translation mod takes priority over the built-in catalog")
Strings.load(nil)
eq(Strings("NEW GAME"), "新游戏", "removing the mod restores the built-in fallback")
T.check(Strings.active(), "built-in fallback remains active without a mod")

-- ROM-free tools and parity tests can still request upstream-English scope.
Strings.setAppCatalogEnabled(false)
eq(Strings("Touch Controls"), "Touch Controls", "explicit English scope disables fallback")
T.check(not Strings.active(), "explicit English scope is inert without a mod")
Strings.setAppCatalogEnabled(true)

T.finish("zh_cn_app_catalog")
