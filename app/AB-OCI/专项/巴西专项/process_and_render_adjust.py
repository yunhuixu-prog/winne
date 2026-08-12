#!/usr/bin/env python3
import csv
import math
from collections import defaultdict
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path("/Users/xuyunhui/Documents/项目")
OUTPUT_DIR = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302"
INPUTS = [
    OUTPUT_DIR / "Adjust子项及滑杆值分布_整体_202606.csv",
    OUTPUT_DIR / "Adjust子项及滑杆值分布_重点市场_202606.csv",
]
SUMMARY_CSV = OUTPUT_DIR / "巴西专项_Adjust子功能对比_202606.csv"
DISTRIBUTION_CSV = OUTPUT_DIR / "巴西专项_Adjust滑杆值分布_步长5_202606.csv"
STATS_CSV = OUTPUT_DIR / "巴西专项_Adjust滑杆使用摘要_202606.csv"
FUNNEL_PNG = OUTPUT_DIR / "巴西专项_Adjust子功能进入使用对比.png"
DISTRIBUTION_PNG = OUTPUT_DIR / "巴西专项_Adjust滑杆值分布.png"
FONT_PATH = "/System/Library/Fonts/PingFang.ttc"

MARKETS = ["整体", "巴西", "美国", "英国", "墨西哥"]
PARAMETERS = [
    "brightness",
    "highlights",
    "shadows",
    "contrast",
    "saturation",
    "sharpness",
    "temperature",
    "auto",
    "flash",
    "grain",
    "fade",
    "deglare",
    "vignette",
]
SIGNED = {
    "brightness",
    "highlights",
    "shadows",
    "contrast",
    "saturation",
    "temperature",
}
UNSIGNED = {
    "sharpness",
    "flash",
    "grain",
    "fade",
    "deglare",
    "vignette",
}
LABELS = {
    "brightness": "Brightness｜亮度",
    "highlights": "Highlights｜高光",
    "shadows": "Shadows｜阴影",
    "contrast": "Contrast｜对比度",
    "saturation": "Saturation｜饱和度",
    "sharpness": "Sharpness｜锐度",
    "temperature": "Temperature｜色温",
    "auto": "AI Auto｜自动",
    "flash": "Flash｜闪光",
    "grain": "Grain｜颗粒",
    "fade": "Fade｜褪色",
    "deglare": "Deglare｜去眩光",
    "vignette": "Vignette｜暗角",
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
    "positive": "#27835D",
    "negative": "#D33F3B",
    "neutral": "#667085",
    "track": "#E4E9F0",
    "zero": "#A9B3C2",
    "overall": "#667085",
}


def normalize_row(row):
    market = row.get("market_name") or row.get("e.market_name")
    parameter = row.get("parameter_name") or row.get("s.parameter_name")
    row_type = row.get("row_type") or row.get("s.row_type")
    raw_value = row.get("raw_value") or row.get("s.raw_value")
    if parameter == "ai_auto":
        parameter = "auto"
    return {
        "market": market,
        "parameter": parameter,
        "row_type": row_type,
        "raw_value": raw_value,
        "user_count": int(row["user_count"]),
        "event_count": int(row["event_count"]),
    }


def load_rows():
    rows = []
    for path in INPUTS:
        with path.open(encoding="utf-8-sig", newline="") as handle:
            rows.extend(normalize_row(row) for row in csv.DictReader(handle))
    return rows


def exact_row(rows, market, parameter, row_type):
    matches = [
        row for row in rows
        if row["market"] == market
        and row["parameter"] == parameter
        and row["row_type"] == row_type
    ]
    if len(matches) != 1:
        raise ValueError((market, parameter, row_type, len(matches)))
    return matches[0]


def weighted_median(values):
    total = sum(weight for _, weight in values)
    threshold = total / 2
    cumulative = 0
    for value, weight in sorted(values):
        cumulative += weight
        if cumulative >= threshold:
            return value
    return None


def bin_lower(value, lower_bound):
    lower = lower_bound + math.floor((value - lower_bound) / 5) * 5
    return max(lower_bound, min(100, int(lower)))


def bin_label(lower):
    upper = min(100, lower + 4)
    return f"{lower}～{upper}" if lower != upper else str(lower)


def build_summary(rows):
    del rows
    daily_rows = {}
    daily_inputs = sorted(
        OUTPUT_DIR.glob("Adjust子功能日均漏斗_整体_202606*.csv")
    ) + sorted(
        OUTPUT_DIR.glob("Adjust子功能日均漏斗_巴西_202606*.csv")
    )
    for path in daily_inputs:
        with path.open(encoding="utf-8-sig", newline="") as handle:
            for row in csv.DictReader(handle):
                key = (row["market_name"], row["date_p"])
                normalized = {
                    field: (
                        row[field]
                        if field in {"market_name", "date_p"}
                        else int(row[field])
                    )
                    for field in row
                }
                if key in daily_rows and daily_rows[key] != normalized:
                    raise ValueError(f"逐日数据重复且不一致：{key}")
                daily_rows[key] = normalized

    expected_dates = {
        f"202606{day:02d}"
        for day in range(1, 31)
    }
    for market in ["整体", "巴西"]:
        actual_dates = {
            date_p
            for row_market, date_p in daily_rows
            if row_market == market
        }
        if actual_dates != expected_dates:
            raise ValueError(
                f"{market}逐日数据不完整："
                f"缺少{sorted(expected_dates - actual_dates)}，"
                f"多出{sorted(actual_dates - expected_dates)}"
            )

    summary = []
    for market in ["整体", "巴西"]:
        selected = [
            row
            for (row_market, _), row in daily_rows.items()
            if row_market == market
        ]
        effective_days = len(selected)
        adjust_enter_sum = sum(row["adjust_enter"] for row in selected)
        for parameter in PARAMETERS:
            enter_sum = sum(
                row[f"{parameter}_enter"]
                for row in selected
            )
            used_sum = sum(
                row[f"{parameter}_used"]
                for row in selected
            )
            summary.append({
                "市场": market,
                "子功能": parameter,
                "子功能名称": LABELS[parameter],
                "进入人数_日均UV": enter_sum / effective_days,
                "使用人数_日均UV": used_sum / effective_days,
                "进入占Adjust": (
                    enter_sum / adjust_enter_sum
                    if adjust_enter_sum else 0
                ),
                "进入使用率": enter_sum and used_sum / enter_sum or 0,
                "Adjust进入人数_日均UV": (
                    adjust_enter_sum / effective_days
                ),
                "有效天数": effective_days,
            })
    with SUMMARY_CSV.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(summary[0]))
        writer.writeheader()
        writer.writerows(summary)
    return summary


def build_distribution(rows):
    distribution = []
    stats = []
    value_rows = [
        row for row in rows
        if row["row_type"] == "VALUE"
        and row["parameter"] in set(PARAMETERS)
    ]
    for market in MARKETS:
        for parameter in PARAMETERS:
            selected = [
                row for row in value_rows
                if row["market"] == market and row["parameter"] == parameter
            ]
            total_events = sum(row["event_count"] for row in selected)
            if parameter == "auto":
                valid = [
                    row for row in selected if row["raw_value"] in {"0", "1"}
                ]
                valid_total = sum(row["event_count"] for row in valid)
                for row in valid:
                    distribution.append({
                        "市场": market,
                        "子功能": parameter,
                        "分层下界": int(row["raw_value"]),
                        "分层上界": int(row["raw_value"]),
                        "分层": "开启（1）" if row["raw_value"] == "1" else "关闭（0）",
                        "事件次数": row["event_count"],
                        "非空事件占比": row["event_count"] / valid_total
                        if valid_total else 0,
                        "非零事件占比": None,
                    })
                enabled = sum(
                    row["event_count"] for row in valid if row["raw_value"] == "1"
                )
                stats.append({
                    "市场": market,
                    "子功能": parameter,
                    "总上报事件": valid_total,
                    "默认0事件占比": 1 - enabled / valid_total if valid_total else 0,
                    "非零事件占比": enabled / valid_total if valid_total else 0,
                    "非零均值": None,
                    "非零中位数": None,
                    "正值占比": None,
                    "异常事件数": 0,
                })
                continue

            lower_bound = -100 if parameter in SIGNED else 0
            valid_values = []
            invalid_events = 0
            zero_events = 0
            for row in selected:
                try:
                    value = float(row["raw_value"])
                except (TypeError, ValueError):
                    invalid_events += row["event_count"]
                    continue
                if not lower_bound <= value <= 100:
                    invalid_events += row["event_count"]
                    continue
                if value == 0:
                    zero_events += row["event_count"]
                    continue
                valid_values.append((value, row["event_count"]))

            nonzero_total = sum(weight for _, weight in valid_values)
            bins = defaultdict(int)
            for value, weight in valid_values:
                bins[bin_lower(value, lower_bound)] += weight
            for lower, count in sorted(bins.items()):
                distribution.append({
                    "市场": market,
                    "子功能": parameter,
                    "分层下界": lower,
                    "分层上界": min(100, lower + 4),
                    "分层": bin_label(lower),
                    "事件次数": count,
                    "非空事件占比": count / total_events if total_events else 0,
                    "非零事件占比": count / nonzero_total if nonzero_total else 0,
                })
            positive_events = sum(
                weight for value, weight in valid_values if value > 0
            )
            stats.append({
                "市场": market,
                "子功能": parameter,
                "总上报事件": total_events,
                "默认0事件占比": zero_events / total_events
                if total_events else 0,
                "非零事件占比": nonzero_total / total_events
                if total_events else 0,
                "非零均值": (
                    sum(value * weight for value, weight in valid_values)
                    / nonzero_total
                    if nonzero_total else None
                ),
                "非零中位数": weighted_median(valid_values),
                "正值占比": (
                    positive_events / nonzero_total
                    if parameter in SIGNED and nonzero_total else None
                ),
                "异常事件数": invalid_events,
            })

    with DISTRIBUTION_CSV.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(distribution[0]))
        writer.writeheader()
        writer.writerows(distribution)
    with STATS_CSV.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(stats[0]))
        writer.writeheader()
        writer.writerows(stats)
    return distribution, stats


def pil_font(size, index=0):
    return ImageFont.truetype(FONT_PATH, size=size, index=index)


PIL_FONTS = {
    "title": pil_font(44),
    "subtitle": pil_font(23),
    "header": pil_font(25),
    "feature": pil_font(25),
    "secondary": pil_font(17),
    "gap": pil_font(25),
    "value": pil_font(17),
    "footnote": pil_font(16),
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


def render_funnel(summary):
    index = {
        (row["市场"], row["子功能"]): row
        for row in summary
    }
    parameters = sorted(
        PARAMETERS,
        key=lambda parameter: -index[("巴西", parameter)]["进入人数_日均UV"],
    )
    metrics = ["进入占 Adjust", "进入使用率"]
    scales = {"进入占 Adjust": 0.03, "进入使用率": 0.04}

    width = 2260
    margin = 48
    top = 180
    header_h = 108
    row_h = 98
    footer_h = 86
    feature_w = 550
    card_h = header_h + row_h * len(parameters) + footer_h
    height = top + card_h + 48

    image = Image.new("RGB", (width, height), COLORS["bg"])
    draw = ImageDraw.Draw(image)
    draw.text(
        (margin, 30),
        "Adjust 子功能｜进入与实际使用对比",
        font=PIL_FONTS["title"],
        fill=COLORS["text"],
    )
    draw.text(
        (margin, 94),
        "按巴西子功能进入人数降序；每列展示 gap（巴西－整体）及巴西/整体具体值。",
        font=PIL_FONTS["subtitle"],
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
        "Adjust 子功能",
        font=PIL_FONTS["header"],
        fill=COLORS["text"],
    )
    draw.text(
        (inner_x + 22, top + 66),
        "巴西子功能进入人数（日均去重 UV）",
        font=PIL_FONTS["secondary"],
        fill=COLORS["muted"],
    )

    subtitles = {
        "进入占 Adjust": "子功能进入 / Adjust 二级进入",
        "进入使用率": "非默认最终值 UV / 子功能进入 UV",
    }
    for column, metric in enumerate(metrics):
        x1 = inner_x + feature_w + column * metric_w
        draw.rectangle((x1, top, x1 + metric_w, body_y), fill=COLORS["header"])
        draw.line((x1, top, x1, footer_y), fill=COLORS["line"], width=2)
        centered_text(
            draw,
            (x1, top + 14, x1 + metric_w, top + 60),
            metric,
            PIL_FONTS["header"],
            COLORS["text"],
        )
        centered_text(
            draw,
            (x1, top + 61, x1 + metric_w, body_y - 4),
            subtitles[metric],
            PIL_FONTS["secondary"],
            COLORS["muted"],
        )
    draw.line((inner_x, body_y, inner_x + inner_w, body_y), fill=COLORS["line"], width=2)

    for row_index, parameter in enumerate(parameters):
        y1 = body_y + row_index * row_h
        y2 = y1 + row_h
        fill = COLORS["card"] if row_index % 2 == 0 else COLORS["stripe"]
        draw.rectangle((inner_x, y1, inner_x + inner_w, y2), fill=fill)
        draw.rectangle((inner_x, y1, inner_x + 6, y2), fill=COLORS["accent"])
        if row_index:
            draw.line((inner_x, y1, inner_x + inner_w, y1), fill=COLORS["line"], width=1)
        brazil = index[("巴西", parameter)]
        overall = index[("整体", parameter)]
        draw.text(
            (inner_x + 24, y1 + 17),
            LABELS[parameter],
            font=PIL_FONTS["feature"],
            fill=COLORS["text"],
        )
        draw.text(
            (inner_x + 24, y1 + 59),
            f"巴西进入 {brazil['进入人数_日均UV']:,.0f} 人/日",
            font=PIL_FONTS["secondary"],
            fill=COLORS["muted"],
        )

        pairs = {
            "进入占 Adjust": (
                brazil["进入占Adjust"],
                overall["进入占Adjust"],
            ),
            "进入使用率": (
                brazil["进入使用率"],
                overall["进入使用率"],
            ),
        }
        for column, metric in enumerate(metrics):
            x1 = inner_x + feature_w + column * metric_w
            brazil_value, overall_value = pairs[metric]
            gap = brazil_value - overall_value
            if gap <= -0.005:
                gap_color = COLORS["negative"]
            elif gap >= 0.005:
                gap_color = COLORS["positive"]
            else:
                gap_color = COLORS["neutral"]
            centered_text(
                draw,
                (x1, y1 + 5, x1 + metric_w, y1 + 39),
                f"{gap * 100:+.1f}pp",
                PIL_FONTS["gap"],
                gap_color,
            )
            bar_x1 = x1 + 92
            bar_x2 = x1 + metric_w - 92
            bar_mid = (bar_x1 + bar_x2) / 2
            bar_y1 = y1 + 45
            bar_y2 = y1 + 58
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
            bar_length = min(abs(gap) / scales[metric], 1.0) * half_width
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
                (x1, y1 + 64, x1 + metric_w, y2 - 4),
                f"（{brazil_value * 100:.1f}% / {overall_value * 100:.1f}%）",
                PIL_FONTS["value"],
                COLORS["muted"],
            )

    draw.line((inner_x, footer_y, inner_x + inner_w, footer_y), fill=COLORS["line"], width=2)
    note = (
        "口径为6月1—30日的日去重 UV 之和计算比例；同一用户可进入多个子功能。"
        "进入使用率以打勾时最终值非0为使用，AI Auto 仅1计为使用；"
        "两列分别使用 ±3pp、±4pp 数据条刻度。"
    )
    draw.text(
        (inner_x + 16, footer_y + 28),
        note,
        font=PIL_FONTS["footnote"],
        fill=COLORS["muted"],
    )
    image.save(FUNNEL_PNG, format="PNG", optimize=True)


def render_distribution(distribution, stats):
    distribution_index = defaultdict(dict)
    for row in distribution:
        distribution_index[(row["市场"], row["子功能"])][
            row["分层下界"]
        ] = row["非零事件占比"]
    stats_index = {
        (row["市场"], row["子功能"]): row
        for row in stats
    }
    plot_order = [
        "brightness",
        "highlights",
        "shadows",
        "contrast",
        "saturation",
        "temperature",
        "sharpness",
        "grain",
        "fade",
        "vignette",
        "flash",
        "deglare",
        "auto",
    ]

    width = 3200
    height = 2420
    margin_x = 70
    top = 210
    bottom = 80
    gap_x = 28
    gap_y = 28
    panel_w = (width - 2 * margin_x - 3 * gap_x) // 4
    panel_h = (height - top - bottom - 3 * gap_y) // 4
    image = Image.new("RGB", (width, height), COLORS["bg"])
    draw = ImageDraw.Draw(image)

    title_font = pil_font(46)
    subtitle_font = pil_font(22)
    panel_title_font = pil_font(25)
    panel_note_font = pil_font(16)
    tick_font = pil_font(15)
    value_font = pil_font(17)
    footnote_font = pil_font(18)

    draw.text(
        (margin_x, 36),
        "Adjust 滑杆值使用分布｜巴西 vs 整体",
        font=title_font,
        fill=COLORS["text"],
    )
    draw.text(
        (margin_x, 106),
        "2026年6月 second_func_use；数值滑杆按步长5分层，曲线为非0事件内分布；面板注释依次为巴西/整体。",
        font=subtitle_font,
        fill=COLORS["muted"],
    )
    legend_x = width - 430
    draw.line((legend_x, 112, legend_x + 62, 112), fill=COLORS["accent"], width=7)
    draw.text((legend_x + 76, 96), "巴西", font=value_font, fill=COLORS["text"])
    draw.line((legend_x + 190, 112, legend_x + 252, 112), fill=COLORS["overall"], width=5)
    draw.text((legend_x + 266, 96), "整体", font=value_font, fill=COLORS["text"])

    for panel_index, parameter in enumerate(plot_order):
        row_index = panel_index // 4
        column_index = panel_index % 4
        x1 = margin_x + column_index * (panel_w + gap_x)
        y1 = top + row_index * (panel_h + gap_y)
        x2 = x1 + panel_w
        y2 = y1 + panel_h
        draw.rounded_rectangle((x1, y1, x2, y2), radius=20, fill=COLORS["card"])
        draw.text(
            (x1 + 24, y1 + 19),
            LABELS[parameter],
            font=panel_title_font,
            fill=COLORS["text"],
        )

        plot_left = x1 + 66
        plot_right = x2 - 30
        plot_top = y1 + 112
        plot_bottom = y2 - 54
        plot_width = plot_right - plot_left
        plot_height = plot_bottom - plot_top

        if parameter == "auto":
            draw.text(
                (x1 + 24, y1 + 63),
                "全部非空上报事件",
                font=panel_note_font,
                fill=COLORS["muted"],
            )
            values = {}
            for market in ["整体", "巴西"]:
                values[market] = [
                    next(
                        (
                            item["非空事件占比"]
                            for item in distribution
                            if item["市场"] == market
                            and item["子功能"] == parameter
                            and item["分层下界"] == category
                        ),
                        0,
                    )
                    for category in [0, 1]
                ]
            draw.line(
                (plot_left, plot_bottom, plot_right, plot_bottom),
                fill=COLORS["line"],
                width=2,
            )
            centers = [
                plot_left + plot_width * 0.3,
                plot_left + plot_width * 0.75,
            ]
            bar_width = 68
            for category_index, center in enumerate(centers):
                for offset, market, color in [
                    (-bar_width, "整体", COLORS["overall"]),
                    (8, "巴西", COLORS["accent"]),
                ]:
                    value = values[market][category_index]
                    bar_height = value * plot_height * 0.9
                    bx1 = center + offset
                    bx2 = bx1 + bar_width - 10
                    by1 = plot_bottom - bar_height
                    draw.rounded_rectangle(
                        (bx1, by1, bx2, plot_bottom),
                        radius=8,
                        fill=color,
                    )
                    centered_text(
                        draw,
                        (bx1 - 12, by1 - 34, bx2 + 12, by1 - 4),
                        f"{value:.1%}",
                        value_font,
                        color,
                    )
                centered_text(
                    draw,
                    (center - 100, plot_bottom + 10, center + 100, y2 - 8),
                    "关闭（0）" if category_index == 0 else "开启（1）",
                    tick_font,
                    COLORS["muted"],
                )
            continue

        brazil_stats = stats_index[("巴西", parameter)]
        overall_stats = stats_index[("整体", parameter)]
        draw.text(
            (x1 + 24, y1 + 63),
            (
                f"非0事件 {brazil_stats['非零事件占比']:.1%}/"
                f"{overall_stats['非零事件占比']:.1%}  ·  "
                f"中位 {brazil_stats['非零中位数']:.0f}/"
                f"{overall_stats['非零中位数']:.0f}"
            ),
            font=panel_note_font,
            fill=COLORS["muted"],
        )

        lower_bound = -100 if parameter in SIGNED else 0
        x_values = list(range(lower_bound, 101, 5))
        series = {
            market: [
                distribution_index[(market, parameter)].get(value, 0)
                for value in x_values
            ]
            for market in ["整体", "巴西"]
        }
        max_y = max(
            max(series["整体"], default=0),
            max(series["巴西"], default=0),
            0.01,
        ) * 1.15
        for fraction in [0, 0.5, 1]:
            y = plot_bottom - fraction * plot_height
            draw.line((plot_left, y, plot_right, y), fill=COLORS["line"], width=1)
            label = f"{max_y * fraction:.0%}"
            bbox = draw.textbbox((0, 0), label, font=tick_font)
            draw.text(
                (plot_left - (bbox[2] - bbox[0]) - 10, y - 10),
                label,
                font=tick_font,
                fill=COLORS["muted"],
            )
        if parameter in SIGNED:
            zero_x = plot_left + (0 - lower_bound) / (100 - lower_bound) * plot_width
            draw.line((zero_x, plot_top, zero_x, plot_bottom), fill=COLORS["zero"], width=2)

        for market, color, line_width in [
            ("整体", COLORS["overall"], 4),
            ("巴西", COLORS["accent"], 6),
        ]:
            points = []
            for value, share in zip(x_values, series[market]):
                px = plot_left + (value - lower_bound) / (100 - lower_bound) * plot_width
                py = plot_bottom - share / max_y * plot_height
                points.append((px, py))
            if len(points) > 1:
                draw.line(points, fill=color, width=line_width, joint="curve")

        ticks = [-100, -50, 0, 50, 100] if parameter in SIGNED else [0, 25, 50, 75, 100]
        for tick in ticks:
            tx = plot_left + (tick - lower_bound) / (100 - lower_bound) * plot_width
            draw.line((tx, plot_bottom, tx, plot_bottom + 6), fill=COLORS["line"], width=2)
            centered_text(
                draw,
                (tx - 38, plot_bottom + 9, tx + 38, y2 - 7),
                str(tick),
                tick_font,
                COLORS["muted"],
            )

    note = (
        "数值0视为未使用，不进入曲线；AI Auto 单独展示0/1全部非空事件。"
        "Deglare发现1次-19异常值（巴西与整体同一条），已从0～100分布剔除。"
    )
    draw.text(
        (margin_x, height - 48),
        note,
        font=footnote_font,
        fill=COLORS["muted"],
    )
    image.save(DISTRIBUTION_PNG, format="PNG", optimize=True)


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    rows = load_rows()
    summary = build_summary(rows)
    distribution, stats = build_distribution(rows)
    render_funnel(summary)
    render_distribution(distribution, stats)
    print({
        "summary_csv": str(SUMMARY_CSV),
        "distribution_csv": str(DISTRIBUTION_CSV),
        "stats_csv": str(STATS_CSV),
        "funnel_png": str(FUNNEL_PNG),
        "distribution_png": str(DISTRIBUTION_PNG),
    })


if __name__ == "__main__":
    main()
