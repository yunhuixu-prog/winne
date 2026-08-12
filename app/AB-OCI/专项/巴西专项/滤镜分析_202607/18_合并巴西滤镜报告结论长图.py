#!/usr/bin/env python3
"""将 5 张巴西滤镜结论图纵向拼接为一张高清长图。"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path("/Users/xuyunhui/Documents/项目")
OUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西滤镜分析_202607"
FILES = [
    "11A_结论1_巴西素材偏好与收入集中.png",
    "11B_结论2_前两屏与选择成本.png",
    "11C_结论3_D1复用与潜力素材.png",
    "11D_结论4_平台与生命周期差异.png",
    "11E_结论5_滑杆默认强度机会.png",
]
TARGET = OUT / "11_巴西专项_滤镜分析结论长图.png"

BG = (243, 246, 250)
INK = (24, 34, 53)
MUTED = (127, 141, 163)
BRAZIL = (233, 78, 66)


def font(size, bold=False):
    candidates = [
        "/System/Library/Fonts/PingFang.ttc",
        "/System/Library/Fonts/STHeiti Medium.ttc" if bold else "/System/Library/Fonts/STHeiti Light.ttc",
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
    ]
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size=size, index=1 if bold and path.endswith(".ttc") else 0)
    return ImageFont.load_default()


def main():
    images = [Image.open(OUT / name).convert("RGB") for name in FILES]
    width = max(im.width for im in images)
    header_h = 300
    separator_h = 38
    footer_h = 95
    total_h = header_h + sum(im.height for im in images) + separator_h * (len(images) - 1) + footer_h

    canvas = Image.new("RGB", (width, total_h), BG)
    draw = ImageDraw.Draw(canvas)

    # 总标题
    draw.rounded_rectangle((48, 54, 198, 116), radius=20, fill=BRAZIL)
    draw.text((123, 85), "FILTERS", fill="white", font=font(28, bold=True), anchor="mm")
    draw.text((48, 152), "巴西专项｜滤镜分析结论总览", fill=INK, font=font(54, bold=True))
    draw.text(
        (50, 230),
        "素材偏好与收入结构 · 选择效率 · D1复用 · 平台与生命周期 · 滑杆强度",
        fill=MUTED,
        font=font(28),
    )

    y = header_h
    for idx, im in enumerate(images):
        if im.width != width:
            new_h = round(im.height * width / im.width)
            im = im.resize((width, new_h), Image.Resampling.LANCZOS)
        canvas.paste(im, (0, y))
        y += im.height
        if idx < len(images) - 1:
            draw.rectangle((0, y, width, y + separator_h), fill=BG)
            draw.line((70, y + separator_h // 2, width - 70, y + separator_h // 2), fill=(220, 227, 236), width=2)
            y += separator_h

    draw.text(
        (width // 2, total_h - 48),
        "数据周期：2026年7月（选择深度为2026/7/29–8/4）｜数据源：AirBrush 素材看板与 Filters 会话数据",
        fill=MUTED,
        font=font(22),
        anchor="mm",
    )

    canvas.save(TARGET, quality=95, optimize=True)
    print(TARGET)
    print(canvas.size)


if __name__ == "__main__":
    main()
