#!/usr/bin/env python3
import json
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


SOURCE = Path("/Users/xuyunhui/Documents/项目/app/AB-OCI/专项/巴西专项/巴西专项_功能数据_202606.json")
OUTPUT_DIR = Path("/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302")
FONT_PATH = "/System/Library/Fonts/PingFang.ttc"

MARKETS = ["巴西", "整体", "美国", "英国", "墨西哥"]
RANK_MARKETS = ["巴西", "美国", "英国", "墨西哥"]
COLORS = {
    "bg": "#F3F5F9",
    "card": "#FFFFFF",
    "text": "#182230",
    "muted": "#7B8798",
    "line": "#E5E9F0",
    "header": "#F7F8FA",
    "brazil": "#D97706",
    "brazil_dark": "#9A5A08",
    "brazil_soft": "#FFF6E8",
    "other": "#9AA5B5",
    "other_dark": "#667085",
    "track": "#E9EDF3",
    "positive": "#3451B2",
    "negative": "#8A94A4",
    "ahead": "#C93532",
    "behind": "#27835D",
}


def font(size):
    return ImageFont.truetype(FONT_PATH, size=size)


FONTS = {
    "title": font(46),
    "subtitle": font(25),
    "header": font(27),
    "header_sub": font(19),
    "feature": font(25),
    "value": font(23),
    "delta": font(17),
    "footnote": font(18),
}


def rounded_bar(draw, xy, fill, radius=7):
    draw.rounded_rectangle(xy, radius=radius, fill=fill)


def draw_shadow(base, box, radius=24):
    shadow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    x1, y1, x2, y2 = box
    sd.rounded_rectangle((x1, y1 + 8, x2, y2 + 8), radius=radius, fill=(30, 41, 59, 18))
    base.alpha_composite(shadow)


def fmt_delta(metric, value, brazil):
    diff = value - brazil
    if metric == "penetration":
        return f"{diff * 100:+.1f}pp"
    return f"{diff:+.1f}"


def render_rank_columns(metric):
    payload = json.loads(SOURCE.read_text(encoding="utf-8"))
    rows = payload["rows"]
    is_penetration = metric == "penetration"
    key = "进入渗透率" if is_penetration else "订阅收入（分成后）"
    title = "各国功能进入渗透率 Top 20" if is_penetration else "各国功能订阅毛利 Top 20"
    subtitle = (
        "每列按该国自己的进入渗透率排序；括号内为具体渗透率。"
        if is_penetration
        else "每列按该国自己的订阅毛利排序；括号内为毛利及其占该市场全部功能毛利的比例，Skin 子功能使用归因 L4。"
    )
    sort_label = "按本国渗透率降序" if is_penetration else "按本国订阅毛利降序"
    display_markets = ["整体", "巴西", "美国", "英国", "墨西哥"]
    top_rows = {}
    rank_maps = {}
    market_totals = {}
    for market in display_markets:
        market_rows = [r for r in rows if r["国家维度"] == market]
        market_rows.sort(key=lambda r: (-float(r[key]), r["功能"]))
        top_rows[market] = market_rows[:20]
        rank_maps[market] = {r["功能"]: i + 1 for i, r in enumerate(market_rows)}
        market_totals[market] = sum(float(r[key]) for r in market_rows)

    width = 2820
    margin = 48
    top = 184
    header_h = 100
    row_h = 68
    foot_h = 68
    card_h = header_h + row_h * 20 + foot_h
    height = top + card_h + 48
    image = Image.new("RGBA", (width, height), COLORS["bg"])
    draw = ImageDraw.Draw(image)

    draw.text((margin, 34), title, font=FONTS["title"], fill=COLORS["text"])
    draw.text((margin, 100), subtitle, font=FONTS["subtitle"], fill=COLORS["muted"])
    legend_x = width - 910
    draw.ellipse((legend_x, 108, legend_x + 16, 124), fill=COLORS["ahead"])
    draw.text((legend_x + 26, 100), "明显靠前", font=FONTS["header_sub"], fill=COLORS["text"])
    draw.ellipse((legend_x + 185, 108, legend_x + 201, 124), fill=COLORS["behind"])
    draw.text((legend_x + 211, 100), "明显靠后", font=FONTS["header_sub"], fill=COLORS["text"])
    draw.text((legend_x + 375, 100), "整体优先 + 三国复核｜Top10 ±2 / 其余 ±3", font=FONTS["header_sub"], fill=COLORS["muted"])

    card = (margin, top, width - margin, top + card_h)
    draw_shadow(image, card)
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle(card, radius=26, fill=COLORS["card"])

    inner_x = margin + 28
    inner_w = width - 2 * margin - 56
    col_w = inner_w / 5
    body_y = top + header_h
    footer_y = top + card_h - foot_h

    for j, market in enumerate(display_markets):
        x1 = inner_x + j * col_w
        x2 = x1 + col_w
        header_fill = "#FDE8C8" if market == "巴西" else COLORS["header"]
        draw.rectangle((x1, top, x2, body_y), fill=header_fill)
        if market == "巴西":
            draw.rectangle((x1, body_y, x2, footer_y), fill=COLORS["brazil_soft"])
        header_color = COLORS["brazil_dark"] if market == "巴西" else COLORS["text"]
        draw.text((x1 + 28, top + 19), market, font=FONTS["header"], fill=header_color)
        draw.text((x1 + 28, top + 60), sort_label, font=FONTS["header_sub"], fill=COLORS["muted"])
        if j > 0:
            draw.line((x1, top, x1, footer_y), fill=COLORS["line"], width=2)

    draw.line((inner_x, body_y, inner_x + inner_w, body_y), fill=COLORS["line"], width=2)
    for i in range(20):
        y1 = body_y + i * row_h
        if i > 0:
            draw.line((inner_x, y1, inner_x + inner_w, y1), fill=COLORS["line"], width=1)
        for j, market in enumerate(display_markets):
            row = top_rows[market][i]
            feature = row["功能"]
            value = float(row[key])
            if market == "整体":
                value_color = COLORS["text"]
                accent = None
            else:
                rank = rank_maps[market][feature]
                overall_gap = rank_maps["整体"][feature] - rank
                peer_avg = sum(rank_maps[m][feature] for m in RANK_MARKETS if m != market) / 3
                peer_gap = peer_avg - rank
                overall_threshold = 2 if rank <= 10 else 3
                peer_threshold = 2 if peer_avg <= 10 else 3
                if overall_gap >= overall_threshold and peer_gap >= peer_threshold:
                    value_color = COLORS["ahead"]
                    accent = COLORS["ahead"]
                elif overall_gap <= -overall_threshold and peer_gap <= -peer_threshold:
                    value_color = COLORS["behind"]
                    accent = COLORS["behind"]
                else:
                    value_color = COLORS["text"]
                    accent = None

            x1 = inner_x + j * col_w
            rank_text = f"{i + 1:02d}"
            draw.text((x1 + 28, y1 + 19), rank_text, font=FONTS["value"], fill=COLORS["muted"])
            if accent:
                draw.rounded_rectangle((x1 + 76, y1 + 20, x1 + 82, y1 + 48), radius=3, fill=accent)
            label_x = x1 + 96
            if is_penetration:
                display_value = f"{value * 100:.1f}%"
            else:
                share = value / market_totals[market] if market_totals[market] else 0
                display_value = f"${value / 1000:.1f}k，{share * 100:.1f}%"
            label = f"{feature}（{display_value}）"
            draw.text((label_x, y1 + 17), label, font=FONTS["feature"], fill=value_color)

    draw.line((inner_x, footer_y, inner_x + inner_w, footer_y), fill=COLORS["line"], width=2)
    note = "整体列不标色。与整体比较：本国 Top10 阈值 2 位、其余 3 位；三国复核：平均排名 Top10 阈值 2 位、其余 3 位。两项同方向满足才标色。"
    draw.text((inner_x + 16, footer_y + 21), note, font=FONTS["footnote"], fill=COLORS["muted"])

    output_name = "巴西专项_功能进入渗透率对比.png" if is_penetration else "巴西专项_功能订阅毛利对比.png"
    output = OUTPUT_DIR / output_name
    image.convert("RGB").save(output, quality=95)
    return output


def render(metric, output_name, title, subtitle):
    payload = json.loads(SOURCE.read_text(encoding="utf-8"))
    rows = payload["rows"]
    index = {(r["国家维度"], r["功能"]): r for r in rows}
    brazil_rows = [r for r in rows if r["国家维度"] == "巴西"]
    key = "进入渗透率" if metric == "penetration" else "订阅收入（分成后）"
    brazil_rows.sort(key=lambda r: (-float(r[key]), r["功能"]))
    rank_maps = {}
    for market in RANK_MARKETS:
        market_rows = [r for r in rows if r["国家维度"] == market]
        market_rows.sort(key=lambda r: (-float(r[key]), r["功能"]))
        rank_maps[market] = {r["功能"]: i + 1 for i, r in enumerate(market_rows)}
    brazil_rows = brazil_rows[:20]

    width = 2600
    margin = 48
    top = 180
    header_h = 104
    row_h = 62
    foot_h = 64
    card_h = header_h + row_h * len(brazil_rows) + foot_h
    height = top + card_h + 48
    image = Image.new("RGBA", (width, height), COLORS["bg"])
    draw = ImageDraw.Draw(image)

    draw.text((margin, 34), title, font=FONTS["title"], fill=COLORS["text"])
    draw.text((margin, 100), subtitle, font=FONTS["subtitle"], fill=COLORS["muted"])
    legend_x = width - 710
    draw.ellipse((legend_x, 108, legend_x + 16, 124), fill=COLORS["ahead"])
    draw.text((legend_x + 26, 100), "明显靠前", font=FONTS["header_sub"], fill=COLORS["text"])
    draw.ellipse((legend_x + 185, 108, legend_x + 201, 124), fill=COLORS["behind"])
    draw.text((legend_x + 211, 100), "明显靠后", font=FONTS["header_sub"], fill=COLORS["text"])
    draw.text((legend_x + 375, 100), "阈值：±3 位", font=FONTS["header_sub"], fill=COLORS["muted"])

    card = (margin, top, width - margin, top + card_h)
    draw_shadow(image, card)
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle(card, radius=26, fill=COLORS["card"])

    inner_x = margin + 28
    inner_w = width - 2 * margin - 56
    feature_w = 350
    market_w = (inner_w - feature_w) / 5
    header_y = top
    body_y = top + header_h

    # Brazil column highlight.
    brazil_x1 = inner_x + feature_w
    draw.rectangle((brazil_x1, header_y, brazil_x1 + market_w, top + card_h - foot_h), fill=COLORS["brazil_soft"])
    draw.rectangle((brazil_x1, header_y, brazil_x1 + market_w, header_y + header_h), fill="#FDE8C8")
    draw.rectangle((inner_x, header_y, inner_x + feature_w, header_y + header_h), fill=COLORS["header"])
    for i in range(1, 5):
        x1 = inner_x + feature_w + i * market_w
        draw.rectangle((x1, header_y, x1 + market_w, header_y + header_h), fill=COLORS["header"])

    draw.text((inner_x + 16, header_y + 22), "功能", font=FONTS["header"], fill=COLORS["text"])
    draw.text((inner_x + 16, header_y + 60), "按巴西从高到低", font=FONTS["header_sub"], fill=COLORS["muted"])
    for i, market in enumerate(MARKETS):
        x1 = inner_x + feature_w + i * market_w
        color = COLORS["brazil_dark"] if market == "巴西" else COLORS["text"]
        draw.text((x1 + 20, header_y + 20), market, font=FONTS["header"], fill=color)
        if market == "整体":
            sub = "数值 / 相对巴西"
        else:
            sub = "数值 / 国家排名"
        draw.text((x1 + 20, header_y + 60), sub, font=FONTS["header_sub"], fill=COLORS["muted"])

    draw.line((inner_x, body_y, inner_x + inner_w, body_y), fill=COLORS["line"], width=2)
    for i, br in enumerate(brazil_rows):
        y1 = body_y + i * row_h
        y2 = y1 + row_h
        if i > 0:
            draw.line((inner_x, y1, inner_x + inner_w, y1), fill=COLORS["line"], width=1)
        draw.text((inner_x + 16, y1 + 17), br["功能"], font=FONTS["feature"], fill=COLORS["text"])

        values = [float(index[(m, br["功能"])][key]) for m in MARKETS]
        if metric == "penetration":
            scale_max = 0.35
        else:
            scale_max = max(values) if max(values) > 0 else 1

        for j, (market, value) in enumerate(zip(MARKETS, values)):
            x1 = inner_x + feature_w + j * market_w
            display = f"{value * 100:.1f}%" if metric == "penetration" else f"${value / 1000:.1f}k"
            value_color = COLORS["brazil_dark"] if market == "巴西" else COLORS["text"]
            draw.text((x1 + 20, y1 + 9), display, font=FONTS["value"], fill=value_color)

            if market == "整体":
                delta = fmt_delta(metric, value if metric == "penetration" else value / 1000, values[0] if metric == "penetration" else values[0] / 1000)
                delta_color = COLORS["positive"] if value > values[0] else COLORS["negative"]
            else:
                rank = rank_maps[market][br["功能"]]
                peer_ranks = [rank_maps[m][br["功能"]] for m in RANK_MARKETS if m != market]
                gap = sum(peer_ranks) / len(peer_ranks) - rank
                if gap >= 3:
                    delta = f"#{rank} · 靠前{gap:.1f}位"
                    delta_color = COLORS["ahead"]
                elif gap <= -3:
                    delta = f"#{rank} · 靠后{abs(gap):.1f}位"
                    delta_color = COLORS["behind"]
                else:
                    delta = f"#{rank} · 接近"
                    delta_color = COLORS["negative"]
            draw.text((x1 + 20, y1 + 38), delta, font=FONTS["delta"], fill=delta_color)

            bar_x1 = x1 + 146
            bar_x2 = x1 + market_w - 22
            bar_y1 = y1 + 27
            bar_y2 = y1 + 39
            rounded_bar(draw, (bar_x1, bar_y1, bar_x2, bar_y2), COLORS["track"], 6)
            ratio = max(0, min(1, value / scale_max))
            if ratio > 0:
                fill = COLORS["brazil"] if market == "巴西" else COLORS["other"]
                rounded_bar(draw, (bar_x1, bar_y1, bar_x1 + (bar_x2 - bar_x1) * ratio, bar_y2), fill, 6)

    footer_y = top + card_h - foot_h
    draw.line((inner_x, footer_y, inner_x + inner_w, footer_y), fill=COLORS["line"], width=2)
    note = (
        "展示巴西 Top 20；条形使用统一 35% 刻度。红色=较其他三国平均排名靠前至少 3 位，绿色=靠后至少 3 位；整体不标色。"
        if metric == "penetration"
        else "展示巴西 Top 20；金额为 2026 年 6 月订阅收入（分成后），条形按行内最大值归一化。红色=排名明显靠前，绿色=明显靠后；整体不标色。"
    )
    draw.text((inner_x + 16, footer_y + 20), note, font=FONTS["footnote"], fill=COLORS["muted"])

    output = OUTPUT_DIR / output_name
    image.convert("RGB").save(output, quality=95)
    return output


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    p1 = render_rank_columns("penetration")
    p2 = render_rank_columns("revenue")
    print(json.dumps({"outputs": [str(p1), str(p2)]}, ensure_ascii=False))


if __name__ == "__main__":
    main()
