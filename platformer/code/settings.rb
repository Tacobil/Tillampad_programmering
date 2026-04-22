require "ruby2d"

set width: 16*64,
height: 9*64,

resizable: true

COIN_AMOUNT = 10
COIN_RADIUS = 24
COIN_COLOR = 'fuchsia'
COIN_SECTORS = 16

VW = Window.width
VH = Window.height


$keys = {"w" => 0, "a" => 0, "s" => 0, "d" => 0, "i" => 0, "o" => 0}

class Ruby2D::Tileset
  attr_reader :tile_width, :tile_height
end


# ---COLLISION---
# Collision check between two rectangles
def rect_rect?(r1, r2)
    return (r1.x + r1.width > r2.x &&       # r1 right edge past r2 left
        r1.x < r2.x + r2.width &&       # r1 left edge past r2 right
        r1.y + r1.height > r2.y &&      # r1 top edge past r2 bottom
        r1.y < r2.y + r2.height)       # r1 bottom edge past r2 top
end

# Collision check between a rectangle and circle
def rect_circle(r, c)
    test_x = c.x
    test_y = c.y

    if c.x < r.x # left edge
        test_x = r.x
    elsif c.x > r.x + r.width # right edge
        test_x = r.x + r.width
    end

    if c.y < r.y # top edge
        test_y = r.y
    elsif c.y > r.y + r.height # bottom edge
        test_y = r.y + r.height
    end 

    dist_x = c.x - test_x
    dist_y = c.y - test_y
    distance = Math.sqrt(dist_x*dist_x + dist_y*dist_y)
    
    return distance < c.radius
end

def sign(n)
    if n > 0
        return 1
    elsif n < 0
        return -1
    else
        return 0
    end
end

def anchor_position(n, element_size, anchor_percentage)
    return n - element_size * anchor_percentage
end

def center(n, element_size)
    return anchor_position(n, element_size, 0.5)
end

def centerize(rect, other_rect)
    rect.x = other_rect.x + other_rect.width / 2 - rect.width / 2
    rect.y = other_rect.y + other_rect.height / 2 - rect.height / 2
end



# Window rect
$window_rect = Rectangle.new(
    x: 0, y: 0, z: -100,
    width: VW, height: VH,
    color: [0.1,0.1,0.1,1]
)

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

P = -1
_ = 0
G = 1
C = 20

O = 30


$map1 = [
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],

    [_,_,_,_],
    [_,_,_,G,_,_,_,_,_,_,_,_,_,_,_,_,_],
    [_,_,_,_,_,_,_,_,_,G,G,_,_,_,_,_,_],
    [_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,G,G,G],
    [_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,G,G],
    [_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_],
    [_,_,_,G,G,_,_,C,_,_,_,_,C,_,_,_,_],
    [_,_,_,_,_,G,G,G,G,G,G,G,G,G,G,G,_],
    [_,_,_,_,P,_,_,_,_,_,_,_,_,_,_,_,_],
    [_,_,_,G,G,G,G,_,G,G,G,G,G,G,G,G,G],
    [_,_,_,G,G,_,_,_,G,_,C,C,_,G,G,G,G],
    [_,_,_,_,_,_,G,_,C,_,G,G,C,C,C,C,C],
    [_,_,_,G,G,G,G,G,G,G,G,C,C,G,G,G,G],
    [_,_,_,_,_,_,_,_,_,_,C,C,G,G,G,G,G],
    [_,_,_,_,G,G,G,_,_,_,G,G,G,G,G,G,G],
    [_,_,_,G,_,_,G,_,G,G,G,G,G,G,G,G,G],
    [_,_,_,_,_,G,G,G,G,G,G,G,G,G,G,G,G],
    [_,_,_,_,_,G,G,G,G,G,G,G,G,G,G,G,G],
]

D = 2
B = 3
M = 4
S = 5

$celeste_map = [
    [B,B,B,B,M,B,B,B,B,B,B,B,B,B,D,D,D,D,D,D,D,M,D,D,D,S,S,S,S,S,S,_,_,_,_,_,S,S,S,S],
    [B,B,B,B,M,_,B,B,B,_,_,_,_,B,B,D,D,D,D,D,D,M,_,_,_,_,_,_,_,_,_,_,_,_,_,_,S,S,S,S],
    [D,D,_,_,M,_,_,_,M,_,_,_,_,D,D,D,D,D,_,_,_,M,_,_,_,_,_,_,_,_,_,_,_,_,_,B,B,B,B,B],
    [D,D,_,_,M,M,M,_,M,_,_,_,_,D,D,D,_,_,_,_,_,M,_,_,_,_,_,_,_,_,_,_,_,_,_,B,B,B,B,B],
    [D,D,_,_,M,_,_,_,M,_,_,_,_,D,D,D,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,B,B,B,B,B,B],
    [D,D,_,_,M,_,_,_,M,_,_,_,_,D,D,D,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,B,B,B,B,B],
    [D,D,_,_,M,M,M,M,M,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,B,B,B,B,B],
]

$map2 = [
    [],
    [],


    [P]+[C]*15,
    [G]*15,
]

$map3 = [

    [P]+[C]*60,
    [G]*60,

]




UNIT = 8