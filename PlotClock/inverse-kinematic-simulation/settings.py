import pygame
import math

RES = VW, VH = (1200, 600)
FPS = 10

BGC = (20,20,20)

SCALE = pygame.Vector2(4.1,4.1)

L1 = 48
L2 = 64

R1 = 48
R2 = 48

OFFSET = 28
PENOFFSET = 16

IDLE = pygame.Vector2(OFFSET/2, -70)

CENTER = pygame.Vector2(VW*0.4, VH*0.9)

def scale(v):
    return pygame.Vector2(v.x*SCALE.x, v.y*SCALE.y) + CENTER
def descale(v):
    return pygame.Vector2((v.x - CENTER.x)/SCALE.x, (v.y - CENTER.y)/SCALE.y)