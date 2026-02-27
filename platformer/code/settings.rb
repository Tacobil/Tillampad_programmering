require "ruby2d"


set width: 16*70
set height: 9*70
set background: [0.3,0.4,1,1]

COIN_AMOUNT = 10
COIN_RADIUS = 24
COIN_COLOR = 'fuchsia'
COIN_SECTORS = 16

VW = Window.width
VH = Window.height

$keys = {"w" => 0, "a" => 0, "s" => 0, "d" => 0}


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