#!/bin/bash

# 1. Modelline über cvt generieren
MODE=1920x1080_60.00
CVT_OUTPUT=$(cvt 1920 1080 60)
MODELINE=$(echo "$CVT_OUTPUT" | grep Modeline | cut -d' ' -f2-)

# 2. Framebuffer-Gesamtgröße setzen (für beide Monitore nebeneinander)
# xrandr --fb 3840x1080

# 3. Mode hinzufügen, falls nicht vorhanden
if ! xrandr | grep -q "$MODE"; then
    eval "xrandr --newmode $MODELINE"
fi
xrandr --addmode VIRTUAL1 "$MODE"

# 4. VIRTUAL1 aktivieren, rechts neben eDP1 positionieren
xrandr --output VIRTUAL1 --mode "$MODE" --pos 1920x0

# 5. Kurze Pause für Sicherheit
sleep 1

# 6. x11vnc nur auf VIRTUAL1 starten (rechte Bildschirmhälfte)
x11vnc -display :0 -clip 1920x1080+1920+0 -forever -shared
