enum UnitCategory {
  length('Length'),
  area('Area'),
  volume('Volume'),
  mass('Weight / Mass'),
  temperature('Temperature'),
  pressure('Pressure'),
  energy('Energy'),
  power('Power'),
  speed('Speed'),
  force('Force'),
  torque('Torque'),
  digital('Digital Storage');

  final String label;
  const UnitCategory(this.label);
}

class UnitDef {
  final String id;
  final String name;
  final String symbol;
  final double conversionFactor; // Relative to category base unit
  final double Function(double)? customToBase;
  final double Function(double)? customFromBase;

  const UnitDef({
    required this.id,
    required this.name,
    required this.symbol,
    this.conversionFactor = 1.0,
    this.customToBase,
    this.customFromBase,
  });

  double toBase(double value) {
    if (customToBase != null) return customToBase!(value);
    return value * conversionFactor;
  }

  double fromBase(double baseValue) {
    if (customFromBase != null) return customFromBase!(baseValue);
    return baseValue / conversionFactor;
  }
}

class UnitRegistry {
  // static final instead of static const accommodates runtime function pointers
  static final Map<UnitCategory, List<UnitDef>> unitsByCategory = {
    // BASE: Meter (m)
    UnitCategory.length: const [
      UnitDef(id: 'mm', name: 'Millimeter', symbol: 'mm', conversionFactor: 0.001),
      UnitDef(id: 'cm', name: 'Centimeter', symbol: 'cm', conversionFactor: 0.01),
      UnitDef(id: 'm', name: 'Meter', symbol: 'm', conversionFactor: 1.0),
      UnitDef(id: 'km', name: 'Kilometer', symbol: 'km', conversionFactor: 1000.0),
      UnitDef(id: 'in', name: 'Inch', symbol: 'in', conversionFactor: 0.0254),
      UnitDef(id: 'ft', name: 'Foot', symbol: 'ft', conversionFactor: 0.3048),
      UnitDef(id: 'yd', name: 'Yard', symbol: 'yd', conversionFactor: 0.9144),
      UnitDef(id: 'mi', name: 'Mile', symbol: 'mi', conversionFactor: 1609.344),
      UnitDef(id: 'nmi', name: 'Nautical Mile', symbol: 'NM', conversionFactor: 1852.0),
      UnitDef(id: 'au', name: 'Astronomical Unit', symbol: 'AU', conversionFactor: 1.495978707e11),
      UnitDef(id: 'ly', name: 'Light-year', symbol: 'ly', conversionFactor: 9.4607304725808e15),
      UnitDef(id: 'pc', name: 'Parsec', symbol: 'pc', conversionFactor: 3.08567758149137e16),
    ],

    // BASE: Square Meter (m²)
    UnitCategory.area: const [
      UnitDef(id: 'sq_m', name: 'Square Meter', symbol: 'm²', conversionFactor: 1.0),
      UnitDef(id: 'sq_ft', name: 'Square Foot', symbol: 'sq ft', conversionFactor: 0.09290304),
      UnitDef(id: 'sq_yd', name: 'Square Yard', symbol: 'sq yd', conversionFactor: 0.83612736),
      UnitDef(id: 'acre', name: 'Acre', symbol: 'ac', conversionFactor: 4046.8564224),
      UnitDef(id: 'hectare', name: 'Hectare', symbol: 'ha', conversionFactor: 10000.0),
      UnitDef(id: 'cent', name: 'Cent', symbol: 'ct', conversionFactor: 40.4685642),
      UnitDef(id: 'ground', name: 'Ground', symbol: 'grnd', conversionFactor: 222.967),
      UnitDef(id: 'guntha', name: 'Guntha', symbol: 'guntha', conversionFactor: 101.17141),
      UnitDef(id: 'bigha', name: 'Bigha (Standard)', symbol: 'bigha', conversionFactor: 2529.285),
      UnitDef(id: 'kanal', name: 'Kanal', symbol: 'kanal', conversionFactor: 505.857),
      UnitDef(id: 'marla', name: 'Marla', symbol: 'marla', conversionFactor: 25.2929),
      UnitDef(id: 'sq_link', name: 'Square Link', symbol: 'sq li', conversionFactor: 0.0404686),
    ],

    // BASE: Liter (L)
    UnitCategory.volume: const [
      UnitDef(id: 'ml', name: 'Milliliter', symbol: 'mL', conversionFactor: 0.001),
      UnitDef(id: 'l', name: 'Liter', symbol: 'L', conversionFactor: 1.0),
      UnitDef(id: 'cu_m', name: 'Cubic Meter', symbol: 'm³', conversionFactor: 1000.0),
      UnitDef(id: 'cu_in', name: 'Cubic Inch', symbol: 'cu in', conversionFactor: 0.016387064),
      UnitDef(id: 'cu_ft', name: 'Cubic Foot', symbol: 'cu ft', conversionFactor: 28.316846592),
      UnitDef(id: 'gal_us', name: 'Gallon (US)', symbol: 'gal', conversionFactor: 3.785411784),
      UnitDef(id: 'qt_us', name: 'Quart (US)', symbol: 'qt', conversionFactor: 0.946352946),
      UnitDef(id: 'pt_us', name: 'Pint (US)', symbol: 'pt', conversionFactor: 0.473176473),
      UnitDef(id: 'cup_us', name: 'Cup (US)', symbol: 'cup', conversionFactor: 0.2365882365),
      UnitDef(id: 'fl_oz_us', name: 'Fluid Ounce (US)', symbol: 'fl oz', conversionFactor: 0.0295735295625),
      UnitDef(id: 'bbl', name: 'Barrel (Oil)', symbol: 'bbl', conversionFactor: 158.987294928),
    ],

    // BASE: Gram (g)
    UnitCategory.mass: const [
      UnitDef(id: 'mg', name: 'Milligram', symbol: 'mg', conversionFactor: 0.001),
      UnitDef(id: 'g', name: 'Gram', symbol: 'g', conversionFactor: 1.0),
      UnitDef(id: 'kg', name: 'Kilogram', symbol: 'kg', conversionFactor: 1000.0),
      UnitDef(id: 't', name: 'Metric Tonne', symbol: 't', conversionFactor: 1000000.0),
      UnitDef(id: 'oz', name: 'Ounce', symbol: 'oz', conversionFactor: 28.349523125),
      UnitDef(id: 'lb', name: 'Pound', symbol: 'lb', conversionFactor: 453.59237),
      UnitDef(id: 'st', name: 'Stone', symbol: 'st', conversionFactor: 6350.29318),
      UnitDef(id: 'ct', name: 'Carat', symbol: 'ct', conversionFactor: 0.2),
      UnitDef(id: 'gr', name: 'Grain', symbol: 'gr', conversionFactor: 0.06479891),
      UnitDef(id: 'slug', name: 'Slug', symbol: 'slug', conversionFactor: 14593.903),
    ],

    // BASE: Celsius (°C)
    UnitCategory.temperature: [
      UnitDef(
        id: 'c',
        name: 'Celsius',
        symbol: '°C',
        customToBase: (v) => v,
        customFromBase: (v) => v,
      ),
      UnitDef(
        id: 'f',
        name: 'Fahrenheit',
        symbol: '°F',
        customToBase: (v) => (v - 32.0) * 5.0 / 9.0,
        customFromBase: (v) => (v * 9.0 / 5.0) + 32.0,
      ),
      UnitDef(
        id: 'k',
        name: 'Kelvin',
        symbol: 'K',
        customToBase: (v) => v - 273.15,
        customFromBase: (v) => v + 273.15,
      ),
      UnitDef(
        id: 'r',
        name: 'Rankine',
        symbol: '°R',
        customToBase: (v) => (v - 491.67) * 5.0 / 9.0,
        customFromBase: (v) => (v + 273.15) * 9.0 / 5.0,
      ),
    ],

    // BASE: Pascal (Pa)
    UnitCategory.pressure: const [
      UnitDef(id: 'pa', name: 'Pascal', symbol: 'Pa', conversionFactor: 1.0),
      UnitDef(id: 'kpa', name: 'Kilopascal', symbol: 'kPa', conversionFactor: 1000.0),
      UnitDef(id: 'bar', name: 'Bar', symbol: 'bar', conversionFactor: 100000.0),
      UnitDef(id: 'psi', name: 'Pounds/Sq Inch', symbol: 'psi', conversionFactor: 6894.757293),
      UnitDef(id: 'atm', name: 'Standard Atmosphere', symbol: 'atm', conversionFactor: 101325.0),
      UnitDef(id: 'mmhg', name: 'Millimeter of Mercury', symbol: 'mmHg', conversionFactor: 133.322387415),
      UnitDef(id: 'torr', name: 'Torr', symbol: 'Torr', conversionFactor: 133.322368421),
    ],

    // BASE: Joule (J)
    UnitCategory.energy: const [
      UnitDef(id: 'j', name: 'Joule', symbol: 'J', conversionFactor: 1.0),
      UnitDef(id: 'kj', name: 'Kilojoule', symbol: 'kJ', conversionFactor: 1000.0),
      UnitDef(id: 'cal', name: 'Gram Calorie', symbol: 'cal', conversionFactor: 4.184),
      UnitDef(id: 'kcal', name: 'Kilocalorie (Food)', symbol: 'kcal', conversionFactor: 4184.0),
      UnitDef(id: 'wh', name: 'Watt-hour', symbol: 'Wh', conversionFactor: 3600.0),
      UnitDef(id: 'kwh', name: 'Kilowatt-hour', symbol: 'kWh', conversionFactor: 3600000.0),
      UnitDef(id: 'btu', name: 'British Thermal Unit', symbol: 'BTU', conversionFactor: 1055.05585),
      UnitDef(id: 'ev', name: 'Electronvolt', symbol: 'eV', conversionFactor: 1.602176634e-19),
      UnitDef(id: 'ft_lb', name: 'Foot-Pound', symbol: 'ft⋅lb', conversionFactor: 1.355817948),
    ],

    // BASE: Watt (W)
    UnitCategory.power: const [
      UnitDef(id: 'w', name: 'Watt', symbol: 'W', conversionFactor: 1.0),
      UnitDef(id: 'kw', name: 'Kilowatt', symbol: 'kW', conversionFactor: 1000.0),
      UnitDef(id: 'hp', name: 'Horsepower (Mechanical)', symbol: 'hp', conversionFactor: 745.699872),
      UnitDef(id: 'btu_h', name: 'BTU / Hour', symbol: 'BTU/h', conversionFactor: 0.29307107),
    ],

    // BASE: Meter per second (m/s)
    UnitCategory.speed: const [
      UnitDef(id: 'mps', name: 'Meter per Second', symbol: 'm/s', conversionFactor: 1.0),
      UnitDef(id: 'kmh', name: 'Kilometer per Hour', symbol: 'km/h', conversionFactor: 0.277777778),
      UnitDef(id: 'mph', name: 'Mile per Hour', symbol: 'mph', conversionFactor: 0.44704),
      UnitDef(id: 'knot', name: 'Knot', symbol: 'kn', conversionFactor: 0.514444444),
      UnitDef(id: 'mach', name: 'Mach (at STP)', symbol: 'Ma', conversionFactor: 340.29),
    ],

    // BASE: Newton (N)
    UnitCategory.force: const [
      UnitDef(id: 'n', name: 'Newton', symbol: 'N', conversionFactor: 1.0),
      UnitDef(id: 'kn', name: 'Kilonewton', symbol: 'kN', conversionFactor: 1000.0),
      UnitDef(id: 'kgf', name: 'Kilogram-Force', symbol: 'kgf', conversionFactor: 9.80665),
      UnitDef(id: 'lbf', name: 'Pound-Force', symbol: 'lbf', conversionFactor: 4.4482216),
      UnitDef(id: 'dyn', name: 'Dyne', symbol: 'dyn', conversionFactor: 1e-5),
    ],

    // BASE: Newton-Meter (N⋅m)
    UnitCategory.torque: const [
      UnitDef(id: 'nm', name: 'Newton-Meter', symbol: 'N⋅m', conversionFactor: 1.0),
      UnitDef(id: 'lbft', name: 'Pound-Foot', symbol: 'lb⋅ft', conversionFactor: 1.3558179483314),
      UnitDef(id: 'kgfm', name: 'Kilogram-Force Meter', symbol: 'kgf⋅m', conversionFactor: 9.80665),
    ],

    // BASE: Bit (b)
    UnitCategory.digital: const [
      UnitDef(id: 'b', name: 'Bit', symbol: 'b', conversionFactor: 1.0),
      UnitDef(id: 'B', name: 'Byte', symbol: 'B', conversionFactor: 8.0),
      UnitDef(id: 'KB', name: 'Kilobyte (KB)', symbol: 'KB', conversionFactor: 8.0 * 1024.0), // 8,192 b
      UnitDef(id: 'MB', name: 'Megabyte (MB)', symbol: 'MB', conversionFactor: 8.0 * 1048576.0), // 8,388,608 b (1024 KB)
      UnitDef(id: 'GB', name: 'Gigabyte (GB)', symbol: 'GB', conversionFactor: 8.0 * 1073741824.0), // 1024 MB
      UnitDef(id: 'TB', name: 'Terabyte (TB)', symbol: 'TB', conversionFactor: 8.0 * 1099511627776.0), // 1024 GB
      UnitDef(id: 'PB', name: 'Petabyte (PB)', symbol: 'PB', conversionFactor: 8.0 * 1125899906842624.0), // 1024 TB
      UnitDef(id: 'KiB', name: 'Kibibyte (IEC)', symbol: 'KiB', conversionFactor: 8.0 * 1024.0),
      UnitDef(id: 'MiB', name: 'Mebibyte (IEC)', symbol: 'MiB', conversionFactor: 8.0 * 1048576.0),
      UnitDef(id: 'GiB', name: 'Gibibyte (IEC)', symbol: 'GiB', conversionFactor: 8.0 * 1073741824.0),
    ],
  };
}