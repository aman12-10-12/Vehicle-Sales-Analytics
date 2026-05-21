# Conclusions

## Key Findings

1. **Price is strongly tied to MMR** — Random Forest R² ≈ 0.97 on a stratified sample; MMR and vehicle attributes explain most variance.
2. **Mileage depreciates value** — Negative correlation between `odometer` and `sellingprice` across all body types.
3. **Volume ≠ value** — High-volume makes (e.g., Ford) dominate units while luxury brands lead revenue per unit (Master Q7 narrative).
4. **Deal mix** — Fair deals are the largest class; Good Deal and Overpriced segments are imbalanced, so classification needs balanced weights.
5. **Seasonality** — Quarterly average prices vary; Q1 vs Q3 comparison supports inventory timing decisions.

## Model Performance (80K sample)

| Model | MAE | RMSE | R² |
|-------|-----|------|-----|
| Linear Regression | ~$1,005 | ~$1,555 | ~0.96 |
| Random Forest | ~$924 | ~$1,427 | ~0.97 |

## Business Recommendations

- Stock makes with strong **composite rank** (volume + price + MMR premium)
- Target **underpriced** units (`sellingprice < 0.9 × MMR`) for margin uplift
- Use **seller scorecard** view to align with premium vs discount auction partners
- Deploy **deal classifier** to flag Good Deal inventory in high-demand states
