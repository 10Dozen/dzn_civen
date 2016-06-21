if !(isServer || isDedicated) exitWith {};

dzn_civen_initialized = false;

//  **************** SETTINGS ********************
call compile preProcessFileLineNumbers "dzn_civen\Settings.sqf";


//  **************** INITIALIZATION ********************
call compile preProcessFileLineNumbers "dzn_civen\Configs.sqf";
call compile preProcessFileLineNumbers "dzn_civen\fn\dzn_civen_functions.sqf";
call compile preProcessFileLineNumbers "dzn_civen\fn\dzn_civen_behaviorFunctions.sqf";
call compile preProcessFileLineNumbers "dzn_civen\fn\dzn_civen_trafficFunctions.sqf";

// ***************** START ****************************
[] spawn {
	waitUntil { time > 5 };
	[] call dzn_fnc_civen_initialize;
};
