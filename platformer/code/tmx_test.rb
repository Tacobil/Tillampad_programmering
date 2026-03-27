# pixels: 320x180
# tiles: 40x22.5
# aspect ratio: 16:9

require_relative "settings.rb"

require "tmx"




map = Tmx.load("data/maps/plains.tmx")

SCALE = 3.2

tilesets = []

# Create tilesets from the map's tilesets
tile_id = 1
map.tilesets.each do |ts|

  new_tileset = Tileset.new(
    ts.image.sub("../", "data/"), # replace ../ in the path for data/
    tile_width: ts.tilewidth,
    tile_height: ts.tileheight,
    spacing: ts.spacing,
    padding: ts.margin,
    scale: SCALE
  )

  columns = (ts.imagewidth / ts.tilewidth)
  rows = (ts.imageheight / ts.tileheight)
  
  rows.times do |y|
    columns.times do |x|
      new_tileset.define_tile(tile_id, x, y)
      tile_id += 1
    end
  end
  tilesets << new_tileset
end


# Build map
map.layers.each do |layer|
  layer.data.each_with_index do |tile_id, i|
    if tile_id == 0
      next
    end

    # calculate x and y from the one-dimensional array of ids
    x = i % layer.width
    y = i / layer.width

    
    if layer.name == "Coins"
      c = Sprite.new(
        "data/graphics/tilesets/pixelated-coin.png",
        clip_width: 8,
        time: 100,
        loop: true,
        x: x*8*SCALE, y: y*8*SCALE,
        width: 8*SCALE, height: 8*SCALE
      )
      c.play
      next
    end

    
    # Find corresponding tileset for the tile_id
    max_id = 0
    tilesets.each_with_index do |ts, i|
      columns = (ts.width / ts.tile_width)
      rows = (ts.height / ts.tile_height)
      tiles = columns * rows

      max_id += tiles
      if tile_id < max_id
        ts.set_tile(tile_id, [{x: x*8*SCALE, y: y*8*SCALE}])
        break
      end
    end

  end
end

# Load objects
map.object_groups.each do |object_group|
  object_group.objects.each do |object|
    puts object.name
    puts object.properties["Collision-Direction"]
  end
end

show




=begin

map.objectgroups.each do |group|
  group.objects.each do |obj|
    puts obj.name
    puts obj.x
    puts obj.y
  end
end

=end