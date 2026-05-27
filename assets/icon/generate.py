"""Generate One Cred app icons."""

from PIL import Image, ImageDraw, ImageFilter
from pathlib import Path

OUT = Path(__file__).resolve().parent

SIZE = 1024

# Brand palette
BG_DARK_TOP = (16, 16, 26, 255)
BG_DARK_BOTTOM = (6, 6, 12, 255)
CYAN = (0, 229, 255, 255)
MAGENTA = (255, 46, 151, 255)
LIME = (181, 255, 61, 255)


def diagonal_gradient(size, c1, c2):
    img = Image.new("RGBA", (size, size), 0)
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = (x * 0.4 + y * 0.6) / (size - 1)
            t = max(0, min(1, t))
            r = int(c1[0] * (1 - t) + c2[0] * t)
            g = int(c1[1] * (1 - t) + c2[1] * t)
            b = int(c1[2] * (1 - t) + c2[2] * t)
            px[x, y] = (r, g, b, 255)
    return img


def vertical_gradient(size, top, bottom):
    img = Image.new("RGBA", (size, size), 0)
    px = img.load()
    for y in range(size):
        t = y / (size - 1)
        r = int(top[0] * (1 - t) + bottom[0] * t)
        g = int(top[1] * (1 - t) + bottom[1] * t)
        b = int(top[2] * (1 - t) + bottom[2] * t)
        for x in range(size):
            px[x, y] = (r, g, b, 255)
    return img


def rounded_mask(size, radius):
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle((0, 0, size, size), radius=radius, fill=255)
    return mask


FONT_CANDIDATES = [
    "/System/Library/Fonts/Supplemental/Arial Black.ttf",
    "/Library/Fonts/Arial Black.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
]


def _load_bold_font(target_height: int):
    from PIL import ImageFont
    for path in FONT_CANDIDATES:
        if Path(path).exists():
            try:
                return ImageFont.truetype(path, int(target_height))
            except Exception:
                continue
    return ImageFont.load_default()


def draw_geo_one(size):
    """Render '1' with a heavy font then paint with the brand gradient.

    Using a real typeface (Arial Black) makes the digit instantly readable at
    every size. We mask the glyph and fill it with a cyan→magenta gradient.
    """
    from PIL import ImageFont

    # Aim for a 1 that fills ~80% of the canvas height.
    font = _load_bold_font(int(size * 0.95))

    # Render the glyph onto a transparent mask, then position-correct it.
    text = "1"
    # Probe size & offset
    tmp = Image.new("L", (size, size), 0)
    td = ImageDraw.Draw(tmp)
    bbox = td.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]

    # Place centred (with a tiny vertical nudge — text bbox includes ascent).
    x = (size - tw) // 2 - bbox[0]
    y = (size - th) // 2 - bbox[1]

    mask = Image.new("L", (size, size), 0)
    md = ImageDraw.Draw(mask)
    md.text((x, y), text, fill=255, font=font)

    # Softly anti-alias edges so the gradient looks smooth.
    mask_blur = mask.filter(ImageFilter.GaussianBlur(size / 800))

    grad = diagonal_gradient(size, CYAN, MAGENTA)
    out = Image.new("RGBA", (size, size), 0)
    out.paste(grad, (0, 0), mask_blur)
    return out, mask


def make_icons():
    # ---------- main icon ----------
    canvas = Image.new("RGBA", (SIZE, SIZE), 0)

    bg = vertical_gradient(SIZE, BG_DARK_TOP, BG_DARK_BOTTOM)

    # Subtle radial glow (cyan/magenta blend) behind the digit
    glow = Image.new("RGBA", (SIZE, SIZE), 0)
    gd = ImageDraw.Draw(glow)
    gd.ellipse(
        (SIZE * 0.10, SIZE * 0.10, SIZE * 0.90, SIZE * 0.90),
        fill=(0, 100, 140, 80),
    )
    gd.ellipse(
        (SIZE * 0.45, SIZE * 0.45, SIZE * 0.95, SIZE * 0.95),
        fill=(120, 30, 90, 60),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(SIZE // 8))
    bg.alpha_composite(glow)

    canvas.alpha_composite(bg)

    # The "1"
    one, _ = draw_geo_one(SIZE)
    # Glow halo (blurred copy below)
    halo = one.filter(ImageFilter.GaussianBlur(SIZE // 28))
    canvas.alpha_composite(halo)
    canvas.alpha_composite(one)

    # Rounded square mask (iOS / general)
    radius = int(SIZE * 0.22)
    mask = rounded_mask(SIZE, radius)
    rounded = Image.new("RGBA", (SIZE, SIZE), 0)
    rounded.paste(canvas, (0, 0), mask)
    rounded.save(OUT / "icon.png", "PNG")

    # Full square
    canvas.save(OUT / "icon_square.png", "PNG")

    # Adaptive foreground (transparent bg + safe area padding)
    fg = Image.new("RGBA", (SIZE, SIZE), 0)
    pad = int(SIZE * 0.18)
    inner = SIZE - 2 * pad
    one_inner, _ = draw_geo_one(inner)
    fg.alpha_composite(
        one_inner.filter(ImageFilter.GaussianBlur(inner // 28)), (pad, pad))
    fg.alpha_composite(one_inner, (pad, pad))
    fg.save(OUT / "icon_foreground.png", "PNG")

    # Adaptive bg solid
    bg_only = Image.new("RGBA", (SIZE, SIZE), BG_DARK_BOTTOM)
    bg_only.save(OUT / "icon_background.png", "PNG")

    for n in ("icon.png", "icon_square.png", "icon_foreground.png",
              "icon_background.png"):
        print("wrote:", OUT / n)


if __name__ == "__main__":
    make_icons()
