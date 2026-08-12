from pathlib import Path
import math

import pandas as pd
from PIL import Image, ImageDraw, ImageFont


OUTPUT_DIR = Path(
    "/Users/xuyunhui/Documents/项目/outputs/"
    "019f839e-6d3f-7a81-b0ac-450473a2e302"
)
PAIR_FILE = OUTPUT_DIR / "巴西功能使用组合_202606.csv"
ONLY_FILE = OUTPUT_DIR / "巴西功能仅使用X_202606.csv"
DATA_FILE = OUTPUT_DIR / "巴西功能组合_X下使用Y占DAU_202606.csv"
IMAGE_FILE = OUTPUT_DIR / "巴西功能组合_X下使用Y占比图_202606.png"

BRAZIL_DAU = 301_029
OVERALL_DAU = 731_237
DAYS = 30
TOP_N = 20

FONT_PATH = "/System/Library/Fonts/PingFang.ttc"


def font(size, bold=False):
    index = 1 if bold else 0
    return ImageFont.truetype(FONT_PATH, size=size, index=index)


def daily_avg(user_days):
    return float(user_days) / DAYS


def rate(user_days, dau):
    return daily_avg(user_days) / dau


def fmt_count(value):
    return f"{int(round(value)):,}"


def fmt_pct(value):
    if value < 0.0005:
        return "<0.1%"
    return f"{value * 100:.1f}%"


def blend(a, b, t):
    t = max(0.0, min(1.0, t))
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


only = pd.read_csv(ONLY_FILE, encoding="utf-8-sig")
only = only.rename(
    columns={"user_day_function.function_name": "feature"}
).sort_values("brazil_x_user_days", ascending=False)
features = only.head(TOP_N)["feature"].tolist()

pairs = pd.read_csv(PAIR_FILE, encoding="utf-8-sig").rename(
    columns={
        "pair.feature_x": "feature_x",
        "pair.feature_y": "feature_y",
        "pair.overall_pair_user_days": "overall_pair_user_days",
        "pair.brazil_pair_user_days": "brazil_pair_user_days",
    }
)
pair_lookup = {
    (row.feature_x, row.feature_y): (
        float(row.brazil_pair_user_days),
        float(row.overall_pair_user_days),
    )
    for row in pairs.itertuples()
}
only_lookup = only.set_index("feature").to_dict("index")

rows = []
for x in features:
    xrow = only_lookup[x]
    rows.append(
        {
            "feature_x": x,
            "feature_y": "",
            "metric": "X使用",
            "brazil_daily_users": daily_avg(xrow["brazil_x_user_days"]),
            "brazil_dau_rate": rate(xrow["brazil_x_user_days"], BRAZIL_DAU),
            "overall_dau_rate": rate(xrow["overall_x_user_days"], OVERALL_DAU),
        }
    )
    rows.append(
        {
            "feature_x": x,
            "feature_y": "",
            "metric": "仅使用X",
            "brazil_daily_users": daily_avg(xrow["brazil_only_x_user_days"]),
            "brazil_dau_rate": rate(
                xrow["brazil_only_x_user_days"], BRAZIL_DAU
            ),
            "overall_dau_rate": rate(
                xrow["overall_only_x_user_days"], OVERALL_DAU
            ),
        }
    )
    for y in features:
        if x == y:
            continue
        brazil_pair, overall_pair = pair_lookup.get((x, y), (0.0, 0.0))
        rows.append(
            {
                "feature_x": x,
                "feature_y": y,
                "metric": "X-Y同日使用",
                "brazil_daily_users": daily_avg(brazil_pair),
                "brazil_dau_rate": rate(brazil_pair, BRAZIL_DAU),
                "overall_dau_rate": rate(overall_pair, OVERALL_DAU),
            }
        )
pd.DataFrame(rows).to_csv(DATA_FILE, index=False, encoding="utf-8-sig")

# Layout
margin_x = 64
title_h = 210
header_h = 176
row_h = 112
footer_h = 112
x_col_w = 350
only_col_w = 280
y_col_w = 194
table_w = x_col_w + only_col_w + TOP_N * y_col_w
canvas_w = margin_x * 2 + table_w
canvas_h = title_h + header_h + TOP_N * row_h + footer_h

bg = (245, 247, 251)
card = (255, 255, 255)
header_bg = (248, 250, 253)
grid = (222, 228, 236)
text = (31, 41, 55)
muted = (123, 137, 158)
accent = (230, 111, 44)
cell_low = (255, 250, 246)
cell_high = (239, 132, 71)
only_fill = (248, 243, 235)

image = Image.new("RGB", (canvas_w, canvas_h), bg)
draw = ImageDraw.Draw(image)

draw.text(
    (margin_x, 38),
    "巴西功能组合｜X 功能下同日使用 Y 功能 Top 20",
    fill=text,
    font=font(52, bold=True),
)
draw.text(
    (margin_x, 112),
    "2026年6月 · 同一用户同一天 · 打勾即使用",
    fill=muted,
    font=font(29),
)
legend_x = canvas_w - margin_x - 1180
draw.rounded_rectangle(
    (legend_x, 104, legend_x + 32, 136), radius=8, fill=cell_high
)
draw.text(
    (legend_x + 46, 101),
    "颜色深浅按巴西 X–Y 占 DAU",
    fill=muted,
    font=font(25),
)
draw.text(
    (legend_x + 440, 101),
    "单元格：巴西日均人数｜巴西占DAU（整体占DAU）",
    fill=muted,
    font=font(25),
)

table_x = margin_x
table_y = title_h
draw.rounded_rectangle(
    (table_x, table_y, table_x + table_w, table_y + header_h + TOP_N * row_h),
    radius=22,
    fill=card,
)
draw.rectangle(
    (table_x, table_y, table_x + table_w, table_y + header_h),
    fill=header_bg,
)

# Header
draw.text(
    (table_x + 26, table_y + 30),
    "X 功能",
    fill=text,
    font=font(31, bold=True),
)
draw.text(
    (table_x + 26, table_y + 82),
    "巴西日均使用人数｜占DAU",
    fill=muted,
    font=font(23),
)
only_x0 = table_x + x_col_w
draw.text(
    (only_x0 + 20, table_y + 30),
    "仅使用 X",
    fill=text,
    font=font(29, bold=True),
)
draw.text(
    (only_x0 + 20, table_y + 82),
    "巴西人数｜巴西（整体）",
    fill=muted,
    font=font(21),
)

for j, y in enumerate(features):
    x0 = only_x0 + only_col_w + j * y_col_w
    bbox = draw.textbbox((0, 0), y, font=font(24, bold=True))
    tw = bbox[2] - bbox[0]
    draw.text(
        (x0 + (y_col_w - tw) / 2, table_y + 28),
        y,
        fill=text,
        font=font(24, bold=True),
    )
    draw.text(
        (x0 + y_col_w / 2, table_y + 91),
        "Y",
        fill=muted,
        font=font(20),
        anchor="mm",
    )

max_pair_rate = 0.0
for x in features:
    for y in features:
        if x != y:
            brazil_pair = pair_lookup.get((x, y), (0.0, 0.0))[0]
            max_pair_rate = max(
                max_pair_rate, rate(brazil_pair, BRAZIL_DAU)
            )

for i, x in enumerate(features):
    y0 = table_y + header_h + i * row_h
    xrow = only_lookup[x]
    if i % 2 == 1:
        draw.rectangle(
            (table_x, y0, table_x + table_w, y0 + row_h),
            fill=(252, 253, 255),
        )

    # X feature label and Brazil usage
    draw.text(
        (table_x + 26, y0 + 17),
        x,
        fill=text,
        font=font(29, bold=True),
    )
    x_daily = daily_avg(xrow["brazil_x_user_days"])
    x_rate = rate(xrow["brazil_x_user_days"], BRAZIL_DAU)
    draw.text(
        (table_x + 26, y0 + 62),
        f"{fmt_count(x_daily)} 人/日｜{fmt_pct(x_rate)}",
        fill=accent,
        font=font(24, bold=True),
    )

    # Only-X cell
    bx_daily = daily_avg(xrow["brazil_only_x_user_days"])
    bx_rate = rate(xrow["brazil_only_x_user_days"], BRAZIL_DAU)
    ox_rate = rate(xrow["overall_only_x_user_days"], OVERALL_DAU)
    draw.rectangle(
        (only_x0 + 1, y0 + 1, only_x0 + only_col_w - 1, y0 + row_h - 1),
        fill=only_fill,
    )
    draw.text(
        (only_x0 + only_col_w / 2, y0 + 37),
        fmt_count(bx_daily),
        fill=text,
        font=font(25, bold=True),
        anchor="mm",
    )
    draw.text(
        (only_x0 + only_col_w / 2, y0 + 76),
        f"{fmt_pct(bx_rate)}（{fmt_pct(ox_rate)}）",
        fill=accent,
        font=font(23, bold=True),
        anchor="mm",
    )

    # X-Y cells
    for j, y in enumerate(features):
        x0 = only_x0 + only_col_w + j * y_col_w
        if x == y:
            draw.rectangle(
                (x0 + 1, y0 + 1, x0 + y_col_w - 1, y0 + row_h - 1),
                fill=(239, 242, 247),
            )
            draw.text(
                (x0 + y_col_w / 2, y0 + row_h / 2),
                "—",
                fill=muted,
                font=font(28),
                anchor="mm",
            )
            continue
        brazil_pair, overall_pair = pair_lookup.get((x, y), (0.0, 0.0))
        b_daily = daily_avg(brazil_pair)
        b_rate = rate(brazil_pair, BRAZIL_DAU)
        o_rate = rate(overall_pair, OVERALL_DAU)
        intensity = math.sqrt(b_rate / max_pair_rate) if max_pair_rate else 0
        fill = blend(cell_low, cell_high, intensity * 0.72)
        draw.rectangle(
            (x0 + 1, y0 + 1, x0 + y_col_w - 1, y0 + row_h - 1),
            fill=fill,
        )
        draw.text(
            (x0 + y_col_w / 2, y0 + 36),
            fmt_count(b_daily),
            fill=text,
            font=font(22, bold=True),
            anchor="mm",
        )
        draw.text(
            (x0 + y_col_w / 2, y0 + 76),
            f"{fmt_pct(b_rate)}（{fmt_pct(o_rate)}）",
            fill=text,
            font=font(20),
            anchor="mm",
        )

# Grid
verticals = [table_x + x_col_w, table_x + x_col_w + only_col_w]
verticals += [
    table_x + x_col_w + only_col_w + j * y_col_w
    for j in range(1, TOP_N)
]
for x in verticals:
    draw.line(
        (x, table_y, x, table_y + header_h + TOP_N * row_h),
        fill=grid,
        width=2,
    )
draw.line(
    (table_x, table_y + header_h, table_x + table_w, table_y + header_h),
    fill=grid,
    width=2,
)
for i in range(1, TOP_N):
    y = table_y + header_h + i * row_h
    draw.line((table_x, y, table_x + table_w, y), fill=grid, width=1)

footer_y = table_y + header_h + TOP_N * row_h + 28
draw.text(
    (margin_x + 12, footer_y),
    "注：人数均为6月用户日÷30的日均值；整体包含巴西。仅使用X按当天全部52个二级功能判断，不局限于图中Top20。",
    fill=muted,
    font=font(23),
)
draw.text(
    (canvas_w - margin_x, footer_y),
    "DAU：巴西 301,029｜整体 731,237",
    fill=muted,
    font=font(23),
    anchor="ra",
)

image.save(IMAGE_FILE, quality=95)
print(IMAGE_FILE)
print(DATA_FILE)
