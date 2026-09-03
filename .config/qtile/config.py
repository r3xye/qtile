import os
import subprocess
from collections.abc import Callable

from libqtile import  hook
from libqtile.config import Output, Screen
from libqtile.backend.wayland.inputs import InputConfig

from components.screens import one_screen, two_screens
from components.keys import keys, mouse
from components.layouts import layouts, floating_layout

from scripts.monitors import amount_of_monitors

@hook.subscribe.startup
def startup():
    home = os.path.expanduser('~/.config/qtile/scripts/startup.sh')
    subprocess.call(home)

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/scripts/autostart.sh')
    subprocess.call(home)

monitors = amount_of_monitors()
match monitors:
  case 1:
      screens = one_screen()
  case 2:
      screens = two_screens()

  case _: 
      screens = one_screen()

fake_screens: list[Screen] | None = None

generate_screens: Callable[[list[Output]], list[Screen]] | None = None


dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = True
auto_fullscreen = True
focus_on_window_activation = "smart"
focus_previous_on_window_remove = False
<<<<<<< HEAD
reconfigure_screens = True
=======
reconfigure_screens = False
>>>>>>> 84cfeaa (beta colors)

auto_minimize = True

wl_input_rules = {
    "type:keyboard": InputConfig(
        kb_layout="us,ru,no",
        # xkb_option="grab:break_action"
    )
}


wl_xcursor_theme = None
wl_xcursor_size = 24

idle_timers = []  # type: list
idle_inhibitors = []  # type: list

wmname = "LG3D"
