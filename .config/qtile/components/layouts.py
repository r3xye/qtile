from libqtile import layout
from libqtile.config import  Match
from utils.colors import PALETTES


color = PALETTES["void-dark"]

layouts = [
    layout.Columns(name = "[]=",
                   border_focus=color["border"],
                   border_normal=color["surface"],
                   border_width=5),
    layout.Max(),
]

floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
