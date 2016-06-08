#define DEBUG		false

dzn_fnc_civen_getLocProperty = {
	// [@Loc, @Property] call dzn_fnc_civen_getLocProperty
	// Properties are:	"population", "populationType","vehicleCount","vehicleType","area","buildings","safe"
	
	switch (toLower(_this select 1)) do {
		case "population": 	{ (_this select 0) getVariable ["dzn_civen_population", nil] };
		case "populationtype": 	{ (_this select 0) getVariable ["dzn_civen_populationType", nil] };
		case "vehiclecount": 	{ (_this select 0) getVariable ["dzn_civen_vehicleCount", nil] };
		case "vehicletype": 	{ (_this select 0) getVariable ["dzn_civen_vehicleType", nil] };
		case "area"	:	{ (_this select 0) getVariable ["dzn_civen_area", nil] };
		case "buildings": 	{ (_this select 0) getVariable ["dzn_civen_buildings", nil] };
		case "roads":		{ (_this select 0) getVariable ["dzn_civen_roads", nil] };		
		case "areapos":		{ (_this select 0) getVariable ["dzn_civen_areaPos", nil] };	
		case "safe":		{ (_this select 0) getVariable ["dzn_civen_isSafe", nil] };
		case "dangertimestamp":	{ (_this select 0) getVariable ["dzn_civen_dangerTimestamp", nil] };
		case "currenttraffic":	{ (_this select 0) getVariable ["dzn_civen_currentTraffic", nil] };
	};
};

dzn_fnc_civen_setLocSafe = {
	// @Loc call dzn_fnc_civen_setLocSafe
	_this setVariable ["dzn_civen_isSafe", true];
};

dzn_fnc_civen_setLocDanger = {
	// @Loc call dzn_fnc_civen_setLocDanger	
	_this setVariable ["dzn_civen_dangerTimestamp", round(time)];
	_this setVariable ["dzn_civen_isSafe", false];
};

dzn_fnc_civen_randomizeParkedVehicle = {
	// [@Vehicle, @VehicleType Random Option (_vType select 3)] spawn dzn_fnc_civen_randomizeParkedVehicle
	// Randomize according to settings
	
	params ["_v", "_opt"];
	private["_fuelMax","_lockedChanceMax","_damageMax"];
	
	// Fuel
	_fuelMax = if (dzn_civen_parked_gFuelMaxForced || isNil { _opt select 0 }) then {
		dzn_civen_parked_gFuelMax
	} else {
		_opt select 0
	};
	_v setFuel random(_fuelMax);
	
	// Locked
	_lockedChanceMax = if (dzn_civen_parked_gLockedChanceForced || isNil { _opt select 1 }) then {
		dzn_civen_parked_gLockedChance
	} else {
		_opt select 1
	};
	if (random(1) < _lockedChanceMax) then {
		_v setVehicleLock "LOCKED";
	} else {
		_v setVehicleLock "UNLOCKED";
	};
	
	// Damage
	_damageMax = if (dzn_civen_parked_gDamageForced	 || isNil { _opt select 2 }) then {
		dzn_civen_parked_gDamage
	} else {
		_opt select 2
	};
	_v setDamage random(_damageMax);
};




dzn_fnc_civen_initialize = {
	if (isNil "dzn_civen_core") exitWith {["DZN CIVEN: There is no 'dzn_civen_core' GameLogic exists."] call BIS_fnc_error; };
	if ((synchronizedObjects dzn_civen_core) isEqualTo []) exitWith {["DZN CIVEN: There is no synchronized to 'dzn_civen_core' GameLogics."] call BIS_fnc_error; };

	private ["_loc","_locSettings","_locPopulation","_area"];
	{
		_loc = _x;
		
		// Settings mapping
		_locSettings = if (roleDescription _loc == "") then {
			[dzn_civen_locationSettings, typeOf _loc] call dzn_fnc_getValueByKey
		} else {
			[dzn_civen_locationSettings, roleDescription _loc] call dzn_fnc_getValueByKey
		};
		
		if (DEBUG) then { player sideChat format ["LOC %1: %2",  _loc, _locSettings]; };
		
		// Population		
		_locPopulation = 0;
		if (!isNil {_loc getVariable "dzn_civen_population"}) then {
			_locPopulation = _loc getVariable "dzn_civen_population";
		} else {
			_locPopulation = if (getDir _loc > -1) then { floor(getDir _loc) - 2 } else { 0 };
		};
		_loc setVariable [
			"dzn_civen_population"
			, _locPopulation
		];		
		
		// Population type
		_loc setVariable [
			"dzn_civen_populationType"
			, [dzn_civen_civilianTypes, _locSettings select 0] call dzn_fnc_getValueByKey
		];
		
		// Vehicle type
		_loc setVariable [
			"dzn_civen_vehicleType"
			, [ dzn_civen_vehicleTypes, _locSettings select 1] call dzn_fnc_getValueByKey
		];
		
		// Vehicle count
		private _parkedCount = 0;
		_parkedCount = if (!isNil {_loc getVariable "dzn_civen_parkedCount"}) then {
			_loc getVariable "dzn_civen_parkedCount"
		} else {
			round ((_locSettings select 2) * _locPopulation)			
		};
		_loc setVariable [
			"dzn_civen_vehicleCount"
			, _parkedCount
		];
		
		// Area
		_area = [];
		{
			if (_x isKindOf "EmptyDetector") then {
				_area pushBack ([_x, false] call dzn_fnc_convertTriggerToLocation);
			};
		} forEach (synchronizedObjects _loc);
		
		_loc setVariable [
			"dzn_civen_area"
			, _area
		];
		
		if (DEBUG) then { player sideChat format ["LOC %1: dzn_civen_area: %2", _loc, _area]; };	
		
		{
			if (_x isKindOf "EmptyDetector") then { deleteVehicle _x; };
		} forEach (synchronizedObjects _loc);
		
		// Get area buildings
		_loc setVariable [
			"dzn_civen_buildings"
			, [_area] call dzn_fnc_getLocationBuildings
		];
		
		// Get area roads
		_loc setVariable [
			"dzn_civen_roads"
			, _area call dzn_fnc_getLocationRoads
		];
		
		// Get location positions
		if (DEBUG) then { player sideChat format ["LOC AREA POS: %1", _area call dzn_fnc_getZonePosition]; };
		_loc setVariable [
			"dzn_civen_areaPos"
			,  _area call dzn_fnc_getZonePosition
		];
		
		_loc setVariable ["dzn_civen_isSafe", true];
		_loc setVariable ["dzn_civen_dangerTimestamp", 0];
		
		// If no 'isActive' or 'isActive' == true - run activate location.
		if ( isNil { _loc getVariable "dzn_civen_isActive" } || {_loc getVariable "dzn_civen_isActive"}) then {
			_loc spawn dzn_fnc_civen_activateLocation;
		};
		
		if (dzn_civen_allowTraffic) then {
			_loc setVariable ["dzn_civen_currentTraffic", []];
		};
		
		sleep 1;
	} forEach (synchronizedObjects dzn_civen_core);
	
	// Traffic
	if (dzn_civen_allowTraffic) then {
		[] execFSM "dzn_civen\FSM\dzn_civen_trafficControl.fsm";
	};
};

dzn_fnc_civen_activateLocation = {
	// @Location spawn dzn_fnc_civen_activateLocation
	params ["_loc"];
	
	private [
		"_maxPopulation"
		,"_locPopulation"
		,"_maxVehicles"
		,"_maxVehicles"		
		,"_pType"
		,"_vType"
		,"_buildings"
		,"_area"
		,"_locGroup"
		,"_home"
		,"_road"
		,"_roads"
		,"_vClass"
		,"_uClass"
		,"_u"	
		,"_s"
		,"_v"
		,"_isEHListener"
		,"_ehListenersCount"
		,"_ehListenersCountMax"
		,"_i"
		,"_dir"
	];	

	_maxPopulation =  [_loc,"population"] call dzn_fnc_civen_getLocProperty;
	_maxVehicles = [_loc,"vehicleCount"] call dzn_fnc_civen_getLocProperty;
	_pType = [_loc,"populationType"] call dzn_fnc_civen_getLocProperty;
	_vType = [_loc,"vehicleType"] call dzn_fnc_civen_getLocProperty;

	_buildings = [_loc,"buildings"] call dzn_fnc_civen_getLocProperty;
	_roads = [_loc, "roads"] call dzn_fnc_civen_getLocProperty;
	_area = [_loc,"area"] call dzn_fnc_civen_getLocProperty;
	
	_locGroup = createGroup civilian;
	_ehListenersCount = 0;
	_ehListenersCountMax = if (round (_maxPopulation * 0.4) < 1) then { 1 } else { round (_maxPopulation * 0.4) };
	if (_maxPopulation < 6 ) then {
		_ehListenersCountMax = _maxPopulation;
	};
	
	for "_i" from 1 to _maxPopulation do {
		sleep 1;
		_home = _buildings call BIS_fnc_selectRandom;
		_uClass = (_pType select 0) call BIS_fnc_selectRandom;
		_u = _locGroup createUnit [_uClass, _home buildingPos round(random 1), [], 0, "NONE"];
		_u setVariable ["dzn_civen_home", _home];
		
		_u allowDamage false;
		_u setSkill 0;
		_u disableAI "TARGET";
		_u disableAI "AUTOTARGET";
		_u disableAI "FSM";
		
		// Assign gear
		if !((_pType select 1) isEqualTo []) then {
			[_u, (_pType select 1) call BIS_fnc_selectRandom] call dzn_fnc_gear_assignKit;
		};
		
		// Custom Code
		_u call (_pType select 2);		
		
		// Listener of FiredNear
		_isEHListener = false;
		if (_ehListenersCount < _ehListenersCountMax) then {
			_isEHListener = true;
			_ehListenersCount = _ehListenersCount + 1;
		};
		
		[_u, _loc, _isEHListener] spawn {
			sleep 2;
			(_this select 0) allowDamage true;
			
			sleep 15;
			if (_this select 2) then {
				(_this select 0) setVariable ["dzn_civen_homeLocation", (_this select 1)];
				(_this select 0) addeventhandler ['FiredNear', {
					((_this select 0) getVariable "dzn_civen_homeLocation") call dzn_fnc_civen_setLocDanger;
				}];
			};
		};
		[_u, _loc] execFSM "dzn_civen\FSM\dzn_civen_civilianBehavior.fsm";
	};
	
	for "_i" from 1 to _maxVehicles do {
		sleep 1;
		_road = _roads call BIS_fnc_selectRandom;
		_roads = _roads - [_road];
		
		_vClass = (_vType select 0) call BIS_fnc_selectRandom;
		_s = if (random(2)>1) then { 1 } else { -1 };
		_v = createVehicle [_vClass, (_road modelToWorld [0, 0, 0]),[], 0, "FORM"];
		_v allowDamage false;
		
		_v setPos (_road modelToWorld [7 * _s, 0, 0]);
		
		_dir = [
			_road
			, if !(isNil { (roadsConnectedTo _road) select (round(random 1)) }) then { 
				(roadsConnectedTo _road) select (round(random 1))	
			} else {
				(roadsConnectedTo _road) select 0	
			}
		] call BIS_fnc_DirTo;		
		_v setDir (if (isNil {_dir}) then { 0 } else { _dir });
		
		// Assign Cargo Gear
		if !((_vType select 1) isEqualTo []) then {
			[_v, (_vType select 1) call BIS_fnc_selectRandom, true] call dzn_fnc_gear_assignKit;
		};
		
		// Custom code
		_v call (_vType select 2);
		
		[_v, _vType select 3] spawn dzn_fnc_civen_randomizeParkedVehicle;
		_v spawn {
			sleep 2;
			_this allowDamage true;
		};	
	};	

	_loc execFSM "dzn_civen\FSM\dzn_civen_locationState.fsm";
	_loc setVariable ["dzn_civen_isActive", true];
};
