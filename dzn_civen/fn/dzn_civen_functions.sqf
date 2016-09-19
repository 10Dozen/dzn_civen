#define DEBUG								false
#define GetLP(LOC,PROP)						[LOC, PROP] call dzn_fnc_civen_getLocProperty
#define ResolveParam(ISGLOBAL,GVAL,LVAL)	if (ISGLOBAL) then {GVAL} else {LVAL}

dzn_fnc_civen_getLocProperty = {
	// [@Loc, @Property] call dzn_fnc_civen_getLocProperty
	// Properties are:	"population", "populationType","vehicleCount","vehicleType","area","buildings","safe"
	params["_loc","_p"];
	private _propertyName = switch (toLower(_p)) do {
		case "population": 		{ "dzn_civen_population" };
		case "populationtype": 	{ "dzn_civen_populationType" };
		case "vehiclecount": 	{ "dzn_civen_vehicleCount" };
		case "vehicletype": 	{ "dzn_civen_vehicleType" };
		case "area"	:			{ "dzn_civen_area" };
		case "buildings": 		{ "dzn_civen_buildings" };
		case "roads":			{ "dzn_civen_roads" };		
		case "areapos":			{ "dzn_civen_areaPos" };	
		case "safe":			{ "dzn_civen_isSafe" };
		case "dangertimestamp":	{ "dzn_civen_dangerTimestamp" };
		case "trafficavailable": { "dzn_civen_trafficAvailable" };
		case "currenttraffic":	{ "dzn_civen_currentTraffic" };
	};	
	
	(_loc getVariable [_propertyName, nil])
};


/*
	Location state
*/

dzn_fnc_civen_setLocSafe = {
	_this setVariable ["dzn_civen_isSafe", true];
};

dzn_fnc_civen_setLocDanger = {
	_this setVariable ["dzn_civen_dangerTimestamp", round(time)];
	_this setVariable ["dzn_civen_isSafe", false];
};

/*
	Activate zone
*/
dzn_fnc_civen_activateLocation = {
	// @Location spawn dzn_fnc_civen_activateLocation
	params ["_loc"];
	if (_loc getVariable ["dzn_civen_isActive", false]) exitWith {};
	
	/*
		Spawn population
	*/
	private _maxPopulation = GetLP(_loc,"population");
	if (_maxPopulation > 0 && dzn_civen_allowCivils) then {	
		private _populationConfig = [dzn_civen_civilianTypes, GetLP(_loc,"populationType")] call dzn_fnc_getValueByKey;
		private _buildings = GetLP(_loc,"buildings");
	
		private _group = createGroup civilian;
		private _ehListenersCount = 0;
		private _ehListenersCountMax = if (round (_maxPopulation * 0.4) < 1) then { 1 } else { round (_maxPopulation * 0.4) };
		if (_maxPopulation < 6 ) then {
			_ehListenersCountMax = _maxPopulation;
		};
		
		for "_i" from 1 to _maxPopulation do {
			sleep dzn_civen_UnitSpawnTimeout;
			
			private _home = selectRandom _buildings;
			
			private _u = _group createUnit [
				selectRandom (_populationConfig select 0)
				, _home buildingPos round(random 1)
				,[]
				,0
				,"NONE"
			];			
			_u allowDamage false;
			_u setSkill 0;
			_u disableAI "TARGET";
			_u disableAI "AUTOTARGET";
			_u disableAI "FSM";
			
			// Assign gear
			if !((_populationConfig select 1) isEqualTo []) then {
				[_u, selectRandom (_populationConfig select 1)] call dzn_fnc_gear_assignKit;
			};
			
			// Custom Code
			_u call (_populationConfig select 2);		
			
			// Listener of FiredNear
			private _isEHListener = false;
			if (_ehListenersCount < _ehListenersCountMax) then {
				_isEHListener = true;
				_ehListenersCount = _ehListenersCount + 1;
			};
			
			[_u, _loc, _isEHListener] spawn {
				params["_unit","_loc","_isListener"];
				sleep 2;
				_unit allowDamage true;
				
				sleep 15;
				if (_isListener && dzn_civen_enableUnsafeBehaviour) then {
					_unit setVariable ["dzn_civen_homeLocation", _loc];
					_unit addEventHandler ['FiredNear', {
						((_this select 0) getVariable "dzn_civen_homeLocation") call dzn_fnc_civen_setLocDanger;
					}];
				};
			};
			
			_u setVariable ["dzn_civen_home",_home];
			[_u, _loc] execFSM "dzn_civen\FSM\dzn_civen_civilianBehavior.fsm";
		};			
	};
	
	/*
		Spawn vehicle
	*/
	private _maxVehicles = GetLP(_loc,"vehicleCount");
	
	_checkHouseNear = {
		private _loc = _this select 0;
		private _pos = _this select 1;
		private _range = _this select 2;
		
		private _result = false;
		{
			if ((_x distance2d _pos) <= _range) exitWith { _result = true };
		} forEach (GetLP(_loc, "buildings"));
		
		_result
	};
	
	if (
		_maxVehicles > 0
		&& !( GetLP(_loc,"roads") isEqualTo [] )
		&& dzn_civen_allowParkedVehicles
	) then {
		private _vehicleConfig = [dzn_civen_vehicleTypes, GetLP(_loc,"vehicleType")] call dzn_fnc_getValueByKey;
		private _roads = GetLP(_loc,"roads");		
		
		for "_i" from 1 to _maxVehicles do {
			sleep dzn_civen_ParkedSpawnTimeout;
			
			private _vehClass = selectRandom (_vehicleConfig select 0);			
			
			private _road = objNull;
			private _s = 0;
			private _vehPos = [-100,-100,0];
			private _dir = 0;
			private _vehPosFound = false;
			
			#define	GET_RANDOM_SIGN	if (random(2)>1) then { 1 } else { -1 }
			#define	CHECK_VEH_POS	((_vehPos isFlatEmpty [(sizeof _vehClass) / 5,-1,300,(sizeof _vehClass)*1.1,0, true]) isEqualTo [] )
			for "_j" from 0 to 1000 do {
				_road = selectRandom _roads;
				_s = GET_RANDOM_SIGN;
				_vehPos = _road modelToWorld [7 * _s, 0, 0];
				
				if ( CHECK_VEH_POS && [_loc, _vehPos, 40] call _checkHouseNear ) exitWith {
					_vehPosFound = true;
					_roads = _roads - [_road];
					
					_dir = [
						_road
						, if !(isNil { (roadsConnectedTo _road) select (round(random 1)) }) then { 
							(roadsConnectedTo _road) select (round(random 1))	
						} else {
							(roadsConnectedTo _road) select 0	
						}
					] call BIS_fnc_DirTo;					
					_dir = if (isNil {_dir}) then { 0 } else { _dir };
				};			
			};
			
			if !(_vehPosFound) then {
				for "_j" from 0 to 1000 do {
					_s = GET_RANDOM_SIGN;
					_vehPos = (selectRandom (GetLP(_loc, "buildings"))) modelToWorld [35 * _s, random(30) * _s, 0];	
				
					if ( CHECK_VEH_POS ) exitWith {
						_vehPosFound = true;
					};
				};
			};	
			
			if !(_vehPosFound) exitWith {};
			
			private _v = [[_vehPos, _dir], _vehClass] call dzn_fnc_createVehicle;			
			
			// Assign Cargo Gear
			if !((_vehicleConfig select 1) isEqualTo []) then {
				[_v, selectRandom (_vehicleConfig select 1), true] call dzn_fnc_gear_assignKit;
			};
			
			// Custom code
			_v call (_vehicleConfig select 2);
			
			[_v, _vehicleConfig select 3] spawn dzn_fnc_civen_randomizeParkedVehicle;			
		};
	};
	if (DEBUG) then { player sideChat format["CIVEN: Location activated - %1", _loc]; };
	
	
	_loc execFSM "dzn_civen\FSM\dzn_civen_locationState.fsm";	
	_loc setVariable ["dzn_civen_isActive", true];
};

dzn_fnc_civen_randomizeParkedVehicle = {
	// [@Vehicle, @VehicleType Random Option (_vType select 3)] spawn dzn_fnc_civen_randomizeParkedVehicle
	// Randomize according to settings
	
	params ["_v", "_settings"];
	
	private["_fuelMax","_lockedChanceMax","_damageMax"];	
	
	// Settings	
	private _fuelMax = ResolveParam(
		dzn_civen_parked_gFuelMaxForced
		,dzn_civen_parked_gFuelMax
		,_settings select 0
	);

	private _lockedChanceMax = ResolveParam(
		dzn_civen_parked_gLockedChanceForced
		,dzn_civen_parked_gLockedChance
		,_settings select 1
	);
		
	private _damageMax  = ResolveParam(
		dzn_civen_parked_gDamageForced
		,dzn_civen_parked_gDamage
		,_settings select 2
	);
	
	_v setFuel random(_fuelMax);
	_v setVehicleLock (if (random(1) < _lockedChanceMax) then { "LOCKED" } else { "UNLOCKED" });
	_v setDamage random(_damageMax);	
};

/*
	Initialization
*/

dzn_fnc_civen_setLocationPropertiesFromConfigLine = {
	/*
		_loc call dzn_fnc_civen_parseConfigLine
		
		Config line is taken from 'dzn_civen_configLine' variable of location:
		e.g. '
		this setVariable ["dzn_civen_configLine", 'civAmount=[1,5]; vehAmount=[1,5]; civType="greececivil"; vehType="GreeceVehicles";']
		
	*/
	if (isNil {_this getVariable "dzn_civen_configLine"}) exitWith {};
	
	private _configList = (_this getVariable "dzn_civen_configLine") splitString ";";
	{
		call compile ("dzn_civen_parsed_" + (_x splitString " " joinString ""));
	} forEach _configList;
	
	
	{		
		if (!isNil (_x select 0)) then {
			_this setVariable [
				_x select 1
				, call compile (_x select 0)
			];
			
			call compile ((_x select 0) + "= nil");
		};
	} forEach [
		["dzn_civen_parsed_civAmount", "dzn_civen_population"]
		,["dzn_civen_parsed_vehAmount", "dzn_civen_parkedCount"]
		,["dzn_civen_parsed_civType", "dzn_civen_populationType"]
		,["dzn_civen_parsed_vehType", "dzn_civen_vehicleType"]
	];
};

dzn_fnc_civen_initLocation = {	
	params["_loc"];
	if (_loc getVariable ["dzn_civen_initialized", false]) exitWith {};
	
	_getRandom = {
		round( random [
			_this select 0
			, ceil( (_this select 0) + (_this select 1) )/2 
			,_this select 1
		])	
	};
	_getRange = {
		if (_this isEqualTo []) then { [0,0] } else { _this }	
	};	
	
	// Get Settings	-- in format ["GreeceCivil", [] or [2,5], "GreeceVehicles", 0.3 or [2,5]] 
	private _locSettings = if (roleDescription _loc == "") then {
		[dzn_civen_locationSettings, typeOf _loc] call dzn_fnc_getValueByKey
	} else {
		[dzn_civen_locationSettings, _loc getVariable "dzn_civen_configName"] call dzn_fnc_getValueByKey
	};
	if (DEBUG) then { player sideChat format ["LOC %1: %2",  _loc, _locSettings]; };
	
	/*
		Parse config from location properties
	*/
	_loc call dzn_fnc_civen_setLocationPropertiesFromConfigLine;
	
	/*
		Get Population		- format X (Number)
		a) from GameLogic parameter
		b) from Config parameter
	*/
	private _population = 0;
	
	if (!isNil {_loc getVariable "dzn_civen_population"}) then {
		_population = ( (_loc getVariable "dzn_civen_population") call _getRange ) call _getRandom;
	} else {
		_population = ( (_locSettings select 1)  call _getRange ) call _getRandom;
	};	
	_population = round(_population);
	
	/*
		Get Population type	- format "Population_ConfigName"
		a) from GameLogic parameter
		b) from Config parameter
	*/
	private _populationType = "";
	if (!isNil {_loc getVariable "dzn_civen_populationType"}) then {
		_populationType = _loc getVariable "dzn_civen_populationType";
	} else {
		_populationType = _locSettings select 0;
	};
	
	/*
		Get Vehicle amount		- format X (Number)
		a) global if forced
		b) from GameLogic parameter
		c) from Config parameter
		
	*/
	private _parkedCount = 0;
	if (dzn_civen_parked_forceAmountPerLocation) then {
		_parkedCount = ( dzn_civen_parked_forceAmountLimit call _getRange ) call _getRandom;	
	} else {
		if (!isNil {_loc getVariable "dzn_civen_parkedCount"}) then {
			_parkedCount = ( (_loc getVariable "dzn_civen_parkedCount") call _getRange ) call _getRandom;	
		} else {		
			if (typename (_locSettings select 3) == "ARRAY") then { 
				_parkedCount = ( (_locSettings select 3) call _getRange ) call _getRandom;	
			} else {
				_parkedCount = round(_locSettings select 3) * _population;
			};
		};	
	};
	_parkedCount = round(_parkedCount);
	
	
	/*
		Get Vehicle type		- format 'VehicleType_Config_Name'
		a) from GameLogic parameter
		b) from Config parameter
	*/	
	private _vehicleType = "";
	if (!isNil {_loc getVariable "dzn_civen_vehicleType"}) then {
		_vehicleType = _loc getVariable "dzn_civen_vehicleType";
	} else {
		_vehicleType = _locSettings select 2;
	};	
	
	/*
		Get Area
	*/	
	private _area = [];	
	private _areaTrgs = synchronizedObjects _loc;
	{
		if (_x isKindOf "EmptyDetector") then {
			_area pushBack ([_x, true] call dzn_fnc_convertTriggerToLocation);
		};
	} forEach _areaTrgs;	
	if (DEBUG) then {  player sideChat format ["LOC %1: dzn_civen_area: %2", _loc, _area]; };		
	if (DEBUG) then { player sideChat format ["LOC AREA POS: %1", _area call dzn_fnc_getZonePosition]; };
		
	/*
		Set up Location properties
	*/
	
	private _roads = _area call dzn_fnc_getLocationRoads;
	[
		_loc
		, [
			["dzn_civen_population"			, _population]
			,["dzn_civen_populationType"		, _populationType]
			,["dzn_civen_vehicleCount"		, _parkedCount]
			,["dzn_civen_vehicleType"		, _vehicleType]
			,["dzn_civen_area"			, _area]
			,["dzn_civen_areaPos"			,  _area call dzn_fnc_getZonePosition]
			,["dzn_civen_buildings"			, [_area] call dzn_fnc_getLocationBuildings]
			,["dzn_civen_roads"			, _roads]
			,["dzn_civen_isSafe"			, true]
			,["dzn_civen_dangerTimestamp"		, 0]
			,["dzn_civen_trafficAvailable"	, !(_roads isEqualTo []) ]
		]
	] call dzn_fnc_setVars;
	
	// If no 'isActive' or 'isActive' == true - run activate location.
	if (_loc getVariable ["dzn_civen_isActive", false]) then {
		_loc spawn dzn_fnc_civen_activateLocation;
	};
	
	if (dzn_civen_allowTraffic && GetLP(_loc,"trafficAvailable")) then {
		_loc setVariable ["dzn_civen_currentTraffic", []];
		dzn_civen_trafficLocations pushBack _loc;
	};

	dzn_civen_locations pushBack _loc;
	_loc setVariable ["dzn_civen_initialized", true];
};


dzn_fnc_civen_initialize = {
	if (isNil "dzn_civen_core") exitWith {
		["DZN CIVEN: There is no 'dzn_civen_core' GameLogic exists."] call BIS_fnc_error; 
	};
	if ((synchronizedObjects dzn_civen_core) isEqualTo []) exitWith {
		["DZN CIVEN: There is no synchronized to 'dzn_civen_core' GameLogics."] call BIS_fnc_error;
	};	
	
	{
		_x call dzn_fnc_civen_initLocation;		
		sleep dzn_civen_LocationInitTimeout;
	} forEach (synchronizedObjects dzn_civen_core);
	
	/*
		Start Traffic
	*/
	if (dzn_civen_allowTraffic) then {
		[] execFSM "dzn_civen\FSM\dzn_civen_trafficControl.fsm";
	};
	
	dzn_civen_initialized = true;
	publicVariable "dzn_civen_initialized";
};

dzn_fnc_civen_activateAllLocations = {
	{
		_x call dzn_fnc_civen_activateLocation;		
		sleep dzn_civen_LocationActivateTimeout;
		if (DEBUG) then { player sideChat format ["CIVEN: Activate %1", _x]; };
	} forEach (synchronizedObjects dzn_civen_core);
};
