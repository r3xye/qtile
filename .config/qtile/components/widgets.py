from libqtile import widget
from os import path
from utils.CurrentScreenImg import Test

home = path.expanduser("~")


def horizontal_widgets():
    return [
        # Test(),
        widget.GroupBox(
            highlight_method='border',
            other_current_screen_border = "ffffff",
            this_screen_border = "404040"
                        ),
        widget.CurrentLayout(),
        widget.Prompt(),
        widget.WindowName(),
        widget.Chord(
            chords_colors={
                "launch": ("#ff0000", "#ffffff"),
            },
            name_transform=lambda name: name.upper(),
        ),
        widget.KeyboardLayout(
            name="keyboardlayout",
            configured_keyboards=["us", "ru", "no"],
        ),
        widget.Clock(format="%Y-%m-%d %a %I:%M %p"),
    ]


def vertical_widgets():
    return [

        widget.Image(
        filename = home + "/.config/qtile/utils/image.png"
        ),

        widget.Clock(
            format="%H\n%M\n%p",
            rotate=False,
            fontsize=14,
            padding=8,
        ),

        widget.Spacer(),

        widget.CPU(
            rotate=False,
            format="CPU\n{load_percent}%",
            fontsize=11,
            update_interval=2,
        ),

        widget.Memory(
            rotate=False,
            format="RAM\n{MemPercent}%",
            fontsize=11,
            update_interval=2,
        ),

        widget.Battery(
            rotate=False,
            format="BAT\n{percent:2.0%}",
            fontsize=11,
            update_interval=30,
        ),

        widget.Spacer(),

        widget.CurrentLayout(
            rotate=False,
        ),

        widget.CurrentScreen(
            active_text=":)",
            inactive_text=":(",
            rotate=False,
            fontsize=24,
        ),
    ]
