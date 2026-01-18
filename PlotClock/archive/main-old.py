import pygame as pg
import sys

from settings import *



class Game:
    def __init__(self):
        pg.init()
        self.screen = pg.display.set_mode(RES)
        self.clock = pg.time.Clock()
        self.running = True

        self.angle_bl = 0
        self.angle_br = 0

        self.angle_cl = 0
        self.angle_cr = 0

        self.joint_left = pygame.Vector2()
        self.joint_right = pygame.Vector2()

        self.left_goal = pygame.Vector2()
        self.right_goal = pygame.Vector2()

        self.pen_pos = pygame.Vector2()

        self.key_dir = pygame.Vector2()
        self.mouse_pos = pygame.Vector2()

    def run(self):
        while self.running:
            self.check_events()
            self.update()
            self.draw()
      
    def check_events(self):
        for event in pg.event.get():
            if event.type == pg.QUIT or (event.type == pg.KEYDOWN and event.key == pg.K_ESCAPE):
                pg.quit()
                sys.exit()

    def input(self):
        pressed = pygame.key.get_pressed()
        self.key_dir = pygame.Vector2(int(pressed[pygame.K_RIGHT]) - int(pressed[pygame.K_LEFT]), int(pressed[pygame.K_DOWN]) - int(pressed[pygame.K_UP]))
        self.mouse_pos = pygame.Vector2(pygame.mouse.get_pos())

    def end(self):
        self.running = False
        pg.quit()
        sys.exit()

    def update_joints(self):
        self.joint_left = pygame.Vector2(math.cos(self.angle_bl), math.sin(self.angle_bl)) * L1 + ORIGIN_LEFT
        self.joint_right = pygame.Vector2(math.cos(self.angle_br), math.sin(self.angle_br)) * R1 + ORIGIN_RIGHT

        self.left_goal = pygame.Vector2(math.cos(self.angle_bl + self.angle_cl), math.sin(self.angle_bl + self.angle_cl)) * L2 + self.joint_left
        self.right_goal = pygame.Vector2(math.cos(self.angle_br + self.angle_cr), math.sin(self.angle_br + self.angle_cr)) * R2 + self.joint_right
        self.pen_pos = self.left_goal.lerp(self.right_goal, 0.5)

        # self.pen_pos = (self.pen_pos - self.joint_left).normalize() * R2 + self.joint_left
        # self.pen_pos = (self.pen_pos - self.joint_right).normalize() * L2 + self.joint_right    
    
    def get_left_angle(self, pos):
        
        if pos.magnitude() > (L1 + L2):
            pos = pos.normalize() * (L1 + L2 - 1)
        x, y = pos.x, pos.y

        q2 = -math.acos((x**2 + y**2 - L1**2 - L2**2) / (2*L1*L2))
        q1 = math.atan2(y, x) + math.atan2((L2 * math.sin(q2)), (L1 + L2 * math.cos(q2)))
        self.angle_cl = -q2
        self.angle_bl = q1

    def get_right_angle(self, pos):
        
        if pos.magnitude() > (R1 + R2):
            pos = pos.normalize() * (R1 + R2 - 1)
        x, y = pos.x, pos.y

        q2 = math.acos((x**2 + y**2 - R1**2 - R2**2) / (2*R1*R2))
        q1 = math.atan2(y, x) + math.atan2((R2 * math.sin(q2)), (R1 + R2 * math.cos(q2)))
        self.angle_cr = -q2
        self.angle_br = q1

    def update(self):
        self.input()
        '''
        dt = self.clock.tick(FPS) * 0.001

        self.angle_bl += dt * math.pi * self.key_dir.x
        self.angle_br += dt * math.pi * self.key_dir.y
        '''
        self.update_joints()
        self.get_left_angle(self.mouse_pos - ORIGIN_LEFT)
        self.get_right_angle(self.mouse_pos - ORIGIN_RIGHT)


        pg.display.update()
        pg.display.set_caption(f'{self.clock.get_fps() :.1f}')

    def draw(self):
        self.screen.fill(BGC)

        pygame.draw.line(self.screen, "green", ORIGIN_LEFT, self.joint_left)
        pygame.draw.line(self.screen, "green", ORIGIN_RIGHT, self.joint_right)

        pygame.draw.line(self.screen, "green", self.left_goal, self.joint_left)
        pygame.draw.line(self.screen, "green", self.right_goal, self.joint_right)

        pygame.draw.circle(self.screen, "white", ORIGIN_LEFT, 5)
        pygame.draw.circle(self.screen, "white", ORIGIN_RIGHT, 5)
        
        pygame.draw.circle(self.screen, "white", self.joint_left, 3)
        pygame.draw.circle(self.screen, "white", self.joint_right, 3)

        pygame.draw.circle(self.screen, "gray", self.left_goal, 3)
        pygame.draw.circle(self.screen, "gray", self.right_goal, 3)

        pygame.draw.circle(self.screen, "red", self.pen_pos, 4)





if __name__ == '__main__':
    game = Game()
    game.run()