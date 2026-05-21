# Executive Data Story (5 Slides)

## 1. Market Size

- **528K+** cleaned auction transactions
- **$ billions** in aggregate selling price across US states
- SUVs and sedans dominate volume; luxury segments drive revenue per unit

## 2. Brand Winners

- Top makes by **volume** differ from top makes by **revenue**
- Ford-style brands win transactions; BMW/Audi-style brands win dollar share
- Use composite rank (volume + price + MMR premium) for stocking decisions

## 3. Regional Opportunities

- State-level **market efficiency score** = avg(sellingprice) / avg(MMR)
- Coastal and high-demand states show tighter price-to-MMR ratios
- Map visual in Power BI highlights expansion targets

## 4. Pricing Strategy

- **Underpriced** inventory (price < 90% MMR) represents measurable margin uplift if repriced to MMR
- Seasonal quarters show price dips — favor Q1 sourcing vs Q3 depending on margin goals
- ML model (Random Forest) supports list-price recommendations with R² > 0.96

## 5. Risk Flags

- Duplicate VIN and rapid resale flags for fraud review
- Overpriced deal class — monitor seller partners with high above-MMR rates
- Data quality funnel: track null VIN, invalid price, missing odometer gates
