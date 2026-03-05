-- Read master + target from temp file
local temp_file = "master_temp.txt"
local lines = {}

local f = io.open(temp_file, "r")
if not f then
  print("Temp file not found:", temp_file)
  return
end

for line in f:lines() do
  local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")  -- trim spaces
  if trimmed ~= "" then
    table.insert(lines, trimmed)
  end
end
f:close()

if #lines < 1 then
  print("Temp file must have at least master")
  return
end

local master_path = lines[1]

local source = app.open(master_path)
if not source then
  print("Could not open master file:", master_path)
  return
end

-- Collect durations
local durations = {}
for i, frame in ipairs(source.frames) do
  durations[i] = frame.duration
end

-- Collect tags
local tags = {}
for _, tag in ipairs(source.tags) do
  table.insert(tags, {
    name = tag.name,
    from = tag.fromFrame.frameNumber,
    to = tag.toFrame.frameNumber,
    aniDir = tag.aniDir
  })
end

-- Function to apply durations + tags + export
local function apply_and_export(spr_path)
  print("Applying timings to", spr_path, "...")
  local spr = app.open(spr_path)
  if not spr then
    print("Could not open file:", spr_path)
    return
  end

  -- Apply durations
  for f = 1, #spr.frames do
    spr.frames[f].duration = durations[f]
  end

  -- Remove existing tags
  for _, tag in ipairs(spr.tags) do
    spr:deleteTag(tag)
  end

  -- Add copied tags
  for _, t in ipairs(tags) do
    spr:newTag(t.from, t.to)
    local new_tag = spr.tags[#spr.tags]
    new_tag.name = t.name
    new_tag.aniDir = t.aniDir
  end

  -- Save updated .ase
  spr:saveAs(spr_path)

  -- Export sprite sheet with your original requested settings
  local png_file = spr_path:gsub("%.ase$", ".png")
  local json_file = spr_path:gsub("%.ase$", ".json")

  app.command.ExportSpriteSheet{
    ui=false,
    askOverwrite=false,
    type=SpriteSheetType.PACKED,
    textureFilename=png_file,
    dataFilename=json_file,
    dataFormat=SpriteSheetDataFormat.JSON,
    splitTags=true,      -- Sprite -> Layers -> Split Layers
    trimSprite=true,     -- Borders -> Trim Sprite
    listTags=true,       -- Output -> JSON data
    listSlices=false
  }

  spr:close()
end

-- Export master first
apply_and_export(master_path)

-- Then apply/export to targets (if any)
for i = 2, #lines do
  apply_and_export(lines[i])
end

-- Delete temp file
os.remove(temp_file)

print("Timings + tags copied + exported for master + targets successfully.")