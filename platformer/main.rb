# thanks to https://www.jeffreythompson.org/collision-detection

require 'ruby2d'

set width: 16*70
set height: 9*70


# ----PLAYER----
$velocity_x = 0
$velocity_y = 0
$acceleration_x = 0
$acceleration_y = 0
$air_time = 0
$world_x = 0
$world_y = 0
$map = nil
$creative = true

$health = 100

keys = {"w" => 0, "a" => 0, "s" => 0, "d" => 0}

player = Rectangle.new(
    x: 125, y: 250,
    width: 60, height: 60,
    color: 'teal',
    z: 20
)


# Player Constants
SPEED = 8
JUMPPOWER = 15
COYOTE_JUMP = 5

# ---------------

COIN_RADIUS = 15
COIN_COLOR = 'fuchsia'
COIN_SECTORS = 16

$maps = [
    {
        "x" => 0,
        "y" => 0,
        "hitboxes" => [
            Rectangle.new(
                x: -10, y: 400,
                width: 1300, height: 50,
                color: 'white',
                z: 1
            ),

            Rectangle.new(
                x: 150, y: 50,
                width: 200, height: 50,
                color: 'white',
                z: 1
            ),
        ],
        "coins" => [
            Circle.new(
                x: 200, y: 370,
                radius: COIN_RADIUS,
                sectors: COIN_SECTORS,
                color: COIN_COLOR,
                z: 10
            ),
            Circle.new(
                x: 280, y: 370,
                radius: COIN_RADIUS,
                sectors: COIN_SECTORS,
                color: COIN_COLOR,
                z: 10
            ),
            Circle.new(
                x: 360, y: 370,
                radius: COIN_RADIUS,
                sectors: COIN_SECTORS,
                color: COIN_COLOR,
                z: 10
            ),
            Circle.new(
                x: 440, y: 370,
                radius: COIN_RADIUS,
                sectors: COIN_SECTORS,
                color: COIN_COLOR,
                z: 10
            ),
            Circle.new(
                x: 520, y: 370,
                radius: COIN_RADIUS,
                sectors: COIN_SECTORS,
                color: COIN_COLOR,
                z: 10
            ),
        ],
    },
    
    {
        "x" => 1,
        "y" => 0,
        "hitboxes" => [
            Rectangle.new(
                x: 0, y: 400,
                width: 1000, height: 50,
                color: "white",
                z: 1
            ),

            Rectangle.new(
                x: 150, y: 50,
                width: 200, height: 50,
                color: "white",
                z: 1
            ),
        ],
        "coins" => [
            Circle.new(
                x: 200, y: 370,
                radius: COIN_RADIUS,
                sectors: COIN_SECTORS,
                color: COIN_COLOR,
                z: 10
            ),
            Circle.new(
                x: 280, y: 370,
                radius: COIN_RADIUS,
                sectors: COIN_SECTORS,
                color: COIN_COLOR,
                z: 10
            ),
            Circle.new(
                x: 440, y: 370,
                radius: COIN_RADIUS,
                sectors: COIN_SECTORS,
                color: COIN_COLOR,
                z: 10
            ),
        ],
    },
    
]


"""
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
        x: 200, y: 370,
        radius: COIN_RADIUS,
        sectors: COIN_SECTORS,
        color: COIN_COLOR,
        z: 10
    ),
    Circle.new(
        x: 280, y: 370,
        radius: COIN_RADIUS,
        sectors: COIN_SECTORS,
        color: COIN_COLOR,
        z: 10
    ),
    Circle.new(
        x: 360, y: 370,
        radius: COIN_RADIUS,
        sectors: COIN_SECTORS,
        color: COIN_COLOR,
        z: 10
    ),
    Circle.new(
        x: 440, y: 370,
        radius: COIN_RADIUS,
        sectors: COIN_SECTORS,
        color: COIN_COLOR,
        z: 10
    ),
    Circle.new(
        x: 520, y: 370,
        radius: COIN_RADIUS,
        sectors: COIN_SECTORS,
        color: COIN_COLOR,
        z: 10
    ),
]


coin = Sprite.new(
  'coin.png',
  clip_width: 84,
  time: 150,
  loop: true
)
coin.play


30.times do |i|
    coins << Circle.new(
        x: i*28, y: 300,
        radius: COIN_RADIUS,
        sectors: COIN_SECTORS,
        color: COIN_COLOR,
        z: 10
    )
end

"""

# ---------------

# Music
song = Music.new('cool-background-music.mp3') # only a test song for now
song.volume = 60
# song.play



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

# ---------------

def set_map(x, y)
    $maps.each do |map|
        if map["x"] == x && map["y"] == y
            # show
            $map = map
            map["hitboxes"].each do |hitbox|
                hitbox.add
            end

            map["coins"].each do |hitbox|
                hitbox.add
            end
        else
            # hide
            map["hitboxes"].each do |hitbox|
                hitbox.remove
            end

            map["coins"].each do |hitbox|
                hitbox.remove
            end
        end

    end
end

def get_map(x, y)
    result = nil
    $maps.each do |map|
        if map["x"] == x && map["y"] == y
            result = map
            break
        end
    end
    if result
        p "valid #{x} #{y}"
    else
        p "invalid #{x} #{y}"
    end

    return result
end

def handle_input(keys)
    $velocity_x = (keys["d"] - keys["a"]) * SPEED

    if $creative == true
        $velocity_y = (keys["s"] - keys["w"]) * SPEED
    else
        if keys["w"] == 1 && $air_time < COYOTE_JUMP && $velocity_y >= 0
            # jump
            $velocity_y = -JUMPPOWER
        end
    end
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
                    $air_time = 0
                elsif $velocity_y < 0
                    player.y = r.y + r.height # set player's top edge to object's bottom edge
                end
                $velocity_y = 0
            end

        end
    end
end

def coin_check(player, coins)
    coins.each_with_index do |coin, i|
        if rect_circle(player, coin)
            coin.remove
            boom = Sound.new('coin.mp3')
            # Play the sound
            boom.play
            coins.delete_at(i)
        end
    end
end

def update_player(player, hitbox_rects)
    $velocity_x += $acceleration_x
    $velocity_y += $acceleration_y
    $air_time += 1

    player.y += $velocity_y
    collision(player, hitbox_rects, "vertical")

    player.x += $velocity_x
    collision(player, hitbox_rects, "horizontal")

    vw = get :width
    vh = get :height

    
    
    # map change
    if player.x + player.width < 0 # left        
        player.x = vw # move to right side
        $world_x -= 1
        set_map($world_x, $world_y)
    end
    if player.x > vw # right
        player.x = 0 - player.width # move to left side
        $world_x += 1
        set_map($world_x, $world_y)
    end
    if player.y + player.height < 0 # top
        player.x = vw # move to bottom side
        $world_y -= 1
        set_map($world_x, $world_y)
    end
    if player.y > vh # bottom
        player.x = 0 - player.width # move to top side
        $world_y += 1
        set_map($world_x, $world_y)
    end

    # invisible walls
    if player.x < 0 && !get_map($world_x - 1, $world_y) # left
        player.x = 0
        $velocity_x = 0
    end
    if player.x - player.width > vw && !get_map($world_x + 1, $world_y) # right
        player.x = vw - player.width
        $velocity_x = 0
    end
    if player.y < 0 && !get_map($world_x, $world_y - 1) # right
        player.y = 0
        $velocity_y = 0
    end
    if player.y - player.height > vh && !get_map($world_x, $world_y + 1) # right
        player.y = vh - player.height
        $velocity_y = 0
    end

end


update do
    update_player(player, $map["hitboxes"])
    handle_input(keys)
    coin_check(player, $map["coins"])
end

# Input
on :key_down do |event|
    if keys[event.key]
        keys[event.key] = 1
    end
    
    if event.key == "up"
        $world_y -= 1
        set_map($world_x, $world_y)
    elsif event.key == "down"
        $world_y += 1
        set_map($world_x, $world_y)
    elsif event.key == "left"
        $world_x -= 1
        set_map($world_x, $world_y)
    elsif event.key == "right"
        $world_x += 1
        set_map($world_x, $world_y)
    end

end

on :key_up do |event|
    if keys[event.key]
        keys[event.key] = 0
    end
end

# Setup
set_map(0,0)

show