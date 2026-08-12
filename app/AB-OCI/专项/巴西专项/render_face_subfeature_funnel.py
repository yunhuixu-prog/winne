#!/usr/bin/env python3
import csv
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path("/Users/xuyunhui/Documents/项目")
SOURCE = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西专项_Face_Adjust子项漏斗_202606.csv"
FUNCTION_SOURCE = ROOT / "app/AB-OCI/专项/巴西专项/巴西专项_功能数据_202606.json"
OUTPUT = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西专项_Face子功能漏斗对比.png"
FONT_PATH = "/System/Library/Fonts/PingFang.ttc"
TITLE = "Face 子功能｜进入与效果确认漏斗"
SUBTITLE = "按巴西子功能进入人数降序；每列展示 gap（巴西－整体）及巴西/整体具体值。"
FEATURE_HEADER = "Face 子功能"
FEATURE_SUBHEADER = "巴西子功能进入人数（日均 UV）"
METRICS = ["进入占 Face", "进入打勾率", "进入保存率"]
HEADER_SUBTITLES = {
    "进入占 Face": "子功能进入 / Face 二级进入",
    "进入打勾率": "子功能打勾 / 子功能进入",
    "进入保存率": "子功能保存 / 子功能进入",
}

COLORS = {
    "bg": "#F3F5F8",
    "card": "#FFFFFF",
    "text": "#1D2939",
    "muted": "#8190A5",
    "line": "#E3E8EF",
    "header": "#F7F9FC",
    "stripe": "#FAFBFD",
    "accent": "#D94A44",
    "accent_soft": "#FFF5F3",
    "positive": "#27835D",
    "negative": "#D33F3B",
    "neutral": "#667085",
    "track": "#E4E9F0",
    "zero": "#A9B3C2",
}


def font(size, index=0):
    return ImageFont.truetype(FONT_PATH, size=size, index=index)


FONTS = {
    "title": font(44),
    "subtitle": font(23),
    "header": font(25),
    "feature": font(27),
    "secondary": font(18),
    "gap": font(26),
    "value": font(18),
    "footnote": font(17),
}


def centered_text(draw, box, text, text_font, fill):
    x1, y1, x2, y2 = box
    bbox = draw.textbbox((0, 0), text, font=text_font)
    width = bbox[2] - bbox[0]
    height = bbox[3] - bbox[1]
    draw.text(
        (x1 + (x2 - x1 - width) / 2, y1 + (y2 - y1 - height) / 2 - 2),
        text,
        font=text_font,
        fill=fill,
    )


def read_data():
    with SOURCE.open(encoding="utf-8-sig", newline="") as handle:
        raw_rows = list(csv.DictReader(handle))
    face_rows = [
        row for row in raw_rows
        if row["二级功能"] == "Face" and row["国家维度"] in {"巴西", "整体"}
    ]
    index = {(row["国家维度"], row["三级功能"]): row for row in face_rows}

    payload = json.loads(FUNCTION_SOURCE.read_text(encoding="utf-8"))
    denominators = {
        row["国家维度"]: float(row["进入人数"])
        for row in payload["rows"]
        if row["功能"] == "Face" and row["国家维度"] in {"巴西", "整体"}
    }
    if round(denominators["巴西"]) != 60972:
        raise ValueError(f"巴西 Face 进入人数口径异常：{denominators['巴西']}")

    features = sorted(
        {row["三级功能"] for row in face_rows},
        key=lambda feature: -float(index[("巴西", feature)]["进入人数"]),
    )
    return [
        {
            "feature": feature,
            "br": index[("巴西", feature)],
            "overall": index[("整体", feature)],
        }
        for feature in features
    ], denominators


def metric_pair(row, denominators, metric):
    br = row["br"]
    overall = row["overall"]
    if metric == "进入占 Face":
        return (
            float(br["进入人数"]) / denominators["巴西"],
            float(overall["进入人数"]) / denominators["整体"],
        )
    if metric == "进入打勾率":
        return float(br["进入打勾率"]), float(overall["进入打勾率"])
    if metric == "进入保存率":
        return float(br["进入保存率"]), float(overall["进入保存率"])
    raise ValueError(metric)


def footnote_text(denominators):
    return (
        f"Face 二级进入人数：巴西 {denominators['巴西']:,.0f} 人/日，"
        f"整体 {denominators['整体']:,.0f} 人/日；"
        "数据条统一使用 ±6pp 刻度，红色向左=巴西低于整体，绿色向右=高于整体。"
        "同一用户可进入多个子功能，因此“进入占 Face”不构成互斥份额。"
    )


def main():
    rows, denominators = read_data()
    metrics = METRICS

    width = 2380
    margin = 48
    top = 180
    header_h = 108
    row_h = 106
    footer_h = 82
    feature_w = 500
    card_h = header_h + row_h * len(rows) + footer_h
    height = top + card_h + 48

    image = Image.new("RGB", (width, height), COLORS["bg"])
    draw = ImageDraw.Draw(image)

    draw.text(
        (margin, 30),
        TITLE,
        font=FONTS["title"],
        fill=COLORS["text"],
    )
    draw.text(
        (margin, 94),
        SUBTITLE,
        font=FONTS["subtitle"],
        fill=COLORS["muted"],
    )

    card = (margin, top, width - margin, top + card_h)
    draw.rounded_rectangle(card, radius=24, fill=COLORS["card"])

    inner_x = margin + 26
    inner_w = width - 2 * margin - 52
    metric_w = (inner_w - feature_w) / len(metrics)
    body_y = top + header_h
    footer_y = top + card_h - footer_h

    draw.rectangle(
        (inner_x, top, inner_x + feature_w, body_y),
        fill=COLORS["header"],
    )
    draw.text(
        (inner_x + 22, top + 24),
        FEATURE_HEADER,
        font=FONTS["header"],
        fill=COLORS["text"],
    )
    draw.text(
        (inner_x + 22, top + 66),
        FEATURE_SUBHEADER,
        font=FONTS["secondary"],
        fill=COLORS["muted"],
    )

    header_subtitles = HEADER_SUBTITLES
    for column, metric in enumerate(metrics):
        x1 = inner_x + feature_w + column * metric_w
        draw.rectangle((x1, top, x1 + metric_w, body_y), fill=COLORS["header"])
        draw.line((x1, top, x1, footer_y), fill=COLORS["line"], width=2)
        centered_text(
            draw,
            (x1, top + 14, x1 + metric_w, top + 60),
            metric,
            FONTS["header"],
            COLORS["text"],
        )
        centered_text(
            draw,
            (x1, top + 61, x1 + metric_w, body_y - 4),
            header_subtitles[metric],
            FONTS["secondary"],
            COLORS["muted"],
        )
    draw.line((inner_x, body_y, inner_x + inner_w, body_y), fill=COLORS["line"], width=2)

    for index, row in enumerate(rows):
        y1 = body_y + index * row_h
        y2 = y1 + row_h
        fill = COLORS["card"] if index % 2 == 0 else COLORS["stripe"]
        draw.rectangle((inner_x, y1, inner_x + inner_w, y2), fill=fill)
        draw.rectangle((inner_x, y1, inner_x + 6, y2), fill=COLORS["accent"])
        if index:
            draw.line((inner_x, y1, inner_x + inner_w, y1), fill=COLORS["line"], width=1)

        draw.text(
            (inner_x + 24, y1 + 20),
            row["feature"],
            font=FONTS["feature"],
            fill=COLORS["text"],
        )
        draw.text(
            (inner_x + 24, y1 + 65),
            f"巴西进入 {float(row['br']['进入人数']):,.0f} 人/日",
            font=FONTS["secondary"],
            fill=COLORS["muted"],
        )

        for column, metric in enumerate(metrics):
            x1 = inner_x + feature_w + column * metric_w
            br_value, overall_value = metric_pair(row, denominators, metric)
            gap = br_value - overall_value
            if gap <= -0.01:
                gap_color = COLORS["negative"]
            elif gap >= 0.01:
                gap_color = COLORS["positive"]
            else:
                gap_color = COLORS["neutral"]

            centered_text(
                draw,
                (x1, y1 + 7, x1 + metric_w, y1 + 43),
                f"{gap * 100:+.1f}pp",
                FONTS["gap"],
                gap_color,
            )

            bar_x1 = x1 + 72
            bar_x2 = x1 + metric_w - 72
            bar_mid = (bar_x1 + bar_x2) / 2
            bar_y1 = y1 + 50
            bar_y2 = y1 + 63
            draw.rounded_rectangle(
                (bar_x1, bar_y1, bar_x2, bar_y2),
                radius=7,
                fill=COLORS["track"],
            )
            draw.line(
                (bar_mid, bar_y1 - 3, bar_mid, bar_y2 + 3),
                fill=COLORS["zero"],
                width=2,
            )
            half_width = (bar_x2 - bar_x1) / 2
            bar_length = min(abs(gap) / 0.06, 1.0) * half_width
            if gap < 0:
                draw.rounded_rectangle(
                    (bar_mid - bar_length, bar_y1, bar_mid, bar_y2),
                    radius=7,
                    fill=COLORS["negative"],
                )
            elif gap > 0:
                draw.rounded_rectangle(
                    (bar_mid, bar_y1, bar_mid + bar_length, bar_y2),
                    radius=7,
                    fill=COLORS["positive"],
                )

            centered_text(
                draw,
                (x1, y1 + 69, x1 + metric_w, y2 - 5),
                f"（{br_value * 100:.1f}% / {overall_value * 100:.1f}%）",
                FONTS["value"],
                COLORS["muted"],
            )

    draw.line((inner_x, footer_y, inner_x + inner_w, footer_y), fill=COLORS["line"], width=2)
    note = footnote_text(denominators)
    draw.text(
        (inner_x + 16, footer_y + 28),
        note,
        font=FONTS["footnote"],
        fill=COLORS["muted"],
    )

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    image.save(OUTPUT, format="PNG", optimize=True)
    print(OUTPUT)


if __name__ == "__main__":
    main()
