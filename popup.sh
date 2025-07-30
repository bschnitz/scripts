#!/bin/bash

# Bildschirmauflösung
screenWidth=$(xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f1)
screenHeight=$(xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f2)

# Fenstergröße
windowWidth=400
windowHeight=200

# Position berechnen
posX=$(( (screenWidth - windowWidth) / 2 ))
posY=$(( (screenHeight - windowHeight) / 2 ))

# Text mit \n statt <br>
text="<span weight='bold'>\nAchtung\n</span>"

# Popup anzeigen
yad --form \
    --title="Floating Popup" \
    --field="$text":LBL "" \
    --center \
    --text-align=center \
    --align=center \
    --width=$windowWidth \
    --height=$windowHeight \
    --on-top \
    --skip-taskbar \
    --posx=$posX \
    --posy=$posY \
    --button="Schließen":0 \
    --center \
    --no-focus \
    --window-icon="" \
    --gtkrc=/dev/null
