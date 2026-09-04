from libqtile import widget
from os import path
from utils.CurrentScreenImg import Test
from utils.colors import PALETTES

home = path.expanduser("~")
color = PALETTES["void-dark"]

def horizontal_widgets():
    return [
        # Test(),
        widget.GroupBox(
            foreground = color["fg"],
            highlight_method='border',
            other_current_screen_border = color["accent-soft"],
            other_screen_border = color["selection"],

            this_current_screen_border = color["accent"],
            this_screen_border = color["border"]
                        ),
        widget.CurrentLayout(
            foreground = color["fg-alt"],
            ),
        widget.Prompt(
            foreground = color["fg-alt"],
            ),
        widget.WindowName(
            foreground = color["fg"],

            ),
        widget.Chord(
            chords_colors={
                "launch": ("#ff0000", "#ffffff"),
            },
            name_transform=lambda name: name.upper(),
        ),
        widget.KeyboardLayout(
            foreground = color["fg"],
            name="keyboardlayout",
            configured_keyboards=["us", "ru", "no"],
        ),
        widget.Clock(format="%Y-%m-%d %a %I:%M %p",
                    foreground = color["fg"],
                     ),
    ]


def vertical_widgets():
    return [

        widget.Image(
        filename = home + "/.config/qtile/utils/image.png"
        ),

        widget.Clock(
            # foreground = color["fg"],
            foreground = color["fg-alt"],
            format="%H\n%M\n%p",
            rotate=False,
            fontsize=14,
            padding=8,
        ),

        widget.Spacer(),

        widget.CPU(
            foreground = color["fg-alt"],
            rotate=False,
            format="CPU\n{load_percent}%",
            fontsize=11,
            update_interval=2,
        ),

        widget.Memory(
            foreground = color["fg-alt"],
            rotate=False,
            format="RAM\n{MemPercent}%",
            fontsize=11,
            update_interval=2,
        ),

        widget.Battery(
            foreground = color["fg-alt"],
            rotate=False,
            format="BAT\n{percent:2.0%}",
            fontsize=11,
            update_interval=30,
        ),

        widget.Spacer(),

        widget.CurrentLayout(
            foreground = color["fg-alt"],
            rotate=False,
        ),

        widget.CurrentScreen(
            active_text=":)",
            active_color=color["green"],
            inactive_text=":(",
            inactive_color=color["red"],
            rotate=False,
            fontsize=24,
        ),
    ]
