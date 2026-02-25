require 'ruby2d'

# Player
$velocity_x = 0
$velocity_y = 0
keys = {"w" => 0, "a" => 0, "s" => 0, "d" => 0}

player = Rectangle.new(
    x: 125, y: 250,
    width: 60, height: 60,
    color: 'teal',
    z: 20
)

# Player Constants
SPEED = 5
# ---------------

# Map
hitbox_rects = [
    Rectangle.new(
        x: 30, y: 400,
        width: 400, height: 50,
        color: 'white',
        z: 1
    ),

    Rectangle.new(
        x: 150, y: 50,
        width: 200, height: 50,
        color: 'white',
        z: 1
    ),
]

coins = [
    Circle.new(
        x: 300, y: 175,
        radius: 22,
        sectors: 16,
        color: 'fuchsia',
        z: 10
    ),
    Circle.new(
        x: 350, y: 175,
        radius: 22,
        sectors: 16,
        color: 'fuchsia',
        z: 10
    ),
    Circle.new(
        x: 400, y: 175,
        radius: 22,
        sectors: 16,
        color: 'fuchsia',
        z: 10
    ),
    Circle.new(
        x: 450, y: 175,
        radius: 22,
        sectors: 16,
        color: 'fuchsia',
        z: 10
    ),
]

# ---------------


# COLLISION
# Collision check between two rectangles
# thanks to https://www.jeffreythompson.org/collision-detection/rect-rect.php
def rect_rect?(r1, r2)
    return (r1.x + r1.width > r2.x &&       # r1 right edge past r2 left
        r1.x < r2.x + r2.width &&       # r1 left edge past r2 right
        r1.y + r1.height > r2.y &&      # r1 top edge past r2 bottom
        r1.y < r2.y + r2.height)       # r1 bottom edge past r2 top
end

# Collision check between a rectangle and circle
# thanks to https://www.jeffreythompson.org/collision-detection/circle-rect.php
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

# ---------------



def handle_input(keys)
    $velocity_x = (keys["d"] - keys["a"]) * SPEED
    $velocity_y = (keys["s"] - keys["w"]) * SPEED
end

# handle player collisions
# issue: only works for stationary objects, because it uses player's velocity to handle collisions
def collision(player, rects, direction)
    rects.each do |r| # iterate all hitbox_rects
        if rect_rect?(r, player)

            if direction == "horizontal"
                if $velocity_x > 0 
                    player.x = r.x - player.width # set player's right edge to object's left edge
                elsif $velocity_x < 0
                    player.x = r.x + r.width # set player's left edge to object's right edge
                end
                $velocity_x = 0
            end

            if direction == "vertical"
                if $velocity_y > 0 
                    player.y = r.y - player.height # set player's bottom edge to object's top edge
                elsif $velocity_y < 0
                    player.y = r.y + r.height # set player's top edge to object's bottom edge
                end
                $velocity_y = 0
            end

        end
    end
end

def coin_check(player, coins)
    coins.each do |coin|
        if rect_circle(player, coin)
            coin.remove
        end
    end

end

def update_player(player, hitbox_rects)
    player.y += $velocity_y
    collision(player, hitbox_rects, "vertical")

    player.x += $velocity_x
    collision(player, hitbox_rects, "horizontal")

end


update do
    update_player(player, hitbox_rects)
    handle_input(keys)
    coin_check(player, coins)

end

# Input
on :key_down do |event|
    if keys[event.key]
        keys[event.key] = 1
    end
end

on :key_up do |event|
    if keys[event.key]
        keys[event.key] = 0
    end
end

show