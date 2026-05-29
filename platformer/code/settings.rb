require "ruby2d"

set width: 16*64,
height: 9*64,

resizable: true

VW = Window.width
VH = Window.height
UNIT = 8 # pixels


$keys = {"w" => 0, "a" => 0, "s" => 0, "d" => 0, "i" => 0, "o" => 0}

class Ruby2D::Tileset
  attr_reader :tile_width, :tile_height
end

# Input
on :key_down do |event|
    if $keys[event.key]
        $keys[event.key] = 1
    end
end

on :key_up do |event|
    if $keys[event.key]
        $keys[event.key] = 0
    end
end

