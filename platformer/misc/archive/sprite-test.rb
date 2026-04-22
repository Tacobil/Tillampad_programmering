require "ruby2d"

coins = []

SCALE = 8*8

10.times do |i|
    c = Sprite.new(
        "data/graphics/tilesets/pixelated-coin.png",
        clip_width: 8,
        x: i * SCALE, y: SCALE,
        width: SCALE, height: SCALE,
        time: 100, loop: true,
        default: i,
    )    
    coins << c
end

show

=begin
f = 0
update do
    if Window.frames % 4 == 0
        coin = coins[f]
        if coin
            coin.play
        end
        f += 1
    end
end
show
=end