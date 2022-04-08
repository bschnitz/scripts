#!/usr/bin/env python3

import sys
import math
import subprocess

class I3BrightnessStatusWriter:
    STATUS_FILE_PATH = '/home/ben/data/dotfiles/cache/brightness'

    def write(self, percentage):
        percentage = '%d' % round(percentage)
        with open(self.STATUS_FILE_PATH, 'w') as f:
            f.write(percentage)
        subprocess.run(['killall', '-USR1', 'i3status'])

class Brightness:
    BACKLIGHT_PATH = '/sys/class/backlight/intel_backlight'

    def __init__(self):
        self.maxBrightness = None
        self.statusWriter = I3BrightnessStatusWriter()

    def get(self):
        path = self.BACKLIGHT_PATH+'/brightness'
        return float(subprocess.check_output(['cat', path]).decode())

    def set(self, n):
        percentage = 100 * (n/self.getMaximum())
        self.statusWriter.write(percentage)
        subprocess.run(['xbacklight', '-set', '%.5f' % percentage])

    def getMaximum(self):
        if self.maxBrightness == None:
            path = self.BACKLIGHT_PATH+'/max_brightness'
            commandOutput = subprocess.check_output(['cat', path])
            self.maxBrightness = float(commandOutput.decode())
        return self.maxBrightness

class Lighter:
    EXPONENTIAL_LEVELLING_CAP = 4/10 # fraction of the maximum brightness
    NON_EXPONENTIAL_STEPSIZE = 1/10 # fraction of the maximum brightness
    EXPONENTIAL_BRIGHTNESS_DECREASE_FACTOR = 3/4

    def __init__(self):
        self.brightness = Brightness()

        maximumBrightness = self.brightness.getMaximum()

        cap = maximumBrightness * self.EXPONENTIAL_LEVELLING_CAP
        self.exponentialLevellingCap = round(cap)

        step = maximumBrightness * self.NON_EXPONENTIAL_STEPSIZE
        self.nonExponentialStepsize = round(step)

    def up(self):
        self.changeBrightness(True)

    def down(self):
        self.changeBrightness(False)

    def isExponential(self, up, brightness):
        if round(brightness - self.exponentialLevellingCap) == 0:
            return not up
        return brightness < self.exponentialLevellingCap

    def changeBrightness(self, up):
        brightness = self.brightness.get()

        if up:
            modStep = 1
            cap = self.brightness.getMaximum()
        else:
            modStep = -1
            cap = 0

        if brightness == cap:
            return

        if up and brightness == 0:
            newBrightness = 1
        elif self.isExponential(up, brightness):
            newBrightness = self.getExponentialBrightness(brightness, modStep)
            if up and newBrightness > self.exponentialLevellingCap:
                newBrightness = self.getBrightness(brightness, 0)
        else:
            newBrightness = self.getBrightness(brightness, modStep)

        if newBrightness == brightness:
            newBrightness = newBrightness + modStep

        self.brightness.set(newBrightness)

    def getBrightness(self, brightness, modStep):
        step = self.getBrightnessStep(brightness)
        return (step+modStep)*self.nonExponentialStepsize

    def getExponentialBrightness(self, brightness, modStep):
        step = self.getExponentialBrightnessStep(brightness)
        factor = self.EXPONENTIAL_BRIGHTNESS_DECREASE_FACTOR
        stepStart = self.exponentialLevellingCap
        return round(stepStart * factor**(step-modStep))

    def getExponentialBrightnessStep(self, brightness):
        """
        c := EXPONENTIAL_BRIGHTNESS_DECREASE_FACTOR
        f(0) := EXPONENTIAL_LEVELLING_CAP

           f(n+1) = f(n) * c
        => f(n+1) = f(0) * c^(n+1)
        => n      = log(c, f(n)/f(0))
        """
        cap = self.exponentialLevellingCap
        factor = self.EXPONENTIAL_BRIGHTNESS_DECREASE_FACTOR
        return round(math.log(brightness/cap, factor))

    def getBrightnessStep(self, brightness):
        return round(brightness/self.nonExponentialStepsize)

if __name__ == '__main__':
    lighter = Lighter()
    up = True if len(sys.argv) > 1 and sys.argv[1] == 'up' else False
    if up:
        lighter.up()
    else:
        lighter.down()
