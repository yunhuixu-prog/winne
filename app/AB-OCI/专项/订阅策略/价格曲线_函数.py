"""
分国家 × 周期（duration: 1month=月, annual=年）的订阅付费率价格曲线。

数据来源: 价格曲线.csv（sub_to_paid_uv >= 100）
指标: sub_to_paid_rate = sub_to_paid_uv / DAU
约束: 输出函数在价格区间内单调递减（价格越高，付费率越低）
"""

from __future__ import annotations

from pathlib import Path
from typing import Literal

import numpy as np

Country = Literal["Australia", "Brazil", "United Kingdom"]
Duration = Literal["1month", "annual"]

MIN_SUB_TO_PAID_UV = 100
_DIR = Path(__file__).resolve().parent
DEFAULT_CSV = _DIR / "价格曲线.csv"

# 由 价格曲线.csv 拟合得到，运行本脚本可刷新（约束：价格↑ → 付费率↓）
_FIT_PARAMS: dict[tuple[str, str], dict] = {
    ("Australia", "1month"): {
        "model": "linear",
        "a": 0.00691962,
        "b": -0.00021593,
        "r2": 0.1685,
    },
    ("Australia", "annual"): {
        "model": "power",
        "a": 1.83392602,
        "b": -1.50000000,
        "r2": 0.5530,
    },
    ("Brazil", "1month"): {
        "model": "linear",
        "a": 0.00118497,
        "b": -0.00000100,
        "r2": -0.0016,
    },
    ("Brazil", "annual"): {
        "model": "inverse",
        "a": -0.00001717,
        "b": 0.04439773,
        "r2": 0.3961,
    },
    ("United Kingdom", "1month"): {
        "model": "linear",
        "a": 0.00368437,
        "b": -0.00002958,
        "r2": 0.0045,
    },
    ("United Kingdom", "annual"): {
        "model": "power",
        "a": 1.67307120,
        "b": -1.50000000,
        "r2": 0.5501,
    },
}


def predict_sub_to_paid_rate(
    country: Country,
    duration: Duration,
    price_usd: float,
) -> float:
    """预测 sub_to_paid_rate。price_usd 为美元单价。"""
    if price_usd <= 0:
        return 0.0
    p = _FIT_PARAMS[(country, duration)]
    a, b, model = p["a"], p["b"], p["model"]
    if model == "power":
        rate = a * (price_usd ** b)
    elif model == "inverse":
        rate = a + b / price_usd
    else:
        rate = a + b * price_usd
    return max(rate, 0.0)


def formula(country: Country, duration: Duration) -> str:
    p = _FIT_PARAMS[(country, duration)]
    a, b, model = p["a"], p["b"], p["model"]
    if model == "power":
        return f"rate = {a:.6g} * price^({b:.4f})"
    if model == "inverse":
        return f"rate = {a:.6g} + ({b:.6g})/price"
    return f"rate = {a:.6g} + ({b:.6g}) * price"


def _weighted_r2(y, pred, w):
    ym = np.average(y, weights=w)
    ss_tot = np.sum(w * (y - ym) ** 2)
    return float(1 - np.sum(w * (y - pred) ** 2) / ss_tot) if ss_tot > 0 else float("nan")


def _fit_power(x, y, w):
    lx, ly = np.log(x), np.log(y)
    beta = np.sum(w * (lx - np.average(lx, weights=w)) * (ly - np.average(ly, weights=w))) / np.sum(
        w * (lx - np.average(lx, weights=w)) ** 2
    )
    alpha = np.average(ly, weights=w) - beta * np.average(lx, weights=w)
    a, b = np.exp(alpha), beta
    pred = a * x ** b
    return {"model": "power", "a": float(a), "b": float(b), "r2": _weighted_r2(y, pred, w)}


def _fit_inverse(x, y, w):
    inv = 1 / x
    ym = np.average(y, weights=w)
    ivm = np.average(inv, weights=w)
    b = np.sum(w * (inv - ivm) * (y - ym)) / np.sum(w * (inv - ivm) ** 2)
    a = ym - b * ivm
    pred = a + b / x
    return {"model": "inverse", "a": float(a), "b": float(b), "r2": _weighted_r2(y, pred, w)}


def _fit_linear(x, y, w):
    xm, ym = np.average(x, weights=w), np.average(y, weights=w)
    b = np.sum(w * (x - xm) * (y - ym)) / np.sum(w * (x - xm) ** 2)
    a = ym - b * xm
    pred = a + b * x
    return {"model": "linear", "a": float(a), "b": float(b), "r2": _weighted_r2(y, pred, w)}


def _is_monotone_decreasing(model: str, a: float, b: float) -> bool:
    """价格越高、付费率越低：power/linear 需 b<0；inverse (a+b/price) 需 b>0。"""
    if model == "power":
        return a > 0 and b < 0
    if model == "inverse":
        return b > 0
    if model == "linear":
        return b < 0
    return False


def _fit_power_constrained(x, y, w):
    """强制 b < 0 的幂律拟合。"""
    best = None
    for b_init in [-0.3, -0.5, -0.8, -1.0, -1.5, -2.0, -3.0]:
        lx, ly = np.log(x), np.log(y)
        # 固定 b，求 a: log(y) = log(a) + b*log(x)
        log_a = np.average(ly - b_init * lx, weights=w)
        a = np.exp(log_a)
        if a <= 0:
            continue
        pred = a * x ** b_init
        r2 = _weighted_r2(y, pred, w)
        cand = {"model": "power", "a": float(a), "b": float(b_init), "r2": r2}
        if best is None or r2 > best["r2"]:
            best = cand
    return best


def _fit_linear_constrained(x, y, w):
    """强制 b <= 0 的线性拟合。"""
    m = _fit_linear(x, y, w)
    if m["b"] < 0:
        return m
    # b >= 0 时固定斜率为负，重新求截距
    xm, ym = np.average(x, weights=w), np.average(y, weights=w)
    best = None
    for b_fix in [-1e-6, -1e-5, -1e-4, -1e-3, -1e-2]:
        a = ym - b_fix * xm
        pred = a + b_fix * x
        r2 = _weighted_r2(y, pred, w)
        cand = {"model": "linear", "a": float(a), "b": float(b_fix), "r2": r2}
        if best is None or r2 > best["r2"]:
            best = cand
    return best


def _fit_inverse_constrained(x, y, w):
    """强制 b > 0 的反比例拟合。"""
    m = _fit_inverse(x, y, w)
    if m["b"] > 0:
        return m
    # b <= 0 时固定 b 为正，重新求 a
    inv = 1 / x
    ym = np.average(y, weights=w)
    ivm = np.average(inv, weights=w)
    best = None
    for b_fix in [1e-4, 1e-3, 0.01, 0.05, 0.1, 0.5, 1.0]:
        a = ym - b_fix * ivm
        pred = a + b_fix / x
        r2 = _weighted_r2(y, pred, w)
        cand = {"model": "inverse", "a": float(a), "b": float(b_fix), "r2": r2}
        if best is None or r2 > best["r2"]:
            best = cand
    return best


def _select_model(g, duration: str):
    x = g["payment_price_usd"].astype(float).values
    y = g["sub_to_paid_rate"].astype(float).values
    w = g["sub_to_paid_uv"].astype(float).values

    cands = []
    for fit_fn in (_fit_power, _fit_inverse, _fit_linear):
        c = fit_fn(x, y, w)
        if _is_monotone_decreasing(c["model"], c["a"], c["b"]):
            cands.append(c)
    for fit_fn in (_fit_power_constrained, _fit_inverse_constrained, _fit_linear_constrained):
        c = fit_fn(x, y, w)
        if c and _is_monotone_decreasing(c["model"], c["a"], c["b"]):
            cands.append(c)

    if not cands:
        raise ValueError(f"无法找到单调递减模型: {g['country'].iloc[0]} {duration}")

    best = max(cands, key=lambda c: c["r2"])
    # 验证在观测价格区间内单调递减
    p_lo, p_hi = float(x.min()), float(x.max())
    r_lo = _predict_from_params(best, p_lo)
    r_hi = _predict_from_params(best, p_hi)
    if r_lo <= r_hi:
        # 优先选区间内明确递减的
        valid = [c for c in cands if _predict_from_params(c, p_lo) > _predict_from_params(c, p_hi)]
        if valid:
            best = max(valid, key=lambda c: c["r2"])
    return best


def refit_from_csv(csv_path: str | Path | None = None) -> dict[tuple[str, str], dict]:
    import pandas as pd

    csv_file = Path(csv_path) if csv_path else DEFAULT_CSV
    if not csv_file.is_absolute():
        csv_file = _DIR / csv_file
    out_dir = csv_file.parent

    df = pd.read_csv(csv_file)
    df = df[(df["sub_to_paid_uv"] >= MIN_SUB_TO_PAID_UV) & df["duration"].isin(["1month", "annual"])].copy()
    period = {"1month": "月", "annual": "年"}
    fit_rows, grid_rows, models = [], [], {}

    for (country, duration), g in df.groupby(["country", "duration"]):
        g = g.sort_values("payment_price_usd")
        m = _select_model(g, duration)
        models[(country, duration)] = m
        x = g["payment_price_usd"].astype(float).values
        fit_rows.append(
            {
                "country": country,
                "duration": duration,
                "period_type": period[duration],
                "n_price_points": len(g),
                "price_min": round(float(x.min()), 2),
                "price_max": round(float(x.max()), 2),
                "total_sub_to_paid_uv": int(g["sub_to_paid_uv"].sum()),
                "model": m["model"],
                "param_a": round(m["a"], 8),
                "param_b": round(m["b"], 8),
                "r2_weighted": round(m["r2"], 4),
                "formula": _formula_from_params(m),
            }
        )
        p5, p95 = np.percentile(x, [5, 95])
        for p in np.linspace(p5, p95, 8):
            grid_rows.append(
                {
                    "country": country,
                    "duration": duration,
                    "period_type": period[duration],
                    "payment_price_usd": round(float(p), 2),
                    "predicted_rate": round(_predict_from_params(m, float(p)), 6),
                    "model": m["model"],
                }
            )

    pd.DataFrame(fit_rows).to_csv(out_dir / "价格曲线_拟合参数.csv", index=False)
    pd.DataFrame(grid_rows).to_csv(out_dir / "价格曲线_预测网格.csv", index=False)
    return models


def _formula_from_params(p: dict) -> str:
    a, b, model = p["a"], p["b"], p["model"]
    if model == "power":
        return f"rate = {a:.6g} * price^({b:.4f})"
    if model == "inverse":
        return f"rate = {a:.6g} + ({b:.6g})/price"
    return f"rate = {a:.6g} + ({b:.6g}) * price"


def _predict_from_params(p: dict, price: float) -> float:
    a, b, model = p["a"], p["b"], p["model"]
    if model == "power":
        rate = a * (price ** b)
    elif model == "inverse":
        rate = a + b / price
    else:
        rate = a + b * price
    return max(rate, 0.0)


if __name__ == "__main__":
    models = refit_from_csv()
    _FIT_PARAMS.update(models)
    import pandas as pd

    df = pd.read_csv(DEFAULT_CSV)
    df = df[(df["sub_to_paid_uv"] >= MIN_SUB_TO_PAID_UV) & df["duration"].isin(["1month", "annual"])]
    for (country, duration), m in models.items():
        period = {"1month": "月", "annual": "年"}[duration]
        g = df[(df["country"] == country) & (df["duration"] == duration)]
        p_lo, p_hi = g["payment_price_usd"].min(), g["payment_price_usd"].max()
        r_lo = _predict_from_params(m, p_lo)
        r_hi = _predict_from_params(m, p_hi)
        mono = "✓" if r_lo > r_hi else "✗"
        print(
            f"{country} | {period}({duration}): {_formula_from_params(m)}  "
            f"[R²={m['r2']:.4f}]  rate({p_lo:.1f})={r_lo:.6f} > rate({p_hi:.1f})={r_hi:.6f} {mono}"
        )
