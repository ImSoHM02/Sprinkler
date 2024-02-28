STRINGS = GLOBAL.STRINGS
Ingredient = GLOBAL.Ingredient
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
TECH = GLOBAL.TECH



Assets = 
{
	Asset("IMAGE", "images/inventoryimages/g_sprinkler.tex" ),
	Asset("ATLAS", "images/inventoryimages/g_sprinkler.xml" ),
	Asset("SOUNDPACKAGE", "sound/Hamlet.fev"),
	Asset("SOUND", "sound/Hamlet.fsb"),
	Asset("ANIM", "anim/sprinkler.zip"),
	Asset("ANIM", "anim/sprinkler_meter.zip"),
}

PrefabFiles =
{
	"g_sprinkler",
	"rain_drop",
	"water_spray",
}

----------------Descriptions----------------
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.G_SPRINKLER = "Makes plants less thirsty!"
GLOBAL.STRINGS.RECIPE_DESC.G_SPRINKLER = "A sprinkler for watering plants"
GLOBAL.STRINGS.NAMES.G_SPRINKLER = "Sprinkler"

TUNING.SPRINKLER_EXTINGUISH_HEAT_PERCENT = GetModConfigData("SprinklerExtinguishHeatPercent")
TUNING.SPRINKLER_MAX_FUEL_TIME = GetModConfigData("SprinklerMaxFuelTime")
TUNING.SPRINKLER_PROTECTION_TIME = GetModConfigData("SprinklerProtectionTime")
TUNING.SPRINKLER_PROTECTION_DIST = GetModConfigData("SprinklerProtectionDist")
TUNING.SPRINKLER_RANGE = GetModConfigData("SprinklerRange")
TUNING.SPRINKLER_TEMP_REDUCTION = GetModConfigData("SprinklerTempReduction")
TUNING.SPRINKLER_WET_PLAYER = GetModConfigData("SprinklerWetPlayer")
TUNING.SPRINKLER_FUEL_BONUS_MULTIPLIER = GetModConfigData("SprinklerFuelBonusMultiplier")

----------------Recipe----------------

local difficultyState = GetModConfigData("SprinklerRecipe")

if difficultyState == 1 then
        AddRecipe2("g_sprinkler",
        { 
        		Ingredient("gears", 1),
				Ingredient("ice", 5)
        },
                TECH.SCIENCE_ZERO, "g_sprinkler_placer", {"GARDENING"})
		RegisterInventoryItemAtlas("images/inventoryimages/g_sprinkler.xml", "g_sprinkler.tex")
end

if difficultyState == 2 then
        AddRecipe2("g_sprinkler",
        { 
        		Ingredient("gears", 2),
				Ingredient("ice", 10)
        },
                TECH.SCIENCE_ONE,"g_sprinkler_placer", {"GARDENING"})
		RegisterInventoryItemAtlas("images/inventoryimages/g_sprinkler.xml", "g_sprinkler.tex")
end

if difficultyState == 3 then
        AddRecipe2("g_sprinkler",
        { 
        		Ingredient("gears", 3),
				Ingredient("ice", 20)
        },
                TECH.SCIENCE_TWO,"g_sprinkler_placer", {"GARDENING"})
		RegisterInventoryItemAtlas("images/inventoryimages/g_sprinkler.xml", "g_sprinkler.tex")
end