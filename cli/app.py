import requests
from pynput import keyboard
import atexit


class Robot():
    base_url = None

    def __init__(self, base_url, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.base_url = base_url

    def stop(self):
        r = requests.get(f'{self.base_url}/stop')
        print(f'{r}')

    def forward(self):
        r = requests.get(f'{self.base_url}/forward')
        print(f'{r}')

    def backward(self):
        r = requests.get(f'{self.base_url}/backward')
        print(f'{r}')

    def left(self):
        r = requests.get(f'{self.base_url}/left')
        print(f'{r}')

    def right(self):
        r = requests.get(f'{self.base_url}/right')
        print(f'{r}')


robot = Robot('http://192.168.1.64:5000')

up = False
down = False
left = False
right = False
last_command = None


def handle_keyboard():
    global last_command
    if left:
        if not last_command == 'left':
            last_command = 'left'
            robot.left()
    elif right:
        if not last_command == 'right':
            last_command = 'right'
            robot.right()
    elif down:
        if not last_command == 'backward':
            last_command = 'backward'
            robot.backward()
    elif up:
        if not last_command == 'forward':
            last_command = 'forward'
            robot.forward()
    else:
        last_command = 'stop'
        robot.stop()


def on_press(key):
    global up, down, left, right
    if key == keyboard.Key.up:
        up = True
    elif key == keyboard.Key.down:
        down = True
    elif key == keyboard.Key.left:
        left = True
    elif key == keyboard.Key.right:
        right = True
    handle_keyboard()


def on_release(key):
    global up, down, left, right
    if key == keyboard.Key.up:
        up = False
    elif key == keyboard.Key.down:
        down = False
    elif key == keyboard.Key.left:
        left = False
    elif key == keyboard.Key.right:
        right = False
    handle_keyboard()
    if key == keyboard.Key.esc:
        # Stop listener
        return False


def cleanup():
    robot.stop()


atexit.register(cleanup)

# Collect events until released
with keyboard.Listener(
        on_press=on_press,
        on_release=on_release) as listener:
    listener.join()
