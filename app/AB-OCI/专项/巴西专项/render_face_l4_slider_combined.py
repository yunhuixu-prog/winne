#!/usr/bin/env python3
import csv
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path("/Users/xuyunhui/Documents/项目")
OUTPUT_DIR = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302"
FACE_SOURCE = OUTPUT_DIR / "巴西专项_Face_Adjust子项漏斗_202606.csv"
SLIDER_STATS_SOURCE = OUTPUT_DIR / "巴西专项_Face_Jaw_Nose滑杆使用摘要_202606.csv"
SLIDER_DIST_SOURCE = OUTPUT_DIR / "巴西专项_Face_Jaw_Nose滑杆值分布_步长5_202606.csv"
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
    "overall_fill": "#DDE3EB",
    "positive": "#27835D",
    "negative": "#D33F3B",
    "neutral": "#667085",
    "track": "#E4E9F0",
    "zero": "#A9B3C2",
}

CONFIGS = {
    "Jaw": {
        "funnel_source": OUTPUT_DIR / "巴西专项_Face_Jaw四级功能漏斗_202606.csv",
        "output": OUTPUT_DIR / "巴西专项_Face_Jaw四级漏斗及滑杆分布.png",
        "title": "Face－Jaw｜四级功能漏斗与滑杆偏好",
        "metric": "进入占 Jaw",
        "feature_header": "Jaw 四级功能",
        "slider_order": [
            "chin",
            "double_chin",
            "jaw_line",
            "jaw",
            "length",
            "jaw_shape",
            "double_chin_pro",
        ],
        "slider_labels": {
            "chin": "Chin｜下巴",
            "double_chin": "Double Chin｜双下巴",
            "jaw_line": "Jaw Line｜下颌线",
            "jaw": "Jaw｜下颌",
            "length": "Length｜长度",
            "jaw_shape": "Jaw Shape｜轮廓形状",
            "double_chin_pro": "Double Chin Pro｜双下巴 Pro",
        },
        "note": (
            "Jaw 默认打开且会记忆上次停留子项，进入占比不能直接视为主动偏好；"
            "滑杆参数按原始上报 key 展示，当前 prf_jaw_mod 未包含 Jaw_angle。"
        ),
    },
    "Nose": {
        "funnel_source": OUTPUT_DIR / "巴西专项_Face_Nose四级功能漏斗_202606.csv",
        "output": OUTPUT_DIR / "巴西专项_Face_Nose四级漏斗及滑杆分布.png",
        "title": "Face－Nose｜四级功能漏斗与滑杆偏好",
        "metric": "进入占 Nose",
        "feature_header": "Nose 四级功能",
        "slider_order": ["size", "width", "bridge", "tip", "root", "length"],
        "slider_labels": {
            "size": "Size｜大小",
            "width": "Width｜宽度",
            "bridge": "Bridge｜鼻梁",
            "tip": "Tip｜鼻尖",
            "root": "Root｜山根",
            "length": "Length｜长度",
        },
        "note": (
            "滑杆调整率＝参数上报事件中至少存在一个非零值的事件占比；"
            "逗号分隔的多人脸滑杆值逐个拆分并按 5 分箱。"
        ),
    },
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


def fmt_signed(value):
    if value == "":
        return "—"
    value = float(value)
    return f"{value:+.0f}" if value else "0"


def read_funnel(config, feature):
    with config["funnel_source"].open(
        encoding="utf-8-sig", newline=""
    ) as handle:
        raw_rows = [
            row
            for row in csv.DictReader(handle)
            if row["国家维度"] in {"巴西", "整体"}
        ]
    index = {
        (row["国家维度"], row["四级功能"]): row
        for row in raw_rows
    }
    features = sorted(
        {
            row["四级功能"]
            for row in raw_rows
            if row["国家维度"] == "巴西"
            and ("整体", row["四级功能"]) in index
        },
        key=lambda name: -float(index[("巴西", name)]["进入人数"]),
    )
    rows = [
        {
            "feature": name,
            "br": index[("巴西", name)],
            "overall": index[("整体", name)],
        }
        for name in features
    ]

    with FACE_SOURCE.open(encoding="utf-8-sig", newline="") as handle:
        face_rows = list(csv.DictReader(handle))
    denominators = {
        row["国家维度"]: float(row["进入人数"])
        for row in face_rows
        if row["二级功能"] == "Face"
        and row["三级功能"] == feature
        and row["国家维度"] in {"巴西", "整体"}
    }
    return rows, denominators


def read_slider_data(feature):
    with SLIDER_STATS_SOURCE.open(
        encoding="utf-8-sig", newline=""
    ) as handle:
        stats_rows = [
            row
            for row in csv.DictReader(handle)
            if row["功能"] == feature
        ]
    stats = {
        (row["市场"], row["子项"]): row
        for row in stats_rows
    }

    with SLIDER_DIST_SOURCE.open(
        encoding="utf-8-sig", newline=""
    ) as handle:
        dist_rows = [
            row
            for row in csv.DictReader(handle)
            if row["功能"] == feature
        ]
    distributions = {}
    for row in dist_rows:
        key = (row["市场"], row["子项"])
        distributions.setdefault(key, {})[
            int(row["分箱中心"])
        ] = float(row["非零滑杆值占比"])
    return stats, distributions


def metric_pair(row, denominators, metric):
    if metric.startswith("进入占"):
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


def draw_funnel_table(draw, box, rows, denominators, config):
    x0, y0, x1, y1 = box
    feature_w = 330
    metrics = [config["metric"], "进入打勾率", "进入保存率"]
    subtitles = {
        config["metric"]: f"四级功能进入 / Face-{config['metric'].split()[-1]} 进入",
        "进入打勾率": "打勾 / 四级功能进入",
        "进入保存率": "保存 / 四级功能进入",
    }
    metric_w = (x1 - x0 - feature_w) / len(metrics)
    header_h = 106
    row_h = (y1 - y0 - header_h) / len(rows)
    body_y = y0 + header_h

    draw.rectangle((x0, y0, x1, body_y), fill=COLORS["header"])
    draw.text(
        (x0 + 20, y0 + 20),
        config["feature_header"],
        font=font(24, True),
        fill=COLORS["text"],
    )
    draw.text(
        (x0 + 20, y0 + 61),
        "巴西进入人数（日均 UV）",
        font=font(16),
        fill=COLORS["muted"],
    )
    for column, metric in enumerate(metrics):
        mx0 = x0 + feature_w + column * metric_w
        draw.line((mx0, y0, mx0, y1), fill=COLORS["line"], width=2)
        centered_text(
            draw,
            (mx0, y0 + 8, mx0 + metric_w, y0 + 56),
            metric,
            font(22, True),
            COLORS["text"],
        )
        centered_text(
            draw,
            (mx0, y0 + 57, mx0 + metric_w, body_y - 3),
            subtitles[metric],
            font(14),
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
            (x0 + 18, ry0 + 12),
            row["feature"].replace("_", " "),
            font=font(21),
            fill=COLORS["text"],
        )
        draw.text(
            (x0 + 18, ry0 + 46),
            f"巴西进入 {float(row['br']['进入人数']):,.0f} 人/日",
            font=font(14),
            fill=COLORS["muted"],
        )
        for column, metric in enumerate(metrics):
            mx0 = x0 + feature_w + column * metric_w
            br_value, overall_value = metric_pair(
                row, denominators, metric
            )
            gap = br_value - overall_value
            if gap <= -0.01:
                color = COLORS["negative"]
            elif gap >= 0.01:
                color = COLORS["positive"]
            else:
                color = COLORS["neutral"]
            centered_text(
                draw,
                (mx0, ry0 + 3, mx0 + metric_w, ry0 + 33),
                f"{gap * 100:+.1f}pp",
                font(20, True),
                color,
            )
            bar_x0 = mx0 + 45
            bar_x1 = mx0 + metric_w - 45
            bar_mid = (bar_x0 + bar_x1) / 2
            bar_y0, bar_y1 = ry0 + 37, ry0 + 48
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
            length = min(abs(gap) / 0.06, 1) * (bar_x1 - bar_x0) / 2
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
                (mx0, ry0 + 52, mx0 + metric_w, ry1 - 2),
                f"（{br_value * 100:.1f}% / {overall_value * 100:.1f}%）",
                font(14),
                COLORS["muted"],
            )


def draw_slider_panel(
    draw,
    box,
    feature,
    subitem,
    label,
    stats,
    distributions,
):
    x0, y0, x1, y1 = box
    draw.text(
        (x0, y0 + 1),
        label,
        font=font(19, True),
        fill=COLORS["text"],
    )
    br_stat = stats[("巴西", subitem)]
    overall_stat = stats[("整体", subitem)]
    stat_text = (
        f"调整率 {float(br_stat['子项调整率']) * 100:.1f}%"
        f"（{float(overall_stat['子项调整率']) * 100:.1f}%）  "
        f"中位值 {fmt_signed(br_stat['非零滑杆值中位数'])}"
        f"（{fmt_signed(overall_stat['非零滑杆值中位数'])}）"
    )
    stat_width = draw.textlength(stat_text, font=font(14, True))
    draw.text(
        (x1 - stat_width, y0 + 4),
        stat_text,
        font=font(14, True),
        fill=COLORS["brazil"],
    )

    px0, px1 = x0 + 42, x1
    py0, py1 = y0 + 39, y1 - 24
    br_dist = distributions[("巴西", subitem)]
    overall_dist = distributions[("整体", subitem)]
    centers = sorted(set(br_dist) | set(overall_dist))
    max_share = max(
        [br_dist.get(center, 0) for center in centers]
        + [overall_dist.get(center, 0) for center in centers]
        + [0.01]
    )
    max_axis = max(0.1, ((int(max_share * 20 - 1e-9) + 1) / 20))
    for grid_index in range(3):
        value = max_axis * grid_index / 2
        y = py1 - (py1 - py0) * grid_index / 2
        draw.line((px0, y, px1, y), fill=COLORS["line"], width=1)
        draw.text(
            (px0 - 38, y - 8),
            f"{value * 100:.0f}%",
            font=font(11),
            fill=COLORS["muted"],
        )

    zero_x = px0 + (px1 - px0) / 2
    draw.line((zero_x, py0, zero_x, py1), fill=COLORS["overall"], width=1)
    bar_width = max(2, int((px1 - px0) / len(centers) * 0.65))
    points = []
    for center in centers:
        x = px0 + (px1 - px0) * (center + 100) / 200
        overall_value = overall_dist.get(center, 0)
        br_value = br_dist.get(center, 0)
        overall_height = (py1 - py0) * overall_value / max_axis
        draw.rectangle(
            (
                x - bar_width / 2,
                py1 - overall_height,
                x + bar_width / 2,
                py1,
            ),
            fill=COLORS["overall_fill"],
        )
        br_y = py1 - (py1 - py0) * br_value / max_axis
        points.append((x, br_y))
    if len(points) > 1:
        draw.line(points, fill=COLORS["brazil"], width=3, joint="curve")
    for x, y in points:
        if y < py1 - 2:
            draw.ellipse((x - 2, y - 2, x + 2, y + 2), fill=COLORS["brazil"])
    for tick in [-100, 0, 100]:
        x = px0 + (px1 - px0) * (tick + 100) / 200
        label_tick = f"{tick:+d}" if tick else "0"
        tick_width = draw.textlength(label_tick, font=font(11))
        draw.text(
            (x - tick_width / 2, py1 + 5),
            label_tick,
            font=font(11),
            fill=COLORS["muted"],
        )


def draw_slider_section(draw, box, feature, config, stats, distributions):
    x0, y0, x1, y1 = box
    header_h = 106
    body_y = y0 + header_h
    draw.rectangle((x0, y0, x1, body_y), fill=COLORS["header"])
    draw.text(
        (x0 + 20, y0 + 19),
        "滑杆值分布",
        font=font(24, True),
        fill=COLORS["text"],
    )
    draw.text(
        (x0 + 20, y0 + 60),
        "非零值按 5 分箱；数值为 巴西（整体）",
        font=font(16),
        fill=COLORS["muted"],
    )
    draw.rectangle(
        (x1 - 250, y0 + 30, x1 - 226, y0 + 42),
        fill=COLORS["overall_fill"],
    )
    draw.text(
        (x1 - 216, y0 + 20),
        "整体",
        font=font(15),
        fill=COLORS["text"],
    )
    draw.line(
        (x1 - 130, y0 + 36, x1 - 92, y0 + 36),
        fill=COLORS["brazil"],
        width=3,
    )
    draw.text(
        (x1 - 82, y0 + 20),
        "巴西",
        font=font(15),
        fill=COLORS["text"],
    )
    draw.line((x0, body_y, x1, body_y), fill=COLORS["line"], width=2)

    panel_count = len(config["slider_order"])
    panel_h = (y1 - body_y) / panel_count
    for index, subitem in enumerate(config["slider_order"]):
        py0 = body_y + index * panel_h
        py1 = py0 + panel_h
        if index:
            draw.line((x0, py0, x1, py0), fill=COLORS["line"], width=1)
        draw_slider_panel(
            draw,
            (x0 + 18, py0 + 8, x1 - 18, py1 - 5),
            feature,
            subitem,
            config["slider_labels"][subitem],
            stats,
            distributions,
        )


def render_feature(feature):
    config = CONFIGS[feature]
    rows, denominators = read_funnel(config, feature)
    stats, distributions = read_slider_data(feature)

    width, height = 3000, 1510
    margin, top, bottom, gap = 48, 170, 95, 24
    funnel_w = 1830
    image = Image.new("RGB", (width, height), COLORS["bg"])
    draw = ImageDraw.Draw(image)

    draw.text(
        (margin, 28),
        config["title"],
        font=font(44, True),
        fill=COLORS["text"],
    )
    draw.text(
        (margin, 91),
        (
            "2026年6月 · 左侧展示四级功能进入与效果确认漏斗；"
            "右侧展示对应原始滑杆参数的调整率、中位值及非零值分布"
        ),
        font=font(22),
        fill=COLORS["muted"],
    )
    draw.ellipse((2500, 72, 2518, 90), fill=COLORS["brazil"])
    draw.text((2528, 64), "巴西", font=font(18), fill=COLORS["text"])
    draw.ellipse((2610, 72, 2628, 90), fill=COLORS["overall"])
    draw.text((2638, 64), "整体", font=font(18), fill=COLORS["text"])

    card = (margin, top, width - margin, height - bottom)
    draw.rounded_rectangle(
        card,
        radius=24,
        fill=COLORS["card"],
        outline=COLORS["line"],
        width=1,
    )
    funnel_box = (
        margin + 20,
        top + 15,
        margin + 20 + funnel_w,
        height - bottom - 15,
    )
    divider_x = funnel_box[2] + gap / 2
    draw.line(
        (divider_x, top + 15, divider_x, height - bottom - 15),
        fill=COLORS["line"],
        width=2,
    )
    slider_box = (
        funnel_box[2] + gap,
        top + 15,
        width - margin - 20,
        height - bottom - 15,
    )

    draw_funnel_table(draw, funnel_box, rows, denominators, config)
    draw_slider_section(
        draw,
        slider_box,
        feature,
        config,
        stats,
        distributions,
    )

    draw.text(
        (margin + 16, height - 65),
        (
            f"Face-{feature} 进入：巴西 {denominators['巴西']:,.0f} 人/日，"
            f"整体 {denominators['整体']:,.0f} 人/日；"
            f"{config['note']}"
        ),
        font=font(15),
        fill=COLORS["muted"],
    )
    image.save(config["output"], format="PNG", optimize=True)
    print(config["output"])


def main():
    for feature in ["Jaw", "Nose"]:
        render_feature(feature)


if __name__ == "__main__":
    main()
