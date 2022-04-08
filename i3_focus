#!/usr/bin/env python3

from i3ipct.focus import Focus
import i3ipc
import sys

if __name__ == '__main__':
  relativity = sys.argv[1] if 1 < len(sys.argv) else 'left'
  focus = Focus(i3ipc.Connection().get_tree().find_focused())
  if relativity == 'left':
    focus.left()
  elif relativity == 'right':
    focus.right()
  elif relativity == 'next_tab_or_down':
    focus.nextTabOrDown()
  elif relativity == 'prev_tab_or_up':
    focus.prevTabOrUp()
