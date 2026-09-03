from libqtile.config import Key


LAYOUT_KEYS = {
    "q": ["q", "Cyrillic_shorti"],
    "w": ["w", "Cyrillic_tse"],
    "e": ["e", "Cyrillic_u"],
    "r": ["r", "Cyrillic_ka"],
    "t": ["t", "Cyrillic_ie"],
    "y": ["y", "Cyrillic_en"],
    "u": ["u", "Cyrillic_ghe"],
    "i": ["i", "Cyrillic_sha"],
    "o": ["o", "Cyrillic_shcha"],
    "p": ["p", "Cyrillic_ze"],

    "a": ["a", "Cyrillic_ef"],
    "s": ["s", "Cyrillic_yeru"],
    "d": ["d", "Cyrillic_ve"],
    "f": ["f", "Cyrillic_a"],
    "g": ["g", "Cyrillic_pe"],
    "h": ["h", "Cyrillic_er"],
    "j": ["j", "Cyrillic_o"],
    "k": ["k", "Cyrillic_el"],
    "l": ["l", "Cyrillic_de"],

    "z": ["z", "Cyrillic_ya"],
    "x": ["x", "Cyrillic_che"],
    "c": ["c", "Cyrillic_es"],
    "v": ["v", "Cyrillic_em"],
    "b": ["b", "Cyrillic_i"],
    "n": ["n", "Cyrillic_te"],
    "m": ["m", "Cyrillic_softsign"],
}


def wKey(modifiers, key, *args, **kwargs):
    key = key.lower()

    if key not in LAYOUT_KEYS:
        return [Key(modifiers, key, *args, **kwargs)]

    return [
        Key(modifiers, layout_key, *args, **kwargs)
        for layout_key in LAYOUT_KEYS[key]
    ]

#это команда чтобы возвращать масив если того требует qtile
# keys = [key for sublist in keys for key in sublist]

