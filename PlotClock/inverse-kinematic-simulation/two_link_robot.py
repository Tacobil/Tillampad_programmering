from settings import *

class TwoLinkRobot:
    def __init__(self, origin, **kwargs):
        self.q1 = kwargs.get("q1", 0)
        self.q2 = kwargs.get("q2", 0)

        self.a1 = kwargs.get("a1", L1)
        self.a2 = kwargs.get("a2", L2)

        self.color = kwargs.get("color", "white")

        self.pen_down = kwargs.get("pen_down", True)

        self.origin = origin
        self.max_dist = self.a1 + self.a2 - 0.1
        self.canvas = pygame.Surface(RES, pygame.SRCALPHA)
        self.canvas.fill((0,0,0,0))
    
    def ik1(self, pos):
        p = pos.copy() - self.origin

        if not self.can_reach(pos):
            p.scale_to_length(self.max_dist)
        
        n = (p.x**2 + p.y**2 - self.a1**2 - self.a2**2) / (2*self.a1*self.a2)
        if n < -1 or n > 1:
            return

        q2 = math.acos(n)
        q1 = math.atan2(p.y, p.x) + math.atan2((self.a2 * math.sin(q2)), (self.a1 + self.a2 * math.cos(q2)))
        self.q2 = -q2
        self.q1 = q1
    
    def can_reach(self, pos):
        pos = pos.copy() - self.origin
        return (pos.magnitude() < self.max_dist)

    def ik2(self, pos):
        p = pos.copy() - self.origin

        if not self.can_reach(pos):
            p.scale_to_length(self.max_dist)

        n = (p.x**2 + p.y**2 - self.a1**2 - self.a2**2) / (2*self.a1*self.a2)
        if n < -1 or n > 1:
            return
        
        q2 = -math.acos(n)
        q1 = math.atan2(p.y, p.x) + math.atan2((self.a2 * math.sin(q2)), (self.a1 + self.a2 * math.cos(q2)))
        self.q2 = -q2
        self.q1 = q1


    def draw(self):
        joint1 = pygame.Vector2(math.cos(self.q1), math.sin(self.q1)) * self.a1 + self.origin
        joint2 = pygame.Vector2(math.cos(self.q1 + self.q2), math.sin(self.q1 + self.q2)) * self.a2 + joint1

        pygame.draw.lines(pygame.display.get_surface(), self.color, False, (scale(self.origin), scale(joint1), scale(joint2)))
        if self.pen_down:
            pygame.draw.circle(self.canvas, "white", scale(joint2), 3)
        