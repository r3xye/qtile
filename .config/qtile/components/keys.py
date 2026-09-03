from libqtile.lazy import lazy
from libqtile import qtile
from libqtile.config import Click, Drag, Group


from utils.wkey import wKey


mod = "mod4"
terminal = "alacritty"


keys = [
    wKey(
        [mod, "shift"],
        "s",
        lazy.spawn("sh -c 'grim -g \"$(slurp)\" - | wl-copy'"),
        desc="Screenshot",
    ),
        
    wKey([mod], "q", lazy.next_screen()),
    wKey([mod], "e", lazy.prev_screen()),
    wKey([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    wKey([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    wKey([mod], "j", lazy.layout.down(), desc="Move focus down"),
    wKey([mod], "k", lazy.layout.up(), desc="Move focus up"),
    wKey([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    wKey([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    wKey([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    wKey([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    wKey([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    wKey([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    wKey([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    wKey([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    wKey([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    wKey(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    wKey([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    wKey([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    wKey([mod], "c", lazy.window.kill(), desc="Kill focused window"),
    wKey(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    wKey([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    wKey([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    wKey([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    wKey([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    wKey([mod],"space", lazy.widget["keyboardlayout"].next_keyboard(), desc="Next keyboard layout."),
]

for vt in range(1, 8):
    keys.append(
        wKey(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend(
        [
            wKey(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            wKey([mod, "shift"], i.name, lazy.window.togroup(i.name),
                desc="move focused window to group {}".format(i.name)),
        ]
    )
keys = [key for sublist in keys for key in sublist]

mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]
