import atexit
import time
import os
from Adafruit_MotorHAT import Adafruit_MotorHAT
import traitlets
from traitlets.config.configurable import Configurable
from traitlets.config.configurable import SingletonConfigurable
from flask_api import FlaskAPI
from flask import current_app


class Motor(Configurable):

    value = traitlets.Float()

    # config
    alpha = traitlets.Float(default_value=1.0).tag(config=True)
    beta = traitlets.Float(default_value=0.0).tag(config=True)

    def __init__(self, driver, channel, *args, **kwargs):
        super(Motor, self).__init__(*args, **kwargs)  # initializes traitlets

        self._driver = driver
        self._motor = self._driver.getMotor(channel)
        atexit.register(self._release)

    @traitlets.observe('value')
    def _observe_value(self, change):
        self._write_value(change['new'])

    def _write_value(self, value):
        """Sets motor value between [-1, 1]"""
        mapped_value = int(255.0 * (self.alpha * value + self.beta))
        speed = min(max(abs(mapped_value), 0), 255)
        self._motor.setSpeed(speed)
        if mapped_value < 0:
            self._motor.run(Adafruit_MotorHAT.FORWARD)
        else:
            self._motor.run(Adafruit_MotorHAT.BACKWARD)

    def _release(self):
        """Stops motor by releasing control"""
        self._motor.run(Adafruit_MotorHAT.RELEASE)


class Robot(SingletonConfigurable):

    left_motor = traitlets.Instance(Motor)
    right_motor = traitlets.Instance(Motor)

    # config
    i2c_bus = traitlets.Integer(default_value=1).tag(config=True)
    left_motor_channel = traitlets.Integer(default_value=1).tag(config=True)
    left_motor_alpha = traitlets.Float(default_value=1.0).tag(config=True)
    right_motor_channel = traitlets.Integer(default_value=2).tag(config=True)
    right_motor_alpha = traitlets.Float(default_value=1.0).tag(config=True)

    def __init__(self, *args, **kwargs):
        super(Robot, self).__init__(*args, **kwargs)
        self.motor_driver = Adafruit_MotorHAT(i2c_bus=self.i2c_bus)
        self.left_motor = Motor(
            self.motor_driver, channel=self.left_motor_channel, alpha=self.left_motor_alpha)
        self.right_motor = Motor(
            self.motor_driver, channel=self.right_motor_channel, alpha=self.right_motor_alpha)

    def set_motors(self, left_speed, right_speed):
        self.left_motor.value = left_speed
        self.right_motor.value = right_speed

    def forward(self, speed=1.0, duration=None):
        self.left_motor.value = speed
        self.right_motor.value = speed

    def backward(self, speed=1.0):
        self.left_motor.value = -speed
        self.right_motor.value = -speed

    def left(self, speed=1.0):
        self.left_motor.value = -speed
        self.right_motor.value = speed

    def right(self, speed=1.0):
        self.left_motor.value = speed
        self.right_motor.value = -speed

    def stop(self):
        self.left_motor.value = 0
        self.right_motor.value = 0


app = FlaskAPI(__name__)
app.robot_speed = 0.5
app.robot = Robot()


@app.route('/stop')
def stop():
    current_app.robot.stop()
    return {}


@app.route('/left')
def left():
    current_app.robot.left(speed=current_app.robot_speed)
    return {}


@app.route('/right')
def right():
    current_app.robot.right(speed=current_app.robot_speed)
    return {}


@app.route('/forward')
def forward():
    current_app.robot.forward(speed=current_app.robot_speed)
    return {}


@app.route('/backward')
def backward():
    current_app.robot.backward(speed=current_app.robot_speed)
    return {}


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)
