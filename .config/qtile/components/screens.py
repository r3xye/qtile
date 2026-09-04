import os
import libqtile.resources
from libqtile import bar, widget
from libqtile.config import Screen
from .widgets import horizontal_widgets, vertical_widgets
from utils.colors import PALETTES
logo = os.path.join(
    os.path.dirname(libqtile.resources.__file__),
    "logo.png",
)


color = PALETTES["void-dark"]

def one_screen():
    return [
            Screen(
            top=bar.Bar(
                horizontal_widgets(),
                24,
                background=color["bg"],
                ),
            background="#000000",
            wallpaper=logo,
            wallpaper_mode="center",
            )
        ]

def two_screens():
    widget1= horizontal_widgets()
    widget1.insert(0, widget.CurrentScreen(fontsize=18, active_text=":)",active_color=color["green"], inactive_text=":(", inactive_color = color["red"]))

    return [
        Screen(
            top=bar.Bar(
                widget1,
                24,
                background=color["bg"],
            ),
            background="#000000",
            wallpaper=logo,
            wallpaper_mode="center",
        ), 
        Screen(
            left=bar.Bar(
                vertical_widgets(),
                42,
                background=color["bg-alt"],
            ),
            background="#000000",
            wallpaper=logo,
            wallpaper_mode="center",
        ),
    ]
