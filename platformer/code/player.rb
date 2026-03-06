
class Player
    SPEED = 8
    JUMPPOWER = 15
    COYOTE_JUMP = 7
    MAX_HEALTH = 100


    attr_accessor :rect, :coins

    def initialize(x, y)
        @velocity_x = 0
        @velocity_y = 0
        @acceleration_x = 0
        @acceleration_y = 0.7
                
        @air_time = 0

        @rect = Rectangle.new(
            x: x, y: y,
            width: 60, height: 60,
            color: 'teal',
            z: 20
        )
        @health = Player::MAX_HEALTH
        @coins = 0

    end

    def input(keys)
        @velocity_x = (keys["d"] - keys["a"]) * Player::SPEED

        # @velocity_y = (keys["s"] - keys["w"]) * Player::SPEED # allow flying
        if keys["w"] == 1 && @air_time <= Player::COYOTE_JUMP && @velocity_y >= 0
            @velocity_y = -Player::JUMPPOWER
        end
    end

    def collision(rects, direction)
        rects.each do |r| # iterate all hitbox_rects
            if rect_rect?(r, @rect)

                if direction == "horizontal"
                    if @velocity_x > 0 
                        @rect.x = r.x - @rect.width # set player's right edge to object's left edge
                    elsif @velocity_x < 0
                        @rect.x = r.x + r.width # set player's left edge to object's right edge
                    end
                    @velocity_x = 0
                end

                if direction == "vertical"
                    if @velocity_y > 0
                        @rect.y = r.y - @rect.height # set player's bottom edge to object's top edge
                        @air_time = 0
                    elsif @velocity_y < 0
                        @rect.y = r.y + r.height # set player's top edge to object's bottom edge
                    end
                    @velocity_y = 0
                end

            end
        end
    end

    def update()
        hitbox_rects = @map["hitboxes"]

        @velocity_x += @acceleration_x
        @velocity_y += @acceleration_y
        @air_time += 1

        @rect.y += @velocity_y
        self.collision(hitbox_rects, "vertical")

        @rect.x += @velocity_x
        self.collision(hitbox_rects, "horizontal")

        @map["interactive"].each do |interaction|
            if rect_rect?(@rect, interaction)
                $image.add # temporary
            else
                $image.remove # temporary
            end
        end

        
        # map change
        if @rect.x + @rect.width < 0 && get_map(@world_x - 1, @world_y) # left       
            @rect.x = VW # move to right side
            @world_x -= 1
            set_map(@world_x, @world_y)
        end
        if @rect.x > VW && get_map(@world_x + 1, @world_y) # right
            @rect.x = 0 - @rect.width # move to left side
            @world_x += 1
            set_map(@world_x, @world_y)
        end
        if @rect.y + @rect.height < 0 && get_map(@world_x, @world_y - 1) # top
            @rect.x = VW # move to bottom side
            @world_y -= 1
            set_map(@world_x, @world_y)
        end
        if @rect.y > VH && get_map(@world_x, @world_y + 1) # bottom
            @rect.x = 0 - @rect.width # move to top side
            @world_y += 1
            set_map(@world_x, @world_y)
        end

        # invisible walls
        if @rect.x < 0 && !get_map(@world_x - 1, @world_y) # left
            @rect.x = 0
            @velocity_x = 0
        elsif @rect.x + @rect.width > VW && !get_map(@world_x + 1, @world_y) # right
            @rect.x = VW - @rect.width
            @velocity_x = 0
        end

        if @rect.y < 0 && !get_map(@world_x, @world_y - 1) # top
            @rect.y = 0
            @velocity_y = 0
        elsif @rect.y + @rect.height > VH && !get_map(@world_x, @world_y + 1) # bottom
            @rect.y = VH - @rect.height
            @velocity_y = 0
            @air_time = 0
        end
        
    end

end