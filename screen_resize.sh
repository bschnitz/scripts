top=0
bottom=230
left=0
right=0
maxres=$(xrandr -q | awk '/^eDP-1 / {getline; print $1}')
maxheight=${maxres#*x}
maxwidth=${maxres%x*}
modename="XREAL"

width=$(( maxwidth - (left + right) ))
height=$(( maxheight - (top + bottom) ))
wh=${width}x$height

echo $width/172x$height/193+0+0 none
xrandr --delmonitor SMALLER
xrandr --setmonitor SMALLER $width/172x$height/193+0+0 none
xrandr --output eDP-1 --transform "1,0,-$left,0,1,-$top,0,0,1"
