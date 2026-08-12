#!/usr/bin/env python3
import csv
import math
from collections import Counter, defaultdict
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path("/Users/xuyunhui/Documents/项目")
OUTPUT_DIR = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302"
COUNT_INPUT = {
    market: OUTPUT_DIR / f"Face打勾子项数分布_{market}_202606.csv"
    for market in ["整体", "巴西"]
}
SLIDER_INPUT = {
    market: OUTPUT_DIR / f"Face_Jaw_Nose滑杆值分布_{market}_202606.csv"
    for market in ["整体", "巴西"]
}

COUNT_CSV = OUTPUT_DIR / "巴西专项_Face_Jaw_Nose子项数分布_202606.csv"
SLIDER_CSV = OUTPUT_DIR / "巴西专项_Face_Jaw_Nose滑杆值分布_步长5_202606.csv"
SLIDER_STATS_CSV = OUTPUT_DIR / "巴西专项_Face_Jaw_Nose滑杆使用摘要_202606.csv"
COUNT_PNG = OUTPUT_DIR / "巴西专项_Face_Jaw_Nose子项数分布.png"
SLIDER_PNG = OUTPUT_DIR / "巴西专项_Face_Jaw_Nose滑杆值分布.png"

FONT_PATH = "/System/Library/Fonts/PingFang.ttc"
COLORS = {
    "bg": "#F3F5F8",
    "card": "#FFFFFF",
    "text": "#172033",
    "muted": "#8390A3",
    "line": "#E3E8EF",
    "track": "#E9EDF3",
    "overall": "#A9B3C2",
    "overall_fill": "#DDE3EB",
    "brazil": "#D9443E",
    "brazil_fill": "#F3B7B2",
    "green": "#21835B",
}

FEATURE_LABELS = {
    "face": "Face 三级子项",
    "jaw": "Jaw 内部子项",
    "nose": "Nose 内部子项",
}
SLIDER_LABELS = {
    ("Jaw", "chin"): "Chin｜下巴",
    ("Jaw", "double_chin"): "Double Chin｜双下巴",
    ("Jaw", "jaw"): "Jaw｜下颌",
    ("Jaw", "jaw_line"): "Jaw Line｜下颌线",
    ("Jaw", "length"): "Length｜长度",
    ("Jaw", "jaw_shape"): "Jaw Shape｜轮廓形状",
    ("Jaw", "double_chin_pro"): "Double Chin Pro｜双下巴 Pro",
    ("Nose", "size"): "Size｜大小",
    ("Nose", "length"): "Length｜长度",
    ("Nose", "width"): "Width｜宽度",
    ("Nose", "bridge"): "Bridge｜鼻梁",
    ("Nose", "tip"): "Tip｜鼻尖",
    ("Nose", "root"): "Root｜山根",
}
SLIDER_ORDER = {
    "Jaw": [
        "chin",
        "double_chin",
        "jaw",
        "jaw_line",
        "length",
        "jaw_shape",
        "double_chin_pro",
    ],
    "Nose": ["size", "length", "width", "bridge", "tip", "root"],
}
BIN_CENTERS = list(range(-98, 98, 5)) + [100]


def font(size, bold=False):
    return ImageFont.truetype(
        FONT_PATH,
        size=size,
        index=1 if bold else 0,
    )


def rounded_rect(draw, box, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(
        box,
        radius=radius,
        fill=fill,
        outline=outline,
        width=width,
    )


def fmt_pct(value, digits=1):
    return f"{value * 100:.{digits}f}%"


def fmt_signed(value, digits=1):
    if value is None:
        return "—"
    sign = "+" if value > 0 else ""
    return f"{sign}{value:.{digits}f}"


def weighted_median(counter):
    total = sum(counter.values())
    if not total:
        return None
    threshold = total / 2
    cumulative = 0
    for value, weight in sorted(counter.items()):
        cumulative += weight
        if cumulative >= threshold:
            return value
    return None


def load_count_data():
    result = {}
    csv_rows = []
    for market, path in COUNT_INPUT.items():
        with path.open(encoding="utf-8-sig", newline="") as handle:
            row = next(csv.DictReader(handle))
        total_event_count = int(row["total_event_count"])
        result[market] = {}
        for feature, maximum in [("face", 7), ("jaw", 7), ("nose", 6)]:
            counts = [int(row[f"{feature}_{i}"]) for i in range(maximum + 1)]
            total = sum(counts)
            if total != total_event_count:
                raise ValueError(
                    f"{market}/{feature} count sum {total} != {total_event_count}"
                )
            distribution = [value / total for value in counts]
            average = sum(i * value for i, value in enumerate(counts)) / total
            positive_share = 1 - distribution[0]
            positive_average = average / positive_share if positive_share else 0
            multi_share_all = sum(distribution[2:])
            multi_share_positive = (
                multi_share_all / positive_share if positive_share else 0
            )
            result[market][feature] = {
                "counts": counts,
                "distribution": distribution,
                "average": average,
                "positive_share": positive_share,
                "positive_average": positive_average,
                "multi_share_all": multi_share_all,
                "multi_share_positive": multi_share_positive,
                "total": total,
            }
            for count, (event_count, share) in enumerate(
                zip(counts, distribution)
            ):
                csv_rows.append({
                    "市场": market,
                    "层级": feature,
                    "层级名称": FEATURE_LABELS[feature],
                    "使用子项数": count,
                    "事件数": event_count,
                    "事件占比": share,
                    "平均使用子项数_全量Face打勾事件": average,
                    "至少使用1项占比": positive_share,
                    "平均使用子项数_至少使用1项事件": positive_average,
                    "至少使用2项占比_全量Face打勾事件": multi_share_all,
                    "至少使用2项占比_至少使用1项事件": multi_share_positive,
                })
    with COUNT_CSV.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(csv_rows[0]))
        writer.writeheader()
        writer.writerows(csv_rows)
    return result


def parse_values(raw_value):
    values = []
    for token in (raw_value or "").split(","):
        token = token.strip()
        if not token:
            continue
        try:
            value = float(token)
        except ValueError:
            continue
        if -100 <= value <= 100:
            values.append(value)
    return values


def bin_center(value):
    lower = math.floor((value + 100) / 5) * 5 - 100
    lower = max(-100, min(100, lower))
    return lower if lower == 100 else lower + 2


def load_slider_data():
    summaries = {}
    distributions = {}
    invalid_weight = defaultdict(int)
    for market, path in SLIDER_INPUT.items():
        accumulators = defaultdict(lambda: {
            "reported_events": 0,
            "adjusted_events": 0,
            "nonzero_values": Counter(),
            "raw_slots": 0,
            "zero_slots": 0,
        })
        with path.open(encoding="utf-8-sig", newline="") as handle:
            for row in csv.DictReader(handle):
                key = (
                    row["slider_value.feature_name"],
                    row["slider_value.subitem_name"],
                )
                weight = int(row["value_count"])
                raw_tokens = [
                    token.strip()
                    for token in row["slider_value.raw_value"].split(",")
                    if token.strip()
                ]
                values = parse_values(row["slider_value.raw_value"])
                invalid_weight[(market, *key)] += (
                    len(raw_tokens) - len(values)
                ) * weight
                if not values:
                    continue
                acc = accumulators[key]
                acc["reported_events"] += weight
                acc["raw_slots"] += len(values) * weight
                acc["zero_slots"] += sum(value == 0 for value in values) * weight
                nonzero_values = [value for value in values if value != 0]
                if nonzero_values:
                    acc["adjusted_events"] += weight
                for value in nonzero_values:
                    acc["nonzero_values"][value] += weight

        for key, acc in accumulators.items():
            total_nonzero = sum(acc["nonzero_values"].values())
            median = weighted_median(acc["nonzero_values"])
            mean = (
                sum(value * weight for value, weight in acc["nonzero_values"].items())
                / total_nonzero
                if total_nonzero else None
            )
            summary = {
                "市场": market,
                "功能": key[0],
                "子项": key[1],
                "子项名称": SLIDER_LABELS.get(key, key[1]),
                "参数上报事件数": acc["reported_events"],
                "至少一个非零值事件数": acc["adjusted_events"],
                "子项调整率": (
                    acc["adjusted_events"] / acc["reported_events"]
                    if acc["reported_events"] else 0
                ),
                "非零滑杆值中位数": median,
                "非零滑杆值均值": mean,
                "有效滑杆值个数": acc["raw_slots"],
                "零值个数": acc["zero_slots"],
                "异常值权重": invalid_weight[(market, *key)],
            }
            summaries[(market, *key)] = summary

            bins = Counter()
            for value, weight in acc["nonzero_values"].items():
                bins[bin_center(value)] += weight
            distributions[(market, *key)] = {
                center: weight / total_nonzero
                for center, weight in bins.items()
            } if total_nonzero else {}

    summary_rows = [summaries[key] for key in sorted(summaries)]
    with SLIDER_STATS_CSV.open(
        "w", encoding="utf-8-sig", newline=""
    ) as handle:
        writer = csv.DictWriter(handle, fieldnames=list(summary_rows[0]))
        writer.writeheader()
        writer.writerows(summary_rows)

    distribution_rows = []
    for (market, feature, subitem), dist in sorted(distributions.items()):
        for center in BIN_CENTERS:
            distribution_rows.append({
                "市场": market,
                "功能": feature,
                "子项": subitem,
                "分箱中心": center,
                "分箱范围": (
                    "100"
                    if center == 100
                    else f"{center - 2}～{center + 2}"
                ),
                "非零滑杆值占比": dist.get(center, 0),
            })
    with SLIDER_CSV.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=list(distribution_rows[0]),
        )
        writer.writeheader()
        writer.writerows(distribution_rows)
    return summaries, distributions


def render_count_distribution(data):
    width, height = 2400, 1120
    image = Image.new("RGB", (width, height), COLORS["bg"])
    draw = ImageDraw.Draw(image)

    draw.text(
        (60, 46),
        "Face / Jaw / Nose｜同次打勾使用子项数分布",
        font=font(42, True),
        fill=COLORS["text"],
    )
    draw.text(
        (60, 104),
        "2026年6月 · 每条 Face 打勾事件为一次观察；Face 统计三级子项，Jaw / Nose 统计内部滑杆子项",
        font=font(22),
        fill=COLORS["muted"],
    )
    draw.ellipse((1760, 70, 1778, 88), fill=COLORS["brazil"])
    draw.text((1788, 63), "巴西", font=font(20), fill=COLORS["text"])
    draw.ellipse((1870, 70, 1888, 88), fill=COLORS["overall"])
    draw.text((1898, 63), "整体", font=font(20), fill=COLORS["text"])
    draw.text(
        (2020, 63),
        "柱高为事件占比",
        font=font(20),
        fill=COLORS["muted"],
    )

    card_y0, card_y1 = 165, 1045
    rounded_rect(
        draw,
        (45, card_y0, width - 45, card_y1),
        22,
        COLORS["card"],
        COLORS["line"],
        1,
    )

    panel_width = 760
    panel_gap = 10
    panel_xs = [65, 65 + panel_width + panel_gap, 65 + (panel_width + panel_gap) * 2]
    for index, feature in enumerate(["face", "jaw", "nose"]):
        x0 = panel_xs[index]
        x1 = x0 + panel_width
        if index:
            draw.line(
                (x0 - 5, card_y0 + 20, x0 - 5, card_y1 - 20),
                fill=COLORS["line"],
                width=2,
            )
        draw.text(
            (x0 + 24, card_y0 + 28),
            FEATURE_LABELS[feature],
            font=font(30, True),
            fill=COLORS["text"],
        )

        b = data["巴西"][feature]
        o = data["整体"][feature]
        if feature == "face":
            metric_lines = [
                f"平均使用：巴西 {b['average']:.2f}（整体 {o['average']:.2f}）",
                (
                    f"至少 2 项：巴西 {fmt_pct(b['multi_share_all'])}"
                    f"（整体 {fmt_pct(o['multi_share_all'])}）"
                ),
            ]
        else:
            metric_lines = [
                (
                    f"至少使用 1 项：巴西 {fmt_pct(b['positive_share'])}"
                    f"（整体 {fmt_pct(o['positive_share'])}）"
                ),
                (
                    f"使用者平均：巴西 {b['positive_average']:.2f}"
                    f"（整体 {o['positive_average']:.2f}）"
                ),
                (
                    f"使用者中 ≥2 项：巴西 {fmt_pct(b['multi_share_positive'])}"
                    f"（整体 {fmt_pct(o['multi_share_positive'])}）"
                ),
            ]
        for line_index, line in enumerate(metric_lines):
            draw.text(
                (x0 + 24, card_y0 + 78 + line_index * 31),
                line,
                font=font(18, bold=line_index == 0),
                fill=COLORS["text"] if line_index == 0 else COLORS["muted"],
            )

        plot_x0, plot_x1 = x0 + 60, x1 - 30
        plot_y0, plot_y1 = card_y0 + 235, card_y1 - 95
        max_share = max(
            max(b["distribution"]),
            max(o["distribution"]),
        )
        max_axis = math.ceil(max_share * 10) / 10
        max_axis = max(0.2, max_axis)
        for grid_index in range(5):
            value = max_axis * grid_index / 4
            y = plot_y1 - (plot_y1 - plot_y0) * grid_index / 4
            draw.line((plot_x0, y, plot_x1, y), fill=COLORS["line"], width=1)
            draw.text(
                (plot_x0 - 50, y - 10),
                fmt_pct(value, 0),
                font=font(15),
                fill=COLORS["muted"],
            )

        n = len(b["distribution"])
        group_width = (plot_x1 - plot_x0) / n
        bar_width = max(12, int(group_width * 0.26))
        for item_index in range(n):
            center = plot_x0 + group_width * (item_index + 0.5)
            for market_index, (market, color) in enumerate([
                ("整体", COLORS["overall"]),
                ("巴西", COLORS["brazil"]),
            ]):
                value = data[market][feature]["distribution"][item_index]
                bar_height = (plot_y1 - plot_y0) * value / max_axis
                offset = -bar_width if market_index == 0 else 0
                bx0 = int(center + offset)
                bx1 = bx0 + bar_width
                by0 = int(plot_y1 - bar_height)
                draw.rounded_rectangle(
                    (bx0, by0, bx1, plot_y1),
                    radius=4,
                    fill=color,
                )
                if value >= 0.035:
                    label = fmt_pct(value)
                    label_width = draw.textlength(label, font=font(14))
                    label_y = by0 - 22
                    other_market = "整体" if market == "巴西" else "巴西"
                    other_value = data[other_market][feature]["distribution"][
                        item_index
                    ]
                    if other_value >= 0.035:
                        other_by0 = int(
                            plot_y1
                            - (plot_y1 - plot_y0) * other_value / max_axis
                        )
                        top_y = min(by0, other_by0)
                        label_y = top_y - (42 if market == "巴西" else 22)
                    draw.text(
                        (bx0 + (bar_width - label_width) / 2, label_y),
                        label,
                        font=font(14),
                        fill=color if market == "巴西" else COLORS["muted"],
                    )
            label_width = draw.textlength(str(item_index), font=font(18))
            draw.text(
                (center - label_width / 2 - 1, plot_y1 + 18),
                str(item_index),
                font=font(18),
                fill=COLORS["text"],
            )

        draw.text(
            ((plot_x0 + plot_x1) / 2 - 42, plot_y1 + 55),
            "使用子项数",
            font=font(17),
            fill=COLORS["muted"],
        )

    draw.text(
        (65, 1065),
        "口径：Face 打勾事件（second_func_use, second_func=face）；非零参数视为使用。Jaw/Nose 的“使用者”指至少调整其内部 1 个子项的事件。",
        font=font(17),
        fill=COLORS["muted"],
    )
    image.save(COUNT_PNG, quality=96)


def draw_slider_panel(
    draw,
    box,
    key,
    summaries,
    distributions,
):
    x0, y0, x1, y1 = box
    draw.text(
        (x0, y0),
        SLIDER_LABELS[key],
        font=font(25, True),
        fill=COLORS["text"],
    )
    b = summaries[("巴西", *key)]
    o = summaries[("整体", *key)]
    b_rate = b["子项调整率"]
    o_rate = o["子项调整率"]
    gap = b_rate - o_rate
    rate_color = (
        COLORS["brazil"]
        if abs(gap) >= 0.01
        else COLORS["text"]
    )
    stat_text = (
        f"调整率 {fmt_pct(b_rate)}（{fmt_pct(o_rate)}）  "
        f"中位值 {fmt_signed(b['非零滑杆值中位数'], 0)}"
        f"（{fmt_signed(o['非零滑杆值中位数'], 0)}）"
    )
    stat_width = draw.textlength(stat_text, font=font(17, True))
    draw.text(
        (x1 - stat_width, y0 + 5),
        stat_text,
        font=font(17, True),
        fill=rate_color,
    )

    px0, px1 = x0 + 50, x1
    py0, py1 = y0 + 50, y1 - 30
    b_dist = distributions[("巴西", *key)]
    o_dist = distributions[("整体", *key)]
    centers = BIN_CENTERS
    max_share = max(
        [b_dist.get(center, 0) for center in centers]
        + [o_dist.get(center, 0) for center in centers]
        + [0.01]
    )
    max_axis = math.ceil(max_share * 20) / 20
    max_axis = max(0.1, max_axis)

    for grid_index in range(3):
        value = max_axis * grid_index / 2
        y = py1 - (py1 - py0) * grid_index / 2
        draw.line((px0, y, px1, y), fill=COLORS["line"], width=1)
        draw.text(
            (px0 - 46, y - 9),
            fmt_pct(value, 0),
            font=font(13),
            fill=COLORS["muted"],
        )
    zero_x = px0 + (px1 - px0) * 100 / 200
    draw.line((zero_x, py0, zero_x, py1), fill=COLORS["overall"], width=1)

    points = []
    bar_width = max(2, int((px1 - px0) / len(centers) * 0.65))
    for center in centers:
        x = px0 + (px1 - px0) * (center + 98) / 200
        o_value = o_dist.get(center, 0)
        b_value = b_dist.get(center, 0)
        o_height = (py1 - py0) * o_value / max_axis
        draw.rectangle(
            (x - bar_width / 2, py1 - o_height, x + bar_width / 2, py1),
            fill=COLORS["overall_fill"],
        )
        b_y = py1 - (py1 - py0) * b_value / max_axis
        points.append((x, b_y))
    if len(points) >= 2:
        draw.line(points, fill=COLORS["brazil"], width=3, joint="curve")
    for x, y in points:
        if y < py1 - 3:
            draw.ellipse((x - 2, y - 2, x + 2, y + 2), fill=COLORS["brazil"])

    for tick in [-100, -50, 0, 50, 100]:
        x = px0 + (px1 - px0) * (tick + 100) / 200
        label = fmt_signed(tick, 0)
        label_width = draw.textlength(label, font=font(14))
        draw.text(
            (x - label_width / 2, py1 + 8),
            label,
            font=font(14),
            fill=COLORS["muted"],
        )


def render_slider_distribution(summaries, distributions):
    width, height = 2400, 2560
    image = Image.new("RGB", (width, height), COLORS["bg"])
    draw = ImageDraw.Draw(image)

    draw.text(
        (60, 42),
        "Face｜Jaw 与 Nose 滑杆值分布",
        font=font(42, True),
        fill=COLORS["text"],
    )
    draw.text(
        (60, 100),
        "2026年6月 · 非零滑杆值按 5 分箱；数值格式为 巴西（整体）",
        font=font(22),
        fill=COLORS["muted"],
    )
    draw.rectangle((1770, 69, 1795, 81), fill=COLORS["overall_fill"])
    draw.text((1805, 59), "整体分布", font=font(19), fill=COLORS["text"])
    draw.line((1945, 75, 1990, 75), fill=COLORS["brazil"], width=4)
    draw.text((2000, 59), "巴西分布", font=font(19), fill=COLORS["text"])

    card_y0, card_y1 = 160, 2460
    rounded_rect(
        draw,
        (45, card_y0, width - 45, card_y1),
        22,
        COLORS["card"],
        COLORS["line"],
        1,
    )
    left_x0, left_x1 = 80, 1170
    right_x0, right_x1 = 1230, 2320
    draw.text(
        (left_x0, card_y0 + 25),
        "Jaw",
        font=font(30, True),
        fill=COLORS["text"],
    )
    draw.text(
        (right_x0, card_y0 + 25),
        "Nose",
        font=font(30, True),
        fill=COLORS["text"],
    )
    draw.line(
        (1200, card_y0 + 20, 1200, card_y1 - 20),
        fill=COLORS["line"],
        width=2,
    )

    panel_height = 300
    start_y = card_y0 + 85
    for row_index, subitem in enumerate(SLIDER_ORDER["Jaw"]):
        y0 = start_y + row_index * panel_height
        y1 = y0 + panel_height - 18
        if row_index:
            draw.line(
                (left_x0, y0 - 9, left_x1, y0 - 9),
                fill=COLORS["line"],
                width=1,
            )
        draw_slider_panel(
            draw,
            (left_x0, y0, left_x1, y1),
            ("Jaw", subitem),
            summaries,
            distributions,
        )
    for row_index, subitem in enumerate(SLIDER_ORDER["Nose"]):
        y0 = start_y + row_index * panel_height
        y1 = y0 + panel_height - 18
        if row_index:
            draw.line(
                (right_x0, y0 - 9, right_x1, y0 - 9),
                fill=COLORS["line"],
                width=1,
            )
        draw_slider_panel(
            draw,
            (right_x0, y0, right_x1, y1),
            ("Nose", subitem),
            summaries,
            distributions,
        )

    draw.text(
        (65, 2480),
        "调整率＝该参数上报事件中至少存在一个非零滑杆值的事件占比；分布按非零滑杆值加权，逗号分隔的多人脸值逐个拆分；异常值已剔除。",
        font=font(17),
        fill=COLORS["muted"],
    )
    image.save(SLIDER_PNG, quality=96)


def main():
    count_data = load_count_data()
    slider_summaries, slider_distributions = load_slider_data()
    render_count_distribution(count_data)
    render_slider_distribution(slider_summaries, slider_distributions)
    print(COUNT_CSV)
    print(SLIDER_CSV)
    print(SLIDER_STATS_CSV)
    print(COUNT_PNG)
    print(SLIDER_PNG)


if __name__ == "__main__":
    main()
