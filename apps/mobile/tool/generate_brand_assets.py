from __future__ import annotations

from io import BytesIO
from pathlib import Path
import subprocess
import urllib.parse
from functools import lru_cache

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[3]
MOBILE = ROOT / 'apps/mobile'
ANDROID_RES = MOBILE / 'android/app/src/main/res'
IOS_ASSETS = MOBILE / 'ios/Runner/Assets.xcassets'
WINDOWS_ICON = MOBILE / 'windows/runner/resources/app_icon.ico'

BRANDING_DIR = MOBILE / 'assets/branding'
ILLUSTRATIONS_DIR = MOBILE / 'assets/illustrations'
DOCS_BRANDING = ROOT / 'docs/branding'
DOCS_EXPORTS = DOCS_BRANDING / 'exports'

ICON_SOURCE = BRANDING_DIR / 'lingstack-mark.svg'
POSTERS = [
    DOCS_BRANDING / 'store-poster-01-library.svg',
    DOCS_BRANDING / 'store-poster-02-workflows.svg',
    DOCS_BRANDING / 'store-poster-03-connect.svg',
]

ANDROID_ICON_SIZES = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

ANDROID_FOREGROUND_SIZES = {
    'mipmap-mdpi': 108,
    'mipmap-hdpi': 162,
    'mipmap-xhdpi': 216,
    'mipmap-xxhdpi': 324,
    'mipmap-xxxhdpi': 432,
}

ANDROID_SPLASH_SIZES = {
    'mipmap-mdpi': 80,
    'mipmap-hdpi': 120,
    'mipmap-xhdpi': 160,
    'mipmap-xxhdpi': 240,
    'mipmap-xxxhdpi': 320,
}

IOS_LAUNCH_SIZES = {
    'LaunchImage.png': (168, 185),
    'LaunchImage@2x.png': (336, 370),
    'LaunchImage@3x.png': (504, 555),
}

IOS_ICON_SIZES = {
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
}

BACKGROUND = '#F6F8FB'
EDGE = Path(r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe')


def svg_to_image(path: Path, width: int, height: int) -> Image.Image:
    if not EDGE.exists():
        raise RuntimeError(f'未找到 Edge：{EDGE}')

    temp_output = DOCS_EXPORTS / '.tmp-render.png'
    temp_output.parent.mkdir(parents=True, exist_ok=True)
    if temp_output.exists():
        temp_output.unlink()

    file_url = 'file:///' + urllib.parse.quote(str(path).replace('\\', '/'), safe=':/')
    command = [
        str(EDGE),
        '--headless',
        '--disable-gpu',
        '--hide-scrollbars',
        f'--window-size={width},{height}',
        f'--screenshot={temp_output}',
        file_url,
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    image = Image.open(temp_output).convert('RGBA')
    temp_output.unlink(missing_ok=True)
    return image


@lru_cache(maxsize=1)
def _base_icon() -> Image.Image:
    return svg_to_image(ICON_SOURCE, 1024, 1024)


def render_square_icon(size: int) -> Image.Image:
    if size == 1024:
        return _base_icon().copy()
    return _base_icon().resize((size, size), Image.Resampling.LANCZOS)


def _rounded_mask(size: int, radius: int | None = None) -> Image.Image:
    radius = radius or int(size * 0.24)
    mask = Image.new('L', (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size, size), radius=radius, fill=255)
    return mask


def _vertical_gradient(size: int, top_color: tuple[int, int, int], bottom_color: tuple[int, int, int]) -> Image.Image:
    image = Image.new('RGBA', (size, size))
    pixels = image.load()
    for y in range(size):
        ratio = y / max(size - 1, 1)
        color = tuple(
            int(top + (bottom - top) * ratio)
            for top, bottom in zip(top_color, bottom_color)
        )
        for x in range(size):
            pixels[x, y] = (*color, 255)
    return image


def _draw_launcher_glyph(size: int, color: tuple[int, int, int, int]) -> Image.Image:
    glyph = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(glyph)
    width = size
    height = size
    card_radius = int(size * 0.085)
    left = (int(width * 0.24), int(height * 0.28), int(width * 0.44), int(height * 0.72))
    top_right = (int(width * 0.53), int(height * 0.28), int(width * 0.79), int(height * 0.45))
    bottom_right = (int(width * 0.53), int(height * 0.50), int(width * 0.79), int(height * 0.72))
    for rect in (left, top_right, bottom_right):
        draw.rounded_rectangle(rect, radius=card_radius, fill=color)
    return glyph


def render_launcher_icon(size: int) -> Image.Image:
    background = _vertical_gradient(size, (68, 96, 255), (107, 124, 255))
    glow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse(
        (
            int(size * 0.06),
            int(size * 0.02),
            int(size * 0.60),
            int(size * 0.56),
        ),
        fill=(255, 255, 255, 54),
    )
    background.alpha_composite(glow)

    border = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    border_draw = ImageDraw.Draw(border)
    border_draw.rounded_rectangle(
        (1, 1, size - 2, size - 2),
        radius=int(size * 0.24),
        outline=(255, 255, 255, 48),
        width=max(1, size // 128),
    )
    background.alpha_composite(border)

    glyph = _draw_launcher_glyph(size, (255, 255, 255, 255))
    shadow = _draw_launcher_glyph(size, (31, 42, 120, 48))
    background.alpha_composite(shadow, (0, int(size * 0.02)))
    background.alpha_composite(glyph)

    masked = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    masked.paste(background, (0, 0), _rounded_mask(size))
    return masked


def render_launcher_foreground(size: int) -> Image.Image:
    foreground = _draw_launcher_glyph(size, (255, 255, 255, 255))
    highlight = _draw_launcher_glyph(size, (255, 255, 255, 30))
    foreground.alpha_composite(highlight, (0, -max(1, size // 72)))
    return foreground


def render_launcher_monochrome(size: int) -> Image.Image:
    return _draw_launcher_glyph(size, (17, 24, 39, 255))


def render_launch_badge(canvas_width: int, canvas_height: int) -> Image.Image:
    canvas = Image.new('RGBA', (canvas_width, canvas_height), (246, 248, 251, 255))
    badge_size = int(min(canvas_width, canvas_height) * 0.72)
    badge = render_square_icon(badge_size)
    left = (canvas_width - badge.width) // 2
    top = (canvas_height - badge.height) // 2
    canvas.alpha_composite(badge, (left, top))
    return canvas


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format='PNG')


def build_android_icons() -> None:
    for folder, size in ANDROID_ICON_SIZES.items():
        save_png(
            render_launcher_icon(size),
            ANDROID_RES / folder / 'ic_launcher.png',
        )
        save_png(
            render_launcher_icon(size),
            ANDROID_RES / folder / 'ic_launcher_round.png',
        )
    for folder, size in ANDROID_FOREGROUND_SIZES.items():
        save_png(
            render_launcher_foreground(size),
            ANDROID_RES / folder / 'ic_launcher_foreground.png',
        )
        save_png(
            render_launcher_monochrome(size),
            ANDROID_RES / folder / 'ic_launcher_monochrome.png',
        )
    for folder, size in ANDROID_SPLASH_SIZES.items():
        save_png(
            render_launch_badge(size, size),
            ANDROID_RES / folder / 'launch_image.png',
        )


def build_ios_icons() -> None:
    app_icon_dir = IOS_ASSETS / 'AppIcon.appiconset'
    for filename, size in IOS_ICON_SIZES.items():
        save_png(render_square_icon(size), app_icon_dir / filename)

    launch_dir = IOS_ASSETS / 'LaunchImage.imageset'
    for filename, (width, height) in IOS_LAUNCH_SIZES.items():
        save_png(render_launch_badge(width, height), launch_dir / filename)


def build_windows_icon() -> None:
    icon_1024 = render_square_icon(1024)
    WINDOWS_ICON.parent.mkdir(parents=True, exist_ok=True)
    icon_1024.save(
        WINDOWS_ICON,
        format='ICO',
        sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)],
    )


def build_brand_exports() -> None:
    DOCS_EXPORTS.mkdir(parents=True, exist_ok=True)
    save_png(render_launcher_icon(1024), DOCS_EXPORTS / 'lingstack-icon-1024.png')
    save_png(render_launch_badge(1440, 3120), DOCS_EXPORTS / 'launch-preview.png')
    save_png(svg_to_image(ILLUSTRATIONS_DIR / 'hero-orbit.svg', 1600, 1066), DOCS_EXPORTS / 'hero-orbit-preview.png')

    for poster in POSTERS:
        output_name = f'{poster.stem}.png'
        save_png(svg_to_image(poster, 1242, 2688), DOCS_EXPORTS / output_name)


def main() -> None:
    build_android_icons()
    build_ios_icons()
    build_windows_icon()
    build_brand_exports()
    print('Generated brand assets for Android, iOS, Windows, and store exports.')


if __name__ == '__main__':
    main()
