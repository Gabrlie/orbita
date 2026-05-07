"""
Generate Orbita app launcher icon assets.

Two outputs are produced:

1) assets/images/orbita_icon.png            (1024x1024)
   Full-bleed icon: black background filling the canvas, with a white-line
   terminal glyph (Ionicons "terminal-outline" style) centered. Used for
   iOS / web / Windows / macOS and as the Android legacy icon.

2) assets/images/orbita_icon_foreground.png (1024x1024)
   Adaptive-icon foreground: fully transparent background with ONLY the
   white terminal glyph drawn, scaled down so it sits inside Android's
   adaptive-icon safe zone (~66/108 of the canvas). The black background
   is supplied separately via flutter_launcher_icons'
   `adaptive_icon_background` color.

Geometry: Ionicons v5 viewBox 0 0 512 512
  - rounded-rect frame at (48,96)-(464,416), radius 32, stroke 28
  - chevron polyline 144,192 -> 208,256 -> 144,320, stroke 28
  - underscore line 232,320 -> 368,320, stroke 28
This is rendered at high resolution then composited / downscaled.
"""

from PIL import Image, ImageDraw

SIZE = 1024
BLACK = (0, 0, 0, 255)
WHITE = (255, 255, 255, 255)
TRANSPARENT = (0, 0, 0, 0)


def rounded_rect_outline(draw, box, radius, width, color):
    draw.rounded_rectangle(box, radius=radius, outline=color, width=width)


def stroked_polyline(draw, points, width, color):
    r = width // 2
    for (x, y) in points:
        draw.ellipse((x - r, y - r, x + r, y + r), fill=color)
    for i in range(len(points) - 1):
        draw.line([points[i], points[i + 1]], fill=color, width=width)


def render_glyph(canvas_size: int, glyph_extent: int) -> Image.Image:
    """Render the white terminal glyph onto a transparent canvas.

    The glyph (Ionicons viewBox 0..512) is centered and scaled so its
    bounding box fits within `glyph_extent` pixels.
    """
    img = Image.new("RGBA", (canvas_size, canvas_size), TRANSPARENT)
    draw = ImageDraw.Draw(img)

    # Render at higher resolution into a temp surface then paste centered,
    # so we can control glyph size independent of canvas size.
    work_size = glyph_extent  # we treat the 512 viewBox as fitting in `glyph_extent`
    scale = work_size / 512.0

    def s(v):
        return int(round(v * scale))

    work = Image.new("RGBA", (work_size, work_size), TRANSPARENT)
    wdraw = ImageDraw.Draw(work)

    stroke = max(2, s(28))  # 28px stroke in 512-unit space

    rounded_rect_outline(
        wdraw,
        box=(s(48), s(96), s(464), s(416)),
        radius=s(32),
        width=stroke,
        color=WHITE,
    )
    stroked_polyline(
        wdraw,
        points=[(s(144), s(192)), (s(208), s(256)), (s(144), s(320))],
        width=stroke,
        color=WHITE,
    )
    stroked_polyline(
        wdraw,
        points=[(s(232), s(320)), (s(368), s(320))],
        width=stroke,
        color=WHITE,
    )

    offset = (canvas_size - work_size) // 2
    img.alpha_composite(work, dest=(offset, offset))
    return img


def main():
    # 1) Full-bleed icon: black BG + glyph spanning ~80% of canvas (matches
    # original Ionicons proportions: 416/512 ≈ 0.81).
    full = Image.new("RGBA", (SIZE, SIZE), BLACK)
    glyph_full = render_glyph(SIZE, glyph_extent=int(SIZE * 0.81))
    full.alpha_composite(glyph_full)
    full_out = "assets/images/orbita_icon.png"
    full.save(full_out, format="PNG")
    print(f"Wrote {full_out} ({SIZE}x{SIZE})")

    # 2) Adaptive foreground: transparent BG + glyph. flutter_launcher_icons
    # adds an additional 16% inset (foreground rendered at 68% of canvas),
    # which alone matches Android's ~72dp visible area. So inside the
    # foreground PNG itself we use a generous 0.88 extent — final on-screen
    # glyph ≈ 0.88 × 0.68 ≈ 60% of total adaptive icon canvas.
    fg = render_glyph(SIZE, glyph_extent=int(SIZE * 0.88))
    fg_out = "assets/images/orbita_icon_foreground.png"
    fg.save(fg_out, format="PNG")
    print(f"Wrote {fg_out} ({SIZE}x{SIZE})")


if __name__ == "__main__":
    main()
