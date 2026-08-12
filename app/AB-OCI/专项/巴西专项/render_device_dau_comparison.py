#!/usr/bin/env python3
import csv
import importlib.util
from collections import defaultdict
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path("/Users/xuyunhui/Documents/项目")
OUTPUT_DIR = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302"
SOURCES = {
    "巴西": OUTPUT_DIR / "日活机型分布_巴西_202606.csv",
    "整体": OUTPUT_DIR / "日活机型分布_整体_202606.csv",
}
CLASSIFIER_PATH = (
    ROOT / "app/AB-OCI/专项/巴西专项/analyze_device_distribution.py"
)
OUTPUT_1 = OUTPUT_DIR / "巴西vs整体_分端与Android品牌DAU占比_202606.png"
OUTPUT_2 = OUTPUT_DIR / "巴西vs整体_Android价格档位与Top25机型DAU占比_202606.png"
SUMMARY_1 = OUTPUT_DIR / "巴西vs整体_分端与Android品牌DAU占比_202606.csv"
SUMMARY_2 = OUTPUT_DIR / "巴西vs整体_Android价格档位与Top25机型DAU占比_202606.csv"

FONT_PATH = "/System/Library/Fonts/PingFang.ttc"
COLORS = {
    "bg": "#F3F5F8",
    "card": "#FFFFFF",
    "header": "#F7F9FC",
    "stripe": "#FAFBFD",
    "text": "#1D2939",
    "muted": "#8190A5",
    "line": "#E1E6ED",
    "track": "#E7EBF1",
    "brazil": "#E85D3F",
    "overall": "#446FA8",
    "positive": "#D94A44",
    "negative": "#27835D",
    "neutral": "#667085",
    "android": "#55A36C",
    "ios": "#5577C9",
    "low": "#D98B35",
    "mid": "#5577C9",
    "high": "#7D57B2",
    "unknown": "#AAB3C0",
}


def font(size, bold=False):
    return ImageFont.truetype(FONT_PATH, size=size, index=1 if bold else 0)


FONTS = {
    "title": font(42, True),
    "subtitle": font(21),
    "section": font(28, True),
    "header": font(20, True),
    "body": font(20),
    "small": font(16),
    "value": font(19, True),
    "footnote": font(15),
}


def load_classifier():
    spec = importlib.util.spec_from_file_location("device_classifier", CLASSIFIER_PATH)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


classifier = load_classifier()


MODEL_ALIASES = {
    ("Samsung", "SM-A155M"): "Galaxy A15",
    ("Samsung", "SM-A566E"): "Galaxy A56",
    ("Samsung", "SM-A065M"): "Galaxy A06",
    ("Samsung", "SM-A556E"): "Galaxy A55",
    ("Samsung", "SM-A546E"): "Galaxy A54",
    ("Samsung", "SM-A075M"): "Galaxy A07",
    ("Samsung", "SM-A165M"): "Galaxy A16",
    ("Samsung", "SM-A146M"): "Galaxy A14",
    ("Samsung", "SM-A156M"): "Galaxy A15 5G",
    ("Samsung", "SM-A057M"): "Galaxy A05s",
    ("Samsung", "SM-A145M"): "Galaxy A14",
    ("Samsung", "SM-S911B"): "Galaxy S23",
    ("Samsung", "SM-S721B"): "Galaxy S24 FE",
    ("Samsung", "SM-S711B"): "Galaxy S23 FE",
    ("Samsung", "SM-S918B"): "Galaxy S23 Ultra",
    ("Samsung", "SM-S928B"): "Galaxy S24 Ultra",
    ("Samsung", "SM-A356E"): "Galaxy A35",
    ("Samsung", "SM-A366E"): "Galaxy A36",
    ("Samsung", "SM-A055M"): "Galaxy A05",
    ("Xiaomi", "23129RA5FL"): "Redmi Note 13 4G",
    ("Xiaomi", "24117RN76L"): "Redmi Note 14 4G",
    ("Xiaomi", "23100RN82L"): "Redmi 13C",
    ("POCO", "2412DPC0AG"): "POCO X7 Pro",
}


def display_model(brand, model):
    alias = MODEL_ALIASES.get((brand, model))
    if alias:
        return f"{alias} · {model}"
    if brand == "Motorola" and model.casefold().startswith("moto"):
        return model
    return f"{brand} · {model}"


def read_rows():
    rows = []
    dates = defaultdict(set)
    for market, path in SOURCES.items():
        with path.open(encoding="utf-8-sig", newline="") as handle:
            for raw in csv.DictReader(handle):
                os_name = raw.get("os_p") or raw.get("a.os_p")
                date_value = raw.get("date_p") or raw.get("a.date_p")
                brand = classifier.normalize_brand(raw["brand"])
                model = raw["device_model"].strip()
                dau = int(raw["dau"])
                row = {
                    "market": market,
                    "date": date_value,
                    "os": os_name,
                    "brand": brand,
                    "model": model,
                    "dau": dau,
                    "tier": (
                        classifier.android_tier(brand, model)
                        if os_name == "android"
                        else "未分类"
                    ),
                }
                rows.append(row)
                dates[market].add(date_value)
    return rows, {market: len(values) for market, values in dates.items()}


def aggregate(rows, date_counts):
    platform = defaultdict(int)
    brand = defaultdict(int)
    model = defaultdict(int)
    tier = defaultdict(int)
    for row in rows:
        platform[(row["market"], row["os"])] += row["dau"]
        if row["os"] == "android":
            brand[(row["market"], row["brand"])] += row["dau"]
            model[(row["market"], row["brand"], row["model"])] += row["dau"]
            tier[(row["market"], row["tier"])] += row["dau"]

    total = {
        market: platform[(market, "android")] + platform[(market, "ios")]
        for market in ("巴西", "整体")
    }
    avg_dau = {
        (market, os_name): platform[(market, os_name)] / date_counts[market]
        for market in ("巴西", "整体")
        for os_name in ("android", "ios")
    }
    return {
        "platform": platform,
        "brand": brand,
        "model": model,
        "tier": tier,
        "total": total,
        "avg_dau": avg_dau,
    }


def pct(value):
    return f"{value * 100:.1f}%"


def gap_text(value):
    return f"{value * 100:+.1f}pp"


def gap_color(value):
    if value >= 0.002:
        return COLORS["positive"]
    if value <= -0.002:
        return COLORS["negative"]
    return COLORS["neutral"]


def draw_title(draw, title, subtitle):
    draw.text((48, 30), title, font=FONTS["title"], fill=COLORS["text"])
    draw.text((48, 91), subtitle, font=FONTS["subtitle"], fill=COLORS["muted"])


def draw_card(draw, box):
    draw.rounded_rectangle(box, radius=22, fill=COLORS["card"])


def draw_share_bar(draw, x1, y, x2, value, color, max_value=1.0):
    draw.rounded_rectangle((x1, y, x2, y + 12), radius=6, fill=COLORS["track"])
    width = max(0, min(1, value / max_value)) * (x2 - x1)
    if width > 0:
        draw.rounded_rectangle((x1, y, x1 + width, y + 12), radius=6, fill=color)


def render_platform_and_brand(data, date_counts):
    width = 1800
    height = 1590
    image = Image.new("RGB", (width, height), COLORS["bg"])
    draw = ImageDraw.Draw(image)
    draw_title(
        draw,
        "巴西 vs 整体｜分端与 Android 品牌 DAU 占比",
        "2026年6月日均；分端分母为总DAU，品牌分母为Android DAU；gap＝巴西－整体。",
    )

    platform_box = (48, 145, width - 48, 500)
    draw_card(draw, platform_box)
    draw.text((78, 175), "分端占比", font=FONTS["section"], fill=COLORS["text"])
    x_bar1, x_bar2 = 330, 1420
    for index, market in enumerate(("巴西", "整体")):
        y = 245 + index * 105
        android = (
            data["platform"][(market, "android")] / data["total"][market]
        )
        ios = data["platform"][(market, "ios")] / data["total"][market]
        draw.text((82, y + 5), market, font=FONTS["header"], fill=COLORS["text"])
        split = x_bar1 + (x_bar2 - x_bar1) * android
        draw.rounded_rectangle(
            (x_bar1, y, x_bar2, y + 40),
            radius=20,
            fill=COLORS["ios"],
        )
        draw.rounded_rectangle(
            (x_bar1, y, split, y + 40),
            radius=20,
            fill=COLORS["android"],
        )
        draw.text(
            (x_bar1 + 18, y + 7),
            f"Android {pct(android)}",
            font=FONTS["value"],
            fill="#FFFFFF",
        )
        ios_label = f"iOS {pct(ios)}"
        label_box = draw.textbbox((0, 0), ios_label, font=FONTS["value"])
        draw.text(
            (x_bar2 - (label_box[2] - label_box[0]) - 18, y + 7),
            ios_label,
            font=FONTS["value"],
            fill="#FFFFFF",
        )
        draw.text(
            (1460, y + 8),
            f"Android DAU {data['avg_dau'][(market, 'android')]:,.0f}",
            font=FONTS["small"],
            fill=COLORS["muted"],
        )
    android_gap = (
        data["platform"][("巴西", "android")] / data["total"]["巴西"]
        - data["platform"][("整体", "android")] / data["total"]["整体"]
    )
    draw.text(
        (82, 444),
        f"Android 占比 gap：{gap_text(android_gap)}",
        font=FONTS["value"],
        fill=gap_color(android_gap),
    )

    brand_box = (48, 530, width - 48, height - 52)
    draw_card(draw, brand_box)
    draw.text((78, 560), "Android 品牌占比", font=FONTS["section"], fill=COLORS["text"])
    headers = [("品牌", 80), ("巴西", 510), ("整体", 960), ("gap", 1490)]
    for label, x in headers:
        draw.text((x, 618), label, font=FONTS["header"], fill=COLORS["muted"])
    draw.line((76, 657, width - 76, 657), fill=COLORS["line"], width=2)

    br_android = data["platform"][("巴西", "android")]
    overall_android = data["platform"][("整体", "android")]
    brands = sorted(
        {
            key[1]
            for key in data["brand"]
            if key[0] in {"巴西", "整体"}
        },
        key=lambda name: -data["brand"][("巴西", name)],
    )
    top_brands = brands[:10]
    rows = []
    for name in top_brands:
        rows.append(
            (
                name,
                data["brand"][("巴西", name)] / br_android,
                data["brand"][("整体", name)] / overall_android,
            )
        )
    other_br = 1 - sum(value[1] for value in rows)
    other_overall = 1 - sum(value[2] for value in rows)
    rows.append(("其他", other_br, other_overall))

    row_h = 73
    for index, (name, br_share, overall_share) in enumerate(rows):
        y = 658 + index * row_h
        if index % 2:
            draw.rectangle((70, y, width - 70, y + row_h), fill=COLORS["stripe"])
        draw.text((82, y + 22), name, font=FONTS["body"], fill=COLORS["text"])
        draw_share_bar(draw, 510, y + 31, 820, br_share, COLORS["brazil"], 0.5)
        draw.text((835, y + 20), pct(br_share), font=FONTS["value"], fill=COLORS["text"])
        draw_share_bar(draw, 960, y + 31, 1270, overall_share, COLORS["overall"], 0.5)
        draw.text(
            (1285, y + 20),
            pct(overall_share),
            font=FONTS["value"],
            fill=COLORS["text"],
        )
        gap = br_share - overall_share
        draw.text(
            (1490, y + 20),
            gap_text(gap),
            font=FONTS["value"],
            fill=gap_color(gap),
        )
    draw.text(
        (78, height - 86),
        f"有效日期：巴西 {date_counts['巴西']} 日，整体 {date_counts['整体']} 日；品牌大小写已合并。",
        font=FONTS["footnote"],
        fill=COLORS["muted"],
    )
    image.save(OUTPUT_1, quality=96)


def render_tier_and_models(data, date_counts):
    width = 1900
    top = 145
    tier_h = 420
    row_h = 70
    header_h = 95
    model_h = header_h + 25 * row_h + 80
    height = top + tier_h + 28 + model_h + 48
    image = Image.new("RGB", (width, height), COLORS["bg"])
    draw = ImageDraw.Draw(image)
    draw_title(
        draw,
        "巴西 vs 整体｜Android 价格档位与 Top25 机型 DAU 占比",
        "2026年6月日均；分母均为各市场Android DAU；gap＝巴西－整体。",
    )

    tier_box = (48, top, width - 48, top + tier_h)
    draw_card(draw, tier_box)
    draw.text((78, top + 30), "价格档位占比", font=FONTS["section"], fill=COLORS["text"])
    draw.text(
        (78, top + 74),
        "低端＜R$1,500｜中端R$1,500–3,999｜高端≥R$4,000｜未知=无法可靠识别",
        font=FONTS["small"],
        fill=COLORS["muted"],
    )

    tier_colors = {
        "低端": COLORS["low"],
        "中端": COLORS["mid"],
        "高端": COLORS["high"],
        "未知": COLORS["unknown"],
    }
    br_android = data["platform"][("巴西", "android")]
    overall_android = data["platform"][("整体", "android")]
    headers = [("档位", 82), ("巴西", 430), ("整体", 930), ("gap", 1510)]
    for label, x in headers:
        draw.text((x, top + 120), label, font=FONTS["header"], fill=COLORS["muted"])
    for index, tier_name in enumerate(("低端", "中端", "高端", "未知")):
        y = top + 164 + index * 58
        br_share = data["tier"][("巴西", tier_name)] / br_android
        overall_share = data["tier"][("整体", tier_name)] / overall_android
        draw.ellipse((82, y + 8, 98, y + 24), fill=tier_colors[tier_name])
        draw.text((112, y + 3), tier_name, font=FONTS["body"], fill=COLORS["text"])
        draw_share_bar(draw, 430, y + 14, 730, br_share, COLORS["brazil"], 0.6)
        draw.text((748, y + 3), pct(br_share), font=FONTS["value"], fill=COLORS["text"])
        draw_share_bar(draw, 930, y + 14, 1230, overall_share, COLORS["overall"], 0.6)
        draw.text(
            (1248, y + 3),
            pct(overall_share),
            font=FONTS["value"],
            fill=COLORS["text"],
        )
        gap = br_share - overall_share
        draw.text(
            (1510, y + 3),
            gap_text(gap),
            font=FONTS["value"],
            fill=gap_color(gap),
        )

    model_top = top + tier_h + 28
    model_box = (48, model_top, width - 48, model_top + model_h)
    draw_card(draw, model_box)
    draw.text((78, model_top + 28), "Android Top25 机型占比", font=FONTS["section"], fill=COLORS["text"])
    headers = [
        ("机型", 82),
        ("档位", 710),
        ("巴西", 860),
        ("整体", 1260),
        ("gap", 1680),
    ]
    for label, x in headers:
        draw.text((x, model_top + 75), label, font=FONTS["header"], fill=COLORS["muted"])
    header_y = model_top + header_h
    draw.line((76, header_y, width - 76, header_y), fill=COLORS["line"], width=2)

    models = sorted(
        {
            (key[1], key[2])
            for key in data["model"]
            if key[0] == "巴西"
        },
        key=lambda pair: -data["model"][("巴西", pair[0], pair[1])],
    )[:25]
    for index, (brand_name, model_name) in enumerate(models):
        y = header_y + index * row_h
        if index % 2:
            draw.rectangle((70, y, width - 70, y + row_h), fill=COLORS["stripe"])
        br_share = data["model"][("巴西", brand_name, model_name)] / br_android
        overall_share = (
            data["model"][("整体", brand_name, model_name)] / overall_android
        )
        tier_name = classifier.android_tier(brand_name, model_name)
        label = display_model(brand_name, model_name)
        if len(label) > 44:
            label = label[:43] + "…"
        draw.text((82, y + 20), label, font=FONTS["body"], fill=COLORS["text"])
        draw.text((710, y + 20), tier_name, font=FONTS["body"], fill=COLORS["text"])
        draw_share_bar(draw, 860, y + 29, 1060, br_share, COLORS["brazil"], 0.03)
        draw.text((1075, y + 18), pct(br_share), font=FONTS["value"], fill=COLORS["text"])
        draw_share_bar(draw, 1260, y + 29, 1460, overall_share, COLORS["overall"], 0.03)
        draw.text(
            (1475, y + 18),
            pct(overall_share),
            font=FONTS["value"],
            fill=COLORS["text"],
        )
        gap = br_share - overall_share
        draw.text(
            (1680, y + 18),
            gap_text(gap),
            font=FONTS["value"],
            fill=gap_color(gap),
        )
    draw.text(
        (78, model_top + model_h - 54),
        f"有效日期：巴西 {date_counts['巴西']} 日，整体 {date_counts['整体']} 日；Top25按巴西机型日均DAU排序。",
        font=FONTS["footnote"],
        fill=COLORS["muted"],
    )
    image.save(OUTPUT_2, quality=96)


def export_summaries(data):
    with SUMMARY_1.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "dimension",
                "item",
                "brazil_share",
                "overall_share",
                "gap_pp",
            ],
        )
        writer.writeheader()
        for os_name in ("android", "ios"):
            br_share = data["platform"][("巴西", os_name)] / data["total"]["巴西"]
            overall_share = (
                data["platform"][("整体", os_name)] / data["total"]["整体"]
            )
            writer.writerow(
                {
                    "dimension": "platform",
                    "item": os_name,
                    "brazil_share": br_share,
                    "overall_share": overall_share,
                    "gap_pp": (br_share - overall_share) * 100,
                }
            )
        br_android = data["platform"][("巴西", "android")]
        overall_android = data["platform"][("整体", "android")]
        brands = sorted(
            {key[1] for key in data["brand"]},
            key=lambda name: -data["brand"][("巴西", name)],
        )
        for brand_name in brands:
            br_share = data["brand"][("巴西", brand_name)] / br_android
            overall_share = data["brand"][("整体", brand_name)] / overall_android
            writer.writerow(
                {
                    "dimension": "android_brand",
                    "item": brand_name,
                    "brazil_share": br_share,
                    "overall_share": overall_share,
                    "gap_pp": (br_share - overall_share) * 100,
                }
            )

    with SUMMARY_2.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "dimension",
                "brand",
                "item",
                "tier",
                "brazil_share",
                "overall_share",
                "gap_pp",
            ],
        )
        writer.writeheader()
        br_android = data["platform"][("巴西", "android")]
        overall_android = data["platform"][("整体", "android")]
        for tier_name in ("低端", "中端", "高端", "未知"):
            br_share = data["tier"][("巴西", tier_name)] / br_android
            overall_share = data["tier"][("整体", tier_name)] / overall_android
            writer.writerow(
                {
                    "dimension": "price_tier",
                    "brand": "",
                    "item": tier_name,
                    "tier": tier_name,
                    "brazil_share": br_share,
                    "overall_share": overall_share,
                    "gap_pp": (br_share - overall_share) * 100,
                }
            )
        models = sorted(
            {
                (key[1], key[2])
                for key in data["model"]
                if key[0] == "巴西"
            },
            key=lambda pair: -data["model"][("巴西", pair[0], pair[1])],
        )[:25]
        for brand_name, model_name in models:
            br_share = data["model"][("巴西", brand_name, model_name)] / br_android
            overall_share = (
                data["model"][("整体", brand_name, model_name)] / overall_android
            )
            writer.writerow(
                {
                    "dimension": "android_model",
                    "brand": brand_name,
                    "item": model_name,
                    "tier": classifier.android_tier(brand_name, model_name),
                    "brazil_share": br_share,
                    "overall_share": overall_share,
                    "gap_pp": (br_share - overall_share) * 100,
                }
            )


def main():
    rows, date_counts = read_rows()
    data = aggregate(rows, date_counts)
    export_summaries(data)
    render_platform_and_brand(data, date_counts)
    render_tier_and_models(data, date_counts)
    print(f"dates={date_counts}")
    for market in ("巴西", "整体"):
        android_share = (
            data["platform"][(market, "android")] / data["total"][market]
        )
        unknown_share = (
            data["tier"][(market, "未知")]
            / data["platform"][(market, "android")]
        )
        print(
            market,
            f"android_share={android_share:.6f}",
            f"unknown_price_share={unknown_share:.6f}",
        )
    for path in (OUTPUT_1, OUTPUT_2, SUMMARY_1, SUMMARY_2):
        print(path)


if __name__ == "__main__":
    main()
