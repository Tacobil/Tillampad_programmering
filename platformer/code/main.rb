# thanks to https://www.jeffreythompson.org/collision-detection
require_relative "settings.rb"

require_relative "player.rb"

$player = Player.new(VW*0.05, VH*0.5)

$maps = [
    {
        "x" => 0,
        "y" => 0,
        "hitboxes" => [
            Rectangle.new(
                x: -100, y: VH-50,
                width: VW+200, height: 50,
                color: 'green',
                z: 1
            ),

            Rectangle.new(
                x: VW*0.5, y: VH*0.7,
                width: 200, height: 50,
                color: 'gray',
                z: 1
            ),

        ],
        "coins" => [
            Circle.new(
                x: 200, y: 370,
                radius: COIN_RADIUS,
                sectors: 8,
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
        "decoration" => [
            Rectangle.new(
                x: 200, y: VH-50-40,
                width: 15, height: 40,
                color: 'brown',
                z: 1
            ),
            Rectangle.new(
                x: 200-(90)/2+15/2, y: VH-50-40-50,
                width: 90, height: 50,
                color: 'brown',
                z: 1
            ),
        ],
        "interactive" => [
            Rectangle.new(
                x: 155, y: VH-50-100,
                width: 100, height: 100,
                color: [0.7, 0.7, 1, 0],
                z: 10,
            ),
            
        ],
    },
    
    {
        "x" => 1,
        "y" => 0,
        "hitboxes" => [
            Rectangle.new(
                x: -100, y: VH-50,
                width: VW+200, height: 50,
                color: 'green',
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
        "decoration" => [],
        "interactive" => [],
    },
    {
        "x" => -1,
        "y" => 0,
        "hitboxes" => [
            Rectangle.new(
                x: -100, y: VH-50,
                width: VW+200, height: 50,
                color: 'green',
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
        "decoration" => [],
        "interactive" => [],
    },
    
]

# ---------------

# Music
song = Music.new('sfx/cool-background-music.mp3') # only a test song for now
song.volume = 60
# song.play

# UI
txt = Text.new(
    'Hello',
    x: 20, y: 20,
    z: 100,
    size: 32,
    color: "black",
    style: "bold",
)


# ---------------

def set_map(x, y)
    $maps.each do |map|
        if map["x"] == x && map["y"] == y
            # show
            $player.map = map
            p $player.map
            map["hitboxes"].each do |ins|
                ins.add
            end

            map["coins"].each do |ins|
                ins.remove
            end

            map["decoration"].each do |ins|
                ins.add
            end

            map["interactive"].each do |ins|
                ins.add
            end

            if map["coin_textures"]
                map["coin_textures"].each do |ins|
                    ins.add
                end
            else
                map["coin_textures"] = []

                map["coins"].each do |ins|
                    sprite = Sprite.new(
                        'textures/purple_coin.png',
                        clip_width: 48,
                        x: ins.x - COIN_RADIUS, y: ins.y - COIN_RADIUS,
                        time: 80,
                        loop: true
                    )
                    sprite.play
                    map["coin_textures"] << sprite

                end
            end
        else
            # hide
            map["hitboxes"].each do |ins|
                ins.remove
            end

            map["coins"].each do |ins|
                ins.remove
            end

            map["decoration"].each do |ins|
                ins.remove
            end

            map["interactive"].each do |ins|
                ins.remove
            end

            if map["coin_textures"]
                map["coin_textures"].each do |ins|
                    ins.remove
                end
            end
        end

    end
end

# get map at coordinate (x, y)
# returns map if map exists, otherwise nil
def get_map(x, y)
    result = nil
    $maps.each do |map|
        if map["x"] == x && map["y"] == y
            result = map
            break
        end
    end

    return result
end

# input handler
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

$image = Image.new(
    "textures/sign.png",
    x: VW*0.5-VW*0.5/2, y: VH*0.6-VH*0.9/2,
    width: VW*0.5, height: VH*0.9,
    z: 10
)
$image.remove

def coin_check(player)
    coins = player.map["coins"]

    coins.each_with_index do |coin, i|
        if rect_circle(player.rect, coin)
            coin.remove
            boom = Sound.new('sfx/coin.mp3')
            # Play the sound
            boom.play
            coins.delete_at(i)

            coin_texture = player.map["coin_textures"][i]
            coin_texture.remove
            player.map["coin_textures"].delete_at(i)
            
            $player.coins += 1
        end
    end
end


update do
    $player.update()
    $player.input($keys)

    coin_check($player)
    
    txt.text = "coins: #{$player.coins} / #{COIN_AMOUNT}"
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

# Setup
set_map(0,0)

show