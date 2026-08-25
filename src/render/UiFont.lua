-- Per-glyph fallback for the launcher's UI faces.
--
-- The launcher draws with LÖVE's default face, which covers Latin and little
-- else.  That was invisible while the launcher was English-only, but its text
-- now goes through Strings (#767/#791) and a translation mod's catalog is
-- loaded before the first launcher frame (LauncherMods.translationStrings), so
-- the moment one is Japanese every kana lands as a tofu box.
--
-- Font:setFallbacks fills ONLY the codepoints the primary face is missing, so
-- Latin keeps the launcher's own look and nothing about an English install
-- changes. Simplified Chinese comes from Fusion Pixel's zh_hans face, which
-- covers the characters Plain Pixel's smaller CJK set does not. The in-game
-- TTF mode uses the same face, so launcher and game agree.
--
-- Measuring and rendering must attach the same fallback or the launcher
-- measures a width it does not draw -- which is how buttons clip.

local UiFont = {}

local FALLBACK_PATH =
  "assets/fonts/fusionpixel/fusion-pixel-12px-proportional-zh_hans.ttf"
-- Fusion Pixel only rasterizes evenly at multiples of its 12px design em, so
-- snap rather than matching the primary size exactly: a fallback glyph a pixel
-- off its grid is far more obvious than one a pixel off its neighbours.
local DESIGN_EM = 12

local cache = {}
local unavailable = false

local function fallbackFor(size)
  if unavailable then return nil end
  local snapped = math.max(DESIGN_EM,
    math.floor(size / DESIGN_EM + 0.5) * DESIGN_EM)
  local hit = cache[snapped]
  if hit ~= nil then return hit or nil end
  local ok, font = pcall(love.graphics.newFont, FALLBACK_PATH, snapped)
  if not ok or not font then
    -- one failure means the file is absent (a trimmed build); stop retrying
    unavailable = true
    return nil
  end
  if font.setFilter then pcall(font.setFilter, font, "nearest", "nearest") end
  cache[snapped] = font
  return font
end

-- attach(font, size) -> font.  Safe to call on every cache miss; a font whose
-- fallback is already set is left alone, and any failure is swallowed so a
-- missing fallback file can never take the launcher down with it.
function UiFont.attach(font, size)
  if not (font and font.setFallbacks) then return font end
  local fallback = fallbackFor(size or (font.getHeight and font:getHeight()) or DESIGN_EM)
  if not fallback or rawequal(fallback, font) then return font end
  pcall(font.setFallbacks, font, fallback)
  return font
end

function UiFont.clear()
  cache, unavailable = {}, false
end

return UiFont
