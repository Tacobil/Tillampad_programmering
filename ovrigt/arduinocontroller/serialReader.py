import serial
import mouse
import keyboard
import math

mouse_speed = 5
deadzone = 0.9
# Track the key press states



key_states = {"d": False, "a": False, "s": False, "w": False, "mouse": False, "left shift": False}


try:
    ser = serial.Serial('COM5', 9600)  # Justera COM-porten till din Arduino-anslutning
except serial.SerialException: # stanna programmet om ingen port hittas
    print("no port was found")
    exit()



def mousePress(button):
    if button and not key_states["mouse"]:
        mouse.press()
        print("pressed")
        key_states["mouse"] = True
    elif not button and key_states["mouse"]:
        mouse.release()
        print("released")
        key_states["mouse"] = False

def presskey(button, key):
    # Check if the button is pressed and key is not currently active
    if button and not key_states.get(key, False):
        keyboard.press(key)
        print("Key pressed:", key)
        key_states[key] = True

    # Check if the button is released and key is currently active
    elif not button and key_states.get(key, False):
        keyboard.release(key)
        print("Key released:", key)
        key_states[key] = False



def moveMouse(x, y):
    mouse.move(x * mouse_speed, y * mouse_speed, absolute=False)

def arrowKeys(x, y):
    # Right (D key)
    if x > deadzone and not key_states["d"]:
        keyboard.press("right")
        key_states["d"] = True
    elif x <= deadzone and key_states["d"]:
        keyboard.release("right")
        key_states["d"] = False

    # Left (A key)
    if x < -deadzone and not key_states["a"]:
        keyboard.press("left")
        key_states["a"] = True
    elif x >= -deadzone and key_states["a"]:
        keyboard.release("left")
        key_states["a"] = False

    # Down (S key)
    if y > deadzone and not key_states["s"]:
        keyboard.press("down")
        key_states["s"] = True
    elif y <= deadzone and key_states["s"]:
        keyboard.release("down")
        key_states["s"] = False

    # Up (W key)
    if y < -deadzone and not key_states["w"]:
        keyboard.press("up")
        key_states["w"] = True
    elif y >= -deadzone and key_states["w"]:
        keyboard.release("up")
        key_states["w"] = False




while True:
    if keyboard.is_pressed("esc"): # stanna programmet när esc trycks
        exit()
    
    if ser.in_waiting > 0:
        try:
            data = ser.readline().decode('utf-8').strip() # läser av serial konsollen
            x, y, joystickDown, button1Down, button2Down = str.split(data, ",") # dela upp datan

            # värden mellan -1 och 1 
            x = float(x)
            y = float(y)

            # true om knappen är nedtryckt
            joystickDown = joystickDown == "1"
            button1Down = button1Down == "1"
            button2Down = button2Down == "1"

            if button1Down:
                y = -1

            #moveMouse(x, y)
            arrowKeys(x, y)
            #mousePress(button1Down)
        except:
            pass


