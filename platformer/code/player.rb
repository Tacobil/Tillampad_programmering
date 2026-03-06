
class Player
    SPEED = 1 * 60
    JUMPPOWER = 280
    GRAVITY = 1200
    COYOTE_JUMP = 4/60.0

    MAX_HEALTH = 100
    WIDTH = UNIT
    HEIGHT = UNIT
    AIR_JUMPS = 1

    attr_accessor :rect

    def initialize(game, x, y)
        @game = game
        @velocity_x = 0
        @velocity_y = 0
        @acceleration_x = 0
        @acceleration_y = Player::GRAVITY

        @world_x = 0
        @world_y = 0
                
        @air_time = 0.0
        @jumps = 0

        @scale = 1

        @rect = Rectangle.new(
            x: x, y: y,
            width: Player::WIDTH, height: Player::HEIGHT,
            color: 'teal',
            z: 20
        )

        @health = Player::MAX_HEALTH
    end

    def set_scale(scale)
        if scale <= 0
            return
        end

        @scale = scale
        @rect.width = Player::WIDTH * scale
        @rect.height = Player::HEIGHT * scale
    end

    def jump
        if @jumps <= Player::AIR_JUMPS
            if @velocity_y >= 0
                p "set"
                @velocity_y = -Player::JUMPPOWER * @scale
            else
                p "inc"
                @velocity_y *= 0.8
                @velocity_y += -Player::JUMPPOWER * @scale
            end
            @jumps += 1
        end
    end

    def input(keys)
        @velocity_x = (keys["d"] - keys["a"]) * Player::SPEED * @scale
        # @velocity_y = (keys["s"] - keys["w"]) * Player::SPEED * @scale # allow flying
        self.set_scale(@scale + (keys["i"] - keys["o"])*0.2)
    end

    def collision(rects, direction, dt)
        rects.each do |r| # iterate all hitbox_rects
            if rect_rect?(r, @rect)
                if direction == "horizontal"
                    @velocity_x = 0
                    if @rect.x + @rect.width / 2.0 < r.x + r.width / 2.0 # player is to the left
                        @rect.x = r.x - @rect.width # set player's right edge to object's left edge
                    else
                        @rect.x = r.x + r.width # set player's left edge to object's right edge
                    end
                end

                if direction == "vertical"
                    @velocity_y = 0
                    if @rect.y + @rect.height / 2.0 > r.y + r.height / 2.0 # player is below
                        @rect.y = r.y + r.height + 1 # set player's top edge to object's bottom edge
                    else
                        @rect.y = r.y - @rect.height # set player's bottom edge to object's top edge
                        @air_time = 0
                        @jumps = 0
                        # apply velocity if object is moving
                        if r.respond_to?(:velocity_x) and r.respond_to?(:velocity_y)
                            @velocity_x += r.velocity_x
                            @velocity_y += r.velocity_y
                        end
                    end
                end

            end
        end
    end

    def wall_collision()

        # map change
        if @rect.x + @rect.width < 0 && Map.get_map(@world_x - 1, @world_y) # left       
            @rect.x = VW # move to right side
            @world_x -= 1
            Map.set_map(@world_x, @world_y)
        end
        if @rect.x > VW && Map.get_map(@world_x + 1, @world_y) # right
            @rect.x = 0 - @rect.width # move to left side
            @world_x += 1
            Map.set_map(@world_x, @world_y)
        end
        if @rect.y + @rect.height < 0 && Map.get_map(@world_x, @world_y - 1) # top
            @rect.x = VW # move to bottom side
            @world_y -= 1
            Map.set_map(@world_x, @world_y)
        end
        if @rect.y > VH && Map.get_map(@world_x, @world_y + 1) # bottom
            @rect.x = 0 - @rect.width # move to top side
            @world_y += 1
            Map.set_map(@world_x, @world_y)
        end

        # invisible walls
        if @rect.x < 0 && !Map.get_map(@world_x - 1, @world_y) # left
            @rect.x = 0
            @velocity_x = 0
        elsif @rect.x + @rect.width > VW && !Map.get_map(@world_x + 1, @world_y) # right
            @rect.x = VW - @rect.width
            @velocity_x = 0
        end

        if @rect.y < 0 && !Map.get_map(@world_x, @world_y - 1) # top
            @rect.y = 0
            @velocity_y = 0
        elsif @rect.y + @rect.height > VH && !Map.get_map(@world_x, @world_y + 1) # bottom
            @rect.y = VH - @rect.height
            @velocity_y = 0
            @air_time = 0
        end
    end

    def update(dt)
        map = @game.map
        @velocity_x += @acceleration_x * Math.sqrt(@scale) * dt
        @velocity_y += @acceleration_y * Math.sqrt(@scale) * dt
        @air_time += dt

        @rect.y += @velocity_y * dt
        self.collision(map.tiles, "vertical", dt)
        self.collision(map.objects, "vertical", dt)

        @rect.x += @velocity_x * dt
        self.collision(map.tiles, "horizontal", dt)
        self.collision(map.objects, "horizontal", dt)

        if @jumps == 0 and @air_time > Player::COYOTE_JUMP
            @jumps += 1
        end

        if @rect.y > VH
            @rect.y = -@rect.height
        end

        # self.wall_collision
        
        
    end

end