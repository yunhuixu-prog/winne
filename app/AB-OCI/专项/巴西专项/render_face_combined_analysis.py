#!/usr/bin/env python3
import csv
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path("/Users/xuyunhui/Documents/项目")
OUTPUT_DIR = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302"
COUNT_SOURCE = OUTPUT_DIR / "巴西专项_Face_Jaw_Nose子项数分布_202606.csv"
FUNNEL_SOURCE = OUTPUT_DIR / "巴西专项_Face_Adjust子项漏斗_202606.csv"
FUNCTION_SOURCE = ROOT / "app/AB-OCI/专项/巴西专项/巴西专项_功能数据_202606.json"
OUTPUT = OUTPUT_DIR / "巴西专项_Face使用深度及子功能漏斗对比.png"
FONT_PATH = "/System/Library/Fonts/PingFang.ttc"

COLORS = {
    "bg": "#F3F5F8",
    "card": "#FFFFFF",
    "text": "#1D2939",
    "muted": "#8190A5",
    "line": "#E3E8EF",
    "header": "#F7F9FC",
    "stripe": "#FAFBFD",
    "brazil": "#D9443E",
    "overall": "#A9B3C2",
    "positive": "#27835D",
    "negative": "#D33F3B",
    "neutral": "#667085",
    "track": "#E4E9F0",
    "zero": "#A9B3C2",
}


def font(size, bold=False):
    return ImageFont.truetype(
        FONT_PATH,
        size=size,
        index=1 if bold else 0,
    )


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


def read_count_data():
    with COUNT_SOURCE.open(encoding="utf-8-sig", newline="") as handle:
        rows = [
            row
            for row in csv.DictReader(handle)
            if row["层级"] == "face"
        ]
    index = {
        (row["市场"], int(row["使用子项数"])): row
        for row in rows
    }
    distributions = {
        market: [
            float(index[(market, count)]["事件占比"])
            for count in range(8)
        ]
        for market in ["巴西", "整体"]
    }
    summary = {}
    for market in ["巴西", "整体"]:
        sample = index[(market, 0)]
        summary[market] = {
            "average": float(sample["平均使用子项数_全量Face打勾事件"]),
            "multi": float(sample["至少使用2项占比_全量Face打勾事件"]),
        }
    return distributions, summary


def read_funnel_data():
    with FUNNEL_SOURCE.open(encoding="utf-8-sig", newline="") as handle:
        rows = [
            row
            for row in csv.DictReader(handle)
            if row["二级功能"] == "Face"
            and row["国家维度"] in {"巴西", "整体"}
        ]
    index = {(row["国家维度"], row["三级功能"]): row for row in rows}

    payload = json.loads(FUNCTION_SOURCE.read_text(encoding="utf-8"))
    denominators = {
        row["国家维度"]: float(row["进入人数"])
        for row in payload["rows"]
        if row["功能"] == "Face"
        and row["国家维度"] in {"巴西", "整体"}
    }
    features = sorted(
        {row["三级功能"] for row in rows},
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
    if metric == "进入占 Face":
        return (
            float(row["br"]["进入人数"]) / denominators["巴西"],
            float(row["overall"]["进入人数"]) / denominators["整体"],
        )
    if metric == "进入打勾率":
        return (
            float(row["br"]["进入打勾率"]),
            float(row["overall"]["进入打勾率"]),
        )
    if metric == "进入保存率":
        return (
            float(row["br"]["进入保存率"]),
            float(row["overall"]["进入保存率"]),
        )
    raise ValueError(metric)


def draw_distribution_panel(draw, box, distributions, summary):
    x0, y0, x1, y1 = box
    draw.text(
        (x0 + 26, y0 + 20),
        "Face 三级子项使用数",
        font=font(27, True),
        fill=COLORS["text"],
    )
    draw.text(
        (x0 + 26, y0 + 61),
        (
            f"平均使用：巴西 {summary['巴西']['average']:.2f}"
            f"（整体 {summary['整体']['average']:.2f}）"
        ),
        font=font(18, True),
        fill=COLORS["text"],
    )
    draw.text(
        (x0 + 26, y0 + 92),
        (
            f"至少使用 2 项：巴西 {summary['巴西']['multi'] * 100:.1f}%"
            f"（整体 {summary['整体']['multi'] * 100:.1f}%）"
        ),
        font=font(17),
        fill=COLORS["muted"],
    )

    plot_x0, plot_x1 = x0 + 76, x1 - 30
    plot_y0, plot_y1 = y0 + 190, y1 - 105
    max_axis = 0.7
    for grid_index in range(5):
        value = max_axis * grid_index / 4
        y = plot_y1 - (plot_y1 - plot_y0) * grid_index / 4
        draw.line((plot_x0, y, plot_x1, y), fill=COLORS["line"], width=1)
        draw.text(
            (plot_x0 - 54, y - 10),
            f"{value * 100:.0f}%",
            font=font(14),
            fill=COLORS["muted"],
        )

    group_width = (plot_x1 - plot_x0) / 8
    bar_width = max(10, int(group_width * 0.28))
    for count in range(8):
        center = plot_x0 + group_width * (count + 0.5)
        values = {
            market: distributions[market][count]
            for market in ["整体", "巴西"]
        }
        top_y = min(
            plot_y1 - (plot_y1 - plot_y0) * value / max_axis
            for value in values.values()
        )
        for market_index, (market, color) in enumerate([
            ("整体", COLORS["overall"]),
            ("巴西", COLORS["brazil"]),
        ]):
            value = values[market]
            height = (plot_y1 - plot_y0) * value / max_axis
            bx0 = int(center - bar_width if market_index == 0 else center)
            bx1 = bx0 + bar_width
            by0 = int(plot_y1 - height)
            draw.rounded_rectangle(
                (bx0, by0, bx1, plot_y1),
                radius=4,
                fill=color,
            )
            if value >= 0.035:
                label = f"{value * 100:.1f}%"
                label_width = draw.textlength(label, font=font(13))
                label_y = top_y - (39 if market == "巴西" else 20)
                draw.text(
                    (bx0 + (bar_width - label_width) / 2, label_y),
                    label,
                    font=font(13),
                    fill=color if market == "巴西" else COLORS["muted"],
                )
        label_width = draw.textlength(str(count), font=font(17))
        draw.text(
            (center - label_width / 2 - 1, plot_y1 + 17),
            str(count),
            font=font(17),
            fill=COLORS["text"],
        )
    centered_text(
        draw,
        (plot_x0, plot_y1 + 48, plot_x1, plot_y1 + 85),
        "同次打勾使用的三级子项数",
        font(16),
        COLORS["muted"],
    )


def draw_funnel_table(draw, box, rows, denominators):
    x0, y0, x1, y1 = box
    feature_w = 340
    metrics = ["进入占 Face", "进入打勾率", "进入保存率"]
    subtitles = {
        "进入占 Face": "子功能进入 / Face 进入",
        "进入打勾率": "打勾 / 子功能进入",
        "进入保存率": "保存 / 子功能进入",
    }
    metric_w = (x1 - x0 - feature_w) / len(metrics)
    header_h = 104
    row_h = (y1 - y0 - header_h) / len(rows)
    body_y = y0 + header_h

    draw.rectangle((x0, y0, x1, body_y), fill=COLORS["header"])
    draw.text(
        (x0 + 22, y0 + 22),
        "Face 子功能",
        font=font(24, True),
        fill=COLORS["text"],
    )
    draw.text(
        (x0 + 22, y0 + 62),
        "巴西进入人数（日均 UV）",
        font=font(16),
        fill=COLORS["muted"],
    )
    for column, metric in enumerate(metrics):
        mx0 = x0 + feature_w + column * metric_w
        draw.line((mx0, y0, mx0, y1), fill=COLORS["line"], width=2)
        centered_text(
            draw,
            (mx0, y0 + 10, mx0 + metric_w, y0 + 56),
            metric,
            font(23, True),
            COLORS["text"],
        )
        centered_text(
            draw,
            (mx0, y0 + 57, mx0 + metric_w, body_y - 3),
            subtitles[metric],
            font(15),
            COLORS["muted"],
        )
    draw.line((x0, body_y, x1, body_y), fill=COLORS["line"], width=2)

    for row_index, row in enumerate(rows):
        ry0 = body_y + row_index * row_h
        ry1 = ry0 + row_h
        draw.rectangle(
            (x0, ry0, x1, ry1),
            fill=COLORS["card"] if row_index % 2 == 0 else COLORS["stripe"],
        )
        draw.rectangle((x0, ry0, x0 + 5, ry1), fill=COLORS["brazil"])
        if row_index:
            draw.line((x0, ry0, x1, ry0), fill=COLORS["line"], width=1)
        draw.text(
            (x0 + 20, ry0 + 13),
            row["feature"],
            font=font(22),
            fill=COLORS["text"],
        )
        draw.text(
            (x0 + 20, ry0 + 48),
            f"巴西进入 {float(row['br']['进入人数']):,.0f} 人/日",
            font=font(15),
            fill=COLORS["muted"],
        )

        for column, metric in enumerate(metrics):
            mx0 = x0 + feature_w + column * metric_w
            br_value, overall_value = metric_pair(row, denominators, metric)
            gap = br_value - overall_value
            if gap <= -0.01:
                color = COLORS["negative"]
            elif gap >= 0.01:
                color = COLORS["positive"]
            else:
                color = COLORS["neutral"]
            centered_text(
                draw,
                (mx0, ry0 + 4, mx0 + metric_w, ry0 + 35),
                f"{gap * 100:+.1f}pp",
                font(21, True),
                color,
            )

            bar_x0 = mx0 + 54
            bar_x1 = mx0 + metric_w - 54
            bar_mid = (bar_x0 + bar_x1) / 2
            bar_y0 = ry0 + 39
            bar_y1 = ry0 + 50
            draw.rounded_rectangle(
                (bar_x0, bar_y0, bar_x1, bar_y1),
                radius=6,
                fill=COLORS["track"],
            )
            draw.line(
                (bar_mid, bar_y0 - 2, bar_mid, bar_y1 + 2),
                fill=COLORS["zero"],
                width=2,
            )
            half_width = (bar_x1 - bar_x0) / 2
            length = min(abs(gap) / 0.06, 1) * half_width
            if gap < 0:
                draw.rounded_rectangle(
                    (bar_mid - length, bar_y0, bar_mid, bar_y1),
                    radius=6,
                    fill=COLORS["negative"],
                )
            elif gap > 0:
                draw.rounded_rectangle(
                    (bar_mid, bar_y0, bar_mid + length, bar_y1),
                    radius=6,
                    fill=COLORS["positive"],
                )
            centered_text(
                draw,
                (mx0, ry0 + 54, mx0 + metric_w, ry1 - 3),
                f"（{br_value * 100:.1f}% / {overall_value * 100:.1f}%）",
                font(15),
                COLORS["muted"],
            )


def main():
    distributions, summary = read_count_data()
    rows, denominators = read_funnel_data()

    width, height = 2920, 1280
    margin = 48
    top = 170
    bottom = 90
    gap = 24
    left_w = 760
    image = Image.new("RGB", (width, height), COLORS["bg"])
    draw = ImageDraw.Draw(image)

    draw.text(
        (margin, 28),
        "Face 子功能｜使用深度与进入效果确认漏斗",
        font=font(44, True),
        fill=COLORS["text"],
    )
    draw.text(
        (margin, 91),
        "2026年6月 · 左侧为同次 Face 打勾使用的三级子项数；右侧按巴西子功能进入人数降序展示巴西与整体差异",
        font=font(22),
        fill=COLORS["muted"],
    )
    draw.ellipse((2410, 72, 2428, 90), fill=COLORS["brazil"])
    draw.text((2438, 64), "巴西", font=font(18), fill=COLORS["text"])
    draw.ellipse((2520, 72, 2538, 90), fill=COLORS["overall"])
    draw.text((2548, 64), "整体", font=font(18), fill=COLORS["text"])

    card = (margin, top, width - margin, height - bottom)
    draw.rounded_rectangle(
        card,
        radius=24,
        fill=COLORS["card"],
        outline=COLORS["line"],
        width=1,
    )
    left_box = (
        margin + 20,
        top + 15,
        margin + 20 + left_w,
        height - bottom - 15,
    )
    divider_x = left_box[2] + gap / 2
    draw.line(
        (divider_x, top + 15, divider_x, height - bottom - 15),
        fill=COLORS["line"],
        width=2,
    )
    right_box = (
        left_box[2] + gap,
        top + 15,
        width - margin - 20,
        height - bottom - 15,
    )

    draw_distribution_panel(draw, left_box, distributions, summary)
    draw_funnel_table(draw, right_box, rows, denominators)

    draw.text(
        (margin + 16, height - 61),
        (
            f"Face 二级进入人数：巴西 {denominators['巴西']:,.0f} 人/日，"
            f"整体 {denominators['整体']:,.0f} 人/日；"
            "漏斗数据条统一使用 ±6pp 刻度，红色向左=巴西低于整体，绿色向右=高于整体。"
        ),
        font=font(16),
        fill=COLORS["muted"],
    )
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    image.save(OUTPUT, format="PNG", optimize=True)
    print(OUTPUT)


if __name__ == "__main__":
    main()
