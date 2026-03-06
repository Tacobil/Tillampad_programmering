require_relative "settings.rb"


def get_map(x, y)
    return false
end
require_relative "player.rb"

player = Player.new(0,0)

tileset = Tileset.new(
    'tileset.png',
    tile_width: 84,
    tile_height: 84,
    padding: 1,
    spacing: 2,
)

tileset.define_tile('red', 0, 0)
tileset.define_tile('blue', 1, 0)
tileset.define_tile('green', 0, 1)
tileset.define_tile('purple', 1, 1)


update do
    # update_player($player, $map["hitboxes"])
    # handle_input($keys)
    # coin_check($player)

    player.update
    player.input($keys)

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




show
