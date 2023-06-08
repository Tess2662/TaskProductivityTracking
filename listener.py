#!/usr/bin/python3
from pynput import keyboard
import sys

ctrl=False

def on_press(key):
    global ctrl
    if key == keyboard.Key.ctrl:
        ctrl = True
    elif ctrl and type(key) == keyboard.KeyCode and (key.char.lower() == sys.argv[1] or key.char.lower() == "é"):
        print(key.char.lower())
        exit(0)

def on_release(key):
    global ctrl
    if key == keyboard.Key.ctrl:
        ctrl = False

with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
    listener.join()
