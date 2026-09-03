import os
import libqtile.resources
from libqtile import bar, widget
from libqtile.config import Screen
from .widgets import horizontal_widgets, vertical_widgets

logo = os.path.join(
    os.path.dirname(libqtile.resources.__file__),
    "logo.png",
)


def one_screen():
    return [
            Screen(
            top=bar.Bar(
                horizontal_widgets(),
                24,
                ),
            background="#000000",
            wallpaper=logo,
            wallpaper_mode="center",
            )
        ]

def two_screens():
    widget1= horizontal_widgets()
    widget1.insert(0, widget.CurrentScreen(fontsize=18, active_text=":)", inactive_text=":("))
    return [
        Screen(
            top=bar.Bar(
                widget1,
                24,
            ),
            background="#000000",
            wallpaper=logo,
            wallpaper_mode="center",
        ), 
        Screen(
            left=bar.Bar(
                vertical_widgets(),
                42,
            ),
            background="#000000",
            wallpaper=logo,
            wallpaper_mode="center",
        ),
    ]
