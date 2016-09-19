//  **************** SETTINGS **************************
call compile preprocessFileLineNumbers "dzn_civen\Settings.sqf";

// ***************** CLINT\SERVER INIT *****************

if (hasInterface) then {
	if !(dzn_civen_enableCivilControl) exitWith {};
	
	call compile preprocessFileLineNumbers "dzn_civen\fn\dzn_civen_clientFunctions.sqf";
	[] spawn dzn_fnc_civen_civCon_addUnitsControls;
};


if !(isServer || isDedicated) exitWith {};

dzn_civen_initialized = false;
dzn_civen_trafficGroup = createGroup civilian;
dzn_civen_trafficTotal = 0;
dzn_civen_locations = [];
dzn_civen_trafficLocations = [];

//  **************** INITIALIZATION ********************
call compile preprocessFileLineNumbers "dzn_civen\Configs.sqf";
call compile preprocessFileLineNumbers "dzn_civen\fn\dzn_civen_functions.sqf";
call compile preprocessFileLineNumbers "dzn_civen\fn\dzn_civen_behaviorFunctions.sqf";
call compile preprocessFileLineNumbers "dzn_civen\fn\dzn_civen_trafficFunctions.sqf";

if (isMultiplayer) then {
	dzn_civen_enableIdleAnimation = false;
};

// ***************** START *****************************
[] spawn {
	waitUntil { time > dzn_civen_InitTime };
	[] call dzn_fnc_civen_initialize;
	
	waitUntil { dzn_civen_initialized };
	[] call dzn_fnc_civen_activateAllLocations;
};


/*
	fnc_markAllObjects = {
     private _all = entities "CAManBase";

     {
      [
       format ["mrk1_%1", _forEachIndex]
       , getPosASL _x
       , "hd_dot"
       , "ColorRed"
       , "1"
       , false
      ] call dzn_fnc_createMarkerIcon;


     } forEach _all;


     player sideChat "All mission objects were marked.";
    };

    call fnc_markAllObjects;
*/
