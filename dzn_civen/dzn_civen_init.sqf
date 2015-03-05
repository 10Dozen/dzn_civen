//	************** DZN_CIVEN PARAMETERS ******************

// Condition of initialization
dzn_civen_conditionBeforeInit		=	"true";

// Delay before and after zones initializations
dzn_civen_preInitTimeout			=	0;
dzn_civen_afterInitTimeout			=	1;

// Civilian population for city, town and village
dzn_civen_cityPopulation 			=	20;
dzn_civen_townPopulation			=	10;
dzn_civen_villagePopulation			=	5;

// Size of locations for check
dzn_civen_citySize					=	500;
dzn_civen_townSize					=	200;
dzn_civen_villageSize				=	100;




//	**************	SERVER OR HEADLESS	*****************
if ( entities "ModuleAnimals_F" isEqualTo [] ) exitWith {
	player globalChat "Are you sure? There is no Animal Module on the map.";
};

// If a player - exits script
if (hasInterface && !isServer) exitWith {};

// Get HC unit (Mission parameter "HeadlessClient" should be defined, see F3 Framework)
if (("HeadlessClient" call BIS_fnc_GetParamValue) == 1) then {
	// If Headless exists - server won't run script
	if (isServer) exitWith {};
};


//	**************	INITIALIZATION *********************
waitUntil { call compile dzn_civen_conditionBeforeInit };

// Initialization of dzn_gear
waitUntil { !isNil {dzn_gear_kitsInitialized} };

// Initialization of dzn_dynai
// call compile preProcessFileLineNumbers "dzn_civen\dzn_civen_customZones.sqf";
// call compile preProcessFileLineNumbers "dzn_civen\dzn_civen_commonFunctions.sqf";
call compile preProcessFileLineNumbers "dzn_civen\dzn_civen_functions.sqf";

// ************** Start of DZN_DYNAI ********************
waitUntil { time > dzn_civen_preInitTimeout };
// call dzn_fnc_civen_initZones;

waitUntil { time > dzn_civen_afterInitTimeout };
// call dzn_fnc_civen_startZones;
