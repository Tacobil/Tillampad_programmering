"""
CONTROLS:

[cursor] - control the arms
[R] - draw rectangle
[C] - draw circle
[delete] - clear canvas

"""

import pygame as pg
import sys

from settings import *
from two_link_robot import TwoLinkRobot


class Game:
    def __init__(self):
        pg.init()
        self.screen = pg.display.set_mode(RES)
        self.clock = pg.time.Clock()
        self.running = True

        self.left_arm = TwoLinkRobot(pygame.Vector2(0,0), color="blue", a1=L1, a2=L2)
        self.right_arm = TwoLinkRobot(pygame.Vector2(OFFSET, 0), color="green", a1=R1, a2=R2)

        self.key_dir = pygame.Vector2()
        self.mouse_pos = pygame.Vector2()
        self.last_pos = pygame.Vector2()
    
        self.draw_num(2, 0, 30, 2)
        #self.draw_to(pygame.Vector2(0, -50))
        #self.draw_to(pygame.Vector2(30, -70))
        #self.draw_to(pygame.Vector2(60, -50))
        #self.draw_to(pygame.Vector2(60, -20))

        
    
    def draw_num(self, s, x, y, num):
        match num:
            case 0:
                self.draw_arc_ccw(x+7*s, y+10*s, 10*s, 90, 460, 2/3)
            case 1:
                self.set_pos(x+3*s, y+15*s)
                self.last_pos = pygame.Vector2(x+3*s, y+15*s)

                self.draw_to(x+10*s, y+20*s)
                self.draw_to(x+10*s, y+0*s)
            case 2:
                self.draw_arc_cw(x+7*s, y+14.5*s, 5.5*s, 160, -50, 1)



    def set_pos(self, pos):
        if self.left_arm.can_reach(pos) == False or self.right_arm.can_reach == False:
            return
         
        self.left_arm.ik2(pos)
        
        direction = pygame.Vector2(math.cos(self.left_arm.q1 + self.left_arm.q2), math.sin(self.left_arm.q1 + self.left_arm.q2))
        pos -= direction * PENOFFSET

        self.right_arm.ik1(pos)
        self.draw()
    
    def draw_circle(self):
        cpos = pygame.Vector2(OFFSET / 2, 65)
        cr = 25
        i = 0

        while i < math.pi * 2:
            pos = pygame.Vector2(math.cos(i), math.sin(i)) * cr + cpos
            pos = pygame.Vector2(pos.x, -pos.y)
            self.set_pos(pos)
            pygame.time.delay(5)
            i += 0.02
    
    def draw_arc_cw(self, x, y, r, start, stop, stretch):
        for i in range(start, stop, -1):
            angleRad = i * math.pi / 180
            self.set_pos(pygame.Vector2(x + stretch * r * math.cos(angleRad), -y + r * math.sin(angleRad)))
            pygame.time.delay(5)
    
    def draw_arc_ccw(self, x, y, r, start, stop, stretch):
        for i in range(start, stop, 1):
            angleRad = i * math.pi / 180
            self.set_pos(pygame.Vector2(x + stretch * r * math.cos(angleRad), -y + r * math.sin(angleRad)))
            pygame.time.delay(5)



        
    def draw_rect(self, x, y, w, h):
        # top side
        step = 0.05
        d = 6

        i = x - w / 2
        while i <= x + w / 2:
            self.set_pos(pygame.Vector2(i, y + h / 2))
            pygame.time.delay(d)
            i += step
        self.set_pos(pygame.Vector2(x + w / 2, y + h / 2))

        # right side
        i = y + h / 2
        while i >= y - h / 2:
            self.set_pos(pygame.Vector2(x + w / 2, i))
            pygame.time.delay(d)
            i -= step
        self.set_pos(pygame.Vector2(x + w / 2, y - h / 2))

        # bottom side
        i = x + w / 2
        while i >= x - w / 2:
            self.set_pos(pygame.Vector2(i, y - h / 2))
            pygame.time.delay(d)
            i -= step
        self.set_pos(pygame.Vector2(x - w / 2, y - h / 2))

        # left side
        i = y - h / 2
        while i <= y + h / 2:
            self.set_pos(pygame.Vector2(x - w / 2, i))
            pygame.time.delay(d)
            i += step
        self.set_pos(pygame.Vector2(x - w / 2, y + h / 2))
    

    def arc_clockwise(self, pos, radius, start, stop, scale):
        increment = 0.05
        count = start
        
        while count <= stop:
            i = count * math.pi / 2
            pen_pos = pygame.Vector2(math.cos(i)*scale.x, math.sin(i)*scale.y) * radius + pos

            count += increment


    
    def draw_to(self, pos):
        distance = math.sqrt(pos.x**2 + pos.y**2)
        steps = math.floor(distance*10)

        step_size = (pos - self.last_pos) / steps

        for i in range(steps):
            self.set_pos(pygame.Vector2(self.last_pos.x + step_size.x * i, self.last_pos.y + step_size.y * i))
            pygame.time.delay(5)
        self.last_pos = pos

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
            if event.type == pg.KEYDOWN:
                match event.key:
                    case pygame.K_c:
                        self.draw_circle()
                    case pygame.K_r:
                        self.draw_rect(OFFSET/2, -7, 5, 5)
                    case pygame.K_DELETE:
                        self.left_arm.canvas.fill((0,0,0,0))


    def end(self):
        self.running = False
        pg.quit()
        sys.exit()

    def input(self):
        keys = pygame.key.get_pressed()
        self.key_dir = pygame.Vector2(int(keys[pygame.K_RIGHT]) - int(keys[pygame.K_LEFT]), int(keys[pygame.K_DOWN]) - int(keys[pygame.K_UP]))
        self.mouse_pos = pygame.Vector2(pygame.mouse.get_pos())

    def update(self):
        self.input()
        mp = descale(self.mouse_pos)
        # self.set_pos(mp)



    def draw(self):
        self.screen.fill(BGC)

        self.screen.blit(self.left_arm.canvas)
        self.left_arm.draw()
        self.right_arm.draw()

        pg.display.update()
        pg.display.set_caption(f'{self.clock.get_fps() :.1f}')

if __name__ == '__main__':
    game = Game()
    game.run()