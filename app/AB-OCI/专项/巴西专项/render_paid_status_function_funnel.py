#!/usr/bin/env python3
import csv
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


OUTPUT_DIR = Path(
    "/Users/xuyunhui/Documents/项目/outputs/"
    "019f839e-6d3f-7a81-b0ac-450473a2e302"
)
INPUT_CSV = OUTPUT_DIR / "巴西专项_功能行为_当前付费状态_202606.csv"
ANALYSIS_CSV = OUTPUT_DIR / "巴西专项_功能行为_当前付费状态_对比分析_202606.csv"

METRICS = [
    ("曝光进入率", "曝光进入率"),
    ("进入打勾率", "进入打勾率"),
    ("打勾保存率", "打勾保存率"),
    ("进入保存率", "进入保存率"),
]

P0 = {"Face", "Skin Tone", "Eraser"}
P1 = {"Body", "Relight", "AI Retouch", "Glowup", "Brighten"}
WATCH = {"Hair", "AI Repair", "Wrinkle", "Concealer"}

COLORS = {
    "canvas": "#F3F6FA",
    "card": "#FFFFFF",
    "header": "#F7F9FC",
    "line": "#E4E9F1",
    "text": "#1F2937",
    "muted": "#8996A8",
    "red": "#D33B35",
    "green": "#198B63",
    "orange": "#D97706",
    "track": "#E5EAF1",
    "p0_bg": "#FFF0EF",
    "p1_bg": "#FFF8E8",
    "brazil": "#C98A20",
}

FONT_PATH = "/System/Library/Fonts/PingFang.ttc"


def font(size, bold=False):
    return ImageFont.truetype(FONT_PATH, size=size, index=1 if bold else 0)


def load_rows():
    rows = list(csv.DictReader(INPUT_CSV.open(encoding="utf-8-sig")))
    numeric = [
        "曝光人数", "进入人数", "打勾人数", "保存人数",
        "曝光进入率", "进入打勾率", "打勾保存率", "进入保存率",
        "曝光有效天数", "进入有效天数", "打勾有效天数", "保存有效天数",
    ]
    for row in rows:
        for key in numeric:
            row[key] = float(row[key]) if row[key] else None
    return rows


def cell(data, market, status, feature):
    return data[(market, status, feature)]


def pp(a, b):
    return (a - b) * 100


def diagnosis(status, feature, gaps):
    if feature == "Teeth":
        return "打勾事件月中变更，后段不可比"

    if status == "Paying":
        fixed = {
            "Face": "付费用户漏斗健康",
            "Skin Tone": "入口为主；进入后亦偏低",
            "Eraser": "付费用户漏斗健康",
            "Body": "入口略低；进入后优于整体",
            "Relight": "付费用户进入后优于整体",
            "AI Retouch": "付费用户进入后优于整体",
            "Glowup": "入口与打勾前体验偏弱",
            "Brighten": "付费用户进入后正常",
        }
    else:
        fixed = {
            "Face": "入口+勾选前+订阅页截断",
            "Skin Tone": "入口为主；各段均偏低",
            "Eraser": "订阅页截断为主",
            "Body": "入口偏低；进入后健康",
            "Relight": "入口/首效+订阅后链路",
            "AI Retouch": "订阅页截断；入口偏低",
            "Glowup": "入口/首效偏低，非订阅页为主",
            "Brighten": "订阅页截断为主",
            "Hair": "打勾前与订阅后均偏低",
            "AI Repair": "订阅页截断（低量级）",
            "Wrinkle": "订阅页截断（低量级）",
            "Concealer": "订阅页截断（低量级）",
        }
    if feature in fixed:
        return fixed[feature]

    bad = []
    labels = [
        ("入口", gaps["曝光进入率"]),
        ("打勾前", gaps["进入打勾率"]),
        ("保存后链路", gaps["打勾保存率"]),
    ]
    for label, value in labels:
        if value <= -3:
            bad.append(label)
    return "整体健康" if not bad else "、".join(bad) + "偏低"


def prepare():
    rows = load_rows()
    data = {
        (row["国家维度"], row["付费状态"], row["功能"]): row
        for row in rows
    }
    features = sorted(
        {row["功能"] for row in rows},
        key=lambda feature: -(
            cell(data, "巴西", "Paying", feature)["进入人数"]
            + cell(data, "巴西", "Un-Paying", feature)["进入人数"]
        ),
    )
    return data, features


def write_analysis_csv(data, features):
    fields = [
        "功能", "优先级", "巴西进入人数",
        "巴西当前付费进入人数", "巴西当前非付费进入人数",
    ]
    for status_label in ["当前付费", "当前非付费"]:
        for metric, _ in METRICS:
            fields.extend([
                f"巴西{status_label}{metric}",
                f"整体{status_label}{metric}",
                f"{status_label}{metric}gap（巴西-整体）",
            ])
    fields.extend([
        "巴西当前非付费-付费进入打勾率gap",
        "整体当前非付费-付费进入打勾率gap",
        "巴西相对整体额外进入打勾损失",
        "巴西当前非付费-付费打勾保存率gap",
        "整体当前非付费-付费打勾保存率gap",
        "巴西相对整体额外打勾保存损失",
        "当前非付费进入保存机会量（人/日）",
        "当前付费进入保存机会量（人/日）",
        "当前付费诊断", "当前非付费诊断", "数据备注",
    ])
    output = []
    for feature in features:
        priority = "P0" if feature in P0 else "P1" if feature in P1 else "关注" if feature in WATCH else ""
        bp = cell(data, "巴西", "Paying", feature)
        bu = cell(data, "巴西", "Un-Paying", feature)
        op = cell(data, "整体", "Paying", feature)
        ou = cell(data, "整体", "Un-Paying", feature)
        record = {
            "功能": feature,
            "优先级": priority,
            "巴西进入人数": bp["进入人数"] + bu["进入人数"],
            "巴西当前付费进入人数": bp["进入人数"],
            "巴西当前非付费进入人数": bu["进入人数"],
        }
        for status, label, b, o in [
            ("Paying", "当前付费", bp, op),
            ("Un-Paying", "当前非付费", bu, ou),
        ]:
            del status
            for metric, _ in METRICS:
                record[f"巴西{label}{metric}"] = b[metric]
                record[f"整体{label}{metric}"] = o[metric]
                record[f"{label}{metric}gap（巴西-整体）"] = b[metric] - o[metric]

        record["巴西当前非付费-付费进入打勾率gap"] = bu["进入打勾率"] - bp["进入打勾率"]
        record["整体当前非付费-付费进入打勾率gap"] = ou["进入打勾率"] - op["进入打勾率"]
        record["巴西相对整体额外进入打勾损失"] = (
            record["巴西当前非付费-付费进入打勾率gap"]
            - record["整体当前非付费-付费进入打勾率gap"]
        )
        record["巴西当前非付费-付费打勾保存率gap"] = bu["打勾保存率"] - bp["打勾保存率"]
        record["整体当前非付费-付费打勾保存率gap"] = ou["打勾保存率"] - op["打勾保存率"]
        record["巴西相对整体额外打勾保存损失"] = (
            record["巴西当前非付费-付费打勾保存率gap"]
            - record["整体当前非付费-付费打勾保存率gap"]
        )
        record["当前非付费进入保存机会量（人/日）"] = (
            bu["进入人数"] * max(0, ou["进入保存率"] - bu["进入保存率"])
        )
        record["当前付费进入保存机会量（人/日）"] = (
            bp["进入人数"] * max(0, op["进入保存率"] - bp["进入保存率"])
        )
        paying_gaps = {metric: pp(bp[metric], op[metric]) for metric, _ in METRICS}
        unpaid_gaps = {metric: pp(bu[metric], ou[metric]) for metric, _ in METRICS}
        record["当前付费诊断"] = diagnosis("Paying", feature, paying_gaps)
        record["当前非付费诊断"] = diagnosis("Un-Paying", feature, unpaid_gaps)
        record["数据备注"] = (
            "打勾事件仅有部分日期返回，进入打勾/打勾保存不可直接比较"
            if feature == "Teeth" else ""
        )
        output.append(record)

    with ANALYSIS_CSV.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(output)


def draw_gap_cell(draw, x0, y0, width, row_height, brazil, overall, gap, invalid=False):
    if invalid:
        draw.text(
            (x0 + width / 2, y0 + 13),
            "口径变更",
            font=font(20, True),
            fill=COLORS["muted"],
            anchor="ma",
        )
        draw.text(
            (x0 + width / 2, y0 + 41),
            "打勾有效天数不足",
            font=font(15),
            fill=COLORS["muted"],
            anchor="ma",
        )
        return

    if gap <= -2:
        color = COLORS["red"]
    elif gap >= 2:
        color = COLORS["green"]
    else:
        color = COLORS["muted"]

    draw.text(
        (x0 + width / 2, y0 + 7),
        f"{gap:+.1f}pp",
        font=font(20, True),
        fill=color,
        anchor="ma",
    )
    center = x0 + width / 2
    half = 112
    bar_y = y0 + 33
    draw.rounded_rectangle(
        (center - half, bar_y, center + half, bar_y + 9),
        radius=5,
        fill=COLORS["track"],
    )
    capped = min(abs(gap), 20.0) / 20.0 * half
    if gap < 0:
        draw.rounded_rectangle(
            (center - capped, bar_y, center, bar_y + 9),
            radius=5,
            fill=color,
        )
    elif gap > 0:
        draw.rounded_rectangle(
            (center, bar_y, center + capped, bar_y + 9),
            radius=5,
            fill=color,
        )
    draw.text(
        (center, y0 + 47),
        f"({brazil * 100:.1f}% / {overall * 100:.1f}%)",
        font=font(15),
        fill=COLORS["muted"],
        anchor="ma",
    )


def render(status, data, features):
    status_cn = "当前付费用户" if status == "Paying" else "当前非付费用户"
    definition = "订阅有效期内" if status == "Paying" else "非订阅有效期内"
    width = 2920
    margin = 44
    top = 205
    header_h = 82
    row_h = 64
    footer_h = 95
    height = top + header_h + row_h * len(features) + footer_h + 35
    image = Image.new("RGB", (width, height), COLORS["canvas"])
    draw = ImageDraw.Draw(image)

    draw.text(
        (margin + 8, 34),
        f"巴西{status_cn}｜功能漏斗对比 Top 25",
        font=font(40, True),
        fill=COLORS["text"],
    )
    draw.text(
        (margin + 8, 92),
        f"同一付费状态下对比巴西 vs 整体；gap = 巴西 - 整体；{status_cn} = {definition}。",
        font=font(21),
        fill=COLORS["muted"],
    )
    draw.ellipse((2090, 58, 2108, 76), fill=COLORS["red"])
    draw.text((2120, 52), "低于整体 ≥2pp", font=font(18), fill=COLORS["text"])
    draw.ellipse((2320, 58, 2338, 76), fill=COLORS["green"])
    draw.text((2350, 52), "高于整体 ≥2pp", font=font(18), fill=COLORS["text"])
    draw.text((2600, 52), "数据条 ±20pp", font=font(18), fill=COLORS["muted"])

    card = (margin, top - 20, width - margin, height - 25)
    draw.rounded_rectangle(card, radius=26, fill=COLORS["card"])

    x_positions = [margin + 20, margin + 440, margin + 865, margin + 1290, margin + 1715, margin + 2140, width - margin - 20]
    headers = ["功能", "曝光进入率", "进入打勾率", "打勾保存率", "进入保存率", "问题定位"]
    draw.rectangle(
        (margin + 20, top, width - margin - 20, top + header_h),
        fill=COLORS["header"],
    )
    for i, title in enumerate(headers):
        x0, x1 = x_positions[i], x_positions[i + 1]
        align_x = x0 + 18 if i in (0, 5) else (x0 + x1) / 2
        anchor = "la" if i in (0, 5) else "ma"
        draw.text(
            (align_x, top + 20),
            title,
            font=font(23, True),
            fill=COLORS["text"],
            anchor=anchor,
        )
        if i in (1, 2, 3, 4):
            draw.text(
                ((x0 + x1) / 2, top + 53),
                "gap 数据条（巴西 / 整体）",
                font=font(15),
                fill=COLORS["muted"],
                anchor="ma",
            )

    for idx, feature in enumerate(features):
        y0 = top + header_h + idx * row_h
        if feature in P0:
            draw.rectangle((margin + 20, y0, width - margin - 20, y0 + row_h), fill=COLORS["p0_bg"])
            priority = "P0"
            badge_color = COLORS["red"]
        elif feature in P1:
            draw.rectangle((margin + 20, y0, width - margin - 20, y0 + row_h), fill=COLORS["p1_bg"])
            priority = "P1"
            badge_color = COLORS["orange"]
        else:
            priority = ""
            badge_color = None
        draw.line(
            (margin + 20, y0 + row_h, width - margin - 20, y0 + row_h),
            fill=COLORS["line"],
            width=1,
        )
        if priority:
            draw.rectangle((margin + 20, y0, margin + 26, y0 + row_h), fill=badge_color)
        draw.text(
            (x_positions[0] + 18, y0 + 8),
            feature,
            font=font(22, True if feature in P0 else False),
            fill=COLORS["text"],
        )
        bp = cell(data, "巴西", "Paying", feature)
        bu = cell(data, "巴西", "Un-Paying", feature)
        row = bp if status == "Paying" else bu
        draw.text(
            (x_positions[0] + 18, y0 + 38),
            f"巴西进入 {row['进入人数']:,.0f} 人/日",
            font=font(15),
            fill=COLORS["muted"],
        )
        if priority:
            badge_x = x_positions[0] + 288
            draw.rounded_rectangle(
                (badge_x, y0 + 18, badge_x + 60, y0 + 44),
                radius=13,
                fill=badge_color,
            )
            draw.text(
                (badge_x + 30, y0 + 31),
                priority,
                font=font(14, True),
                fill="#FFFFFF",
                anchor="mm",
            )

        overall = cell(data, "整体", status, feature)
        gaps = {}
        for metric_index, (metric, _) in enumerate(METRICS):
            gap = pp(row[metric], overall[metric])
            gaps[metric] = gap
            invalid = feature == "Teeth" and metric in {"进入打勾率", "打勾保存率"}
            draw_gap_cell(
                draw,
                x_positions[metric_index + 1],
                y0,
                x_positions[metric_index + 2] - x_positions[metric_index + 1],
                row_h,
                row[metric],
                overall[metric],
                gap,
                invalid=invalid,
            )
        draw.text(
            (x_positions[5] + 18, y0 + row_h / 2),
            diagnosis(status, feature, gaps),
            font=font(18, True if feature in P0 | P1 else False),
            fill=(
                COLORS["red"] if feature in P0
                else COLORS["orange"] if feature in P1
                else COLORS["text"]
            ),
            anchor="lm",
        )

    for x in x_positions[1:-1]:
        draw.line(
            (x, top, x, top + header_h + row_h * len(features)),
            fill=COLORS["line"],
            width=1,
        )

    foot_y = top + header_h + row_h * len(features) + 30
    note = (
        "解释口径：打勾事件先于订阅页，因此“进入→打勾”低通常是入口后交互/首效问题；"
        "当前非付费“打勾→保存”低优先视为订阅页截断。Teeth 打勾事件仅部分日期返回，后段不作判断。"
    )
    draw.text((margin + 42, foot_y), note, font=font(17), fill=COLORS["muted"])
    draw.text(
        (width - margin - 42, foot_y + 34),
        "数据源：北斗 10015706｜2026-06｜图片编辑｜巴西 vs 整体",
        font=font(15),
        fill=COLORS["muted"],
        anchor="ra",
    )
    output = OUTPUT_DIR / f"巴西专项_{status_cn}功能漏斗对比_202606.png"
    image.save(output, quality=95)
    return output


def main():
    data, features = prepare()
    write_analysis_csv(data, features)
    outputs = [render(status, data, features) for status in ["Paying", "Un-Paying"]]
    print(ANALYSIS_CSV)
    for output in outputs:
        print(output)


if __name__ == "__main__":
    main()
