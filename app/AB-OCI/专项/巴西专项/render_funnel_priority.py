#!/usr/bin/env python3
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


SOURCE = Path("/Users/xuyunhui/Documents/项目/app/AB-OCI/专项/巴西专项/巴西专项_功能数据_202606.json")
OUTPUT = Path("/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西专项_重点优化功能漏斗对比.png")
FONT_PATH = "/System/Library/Fonts/PingFang.ttc"
TITLE = "巴西进入人数 Top 25｜行为漏斗对比"
SUBTITLE = "按巴西进入人数从高到低；指标格式为 gap（巴西 / 整体），P0/P1 功能分别标红、标橙。"

BRAZIL_DAU = 301029
OVERALL_DAU = 731237
PRIORITIES = {
    "Face": "P0",
    "Eraser": "P0",
    "Skin Tone": "P0",
    "AI Retouch": "P1",
    "Body": "P1",
    "Relight": "P1",
    "Glowup": "P1",
    "Brighten": "P1",
}

COLORS = {
    "bg": "#F3F5F9",
    "card": "#FFFFFF",
    "text": "#182230",
    "muted": "#7B8798",
    "line": "#E5E9F0",
    "header": "#F7F8FA",
    "p0": "#C93532",
    "p0_soft": "#FFF2F1",
    "p1": "#D97706",
    "p1_soft": "#FFF8EB",
    "normal_soft": "#FAFBFC",
    "normal_accent": "#D5DAE2",
    "positive": "#27835D",
    "negative": "#C93532",
    "neutral": "#667085",
    "bar_track": "#E6EAF0",
    "bar_zero": "#AEB7C5",
}


def font(size):
    return ImageFont.truetype(FONT_PATH, size=size)


FONTS = {
    "title": font(46),
    "subtitle": font(24),
    "header": font(25),
    "feature": font(26),
    "tag": font(18),
    "secondary": font(18),
    "gap": font(25),
    "value": font(18),
    "footnote": font(18),
}


def draw_shadow(base, box, radius=24):
    shadow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    x1, y1, x2, y2 = box
    sd.rounded_rectangle((x1, y1 + 8, x2, y2 + 8), radius=radius, fill=(30, 41, 59, 18))
    base.alpha_composite(shadow)


def safe_div(num, den):
    return float(num) / float(den) if den else 0.0


def metric_pair(br, overall, metric):
    if metric == "进入率":
        return safe_div(br["进入人数"], BRAZIL_DAU), safe_div(overall["进入人数"], OVERALL_DAU)
    if metric == "曝光率":
        return safe_div(br["曝光人数"], BRAZIL_DAU), safe_div(overall["曝光人数"], OVERALL_DAU)
    if metric == "曝光进入率":
        return safe_div(br["进入人数"], br["曝光人数"]), safe_div(overall["进入人数"], overall["曝光人数"])
    if metric == "进入打勾率":
        return safe_div(br["打勾人数"], br["进入人数"]), safe_div(overall["打勾人数"], overall["进入人数"])
    if metric == "打勾保存率":
        return safe_div(br["保存人数"], br["打勾人数"]), safe_div(overall["保存人数"], overall["打勾人数"])
    if metric == "进入保存率":
        return safe_div(br["保存人数"], br["进入人数"]), safe_div(overall["保存人数"], overall["进入人数"])
    raise ValueError(metric)


def centered_text(draw, box, text, text_font, fill):
    x1, y1, x2, y2 = box
    bbox = draw.textbbox((0, 0), text, font=text_font)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    draw.text((x1 + (x2 - x1 - w) / 2, y1 + (y2 - y1 - h) / 2 - 2), text, font=text_font, fill=fill)


def main():
    payload = json.loads(SOURCE.read_text(encoding="utf-8"))
    index = {(r["国家维度"], r["功能"]): r for r in payload["rows"]}
    brazil_rows = [r for r in payload["rows"] if r["国家维度"] == "巴西"]
    brazil_rows.sort(key=lambda r: (-float(r["进入人数"]), r["功能"]))
    rows = []
    for br in brazil_rows[:25]:
        feature = br["功能"]
        overall = index[("整体", feature)]
        rows.append({"feature": feature, "priority": PRIORITIES.get(feature), "br": br, "overall": overall})
    rows.sort(key=lambda x: (-float(x["br"]["进入人数"]), x["feature"]))

    metrics = ["进入率", "曝光率", "曝光进入率", "进入打勾率", "打勾保存率", "进入保存率"]
    width = 2940
    margin = 48
    top = 188
    header_h = 106
    row_h = 92
    footer_h = 82
    card_h = header_h + row_h * len(rows) + footer_h
    height = top + card_h + 48
    image = Image.new("RGBA", (width, height), COLORS["bg"])
    draw = ImageDraw.Draw(image)

    draw.text((margin, 34), TITLE, font=FONTS["title"], fill=COLORS["text"])
    draw.text((margin, 102), SUBTITLE, font=FONTS["subtitle"], fill=COLORS["muted"])

    legend_x = width - 520
    draw.rounded_rectangle((legend_x, 102, legend_x + 82, 136), radius=17, fill=COLORS["p0"])
    centered_text(draw, (legend_x, 102, legend_x + 82, 136), "P0", FONTS["tag"], "#FFFFFF")
    draw.text((legend_x + 96, 103), "优先优化", font=FONTS["secondary"], fill=COLORS["text"])
    draw.rounded_rectangle((legend_x + 230, 102, legend_x + 312, 136), radius=17, fill=COLORS["p1"])
    centered_text(draw, (legend_x + 230, 102, legend_x + 312, 136), "P1", FONTS["tag"], "#FFFFFF")
    draw.text((legend_x + 326, 103), "重点关注", font=FONTS["secondary"], fill=COLORS["text"])

    card = (margin, top, width - margin, top + card_h)
    draw_shadow(image, card)
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle(card, radius=26, fill=COLORS["card"])

    inner_x = margin + 28
    inner_w = width - 2 * margin - 56
    feature_w = 490
    metric_w = (inner_w - feature_w) / len(metrics)
    body_y = top + header_h
    footer_y = top + card_h - footer_h

    draw.rectangle((inner_x, top, inner_x + feature_w, body_y), fill=COLORS["header"])
    draw.text((inner_x + 22, top + 24), "功能", font=FONTS["header"], fill=COLORS["text"])
    draw.text((inner_x + 22, top + 64), "优先级 / 巴西进入人数", font=FONTS["secondary"], fill=COLORS["muted"])
    for j, metric in enumerate(metrics):
        x1 = inner_x + feature_w + j * metric_w
        draw.rectangle((x1, top, x1 + metric_w, body_y), fill=COLORS["header"])
        centered_text(draw, (x1, top + 16, x1 + metric_w, top + 60), metric, FONTS["header"], COLORS["text"])
        centered_text(draw, (x1, top + 58, x1 + metric_w, body_y - 5), "gap 数据条（巴西 / 整体）", FONTS["secondary"], COLORS["muted"])
        draw.line((x1, top, x1, footer_y), fill=COLORS["line"], width=2)
    draw.line((inner_x, body_y, inner_x + inner_w, body_y), fill=COLORS["line"], width=2)

    for i, row in enumerate(rows):
        y1 = body_y + i * row_h
        y2 = y1 + row_h
        priority = row["priority"]
        if priority == "P0":
            accent, soft = COLORS["p0"], COLORS["p0_soft"]
        elif priority == "P1":
            accent, soft = COLORS["p1"], COLORS["p1_soft"]
        else:
            accent = COLORS["normal_accent"]
            soft = COLORS["card"] if i % 2 == 0 else COLORS["normal_soft"]
        draw.rectangle((inner_x, y1, inner_x + inner_w, y2), fill=soft)
        draw.rectangle((inner_x, y1, inner_x + 7, y2), fill=accent)
        if i > 0:
            draw.line((inner_x, y1, inner_x + inner_w, y1), fill=COLORS["line"], width=1)

        draw.text((inner_x + 24, y1 + 17), row["feature"], font=FONTS["feature"], fill=COLORS["text"])
        if priority:
            tag_x = inner_x + 224
            draw.rounded_rectangle((tag_x, y1 + 17, tag_x + 68, y1 + 49), radius=16, fill=accent)
            centered_text(draw, (tag_x, y1 + 17, tag_x + 68, y1 + 49), priority, FONTS["tag"], "#FFFFFF")
        enter_text = f"巴西进入 {float(row['br']['进入人数']):,.0f} 人/日"
        draw.text((inner_x + 24, y1 + 57), enter_text, font=FONTS["secondary"], fill=COLORS["muted"])

        for j, metric in enumerate(metrics):
            x1 = inner_x + feature_w + j * metric_w
            if row["feature"] == "Teeth" and metric == "打勾保存率":
                centered_text(
                    draw,
                    (x1, y1 + 12, x1 + metric_w, y1 + 46),
                    "口径异常",
                    FONTS["gap"],
                    COLORS["neutral"],
                )
                centered_text(
                    draw,
                    (x1, y1 + 52, x1 + metric_w, y2 - 5),
                    "打勾事件仅部分日期返回",
                    FONTS["value"],
                    COLORS["muted"],
                )
                continue

            br_value, overall_value = metric_pair(row["br"], row["overall"], metric)
            gap = br_value - overall_value
            gap_color = COLORS["negative"] if gap <= -0.02 else COLORS["positive"] if gap >= 0.02 else COLORS["neutral"]
            gap_text = f"{gap * 100:+.1f}pp"
            value_text = f"（{br_value * 100:.1f}% / {overall_value * 100:.1f}%）"
            centered_text(draw, (x1, y1 + 6, x1 + metric_w, y1 + 40), gap_text, FONTS["gap"], gap_color)

            bar_x1 = x1 + 64
            bar_x2 = x1 + metric_w - 64
            bar_mid = (bar_x1 + bar_x2) / 2
            bar_y1 = y1 + 43
            bar_y2 = y1 + 55
            draw.rounded_rectangle((bar_x1, bar_y1, bar_x2, bar_y2), radius=6, fill=COLORS["bar_track"])
            draw.line((bar_mid, bar_y1 - 2, bar_mid, bar_y2 + 2), fill=COLORS["bar_zero"], width=2)
            half_width = (bar_x2 - bar_x1) / 2
            bar_length = min(abs(gap) / 0.14, 1.0) * half_width
            if gap < 0 and bar_length > 0:
                draw.rounded_rectangle((bar_mid - bar_length, bar_y1, bar_mid, bar_y2), radius=6, fill=COLORS["negative"])
            elif gap > 0 and bar_length > 0:
                draw.rounded_rectangle((bar_mid, bar_y1, bar_mid + bar_length, bar_y2), radius=6, fill=COLORS["positive"])

            centered_text(draw, (x1, y1 + 59, x1 + metric_w, y2 - 5), value_text, FONTS["value"], COLORS["muted"])

    draw.line((inner_x, footer_y, inner_x + inner_w, footer_y), fill=COLORS["line"], width=2)
    note = "数据条以中线为 0，五列统一使用 ±14pp 刻度：红色向左=巴西低于整体，绿色向右=高于整体。整体包含巴西；Teeth 打勾事件仅部分日期返回，打勾保存率不展示。"
    draw.text((inner_x + 16, footer_y + 27), note, font=FONTS["footnote"], fill=COLORS["muted"])

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(OUTPUT, quality=95)
    print(str(OUTPUT))


if __name__ == "__main__":
    main()
