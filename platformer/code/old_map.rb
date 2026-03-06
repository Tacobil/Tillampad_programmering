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
            Rectangle.new(
                x: 0, y: 0,
                width: VW, height: VH,
                color: 'blue',
                z: -10
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
        "decoration" => [
            Rectangle.new(
                x: 0, y: 0,
                width: VW, height: VH,
                color: 'blue',
                z: -10
            ),
        ],
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
        "decoration" => [
            Rectangle.new(
                x: 0, y: 0,
                width: VW, height: VH,
                color: 'blue',
                z: -10
            ),
        ],
        "interactive" => [],
    },
]

def set_map(x, y)
    $maps.each do |map|
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


    map = get_map(x, y)
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
    return map
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