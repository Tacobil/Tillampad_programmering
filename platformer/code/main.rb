# thanks to https://www.jeffreythompson.org/collision-detection
require_relative "settings.rb"

require_relative "player.rb"
require_relative "map.rb"

require_relative "old_map"

$player = Player.new(VW*0.05, VH*0.5)



# ---------------

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

# Setup
set_map(0,0)

show