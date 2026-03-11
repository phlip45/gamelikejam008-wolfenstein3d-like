-- Read master + target from temp file
local temp_file = "master_temp.txt"
local lines = {}

local f = io.open(temp_file, "r")
if not f then
  print("Temp file not found:", temp_file)
  return
end

for line in f:lines() do
  local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
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

print("Master sprite:", master_path)

-- Collect durations
local durations = {}
for i, frame in ipairs(source.frames) do
  durations[i] = frame.duration
end

-- Collect tags
local tags = {}
for _, tag in ipairs(source.tags) do
  local t = {
    name = tag.name,
    from = tag.fromFrame.frameNumber,
    to = tag.toFrame.frameNumber,
    aniDir = tag.aniDir
  }

  table.insert(tags, t)

  print("Master tag found:", t.name, "frames", t.from, "-", t.to)
end

-- Function to apply durations + tags + export
local function apply_and_export(spr_path)

  print("")
  print("Applying timings to", spr_path)

  local spr = app.open(spr_path)
  if not spr then
    print("Could not open file:", spr_path)
    return
  end

  -- Apply durations
  for f = 1, #spr.frames do
    spr.frames[f].duration = durations[f]
  end

  -- CLEAR ALL TAGS FIRST
  print("Clearing existing tags...")
  for i = #spr.tags, 1, -1 do
    spr:deleteTag(spr.tags[i])
  end

  -- Add copied tags
  print("Adding tags:")
  for _, t in ipairs(tags) do

    print("  ->", t.name, "frames", t.from, "-", t.to)

    local new_tag = spr:newTag(t.from, t.to)

    if new_tag then
      new_tag.name = t.name
      new_tag.aniDir = t.aniDir
    else
      print("  !! failed creating tag:", t.name)
    end
  end

  -- Save updated .ase
  spr:saveAs(spr_path)

  -- Export sprite sheet
  local png_file = spr_path:gsub("%.ase$", ".png")
  local json_file = spr_path:gsub("%.ase$", ".json")

  print("Exporting:", png_file, json_file)

  app.command.ExportSpriteSheet{
    ui=false,
    askOverwrite=false,
    type=SpriteSheetType.PACKED,
    textureFilename=png_file,
    dataFilename=json_file,
    dataFormat=SpriteSheetDataFormat.JSON,
    splitTags=true,
    trimSprite=true,
    listTags=true,
    listSlices=false
  }

  spr:close()
end

-- Export master first
apply_and_export(master_path)

-- Then targets
for i = 2, #lines do
  apply_and_export(lines[i])
end

source:close()

-- Delete temp file
os.remove(temp_file)

print("")
print("Timings + tags copied + exported for master + targets successfully.")