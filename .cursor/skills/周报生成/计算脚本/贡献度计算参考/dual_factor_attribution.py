import csv
import math
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
INPUT_FILE = BASE_DIR / "case3.csv"
OUTPUT_FILE = BASE_DIR / "case3_final.csv"


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
    total_b_share = 0.0
    total_a_share = 0.0
    overall_b = 0.0
    overall_a = 0.0

    for row in rows:
        b_rate = float(row["b_rate"])
        a_rate = float(row["a_rate"])
        b_share = float(row["b_share"])
        a_share = float(row["a_share"])
        total_b_share += b_share
        total_a_share += a_share
        overall_b += b_rate * b_share
        overall_a += a_rate * a_share
        parsed.append(
            {
                "name": row["group"],
                "b_rate": b_rate,
                "a_rate": a_rate,
                "b_share": b_share,
                "a_share": a_share,
            }
        )

    if not math.isclose(total_b_share, 1.0, rel_tol=0, abs_tol=1e-9):
        raise ValueError("Dual-factor attribution requires b_share to sum to 1.")
    if not math.isclose(total_a_share, 1.0, rel_tol=0, abs_tol=1e-9):
        raise ValueError("Dual-factor attribution requires a_share to sum to 1.")

    total_abs_change = overall_a - overall_b
    total_rate_change = safe_div(overall_a, overall_b) - 1

    result = []
    for row in parsed:
        child_abs_change = row["a_rate"] - row["b_rate"]
        child_rate_change = safe_div(row["a_rate"], row["b_rate"]) - 1
        aux_abs_change = row["a_share"] - row["b_share"]
        aux_rate_change = safe_div(row["a_share"], row["b_share"]) - 1
        contribution_abs = (
            (row["a_rate"] - row["b_rate"]) * row["b_share"]
            + (row["a_share"] - row["b_share"]) * (row["a_rate"] - overall_b)
        )
        contribution_share = safe_div(contribution_abs, total_abs_change)
        contribution_rate = contribution_share * total_rate_change
        result.append(
            {
                "case": "case3",
                "method": "dual_factor_mix_shift",
                "dimension": row["name"],
                "overall_b_value": overall_b,
                "overall_a_value": overall_a,
                "overall_abs_change": total_abs_change,
                "overall_rate_change": total_rate_change,
                "overall_aux_b_value": total_b_share,
                "overall_aux_a_value": total_a_share,
                "overall_aux_abs_change": total_a_share - total_b_share,
                "overall_aux_rate_change": safe_div(total_a_share, total_b_share) - 1,
                "child_b_value": row["b_rate"],
                "child_a_value": row["a_rate"],
                "child_abs_change": child_abs_change,
                "child_rate_change": child_rate_change,
                "child_aux_b_value": row["b_share"],
                "child_aux_a_value": row["a_share"],
                "child_aux_abs_change": aux_abs_change,
                "child_aux_rate_change": aux_rate_change,
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
        raise ValueError("Contribution abs does not sum correctly for case3.")
    if not math.isclose(sum_contribution_share, 1.0, rel_tol=0, abs_tol=1e-9):
        raise ValueError("Contribution share does not sum to 1 for case3.")
    if not math.isclose(sum_contribution_rate, total_rate_change, rel_tol=0, abs_tol=1e-9):
        raise ValueError("Contribution rate does not sum correctly for case3.")


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
