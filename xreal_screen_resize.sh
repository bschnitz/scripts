top=0
bottom=200
left=200
right=0
maxres=$(xrandr -q | awk '/^DP-1 / {getline; print $1}')
maxheight=${maxres#*x}
maxwidth=${maxres%x*}
modename="XREAL"

width=$(( maxwidth - (left + right) ))
height=$(( maxheight - (top + bottom) ))
wh=${width}x$height

modeline=$(cvt $width $height | tail -1 | awk '{for (i=3; i<=NF; i++) printf $i " "; print ""}')
echo $modename
echo $modeline
echo $wh
xrandr --output DP-1 --auto
xrandr --output eDP-1 --auto
xrandr --delmode DP-1 $modename
xrandr --delmode eDP-1 $modename
xrandr --rmmode $modename
xrandr --newmode $modename $modeline
xrandr --addmode DP-1 $modename
xrandr --addmode eDP-1 $modename
xrandr --output eDP-1 --fb $wh --panning $wh --mode $modename
#xrandr --fb  $wh --output eDP-1 --mode $maxres
