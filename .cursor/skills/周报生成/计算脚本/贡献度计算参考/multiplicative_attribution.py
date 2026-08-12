import csv
import math
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
INPUT_FILE = BASE_DIR / "case2.csv"
OUTPUT_FILE = BASE_DIR / "case2_final.csv"


def safe_div(numerator, denominator):
    if denominator == 0:
        raise ValueError("Denominator cannot be zero.")
    return numerator / denominator


def round_num(value, digits=10):
    return round(value, digits)


def load_rows():
    with INPUT_FILE.open("r", encoding="utf-8-sig", newline="") as file:
        return list(csv.DictReader(file))


def build_rows():
    rows = load_rows()
    parsed = []
    total_b = 1.0
    total_a = 1.0

    for row in rows:
        b_value = float(row["b_value"])
        a_value = float(row["a_value"])
        if b_value <= 0 or a_value <= 0:
            raise ValueError("Multiplicative attribution requires positive values.")
        total_b *= b_value
        total_a *= a_value
        parsed.append({"name": row["factor"], "b_value": b_value, "a_value": a_value})

    total_abs_change = total_a - total_b
    total_rate_change = safe_div(total_a, total_b) - 1
    total_log_change = math.log(total_a) - math.log(total_b)
    lmdi_scale = safe_div(total_abs_change, total_log_change)

    result = []
    for row in parsed:
        child_abs_change = row["a_value"] - row["b_value"]
        child_rate_change = safe_div(row["a_value"], row["b_value"]) - 1
        log_change = math.log(row["a_value"]) - math.log(row["b_value"])
        contribution_abs = lmdi_scale * log_change
        contribution_share = safe_div(contribution_abs, total_abs_change)
        contribution_rate = contribution_share * total_rate_change
        result.append(
            {
                "case": "case2",
                "method": "multiplicative_lmdi",
                "dimension": row["name"],
                "overall_b_value": total_b,
                "overall_a_value": total_a,
                "overall_abs_change": total_abs_change,
                "overall_rate_change": total_rate_change,
                "overall_aux_b_value": "",
                "overall_aux_a_value": "",
                "overall_aux_abs_change": "",
                "overall_aux_rate_change": "",
                "child_b_value": row["b_value"],
                "child_a_value": row["a_value"],
                "child_abs_change": child_abs_change,
                "child_rate_change": child_rate_change,
                "child_aux_b_value": "",
                "child_aux_a_value": "",
                "child_aux_abs_change": "",
                "child_aux_rate_change": "",
                "contribution_abs_change": contribution_abs,
                "contribution_share": contribution_share,
                "contribution_rate_change": contribution_rate,
            }
        )
    return result


def validate_rows(rows):
    total_abs_change = rows[0]["overall_abs_change"]
    total_rate_change = rows[0]["overall_rate_change"]
    sum_contribution_abs = sum(row["contribution_abs_change"] for row in rows)
    sum_contribution_share = sum(row["contribution_share"] for row in rows)
    sum_contribution_rate = sum(row["contribution_rate_change"] for row in rows)

    if not math.isclose(sum_contribution_abs, total_abs_change, rel_tol=0, abs_tol=1e-9):
        raise ValueError("Contribution abs does not sum correctly for case2.")
    if not math.isclose(sum_contribution_share, 1.0, rel_tol=0, abs_tol=1e-9):
        raise ValueError("Contribution share does not sum to 1 for case2.")
    if not math.isclose(sum_contribution_rate, total_rate_change, rel_tol=0, abs_tol=1e-9):
        raise ValueError("Contribution rate does not sum correctly for case2.")


def write_rows(rows):
    fieldnames = [
        "case",
        "method",
        "dimension",
        "overall_b_value",
        "overall_a_value",
        "overall_abs_change",
        "overall_rate_change",
        "overall_aux_b_value",
        "overall_aux_a_value",
        "overall_aux_abs_change",
        "overall_aux_rate_change",
        "child_b_value",
        "child_a_value",
        "child_abs_change",
        "child_rate_change",
        "child_aux_b_value",
        "child_aux_a_value",
        "child_aux_abs_change",
        "child_aux_rate_change",
        "contribution_abs_change",
        "contribution_share",
        "contribution_rate_change",
    ]

    with OUTPUT_FILE.open("w", encoding="utf-8-sig", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({key: round_num(value) if isinstance(value, float) else value for key, value in row.items()})


def main():
    rows = build_rows()
    validate_rows(rows)
    write_rows(rows)
    print(f"Generated {OUTPUT_FILE.name} with {len(rows)} rows.")


if __name__ == "__main__":
    main()
