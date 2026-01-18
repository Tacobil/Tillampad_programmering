import pygame
import math

RES = VW, VH = (1200, 600)
FPS = 60

BGC = (20,20,20)

SCALE = pygame.Vector2(41,41)

L1 = 4.8
L2 = 6.4

R1 = 4.8
R2 = 4.8

OFFSET = 2.8
PENOFFSET = 1.6

IDLE = pygame.Vector2(OFFSET/2, -7)

CENTER = pygame.Vector2(VW*0.5, VH*0.7)

def scale(v):
    return pygame.Vector2(v.x*SCALE.x, v.y*SCALE.y) + CENTER
def descale(v):
    v -= CENTER
    return pygame.Vector2(v.x/SCALE.x, v.y/SCALE.y)