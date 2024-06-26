-- Add the column "Group" to the table Servings  in third place
DROP TABLE TEMP;
CREATE TABLE temp AS
SELECT
    TIMESTAMP,
    Day,
    'None' as "Group",
    "Food Name",
    "Amount",
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
    "Category"
FROM "cronometer_servings";
DROP TABLE "cronometer_servings";
CREATE TABLE "cronometer_servings" AS SELECT * FROM "temp";
DROP TABLE "temp";
