#!/usr/bin/env python3

import re
import sys
import subprocess

class Volume:
    DEVICE = 'Master'

    def __init__(self):
        self.maxVolume = None

    def getDevice(self):
        return self.DEVICE

    def getDeviceSummary(self):
        output = subprocess.check_output(['amixer', 'sget', self.getDevice()])
        return output.decode().split("\n")

    def getDeviceValue(self, regex):
        summary = self.getDeviceSummary()
        summary = map(lambda x: re.search(regex, x), summary)
        return next(filter(lambda x: x != None, summary)).group(1)

    def get(self):
        return int(self.getDeviceValue("Left[^0-9]*([0-9]+)"))

    def isMuted(self):
        return self.getDeviceValue(".*\[(on|off)\]") == 'off'

    def setMute(self, mute=True):
        self.set('mute' if mute else 'unmute')

    def getMaximum(self):
        if self.maxVolume == None:
            self.maxVolume = int(self.getDeviceValue("Limits.*- ([0-9]+)"))
        return self.maxVolume

    def set(self, value):
        subprocess.run(['amixer', 'sset', self.getDevice(), str(value)])

class Mixer:
    STEPSIZE_FRACTION = 1/40 # fraction of maximum volume for increasing sound

    def __init__(self):
        self.volume = Volume()
        self.maxVolume = self.volume.getMaximum()
        self.stepsize = self.maxVolume * self.STEPSIZE_FRACTION

    def increase(self):
        volume = self.volume.get()
        step = round(volume/self.stepsize)
        newVolume = (step+1)*self.stepsize
        self.volume.set(min(newVolume, self.maxVolume))

    def decrease(self):
        volume = self.volume.get()
        step = round(volume/self.stepsize)
        newVolume = (step-1)*self.stepsize
        self.volume.set(max(newVolume, 0))

    def toggleMute(self):
        self.volume.setMute(not self.volume.isMuted())


if __name__ == '__main__':
    mixer = Mixer()
    if sys.argv[1] == 'up':
        mixer.increase()
    elif sys.argv[1] == 'down':
        mixer.decrease()
    else:
        mixer.toggleMute()
