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

# Window rect
Rectangle.new(
    x: 0, y: 0, z: -1,
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


$map = [
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
    [_,_,_,G,G,_,_,_,_,_,_,_,_,_,_,_,_],
    [_,_,_,_,_,G,_,G,_,G,_,G,_,G,_,_,_],
    [_,_,_,_,P,_,_,_,_,_,_,_,_,_,_,_,_],
    [_,_,_,G,G,G,G,_,G,G,G,G,G,G,G,G,G],
    [_,_,_,G,G,_,_,_,G,_,_,_,_,G,G,G,G],
    [_,_,_,_,_,_,G,_,_,_,G,G,_,_,_,_,_],
    [_,_,_,G,G,G,G,G,G,G,G,_,_,G,G,G,G],
    [_,_,_,_,_,_,_,_,_,_,_,_,G,G,G,G,G],
    [_,_,_,_,G,G,G,_,_,_,G,G,G,G,G,G,G],
    [_,_,_,G,_,_,G,_,G,G,G,G,G,G,G,G,G],
    [_,_,_,_,_,G,G,G,G,G,G,G,G,G,G,G,G],
    [_,_,_,_,_,G,G,G,G,G,G,G,G,G,G,G,G],
]

UNIT = 16