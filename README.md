# Calc+

An ad-free, completely offline, all-in-one multi-utility calculator built with Flutter. Calc+ delivers a clutter-free, responsive experience with a unified dark aesthetic, modular architecture, and tools spanning everyday arithmetic, finance, construction, health, sports management, and developer utilities.

## ✨ Features

- **100% Ad-Free & Offline:** Zero distractions, zero data collection, and no internet access required for calculations.
- **Modular Plugin Architecture:** Built around an isolated module engine (`ModuleRegistry` & `CalculatorModule`) for extensible, self-contained tools.
- **Unified Semantic Design:** Consistent slate-and-accent design system (`OmniTheme`) with smooth dark-mode ergonomics.
- **Customizable Dashboard & Favorites:** Pin frequently used calculators to a compact, quick-access gradient grid on the home screen.
- **Universal Live Search:** Instant, multi-indexed search covering module titles, descriptions, and inner toolkit operational modes.

---

## 🧮 Calculator & Utility Catalog

### 1. Everyday & General Math
- **Basic Math:** Standard arithmetic, percentage shortcuts, sign toggle, parenthetical evaluation, and calculation history.
- **Scientific Math:** Trigonometric functions, inverse and hyperbolic functions, natural & base-10 logarithms, roots ($\sqrt{x}$, $\sqrt[3]{x}$), powers ($x^y$, $x^2$, $x^3$, $e^x$, $10^x$), factorials ($n!$), absolute values, and Radian/Degree switching.
- **Universal Unit Converter:** Bidirectional conversion across 12 physical and digital domains (Length, Area with regional land units, Volume, Weight/Mass, Temperature, Pressure, Energy, Power, Speed, Force, Torque, and Digital Storage).
- **Date & Time Interval:** Exact calendar duration between dates (years, months, days, total hours/minutes), working days vs. weekends breakdown, and custom date addition/subtraction offset engine.
- **Fuel Cost & Trip Mileage:** Fuel required, round-trip toggles, passenger expense splitting, and metric (km & km/L) vs. imperial (miles & MPG) switching.
- **Percentages:** Quick share calculations, percentage increase/decrease, percentage difference, and original value reverse-lookup.
- **Shopping & Bills:** Discount stacking, sales tax additions/removals, unit price comparison, and tip splitting.
- **Ratios & Proportions:** Ratio scaling, multi-part total splitting, and missing proportional value solving.
- **Fractions & Mixed Numbers:** Exact fraction arithmetic (addition, subtraction, multiplication, division) with simplification.
- **Calendar & Unix Time:** ISO week numbers, day of the year, leap year validation, and UTC Unix epoch conversions.
- **Word Count:** Real-time character, word, sentence, and paragraph counters for text editing.
- **Shift & Time Sheet:** Clock-in/clock-out duration, overnight shift calculations, unpaid break deductions, and decimal hour conversions.
- **Energy & Battery:** Appliance electricity cost estimation, battery runtime, watt-hour (Wh), and amp-hour (Ah) conversions.

### 2. Finance & Business
- **Loan & Mortgage (EMI):** Monthly EMI calculator supporting both reducing balance and flat interest rates, principal vs. interest breakdown charts, and a month-by-month amortization schedule.
- **SIP & Lump Sum Investment:** Compound growth projections, CAGR returns, year-by-year schedules, and real-return calculations with inflation adjustments.
- **Salary & Work:** Gross-to-net pay estimates, overtime multipliers, sales commissions, raises, and annualized hourly rates.
- **Business Pricing:** Margin vs. markup pricing calculators, gross profit margins, and break-even sales volume analysis.
- **Savings & Budget:** Emergency fund sizing, savings goal target timelines, debt-to-income (DTI) ratio, and credit card utilization.
- **Interest & Returns:** Simple interest, compound growth, CAGR, Return on Investment (ROI), and inflation adjustments.

### 3. Construction & Geometry
- **Areas & Solids (Geometry):** 2D perimeter and area alongside 3D surface area and volume calculators for standard geometric shapes.
- **Paint, Tile & Flooring:** Rectangular room surface estimators, wall paint volume, floor tile counts, waste allowance percentages, and pack estimates.
- **Concrete, Soil & Mulch:** Volume calculators for rectangular slabs and circular columns, bag count estimation, and bulk material tonnage.

### 4. Health & Fitness
- **BMI & Ideal Body Weight (IBW):** Body Mass Index with WHO categorization spectrum, healthy weight target boundaries, and Devine & Robinson IBW formulas.
- **BMR & Daily Calorie Needs (TDEE):** Basal Metabolic Rate using the Mifflin-St Jeor equation, physical activity multipliers, and daily calorie targets for weight loss, maintenance, and muscle gain.
- **Pace, Speed & Finish Time:** Target running/cycling pace calculations, split times, and race finish time projections.
- **Strength Training:** Workout volume load calculations, total rep counts, and barbell plate-loading math per side.

### 5. Developer & Engineering
- **File Size & Transfer:** Data transfer duration estimates, network throughput, and decimal (MB/GB) vs. binary (MiB/GiB) capacity math.
- **Circuit Arithmetic:** Ohm’s law (DC voltage, current, resistance, power) and unloaded resistor voltage dividers.
- **Integer Tools:** Number base conversions (Binary, Octal, Decimal, Hexadecimal), GCD, LCM, factorials, permutations ($nPr$), and combinations ($nCr$).
- **Statistics & Averages:** Mean, median, mode, range, mean absolute deviation (MAD), weighted averages, sample variance, and standard deviation.

### 6. Sports & Tournaments
- **Round-Robin Match Scheduler:** Multi-pool tournament fixture generator with customizable matches per team, multi-leg / multi-round cycle support, and automated conflict-minimized random ordering.

---

## 🛠 Tech Stack

- **Framework:** Flutter (Android)
- **State Management:** Riverpod (`flutter_riverpod`)
- **Persistence:** `shared_preferences`
- **Charts & Data Visualization:** `fl_chart`
- **Math Engine:** `math_expressions`
- **External Redirection:** `url_launcher`