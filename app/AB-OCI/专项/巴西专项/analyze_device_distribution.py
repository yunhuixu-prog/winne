#!/usr/bin/env python3
import csv
import re
from collections import defaultdict
from pathlib import Path


ROOT = Path("/Users/xuyunhui/Documents/项目")
OUTPUT_DIR = ROOT / "outputs/019f839e-6d3f-7a81-b0ac-450473a2e302"
SOURCES = {
    "巴西": OUTPUT_DIR / "活跃机型分布_巴西_202606.csv",
    "整体": OUTPUT_DIR / "活跃机型分布_整体_202606.csv",
}


def normalize_brand(value):
    text = (value or "Unknown").strip()
    key = text.casefold()
    aliases = {
        "samsung": "Samsung",
        "apple": "Apple",
        "motorola": "Motorola",
        "xiaomi": "Xiaomi",
        "redmi": "Xiaomi",
        "poco": "POCO",
        "realme": "realme",
        "oppo": "OPPO",
        "oneplus": "OnePlus",
        "huawei": "Huawei",
        "honor": "HONOR",
        "lg": "LG",
        "lge": "LG",
        "asus": "ASUS",
        "vivo": "vivo",
        "zte": "ZTE",
        "infinix": "Infinix",
        "tecno": "TECNO",
    }
    return aliases.get(key, text)


def android_tier(brand, model):
    text = model.casefold()

    if brand == "Samsung":
        match = re.search(r"sm-a(\d{2})", text)
        if match:
            series = int(match.group(1))
            return "低端" if series < 20 else "中端"
        match = re.search(r"sm-m(\d{2})", text)
        if match:
            series = int(match.group(1))
            return "低端" if series < 30 else "中端"
        if re.search(r"sm-(f|w)", text):
            return "高端"
        if re.search(r"sm-s(918|928|938|936|931)", text):
            return "高端"
        if re.search(r"sm-(s|n)", text) or re.search(r"sm-g(7|8|9)", text):
            return "中端"
        if re.search(r"sm-(j|e|c)", text):
            return "低端"

    if brand == "Motorola":
        if "signature" in text or (
            "razr" in text and ("ultra" in text or "fold" in text)
        ):
            return "高端"
        if "razr" in text:
            return "中端"
        if "edge" in text:
            return "高端" if "ultra" in text else "中端"
        match = re.search(r"moto g\s*(\d+)", text)
        if match:
            return "低端" if int(match.group(1)) < 50 else "中端"
        if "moto e" in text:
            return "低端"

    if brand == "Xiaomi":
        low_codes = {
            "23100rn82l",
            "23106rn0da",
            "23053rn02a",
            "220333qny",
            "2201117tg",
            "2201117sg",
        }
        if text in low_codes or "redmi a" in text or "redmi 13c" in text:
            return "低端"
        if "ultra" in text or re.search(r"xiaomi\s*(1[3-9]|[2-9][0-9])", text):
            return "高端"
        if "redmi" in text or "note" in text or re.match(r"\d{5}[a-z0-9]+", text):
            return "中端"

    if brand == "POCO":
        if re.search(r"poco\s*[cm]", text):
            return "低端"
        return "中端"

    if brand == "realme":
        if "gt" in text:
            return "高端"
        if re.search(r"realme\s*c", text):
            return "低端"
        return "中端"

    if brand in {"Infinix", "TECNO", "Itel", "Multilaser", "Positivo"}:
        if any(token in text for token in ("zero ultra", "phantom", "camon 40", "note 50")):
            return "中端"
        return "低端"

    if brand in {"Google", "OnePlus"}:
        return "高端"

    if brand in {"OPPO", "vivo", "HONOR", "Huawei"}:
        if any(token in text for token in ("find", "magic", "mate", "pura", "pro", "ultra")):
            return "高端"
        if any(token in text for token in ("a", "y", "lite")):
            return "低端"
        return "中端"

    if brand in {"LG", "lge", "TCL", "ZTE", "ASUS", "Nokia"}:
        return "未知"

    return "未知"


def ios_tier(model):
    match = re.match(r"iphone(\d+),", model.casefold())
    if not match:
        return "未知"
    generation = int(match.group(1))
    if generation >= 15:
        return "高端"
    if generation >= 12:
        return "中端"
    return "低端"


def assign_tier(row):
    if row["os"] == "android":
        return android_tier(row["brand"], row["model"])
    if row["os"] == "ios":
        return ios_tier(row["model"])
    return "未知"


def read_rows():
    rows = []
    for market, path in SOURCES.items():
        with path.open(encoding="utf-8-sig", newline="") as handle:
            for row in csv.DictReader(handle):
                rows.append(
                    {
                        "market": market,
                        "os": row.get("os_p") or row.get("a.os_p"),
                        "brand": normalize_brand(row["brand"]),
                        "model": row["device_model"].strip(),
                        "uv": int(row["active_uv"]),
                        "days": int(row["active_user_days"]),
                    }
                )
    for row in rows:
        row["tier"] = assign_tier(row)
    return rows


def export(rows):
    detail_path = OUTPUT_DIR / "活跃机型价格档位明细_巴西vs整体_202606.csv"
    with detail_path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "market",
                "os",
                "brand",
                "model",
                "tier",
                "uv",
                "days",
            ],
        )
        writer.writeheader()
        writer.writerows(rows)

    totals = defaultdict(int)
    tier_uv = defaultdict(int)
    for row in rows:
        totals[(row["market"], row["os"])] += row["uv"]
        tier_uv[(row["market"], row["os"], row["tier"])] += row["uv"]

    summary_path = OUTPUT_DIR / "活跃机型价格档位汇总_巴西vs整体_202606.csv"
    with summary_path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["market", "os", "tier", "active_uv", "share"],
        )
        writer.writeheader()
        for market in ("巴西", "整体"):
            for os_name in ("android", "ios"):
                total = totals[(market, os_name)]
                for tier in ("低端", "中端", "高端", "未知"):
                    uv = tier_uv[(market, os_name, tier)]
                    writer.writerow(
                        {
                            "market": market,
                            "os": os_name,
                            "tier": tier,
                            "active_uv": uv,
                            "share": uv / total if total else 0,
                        }
                    )
    comparison_path = OUTPUT_DIR / "活跃品牌机型占比对比_巴西vs整体_202606.csv"
    totals = defaultdict(int)
    brands = defaultdict(int)
    models = defaultdict(int)
    model_tier = {}
    for row in rows:
        totals[(row["market"], row["os"])] += row["uv"]
        brands[(row["market"], row["os"], row["brand"])] += row["uv"]
        models[(row["market"], row["os"], row["brand"], row["model"])] += row["uv"]
        model_tier[(row["os"], row["brand"], row["model"])] = row["tier"]

    comparison_rows = []
    for os_name in ("android", "ios"):
        for brand in sorted(
            {
                brand
                for market, current_os, brand in brands
                if current_os == os_name
            }
        ):
            br_uv = brands[("巴西", os_name, brand)]
            overall_uv = brands[("整体", os_name, brand)]
            br_share = br_uv / totals[("巴西", os_name)]
            overall_share = overall_uv / totals[("整体", os_name)]
            comparison_rows.append(
                {
                    "dimension": "brand",
                    "os": os_name,
                    "brand": brand,
                    "model": "",
                    "tier": "",
                    "brazil_uv": br_uv,
                    "brazil_share": br_share,
                    "overall_uv": overall_uv,
                    "overall_share": overall_share,
                    "gap_pp": (br_share - overall_share) * 100,
                }
            )
        for brand, model in sorted(
            {
                (brand, model)
                for market, current_os, brand, model in models
                if current_os == os_name
            }
        ):
            br_uv = models[("巴西", os_name, brand, model)]
            overall_uv = models[("整体", os_name, brand, model)]
            br_share = br_uv / totals[("巴西", os_name)]
            overall_share = overall_uv / totals[("整体", os_name)]
            comparison_rows.append(
                {
                    "dimension": "model",
                    "os": os_name,
                    "brand": brand,
                    "model": model,
                    "tier": model_tier[(os_name, brand, model)],
                    "brazil_uv": br_uv,
                    "brazil_share": br_share,
                    "overall_uv": overall_uv,
                    "overall_share": overall_share,
                    "gap_pp": (br_share - overall_share) * 100,
                }
            )
    comparison_rows.sort(
        key=lambda row: (
            row["os"],
            row["dimension"],
            -row["brazil_share"],
            row["brand"],
            row["model"],
        )
    )
    with comparison_path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "dimension",
                "os",
                "brand",
                "model",
                "tier",
                "brazil_uv",
                "brazil_share",
                "overall_uv",
                "overall_share",
                "gap_pp",
            ],
        )
        writer.writeheader()
        writer.writerows(comparison_rows)

    return detail_path, summary_path, comparison_path


def print_top(rows):
    totals = defaultdict(int)
    brands = defaultdict(int)
    models = defaultdict(int)
    for row in rows:
        key = (row["market"], row["os"])
        totals[key] += row["uv"]
        brands[(row["market"], row["os"], row["brand"])] += row["uv"]
        models[(row["market"], row["os"], row["brand"], row["model"])] += row["uv"]

    for market in ("巴西", "整体"):
        for os_name in ("android", "ios"):
            total = totals[(market, os_name)]
            print(f"\n## {market} {os_name} total user-model pairs={total:,}")
            print("Brands")
            brand_rows = sorted(
                (
                    (brand, uv)
                    for (m, o, brand), uv in brands.items()
                    if m == market and o == os_name
                ),
                key=lambda item: (-item[1], item[0]),
            )
            for brand, uv in brand_rows[:15]:
                print(f"{brand}\t{uv:,}\t{uv / total:.2%}")

            print("Models")
            model_rows = sorted(
                (
                    (brand, model, uv)
                    for (m, o, brand, model), uv in models.items()
                    if m == market and o == os_name
                ),
                key=lambda item: (-item[2], item[0], item[1]),
            )
            for brand, model, uv in model_rows[:50]:
                print(f"{brand}\t{model}\t{uv:,}\t{uv / total:.2%}")

    print("\n## Android brand comparison")
    for brand in sorted(
        {row["brand"] for row in rows if row["os"] == "android"},
        key=lambda item: -brands[("巴西", "android", item)],
    )[:15]:
        br_share = brands[("巴西", "android", brand)] / totals[("巴西", "android")]
        overall_share = (
            brands[("整体", "android", brand)] / totals[("整体", "android")]
        )
        print(
            f"{brand}\t巴西={br_share:.2%}\t整体={overall_share:.2%}"
            f"\tgap={(br_share - overall_share) * 100:+.2f}pp"
        )

    print("\n## Brazil Android top model comparison")
    br_models = sorted(
        (
            (brand, model, uv)
            for (market, os_name, brand, model), uv in models.items()
            if market == "巴西" and os_name == "android"
        ),
        key=lambda item: (-item[2], item[0], item[1]),
    )[:30]
    for brand, model, br_uv in br_models:
        br_share = br_uv / totals[("巴西", "android")]
        overall_share = (
            models[("整体", "android", brand, model)]
            / totals[("整体", "android")]
        )
        tier = next(
            row["tier"]
            for row in rows
            if row["market"] == "巴西"
            and row["os"] == "android"
            and row["brand"] == brand
            and row["model"] == model
        )
        print(
            f"{brand}\t{model}\t{tier}\t巴西={br_share:.2%}"
            f"\t整体={overall_share:.2%}\tgap={(br_share - overall_share) * 100:+.2f}pp"
        )

    print("\n## Price tiers")
    tier_uv = defaultdict(int)
    for row in rows:
        tier_uv[(row["market"], row["os"], row["tier"])] += row["uv"]
    for market in ("巴西", "整体"):
        for os_name in ("android", "ios"):
            total = totals[(market, os_name)]
            values = []
            for tier in ("低端", "中端", "高端", "未知"):
                uv = tier_uv[(market, os_name, tier)]
                values.append(f"{tier}={uv / total:.2%} ({uv:,})")
            print(f"{market}\t{os_name}\t" + "\t".join(values))


if __name__ == "__main__":
    data = read_rows()
    paths = export(data)
    print_top(data)
    for path in paths:
        print(path)
