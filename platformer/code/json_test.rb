require "json"

map1 = {
    "x" => 0, "y" => 0,

    "map" => [
        [1,1,1],
        [2,0,0],
        [1,1,1],
    ],
}

map2 = {
    
}

maps = [
    map1,
    map2
]

# JSON.generate     ruby -> json
# JSON.parse        json -> ruby


File.open('resources/maps.json', 'w') do |file|
    file.write(JSON.generate(maps))
end