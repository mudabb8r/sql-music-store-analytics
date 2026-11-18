"""Build the sales dashboard from the query results.

Creates two files:
  dashboard.html          interactive dashboard (open in any browser)
  images/dashboard.png    static image used in the README

Usage:  python dashboard.py   (runs the SQL first, so it always uses fresh numbers)
"""
from pathlib import Path

import matplotlib.pyplot as plt
import plotly.graph_objects as go
from plotly.subplots import make_subplots

from run_queries import run_all

ROOT = Path(__file__).parent
BLUE, LIGHT, GREY = "#2a7ab9", "#9dc3e6", "#7f7f7f"


def build_html(r):
    k = r["01_kpis"].iloc[0]
    monthly, country, genre = r["02_monthly_revenue"], r["03_revenue_by_country"].head(10), r["05_genre_revenue"].head(8)
    seg = r["07_customer_segments"]["segment"].value_counts()

    fig = make_subplots(
        rows=3, cols=4,
        specs=[[{"type": "indicator"}] * 4,
               [{"type": "xy", "colspan": 4}, None, None, None],
               [{"type": "xy", "colspan": 2}, None, {"type": "xy", "colspan": 2}, None]],
        row_heights=[0.18, 0.41, 0.41], vertical_spacing=0.09,
        subplot_titles=("", "", "", "", "Monthly revenue and 3-month rolling average",
                        "Top 10 countries by revenue", "Revenue by genre (top 8)"),
    )
    kpis = [("Total revenue", k.total_revenue, "$"), ("Invoices", int(k.invoices), ""),
            ("Customers", int(k.customers), ""), ("Avg invoice", k.avg_invoice_value, "$")]
    for i, (title, value, prefix) in enumerate(kpis, start=1):
        fig.add_trace(go.Indicator(mode="number", value=value, title={"text": title},
                                   number={"prefix": prefix, "valueformat": ",.2f" if prefix else ","}), row=1, col=i)
    fig.add_trace(go.Bar(x=monthly["month"], y=monthly["revenue"], name="Revenue", marker_color=LIGHT), row=2, col=1)
    fig.add_trace(go.Scatter(x=monthly["month"], y=monthly["rolling_3m_avg"], name="3-month avg", line=dict(color=BLUE, width=3)), row=2, col=1)
    fig.add_trace(go.Bar(x=country["revenue"][::-1], y=country["country"][::-1], orientation="h", marker_color=BLUE,
                         name="Country", showlegend=False), row=3, col=1)
    fig.add_trace(go.Bar(x=genre["revenue"][::-1], y=genre["genre"][::-1], orientation="h", marker_color=GREY,
                         name="Genre", showlegend=False), row=3, col=3)
    fig.update_layout(title=f"Music Store Sales Dashboard · customer segments: " +
                            ", ".join(f"{n} {s}" for s, n in seg.items()),
                      height=950, template="plotly_white", legend=dict(orientation="h", y=0.79, x=0))
    fig.write_html(ROOT / "dashboard.html", include_plotlyjs="cdn")


def build_png(r):
    k = r["01_kpis"].iloc[0]
    monthly, country, genre = r["02_monthly_revenue"], r["03_revenue_by_country"].head(10), r["05_genre_revenue"].head(8)
    fig = plt.figure(figsize=(14, 9))
    gs = fig.add_gridspec(3, 4, height_ratios=[0.35, 1, 1], hspace=0.55, wspace=0.9)
    for i, (title, value) in enumerate([("Total revenue", f"${k.total_revenue:,.2f}"), ("Invoices", f"{int(k.invoices):,}"),
                                        ("Customers", f"{int(k.customers)}"), ("Avg invoice", f"${k.avg_invoice_value:.2f}")]):
        ax = fig.add_subplot(gs[0, i]); ax.axis("off")
        ax.text(0.5, 0.65, value, ha="center", fontsize=22, weight="bold", color=BLUE)
        ax.text(0.5, 0.1, title, ha="center", fontsize=11, color=GREY)
    ax = fig.add_subplot(gs[1, :])
    ax.bar(monthly["month"], monthly["revenue"], color=LIGHT, label="Revenue")
    ax.plot(monthly["month"], monthly["rolling_3m_avg"], color=BLUE, lw=2.5, label="3-month average")
    ax.set_xticks(monthly["month"][::6]); ax.set_title("Monthly revenue ($)", loc="left"); ax.legend(loc="upper left", frameon=False)
    ax = fig.add_subplot(gs[2, :2]); ax.barh(country["country"][::-1], country["revenue"][::-1], color=BLUE)
    ax.set_title("Top 10 countries by revenue ($)", loc="left")
    ax = fig.add_subplot(gs[2, 2:]); ax.barh(genre["genre"][::-1], genre["revenue"][::-1], color=GREY)
    ax.set_title("Revenue by genre, top 8 ($)", loc="left")
    fig.suptitle("Music Store Sales Dashboard", fontsize=16, x=0.125, ha="left", weight="bold")
    (ROOT / "images").mkdir(exist_ok=True)
    fig.savefig(ROOT / "images" / "dashboard.png", dpi=110, bbox_inches="tight")


if __name__ == "__main__":
    results = run_all()
    build_html(results)
    build_png(results)
    print("Saved dashboard.html and images/dashboard.png")
