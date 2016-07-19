if !(isServer || isDedicated) exitWith {};

dzn_civen_initialized = false;
dzn_civen_trafficGroup = createGroup civilian;

//  **************** SETTINGS ********************
call compile preProcessFileLineNumbers "dzn_civen\Settings.sqf";


//  **************** INITIALIZATION ********************
call compile preProcessFileLineNumbers "dzn_civen\Configs.sqf";
call compile preProcessFileLineNumbers "dzn_civen\fn\dzn_civen_functions.sqf";
call compile preProcessFileLineNumbers "dzn_civen\fn\dzn_civen_behaviorFunctions.sqf";
call compile preProcessFileLineNumbers "dzn_civen\fn\dzn_civen_trafficFunctions.sqf";

if (isMultiplayer) then {
	dzn_civen_enableIdleAnimation = false;
};

// ***************** START ****************************
[] spawn {
	waitUntil { time > dzn_civen_InitTime };
	[] call dzn_fnc_civen_initialize;
	
	waitUntil { dzn_civen_initialized };
	[] call dzn_fnc_civen_activateAllLocations;
};
