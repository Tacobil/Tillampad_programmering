require_relative "settings.rb"

require "tmx"

map = Tmx.load("data/maps/plains.tmx")

SCALE = 3.2
# pixels: 320x180
# aspect ratio: 16:9
# tiles: 40x22.5

nightfield_tileset = Tileset.new(
  "data/graphics/tilesets/nightfield-tileset.png",
  tile_width: 8,
  tile_height: 8,
  scale: SCALE
)

cuteforest_tileset = Tileset.new(
  "data/graphics/tilesets/cuteforest-tileset.png",
  tile_width: 8,
  tile_height: 8,
  scale: SCALE
)



tile_id = 1
9.times do |y|
  23.times do |x|
    # puts "#{x} #{y} #{tile_id}"
    nightfield_tileset.define_tile(tile_id, x, y)
    tile_id += 1
  end
end

5.times do |y|
  19.times do |x|
    cuteforest_tileset.define_tile(tile_id, x, y)
    tile_id += 1
  end
end

map.layers.each do |layer|
  layer.data.each_with_index do |tile_id, i|
    if tile_id == 0
      next
    end

    x = i % layer.width
    y = i / layer.width

    c = [{x: x*8*SCALE, y: y*8*SCALE}]

    if layer.name == "Coins"
      Sprite.new(
        "data/graphics/tilesets/pixelated-coin.png",
        clip_width: 8,
        time: 100,
        loop: true,
        x: 
      )
    end
          
    if tile_id.to_i < 23*9
      nightfield_tileset.set_tile(tile_id, c)
    elsif tile_id.to_i < 23*9 + 19*5
      cuteforest_tileset.set_tile(tile_id, c)
    end
  end
end

map.object_groups.each do |object_group|
  object_group.objects.each do |object|
    puts object.name
  end
end

show




=begin
map.width
map.height
map.tilewidth
map.tileheight
map.layers
map.tilesets

map.layers.each do |layer|
  puts layer.name
end


layer = map.layers.first

layer.data.each_with_index do |tile_id, i|
  puts tile_id
end

layer.tile_at(x, y)

tile.gid


map.objectgroups.each do |group|
  group.objects.each do |obj|
    puts obj.name
    puts obj.x
    puts obj.y
  end
end

map.tilesets.each do |tileset|
  puts tileset.name
  puts tileset.tilewidth
end


=end