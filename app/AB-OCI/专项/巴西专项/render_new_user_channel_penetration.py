#!/usr/bin/env python3
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


SOURCE = Path(__file__).with_name("巴西专项_功能渗透率_自然渠道新用户_202606.json")
OUTPUT_DIR = Path("/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302")
FONT_PATH = "/System/Library/Fonts/PingFang.ttc"
DISPLAY_MARKETS = ["整体", "巴西", "美国", "英国", "墨西哥"]
RANK_MARKETS = ["巴西", "美国", "英国", "墨西哥"]
COLORS = {
    "bg": "#F3F5F9", "card": "#FFFFFF", "text": "#182230", "muted": "#7B8798",
    "line": "#E5E9F0", "header": "#F7F8FA", "brazil_dark": "#9A5A08",
    "brazil_soft": "#FFF6E8", "ahead": "#C93532", "behind": "#27835D",
}


def font(size):
    return ImageFont.truetype(FONT_PATH, size=size)


FONTS = {
    "title": font(46), "subtitle": font(25), "header": font(27), "header_sub": font(19),
    "feature": font(25), "value": font(23), "footnote": font(18),
}


def draw_shadow(base, box, radius=24):
    shadow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    x1, y1, x2, y2 = box
    sd.rounded_rectangle((x1, y1 + 8, x2, y2 + 8), radius=radius, fill=(30, 41, 59, 18))
    base.alpha_composite(shadow)


def render(segment_cn):
    payload = json.loads(SOURCE.read_text(encoding="utf-8"))
    rows = [r for r in payload["rows"] if r["用户类型"] == segment_cn]
    top_rows, rank_maps, value_maps = {}, {}, {}
    for market in DISPLAY_MARKETS:
        market_rows = [r for r in rows if r["国家维度"] == market]
        market_rows.sort(key=lambda r: (-float(r["进入渗透率"]), r["功能"]))
        top_rows[market] = market_rows[:20]
        rank_maps[market] = {r["功能"]: i + 1 for i, r in enumerate(market_rows)}
        value_maps[market] = {r["功能"]: float(r["进入渗透率"]) for r in market_rows}

    width, margin, top = 2820, 48, 184
    header_h, row_h, foot_h = 100, 68, 68
    card_h = header_h + row_h * 20 + foot_h
    height = top + card_h + 48
    image = Image.new("RGBA", (width, height), COLORS["bg"])
    draw = ImageDraw.Draw(image)

    draw.text((margin, 34), f"{segment_cn}｜各国功能进入渗透率 Top 20", font=FONTS["title"], fill=COLORS["text"])
    draw.text((margin, 100), f"每列按该市场的{segment_cn}进入渗透率排序；括号内为2026年6月日均渗透率。", font=FONTS["subtitle"], fill=COLORS["muted"])
    legend_x = width - 910
    draw.ellipse((legend_x, 108, legend_x + 16, 124), fill=COLORS["ahead"])
    draw.text((legend_x + 26, 100), "明显靠前", font=FONTS["header_sub"], fill=COLORS["text"])
    draw.ellipse((legend_x + 185, 108, legend_x + 201, 124), fill=COLORS["behind"])
    draw.text((legend_x + 211, 100), "明显靠后", font=FONTS["header_sub"], fill=COLORS["text"])
    draw.text((legend_x + 375, 100), "整体值差 >2pp + 三国排名复核｜Top10 ±2 / 其余 ±3", font=FONTS["header_sub"], fill=COLORS["muted"])

    card = (margin, top, width - margin, top + card_h)
    draw_shadow(image, card)
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle(card, radius=26, fill=COLORS["card"])
    inner_x, inner_w = margin + 28, width - 2 * margin - 56
    col_w = inner_w / 5
    body_y, footer_y = top + header_h, top + card_h - foot_h

    for j, market in enumerate(DISPLAY_MARKETS):
        x1, x2 = inner_x + j * col_w, inner_x + (j + 1) * col_w
        draw.rectangle((x1, top, x2, body_y), fill="#FDE8C8" if market == "巴西" else COLORS["header"])
        if market == "巴西":
            draw.rectangle((x1, body_y, x2, footer_y), fill=COLORS["brazil_soft"])
        draw.text((x1 + 28, top + 19), market, font=FONTS["header"], fill=COLORS["brazil_dark"] if market == "巴西" else COLORS["text"])
        draw.text((x1 + 28, top + 60), f"按{segment_cn}渗透率降序", font=FONTS["header_sub"], fill=COLORS["muted"])
        if j:
            draw.line((x1, top, x1, footer_y), fill=COLORS["line"], width=2)

    draw.line((inner_x, body_y, inner_x + inner_w, body_y), fill=COLORS["line"], width=2)
    for i in range(20):
        y1 = body_y + i * row_h
        if i:
            draw.line((inner_x, y1, inner_x + inner_w, y1), fill=COLORS["line"], width=1)
        for j, market in enumerate(DISPLAY_MARKETS):
            row = top_rows[market][i]
            feature, value = row["功能"], float(row["进入渗透率"])
            accent = None
            value_color = COLORS["text"]
            if market != "整体":
                rank = rank_maps[market][feature]
                value_gap = value - value_maps["整体"][feature]
                peer_avg = sum(rank_maps[m][feature] for m in RANK_MARKETS if m != market) / 3
                peer_gap = peer_avg - rank
                rank_threshold = 2 if peer_avg <= 10 else 3
                if value_gap > 0.02 and peer_gap >= rank_threshold:
                    accent = value_color = COLORS["ahead"]
                elif value_gap < -0.02 and peer_gap <= -rank_threshold:
                    accent = value_color = COLORS["behind"]
            x1 = inner_x + j * col_w
            draw.text((x1 + 28, y1 + 19), f"{i + 1:02d}", font=FONTS["value"], fill=COLORS["muted"])
            if accent:
                draw.rounded_rectangle((x1 + 76, y1 + 20, x1 + 82, y1 + 48), radius=3, fill=accent)
            draw.text((x1 + 96, y1 + 17), f"{feature}（{value * 100:.1f}%）", font=FONTS["feature"], fill=value_color)

    draw.line((inner_x, footer_y, inner_x + inner_w, footer_y), fill=COLORS["line"], width=2)
    note = "整体列不标色。先与整体渗透率比较，差值须超过 2 个百分点；再与其余三国平均排名复核：平均排名 Top10 阈值 2 位、其余 3 位。两项同方向满足才标色。"
    draw.text((inner_x + 16, footer_y + 21), note, font=FONTS["footnote"], fill=COLORS["muted"])
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output = OUTPUT_DIR / f"巴西专项_{segment_cn}功能进入渗透率对比.png"
    image.convert("RGB").save(output, quality=95)
    return output


if __name__ == "__main__":
    for segment in ("自然新用户", "渠道新用户"):
        print(render(segment))
