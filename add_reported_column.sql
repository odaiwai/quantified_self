DROP TABLE IF EXISTS cronometer2_dailysummary;
CREATE TABLE cronometer2_dailysummary as
  SELECT
    Timestamp,
    0 as Reported,
    Date,
    "Energy (kcal)",
    "Alcohol (g)",
    "Caffeine (mg)",
    "Water (g)",
    "B1 (Thiamine) (mg)",
    "B2 (Riboflavin) (mg)",
    "B3 (Niacin) (mg)",
    "B5 (Pantothenic Acid) (mg)",
    "B6 (Pyridoxine) (mg)",
    "B12 (Cobalamin) (µg)",
    "Folate (µg)",
    "Vitamin A (µg)",
    "Vitamin C (mg)",
    "Vitamin D (IU)",
    "Vitamin E (mg)",
    "Vitamin K (µg)",
    "Calcium (mg)",
    "Copper (mg)",
    "Iron (mg)",
    "Magnesium (mg)",
    "Manganese (mg)",
    "Phosphorus (mg)",
    "Potassium (mg)",
    "Selenium (µg)",
    "Sodium (mg)",
    "Zinc (mg)",
    "Carbs (g)",
    "Fiber (g)",
    "Starch (g)",
    "Sugars (g)",
    "Net Carbs (g)",
    "Fat (g)",
    "Cholesterol (mg)",
    "Monounsaturated (g)",
    "Polyunsaturated (g)",
    "Saturated (g)",
    "Trans-Fats (g)",
    "Omega-3 (g)",
    "Omega-6 (g)",
    "Cystine (g)",
    "Histidine (g)",
    "Isoleucine (g)",
    "Leucine (g)",
    "Lysine (g)",
    "Methionine (g)",
    "Phenylalanine (g)",
    "Protein (g)",
    "Threonine (g)",
    "Tryptophan (g)",
    "Tyrosine (g)",
    "Valine (g)",
    Completed
from cronometer_dailysummary;

DROP TABLE IF EXISTS cronometer2_servings;
CREATE TABLE cronometer2_servings
    as SELECT
    Timestamp,
    0 as Reported,
    Day,
    "Group",
    "Food Name",
    Amount,
    "Energy (kcal)",
    "Alcohol (g)",
    "Caffeine (mg)",
    "Water (g)",
    "B1 (Thiamine) (mg)",
    "B2 (Riboflavin) (mg)",
    "B3 (Niacin) (mg)",
    "B5 (Pantothenic Acid) (mg)",
    "B6 (Pyridoxine) (mg)",
    "B12 (Cobalamin) (µg)",
    "Folate (µg)",
    "Vitamin A (µg)",
    "Vitamin C (mg)",
    "Vitamin D (IU)",
    "Vitamin E (mg)",
    "Vitamin K (µg)",
    "Calcium (mg)",
    "Copper (mg)",
    "Iron (mg)",
    "Magnesium (mg)",
    "Manganese (mg)",
    "Phosphorus (mg)",
    "Potassium (mg)",
    "Selenium (µg)",
    "Sodium (mg)",
    "Zinc (mg)",
    "Carbs (g)",
    "Fiber (g)",
    "Starch (g)",
    "Sugars (g)",
    "Net Carbs (g)",
    "Fat (g)",
    "Cholesterol (mg)",
    "Monounsaturated (g)",
    "Polyunsaturated (g)",
    "Saturated (g)",
    "Trans-Fats (g)",
    "Omega-3 (g)",
    "Omega-6 (g)",
    "Cystine (g)",
    "Histidine (g)",
    "Isoleucine (g)",
    "Leucine (g)",
    "Lysine (g)",
    "Methionine (g)",
    "Phenylalanine (g)",
    "Protein (g)",
    "Threonine (g)",
    "Tryptophan (g)",
    "Tyrosine (g)",
    "Valine (g)",
    Category
from cronometer_servings;

DROP TABLE IF EXISTS cronometer2_NOTES;
CREATE TABLE cronometer2_NOTES as
  SELECT
    Timestamp,
    0 as Reported,
    Day,
    "Group",
    Note
    from cronometer_notes;

DROP TABLE IF EXISTS cronometer2_EXERCISES;
CREATE TABLE cronometer2_EXERCISES as
  SELECT
    Day,
    0 as Reported,
    "Group",
    Timestamp,
    Exercise,
    Minutes,
    "Calories Burned"
    from cronometer_exercises;

DROP TABLE IF EXISTS cronometer2_BIOMETRICS;
CREATE TABLE cronometer2_BIOMETRICS as
    SELECT
    Timestamp,
    0 as Reported,
    Day,
    "Group",
    Unit,
    Amount
from cronometer_exercises;

CREATE UNIQUE INDEX cronometer2_dailysummary_idx on cronometer2_dailysummary (timestamp, date);
