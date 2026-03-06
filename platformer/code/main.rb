# thanks to https://www.jeffreythompson.org/collision-detection
require_relative "settings.rb"

require_relative "player.rb"
require_relative "map.rb"

require_relative "old_map"

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

$image = Image.new(
    "textures/sign.png",
    x: VW*0.5-VW*0.5/2, y: VH*0.6-VH*0.9/2,
    width: VW*0.5, height: VH*0.9,
    z: 10
)

$image.remove


class Game
    attr_accessor :world_x, :world_y :map
    def initialize()
        @map = []
        @world_x = 0
        @world_y = 0

        @player = Player.new(self)

    end

end



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