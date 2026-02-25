require 'ruby2d'

# Player
$velocity_x = 0
$velocity_y = 0
keys = {"w" => 0, "a" => 0, "s" => 0, "d" => 0}

player = Rectangle.new(
    x: 125, y: 250,
    width: 100, height: 100,
    color: 'teal',
    z: 20
)

# Player Constants
SPEED = 5
# ---------------

# Map
hitbox_rects = [
    Rectangle.new(
        x: 125, y: 250,
        width: 200, height: 150,
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

# ---------------


# Collision check between two rectangles
def colliding?(r1, r2)
    if (r1.x + r1.width >= r2.x &&       # r1 right edge past r2 left
        r1.x <= r2.x + r2.width &&       # r1 left edge past r2 right
        r1.y + r1.height >= r2.y &&      # r1 top edge past r2 bottom
        r1.y <= r2.y + r2.height)       # r1 bottom edge past r2 top

        return true
    end
    
    return false;
end


def handle_input(keys)
    $velocity_x = (keys["d"] - keys["a"]) * SPEED
    $velocity_y = (keys["s"] - keys["w"]) * SPEED
end


def collision(rects, player, direction)
    rects.each do |r|
        if colliding?(r, player)
            p "collison"
        end
    end
end


def update_player(player)
    player.x += $velocity_x
    player.y += $velocity_y
end


update do
    handle_input(keys)
    update_player(player)
    collision(hitbox_rects, player, "horizontal")
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