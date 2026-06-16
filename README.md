# Project: Supply Chain Delivery Delay Analysis

## Overview
This project explores a multi-label delivery delay dataset (15,549 orders, 5 global markets, 2015–2018) to **identify the operational factors driving late deliveries**. More than half of all orders in the dataset were delayed, **this project investigates why, and what a business should do about it**.

## Tools used
SQL Server (T-SQL) for data exploration, Tableau Public for visualization

## Dataset
[Logistics Supply chain real world data, sourced from Kaggle"](https://www.kaggle.com/datasets/pushpitkamboj/logistics-data-containing-real-world-data?resource=download)

## Analytical approach
This analysis followed a structured five-phase framework:
1. **Data understanding**: mapping variables and identifying the target (label)
2. **Data quality audit**: checking nulls, duplicates, and data type issues
3. **Surface-level exploration**: breaking down the delivery outcomes (delayed, on time, early), volume and distribution of orders across key dimensions such as shipping modes, product categories, customer segments, year trend, etc.
4. **Deep-dive analysis**: crossing delay rate with shipping modes, markets, customer segments, product categories, and order status to detect key drivers of delay rate and additional insights
5. **Business synthesis**: translating findings into actionable recommendations

## Key findings
- 58% of all orders experienced delivery delays
- Shipping mode is the dominant delay driver: First Class (98% delay rate) and Second Class (77%) significantly underperform Standard Class (41%)
- Market, customer segment, payment type, and order status show no meaningful variation in delay rate, ruling out geographic or demographic causes
- Delay rate remained stable (57–60%) across 2015–2018, indicating a persistent structural issue rather than a one-time event

## Recommendations
1. Audit First Class and Second Class shipping operations urgently
2. Reallocate operational focus toward Standard Class, the best-performing mode
3. Investigate warehouse/dispatch processes as delays on lightweight, portable items point to upstream inefficiencies, not handling or shipping difficulty
4. Treat delay rate as a customer retention risk, not just a logistics metric

## Dashboard
[Link to Tableau Public dashboard](https://public.tableau.com/views/SupplyChainDeliveryPerformanceAnalysis_17815233349170/Dashboard1?:language=en-GB&:sid=&:redirect=auth&publish=yes&showOnboarding=true&:display_count=n&:origin=viz_share_link)

**Dashboard Preview**
<img width="1269" height="1579" alt="Supply Chain Delay Analysis" src="https://github.com/user-attachments/assets/09d48155-3c16-462e-afaa-4e50d2284ba6" />

## Files
- `Data Exploration - Supply Chain Delivery Performance.sql` - null checks, duplicate detection, data type fixes and full exploratory analysis across all dimensions
- `dashboard_export_queries.sql` - aggregated queries used to feed Tableau
