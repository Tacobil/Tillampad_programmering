# Collision Detection: https://www.jeffreythompson.org/collision-detection
module Collision
    # Collision check between two rectangles
    # 
    # @param r1 [Ruby2d::Rectangle] the first rectangle
    # @param r2 [Ruby2d::Rectangle] the second rectangle
    # @return [bool] are the rectangles colliding?
    def rect_rect?(r1, r2)
        return (r1.x + r1.width > r2.x &&       # r1 right edge past r2 left
            r1.x < r2.x + r2.width &&       # r1 left edge past r2 right
            r1.y + r1.height > r2.y &&      # r1 top edge past r2 bottom
            r1.y < r2.y + r2.height)       # r1 bottom edge past r2 top
    end

    # Collision check between a rectangle and circle
    # 
    # @param r [Ruby2d::Rectangle] the rectangle
    # @param c [Ruby2d::Circle] the circle
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
end

module Utility
    # Sign a number (clamp to -1, 0 or 1)
    # 
    # @param n [Number] the number to be signed
    # @return [Integer] the signed number
    def sign(n)
        if n > 0
            return 1
        elsif n < 0
            return -1
        else
            return 0
        end
    end

    # Offset a number by half the element size. Used for UI
    # 
    # @param n [Number] the number to be offset
    # @param element_size [Number] the size of the element
    # @return [Number] the centerized number
    def centerize(n, element_size)
        return n - element_size / 2
    end

    # Move a rectangle to the center of another rectangle. Used for UI
    # 
    # @param rect [Rectangle] the rectangle to be moved
    # @param other_rect [Rectangle] the rectangle to be moved to
    def centerize_rect(rect, other_rect)
        rect.x = other_rect.x + other_rect.width / 2 - rect.width / 2
        rect.y = other_rect.y + other_rect.height / 2 - rect.height / 2
    end

end
