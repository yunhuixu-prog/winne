#!/usr/bin/env python3
import csv
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


SOURCE = Path(
    "/Users/xuyunhui/Documents/项目/outputs/"
    "019f839e-6d3f-7a81-b0ac-450473a2e302/"
    "AI任务成功率及耗时_巴西vs整体_202606.csv"
)
OUTPUT = Path(
    "/Users/xuyunhui/Documents/项目/outputs/"
    "019f839e-6d3f-7a81-b0ac-450473a2e302/"
    "巴西专项_AI任务表现对比_202606.png"
)

FONT_PATH = "/System/Library/Fonts/PingFang.ttc"
COLORS = {
    "bg": "#F3F5F9",
    "card": "#FFFFFF",
    "header": "#F7F8FA",
    "text": "#182230",
    "muted": "#7B8798",
    "line": "#E4E9F0",
    "track": "#E6EAF0",
    "zero": "#AEB7C5",
    "positive": "#27835D",
    "negative": "#CF3633",
    "neutral": "#667085",
    "focus": "#FFF8EB",
    "focus_accent": "#D97706",
}


def font(size):
    return ImageFont.truetype(FONT_PATH, size=size)


F = {
    "title": font(43),
    "subtitle": font(22),
    "header": font(23),
    "feature": font(25),
    "secondary": font(17),
    "gap": font(22),
    "value": font(16),
    "note": font(16),
}


def number(value):
    if value in ("", "\\N", None):
        return None
    return float(value)


def integer(value):
    parsed = number(value)
    return int(parsed) if parsed is not None else 0


def read_rows():
    with SOURCE.open("r", encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle))


def raw_row(rows, market, second, third):
    for row in rows:
        if (
            row["market_name"] == market
            and row["event_detail.second_func_raw"] == second
            and row["event_detail.third_func_raw"] == third
        ):
            return normalize(row)
    raise KeyError((market, second, third))


def normalize(row):
    return {
        "pv": integer(row["create_task_pv"]),
        "uv": integer(row["create_task_uv"]),
        "success_pv": integer(row["success_task_pv"]),
        "failed_pv": integer(row["failed_task_pv"]),
        "cancel_pv": integer(row["manual_cancel_task_pv"]),
        "success_rate": number(row["success_rate"]) or 0,
        "failed_rate": number(row["failed_rate"]) or 0,
        "cancel_rate": number(row["manual_cancel_rate"]) or 0,
        "success_ms": number(row["success_avg_time_ms"]),
        "failed_ms": number(row["failed_avg_time_ms"]),
        "cancel_ms": number(row["manual_cancel_avg_time_ms"]),
        "success_valid": integer(row["success_time_valid_pv"]),
        "failed_valid": integer(row["failed_time_valid_pv"]),
        "cancel_valid": integer(row["manual_cancel_time_valid_pv"]),
    }


def aggregate_relight(rows, market):
    parts = [
        normalize(row)
        for row in rows
        if row["market_name"] == market
        and row["event_detail.second_func_raw"] == "relight"
    ]
    result = {
        key: sum(part[key] for part in parts)
        for key in (
            "pv",
            "success_pv",
            "failed_pv",
            "cancel_pv",
            "success_valid",
            "failed_valid",
            "cancel_valid",
        )
    }
    result["uv"] = None
    result["success_rate"] = result["success_pv"] / result["pv"]
    result["failed_rate"] = result["failed_pv"] / result["pv"]
    result["cancel_rate"] = result["cancel_pv"] / result["pv"]
    for prefix in ("success", "failed", "cancel"):
        valid = result[f"{prefix}_valid"]
        result[f"{prefix}_ms"] = (
            sum((part[f"{prefix}_ms"] or 0) * part[f"{prefix}_valid"] for part in parts)
            / valid
            if valid
            else None
        )
    return result


def centered(draw, box, text, text_font, fill):
    x1, y1, x2, y2 = box
    bounds = draw.textbbox((0, 0), text, font=text_font)
    width = bounds[2] - bounds[0]
    height = bounds[3] - bounds[1]
    draw.text(
        (x1 + (x2 - x1 - width) / 2, y1 + (y2 - y1 - height) / 2 - 2),
        text,
        font=text_font,
        fill=fill,
    )


def shadow(base, box, radius=24):
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(
        (x1, y1 + 7, x2, y2 + 7),
        radius=radius,
        fill=(30, 41, 59, 18),
    )
    base.alpha_composite(layer)


def compact(value):
    if value is None:
        return "—"
    if value >= 1_000_000:
        return f"{value / 1_000_000:.2f}M"
    if value >= 1_000:
        return f"{value / 1_000:.1f}K"
    return f"{value:,}"


def metric_value(row, metric):
    if metric == "成功率":
        return row["success_rate"]
    if metric == "失败率":
        return row["failed_rate"]
    if metric == "手动取消率":
        return row["cancel_rate"]
    if metric == "成功耗时":
        return row["success_ms"] / 1000
    if metric == "失败耗时":
        return row["failed_ms"] / 1000
    if metric == "取消耗时":
        return row["cancel_ms"] / 1000
    raise ValueError(metric)


def draw_gap_metric(draw, x1, y1, width, height, br, overall, metric):
    br_value = metric_value(br, metric)
    overall_value = metric_value(overall, metric)
    gap = br_value - overall_value
    is_rate = metric.endswith("率")
    threshold = 0.01 if is_rate else 1.0
    if metric == "成功率":
        color = (
            COLORS["positive"]
            if gap >= threshold
            else COLORS["negative"]
            if gap <= -threshold
            else COLORS["neutral"]
        )
    else:
        color = (
            COLORS["negative"]
            if gap >= threshold
            else COLORS["positive"]
            if gap <= -threshold
            else COLORS["neutral"]
        )
    gap_text = f"{gap * 100:+.1f}pp" if is_rate else f"{gap:+.1f}s"
    value_text = (
        f"（{br_value * 100:.1f}% / {overall_value * 100:.1f}%）"
        if is_rate
        else f"（{br_value:.1f}s / {overall_value:.1f}s）"
    )
    centered(draw, (x1, y1 + 13, x1 + width, y1 + 46), gap_text, F["gap"], color)

    bar_x1, bar_x2 = x1 + 42, x1 + width - 42
    bar_mid = (bar_x1 + bar_x2) / 2
    bar_y1, bar_y2 = y1 + 52, y1 + 64
    draw.rounded_rectangle((bar_x1, bar_y1, bar_x2, bar_y2), radius=6, fill=COLORS["track"])
    draw.line((bar_mid, bar_y1 - 2, bar_mid, bar_y2 + 2), fill=COLORS["zero"], width=2)
    scale = 0.04 if is_rate else 30.0
    length = min(abs(gap) / scale, 1.0) * ((bar_x2 - bar_x1) / 2)
    if gap < 0:
        draw.rounded_rectangle((bar_mid - length, bar_y1, bar_mid, bar_y2), radius=6, fill=color)
    elif gap > 0:
        draw.rounded_rectangle((bar_mid, bar_y1, bar_mid + length, bar_y2), radius=6, fill=color)
    centered(draw, (x1, y1 + 69, x1 + width, y1 + height - 7), value_text, F["value"], COLORS["muted"])


def main():
    source_rows = read_rows()
    specs = [
        ("Auto候选*", "adjust / third_func为空", ("adjust", "\\N")),
        ("Flash", "adjust / flash", ("adjust", "flash")),
        ("Deglare", "adjust / deglare", ("adjust", "deglare")),
        ("Relight汇总", "relight / 全部third_func", None),
    ]
    rows = []
    for label, raw, key in specs:
        if key:
            overall = raw_row(source_rows, "整体", *key)
            brazil = raw_row(source_rows, "巴西", *key)
        else:
            overall = aggregate_relight(source_rows, "整体")
            brazil = aggregate_relight(source_rows, "巴西")
        rows.append({"label": label, "raw": raw, "br": brazil, "overall": overall})

    metrics = ["成功率", "失败率", "手动取消率", "成功耗时", "失败耗时", "取消耗时"]
    width = 2740
    margin = 48
    top = 178
    header_h = 104
    row_h = 132
    footer_h = 94
    card_h = header_h + row_h * len(rows) + footer_h
    height = top + card_h + 48
    image = Image.new("RGBA", (width, height), COLORS["bg"])
    draw = ImageDraw.Draw(image)

    draw.text((margin, 30), "巴西 AI 功能任务表现｜巴西 vs 整体", font=F["title"], fill=COLORS["text"])
    draw.text(
        (margin, 94),
        "2026年6月；gap=巴西−整体。率类越低通常越好仅适用于失败率、手动取消率；耗时单位为秒。",
        font=F["subtitle"],
        fill=COLORS["muted"],
    )

    card = (margin, top, width - margin, top + card_h)
    shadow(image, card)
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle(card, radius=26, fill=COLORS["card"])

    inner_x = margin + 26
    inner_w = width - 2 * margin - 52
    feature_w = 390
    volume_w = 300
    metric_w = (inner_w - feature_w - volume_w) / len(metrics)
    body_y = top + header_h
    footer_y = top + card_h - footer_h

    headers = [("功能", feature_w), ("任务量", volume_w)] + [(metric, metric_w) for metric in metrics]
    cursor = inner_x
    for title, col_w in headers:
        draw.rectangle((cursor, top, cursor + col_w, body_y), fill=COLORS["header"])
        centered(draw, (cursor, top + 16, cursor + col_w, top + 58), title, F["header"], COLORS["text"])
        sub = "原始上报值" if title == "功能" else "PV / UV（巴西 / 整体）" if title == "任务量" else "gap 数据条（巴西 / 整体）"
        centered(draw, (cursor, top + 58, cursor + col_w, body_y - 4), sub, F["secondary"], COLORS["muted"])
        if cursor > inner_x:
            draw.line((cursor, top, cursor, footer_y), fill=COLORS["line"], width=2)
        cursor += col_w

    for index, row in enumerate(rows):
        y1 = body_y + index * row_h
        y2 = y1 + row_h
        fill = COLORS["focus"] if row["label"] in ("Auto候选*", "Deglare") else COLORS["card"]
        draw.rectangle((inner_x, y1, inner_x + inner_w, y2), fill=fill)
        if index:
            draw.line((inner_x, y1, inner_x + inner_w, y1), fill=COLORS["line"], width=1)
        if fill == COLORS["focus"]:
            draw.rectangle((inner_x, y1, inner_x + 7, y2), fill=COLORS["focus_accent"])

        draw.text((inner_x + 22, y1 + 27), row["label"], font=F["feature"], fill=COLORS["text"])
        draw.text((inner_x + 22, y1 + 74), row["raw"], font=F["secondary"], fill=COLORS["muted"])

        volume_x = inner_x + feature_w
        br_uv = compact(row["br"]["uv"])
        overall_uv = compact(row["overall"]["uv"])
        centered(
            draw,
            (volume_x, y1 + 22, volume_x + volume_w, y1 + 60),
            f"PV  {compact(row['br']['pv'])} / {compact(row['overall']['pv'])}",
            F["secondary"],
            COLORS["text"],
        )
        centered(
            draw,
            (volume_x, y1 + 64, volume_x + volume_w, y1 + 102),
            f"UV  {br_uv} / {overall_uv}",
            F["secondary"],
            COLORS["muted"],
        )

        for metric_index, metric in enumerate(metrics):
            x1 = inner_x + feature_w + volume_w + metric_index * metric_w
            draw_gap_metric(draw, x1, y1, metric_w, row_h, row["br"], row["overall"], metric)

    draw.line((inner_x, footer_y, inner_x + inner_w, footer_y), fill=COLORS["line"], width=2)
    note1 = "红色表示巴西更差（成功率更低，或失败/取消率、耗时更高），绿色表示巴西更好；率类使用 ±4pp，耗时使用 ±30s。整体包含巴西。"
    note2 = "Auto候选*=原始 second_func=adjust 且 third_func 为空，需结合埋点定义确认；Relight按全部原始 third_func 加权汇总，UV不可跨子项去重。"
    draw.text((inner_x + 14, footer_y + 20), note1, font=F["note"], fill=COLORS["muted"])
    draw.text((inner_x + 14, footer_y + 52), note2, font=F["note"], fill=COLORS["muted"])

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(OUTPUT, quality=96)
    print(OUTPUT)


if __name__ == "__main__":
    main()
