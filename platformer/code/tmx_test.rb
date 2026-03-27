require "tmx"
require "pry"

map = Tmx.load("data/maps/world.tmx")




puts map.public_methods(false)
binding.pry

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