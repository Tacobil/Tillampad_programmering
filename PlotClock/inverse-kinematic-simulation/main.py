"""
CONTROLS:

[cursor] - control the arms
[left mouse button] - draw
[C] - draw circle
[delete] - clear canvas
[0 1 2 3 4 5 6 7 8 9] - draw a digit 
[P] - copy to clipboard

"""

import pyperclip
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

        self.coordinates = []

        
    
    def draw_num(self, x, y, s, num):
        match num:
            case 0:
                self.draw_arc_ccw(x+7*s, y+10*s, 10*s, 90, 460, 2/3)
            case 1:
                self.last_pos = pygame.Vector2(x+3*s, y+15*s)
                self.set_pos(self.last_pos)
                self.draw_to(pygame.Vector2(x+10*s, y+20*s))
                self.draw_to(pygame.Vector2(x+10*s, y+0*s))
            case 2:
                self.draw_arc_cw(x+7*s, y+14.5*s, 5.5*s, 160, -50, 1)
                self.draw_to(pygame.Vector2(x+1*s, y+0*s))
                self.draw_to(pygame.Vector2(x+13*s, y+0*s))
            case 3:
                self.draw_arc_cw(x+7*s, y+15*s, 5*s, 135, -90, 1.2)
                self.draw_arc_cw(x+7*s, y+5*s, 5*s, 90, -140, 1.2)
            case 4:
                self.last_pos = pygame.Vector2(x+13*s, y+6*s)
                self.set_pos(self.last_pos)

                self.draw_to(pygame.Vector2(x+0*s, y+6*s))
                self.draw_to(pygame.Vector2(x+10*s, y+20*s))
                self.draw_to(pygame.Vector2(x+10*s, y+0*s))
            case 5:
                self.last_pos = pygame.Vector2(x+14*s, y+20*s)
                self.set_pos(self.last_pos)

                self.draw_to(pygame.Vector2(x+2*s, y+20*s))
                self.draw_to(pygame.Vector2(x+2*s, y+10*s))

                self.draw_arc_cw(x+7*s, y+6*s, 6*s, 133, -150, 1.2)
            case 6:
                self.draw_arc_ccw(x+7.2*s, y+12*s, 8*s, 40, 180, 0.9)
                self.draw_to(pygame.Vector2(x+0*s, y+6.5*s))
                self.draw_arc_ccw(x+7.2*s, y+6*s, 6*s, 180, 540, 1.2)
            case 7:
                self.last_pos = pygame.Vector2(x+1*s, y+20*s)
                self.set_pos(self.last_pos)

                self.draw_to(pygame.Vector2(x+15*s, y+20*s))
                self.draw_to(pygame.Vector2(x+4*s, y+0*s))
            case 8:
                self.draw_arc_ccw(x+7.5*s, y+15*s, 5*s, 90, 270, 1.2)

                self.draw_arc_cw(x+7.5*s, y+5*s, 5*s, 90, -270, 1.3)
                self.draw_arc_ccw(x+7.5*s, y+15*s, 5*s, 270, 450, 1.2)
            case 9:
                self.draw_arc_cw(x+5*s, y+14*s, 6*s, 360, 0, 1.2)
                self.draw_to(pygame.Vector2(x+12*s, y+6.5*s))
                self.draw_arc_cw(x+5.5*s, y+6*s, 6*s, 0, -160, 1.1)


    def set_pos(self, pos):
        pos = pygame.Vector2(pos.x, -pos.y) # invert y and make new object
        if self.left_arm.can_reach(pos) == False or self.right_arm.can_reach == False:
            return
        
        self.left_arm.ik2(pos)
        
        direction = pygame.Vector2(math.cos(self.left_arm.q1 + self.left_arm.q2), math.sin(self.left_arm.q1 + self.left_arm.q2))
        pos -= direction * PENOFFSET

        self.right_arm.ik1(pos)
        self.draw()
    
    def draw_arc_cw(self, x, y, r, start, stop, stretch):
        def get_point(i):
            angleRad = i * math.pi / 180
            return pygame.Vector2(x + stretch * r * math.cos(angleRad), y + r * math.sin(angleRad))

        start_pos = get_point(start)
        self.set_pos(pygame.Vector2(start_pos.x, -start_pos.y)) # some jank with y-cordinates forces me to invert it here
        self.last_pos = start_pos

        for i in range(start, stop, -1):
            self.draw_to(get_point(i))
    
    def draw_arc_ccw(self, x, y, r, start, stop, stretch):
        def get_point(i):
            angleRad = i * math.pi / 180
            return pygame.Vector2(x + stretch * r * math.cos(angleRad), y + r * math.sin(angleRad))
        
        start_pos = get_point(start)
        self.set_pos(pygame.Vector2(start_pos.x, -start_pos.y))
        self.last_pos = start_pos

        for i in range(start, stop, 1):
            self.draw_to(get_point(i))

    # draws a line from last pos to pos. draw_to has consistent speed unlike set_pos

    def draw_to(self, pos):
        distance = (self.last_pos - pos).magnitude()
        steps = math.floor(distance * 3) # 3 = 3 steps per mm

        if steps == 0:
            return
        
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
                if event.unicode.isdigit():
                    self.draw_num(self.last_pos.x, self.last_pos.y, 2, int(event.unicode))
                
                match event.key:
                    case pygame.K_DELETE:
                        self.left_arm.canvas.fill((0,0,0,0))
                        self.coordinates.clear()
                    case pygame.K_p:
                        print("\n\n\n\n\n\n")
                        string = ""
                        for c in self.coordinates:
                            string = string + "{" + f"{int(c.x)}, {int(-c.y)}" + "},\n"
                        
                        pyperclip.copy(string)
                        print("Copied points to clipboard")
            if event.type == pg.MOUSEBUTTONDOWN:
                self.coordinates.append(descale(self.mouse_pos))
                self.coordinates.append(pygame.Vector2(0,100))
                print(" mouse down")
            if event.type == pg.MOUSEBUTTONUP:
                self.coordinates.append(pygame.Vector2(1,100))


    def end(self):
        self.running = False
        pg.quit()
        sys.exit()

    def input(self):
        keys = pygame.key.get_pressed()
        self.key_dir = pygame.Vector2(int(keys[pygame.K_RIGHT]) - int(keys[pygame.K_LEFT]), int(keys[pygame.K_DOWN]) - int(keys[pygame.K_UP]))
        self.mouse_pos = pygame.Vector2(pygame.mouse.get_pos())
        

    def update(self):
        self.clock.tick(FPS)
        self.input()
        if pygame.mouse.get_pressed()[0]:
            mp = descale(self.mouse_pos)
            self.set_pos(pygame.Vector2(mp.x, -mp.y))
            self.last_pos = pygame.Vector2(mp.x, -mp.y)
            self.coordinates.append(mp)

    def draw(self):
        self.screen.fill(BGC)

        self.screen.blit(self.left_arm.canvas)
        self.left_arm.draw()
        self.right_arm.draw()

        # lines
        for i, c in enumerate(self.coordinates):
            if i < len(self.coordinates) - 1:
                next_c = self.coordinates[i+1]
                if c.y == 100 or next_c.y == 100:
                    continue
                pygame.draw.line(self.screen, "white", scale(c), scale(next_c))
            
        
        # draw rect

        pg.display.update()
        pg.display.set_caption(f'{self.clock.get_fps() :.1f}')

if __name__ == '__main__':
    game = Game()
    game.run()