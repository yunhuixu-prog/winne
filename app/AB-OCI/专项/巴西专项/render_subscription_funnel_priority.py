#!/usr/bin/env python3
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


BEHAVIOR_SOURCE = Path("/Users/xuyunhui/Documents/项目/app/AB-OCI/专项/巴西专项/巴西专项_功能数据_202606.json")
EXPOSURE_SOURCE = Path("/Users/xuyunhui/Documents/项目/app/AB-OCI/专项/巴西专项/巴西专项_订阅页曝光人数_202606.json")
OUTPUT = Path("/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西专项_功能订阅链路对比_去除P0P1_高清无阴影.png")
FONT_PATH = "/System/Library/Fonts/PingFang.ttc"
MONTH_DAYS = 30

FREE_FEATURES = {"Reshape", "Resize"}

COLORS = {
    "bg": "#F3F5F9", "card": "#FFFFFF", "text": "#182230", "muted": "#7B8798",
    "line": "#E5E9F0", "header": "#F7F8FA", "p0": "#C93532", "p0_soft": "#FFF2F1",
    "p1": "#D97706", "p1_soft": "#FFF8EB", "free": "#3769A6", "free_soft": "#F1F6FD",
    "normal_soft": "#FAFBFC", "normal_accent": "#D5DAE2", "positive": "#27835D",
    "negative": "#C93532", "neutral": "#667085", "bar_track": "#E6EAF0", "bar_zero": "#AEB7C5",
}


def font(size):
    return ImageFont.truetype(FONT_PATH, size=size)


FONTS = {
    "title": font(46), "subtitle": font(23), "header": font(24), "feature": font(25),
    "tag": font(17), "secondary": font(17), "gap": font(23), "value": font(17), "footnote": font(17),
}


def safe_div(num, den):
    return float(num) / float(den) if den else 0.0


def centered_text(draw, box, text, text_font, fill):
    x1, y1, x2, y2 = box
    bbox = draw.textbbox((0, 0), text, font=text_font)
    w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text((x1 + (x2 - x1 - w) / 2, y1 + (y2 - y1 - h) / 2 - 2), text, font=text_font, fill=fill)


def draw_shadow(base, box, radius=24):
    shadow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    x1, y1, x2, y2 = box
    sd.rounded_rectangle((x1, y1 + 8, x2, y2 + 8), radius=radius, fill=(30, 41, 59, 18))
    base.alpha_composite(shadow)


def metric_pair(br, overall, br_exposure, overall_exposure, metric):
    if metric == "打勾触发订阅页率":
        return safe_div(br_exposure, br["打勾人数"] * MONTH_DAYS), safe_div(overall_exposure, overall["打勾人数"] * MONTH_DAYS)
    if metric == "曝光订阅成功率":
        return safe_div(br["订阅成功人数"], br_exposure), safe_div(overall["订阅成功人数"], overall_exposure)
    if metric == "成功付费率":
        return safe_div(br["付费人数"], br["订阅成功人数"]), safe_div(overall["付费人数"], overall["订阅成功人数"])
    if metric == "付费 ARPPU":
        return safe_div(br["订阅收入（分成后）"], br["付费人数"]), safe_div(overall["订阅收入（分成后）"], overall["付费人数"])
    raise ValueError(metric)


def main():
    behavior = json.loads(BEHAVIOR_SOURCE.read_text(encoding="utf-8"))["rows"]
    exposures = json.loads(EXPOSURE_SOURCE.read_text(encoding="utf-8"))["rows"]
    index = {(r["国家维度"], r["功能"]): r for r in behavior}
    exposure_index = {(r["国家维度"], r["功能"]): float(r["订阅页曝光人数"]) for r in exposures}
    features = sorted(
        [feature for market, feature in exposure_index if market == "巴西"],
        key=lambda feature: (-exposure_index[("巴西", feature)], feature),
    )[:25]
    rows = [{
        "feature": feature,
        "free": feature in FREE_FEATURES,
        "br": index[("巴西", feature)],
        "overall": index[("整体", feature)],
        "br_exposure": exposure_index[("巴西", feature)],
        "overall_exposure": exposure_index[("整体", feature)],
    } for feature in features]

    metrics = ["打勾触发订阅页率", "曝光订阅成功率", "成功付费率", "付费 ARPPU"]
    scales = {"打勾触发订阅页率": 0.15, "曝光订阅成功率": 0.025, "成功付费率": 0.15, "付费 ARPPU": 15.0}
    thresholds = {"打勾触发订阅页率": 0.02, "曝光订阅成功率": 0.005, "成功付费率": 0.02, "付费 ARPPU": 2.0}

    width, margin, top = 2580, 48, 188
    header_h, row_h, footer_h = 106, 92, 128
    card_h = header_h + row_h * len(rows) + footer_h
    height = top + card_h + 48
    image = Image.new("RGBA", (width, height), COLORS["bg"])
    draw = ImageDraw.Draw(image)

    draw.text((margin, 34), "巴西订阅页曝光 Top 25｜功能订阅链路对比", font=FONTS["title"], fill=COLORS["text"])
    draw.text((margin, 102), "按巴西订阅页曝光人数从高到低；指标格式为 gap（巴西 / 整体），免费功能单独标识。", font=FONTS["subtitle"], fill=COLORS["muted"])
    legend_x = width - 300
    draw.rounded_rectangle((legend_x, 102, legend_x + 92, 136), radius=17, fill=COLORS["free"])
    centered_text(draw, (legend_x, 102, legend_x + 92, 136), "免费", FONTS["tag"], "#FFFFFF")
    draw.text((legend_x + 106, 103), "不判低触发", font=FONTS["secondary"], fill=COLORS["text"])

    card = (margin, top, width - margin, top + card_h)
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle(card, radius=26, fill=COLORS["card"])
    inner_x, inner_w = margin + 28, width - 2 * margin - 56
    feature_w = 500
    metric_w = (inner_w - feature_w) / 4
    body_y, footer_y = top + header_h, top + card_h - footer_h

    draw.rectangle((inner_x, top, inner_x + feature_w, body_y), fill=COLORS["header"])
    draw.text((inner_x + 22, top + 24), "功能", font=FONTS["header"], fill=COLORS["text"])
    draw.text((inner_x + 22, top + 64), "巴西订阅页曝光人数", font=FONTS["secondary"], fill=COLORS["muted"])
    subtitles = {
        "打勾触发订阅页率": "订阅页曝光 / 月折算打勾",
        "曝光订阅成功率": "订阅成功 / 订阅页曝光",
        "成功付费率": "付费人数 / 订阅成功人数",
        "付费 ARPPU": "订阅毛利 / 付费人数",
    }
    for j, metric in enumerate(metrics):
        x1 = inner_x + feature_w + j * metric_w
        draw.rectangle((x1, top, x1 + metric_w, body_y), fill=COLORS["header"])
        centered_text(draw, (x1, top + 16, x1 + metric_w, top + 58), metric, FONTS["header"], COLORS["text"])
        centered_text(draw, (x1, top + 57, x1 + metric_w, body_y - 5), subtitles[metric], FONTS["secondary"], COLORS["muted"])
        draw.line((x1, top, x1, footer_y), fill=COLORS["line"], width=2)
    draw.line((inner_x, body_y, inner_x + inner_w, body_y), fill=COLORS["line"], width=2)

    for i, row in enumerate(rows):
        y1, y2 = body_y + i * row_h, body_y + (i + 1) * row_h
        if row["free"]:
            accent, soft, tag = COLORS["free"], COLORS["free_soft"], "免费"
        else:
            accent, soft, tag = COLORS["normal_accent"], COLORS["card"] if i % 2 == 0 else COLORS["normal_soft"], None
        draw.rectangle((inner_x, y1, inner_x + inner_w, y2), fill=soft)
        draw.rectangle((inner_x, y1, inner_x + 7, y2), fill=accent)
        if i:
            draw.line((inner_x, y1, inner_x + inner_w, y1), fill=COLORS["line"], width=1)
        draw.text((inner_x + 24, y1 + 17), row["feature"], font=FONTS["feature"], fill=COLORS["text"])
        if tag:
            tag_x, tag_w = inner_x + 232, 72 if tag != "免费" else 84
            draw.rounded_rectangle((tag_x, y1 + 17, tag_x + tag_w, y1 + 49), radius=16, fill=accent)
            centered_text(draw, (tag_x, y1 + 17, tag_x + tag_w, y1 + 49), tag, FONTS["tag"], "#FFFFFF")
        draw.text((inner_x + 24, y1 + 57), f"巴西订阅页曝光 {row['br_exposure']:,.0f} 人/月", font=FONTS["secondary"], fill=COLORS["muted"])

        for j, metric in enumerate(metrics):
            br_value, overall_value = metric_pair(row["br"], row["overall"], row["br_exposure"], row["overall_exposure"], metric)
            gap = br_value - overall_value
            x1 = inner_x + feature_w + j * metric_w
            threshold = thresholds[metric]
            gap_color = COLORS["negative"] if gap <= -threshold else COLORS["positive"] if gap >= threshold else COLORS["neutral"]
            if metric == "付费 ARPPU":
                gap_text = f"{gap:+.1f} 美元"
                value_text = f"（${br_value:.1f} / ${overall_value:.1f}）"
            else:
                gap_text = f"{gap * 100:+.1f}pp"
                value_text = f"（{br_value * 100:.1f}% / {overall_value * 100:.1f}%）"
            centered_text(draw, (x1, y1 + 6, x1 + metric_w, y1 + 40), gap_text, FONTS["gap"], gap_color)
            bar_x1, bar_x2 = x1 + 64, x1 + metric_w - 64
            bar_mid, bar_y1, bar_y2 = (bar_x1 + bar_x2) / 2, y1 + 43, y1 + 55
            draw.rounded_rectangle((bar_x1, bar_y1, bar_x2, bar_y2), radius=6, fill=COLORS["bar_track"])
            draw.line((bar_mid, bar_y1 - 2, bar_mid, bar_y2 + 2), fill=COLORS["bar_zero"], width=2)
            half_width = (bar_x2 - bar_x1) / 2
            bar_length = min(abs(gap) / scales[metric], 1.0) * half_width
            if gap < 0 and bar_length:
                draw.rounded_rectangle((bar_mid - bar_length, bar_y1, bar_mid, bar_y2), radius=6, fill=COLORS["negative"])
            elif gap > 0 and bar_length:
                draw.rounded_rectangle((bar_mid, bar_y1, bar_mid + bar_length, bar_y2), radius=6, fill=COLORS["positive"])
            centered_text(draw, (x1, y1 + 59, x1 + metric_w, y2 - 5), value_text, FONTS["value"], COLORS["muted"])

    draw.line((inner_x, footer_y, inner_x + inner_w, footer_y), fill=COLORS["line"], width=2)
    note1 = "打勾触发订阅页率 = 月累计订阅页曝光 ÷（日均打勾人数 × 30），用于统一表5的日均/月累计口径，属于折算估计。"
    note2 = "Reshape/Resize 免费，不判低触发。"
    note3 = "数据条各列独立刻度：红色向左=巴西低于整体，绿色向右=高于整体；付费 ARPPU 受巴西定价与 SKU 结构影响，不单独作为产品体验问题。"
    draw.text((inner_x + 16, footer_y + 17), note1, font=FONTS["footnote"], fill=COLORS["muted"])
    draw.text((inner_x + 16, footer_y + 49), note2, font=FONTS["footnote"], fill=COLORS["muted"])
    draw.text((inner_x + 16, footer_y + 81), note3, font=FONTS["footnote"], fill=COLORS["muted"])

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(OUTPUT, quality=95)
    print(str(OUTPUT))


if __name__ == "__main__":
    main()
