#define	DEBUG		false
#define GetLP(LOC,PROP)						[LOC, PROP] call dzn_fnc_civen_getLocProperty

dzn_fnc_civen_checkNearPlayers = {
	// @Boolean = @Loc call dzn_fnc_civen_checkNearPlayers;		
	private _areaPos = (GetLP(_this, "areapos")) select 0; // <<Pos3d>>, xMin, yMin, xMax, yMax
	if (DEBUG) then { player sideChat format ["dest: %1",  str(_this)]; };	
	
	[_areaPos, 600] call dzn_fnc_isPlayerNear
};

dzn_fnc_civen_getTrafficNeededLocations = {
	// call dzn_fnc_civen_getTrafficNeededLocations
	// RETURN: Array of locaions where to spawn
	private["_curTraffic","_trafficLocationList","_i"];
	
	_trafficLocationList = [];
	
	{
		_curTraffic = GetLP(_x, "currentTraffic");
		if (
			count (_curTraffic) < dzn_civen_trafficPerLocation 
			&& { !(_x call dzn_fnc_civen_checkNearPlayers) }
		) then {
			for "_i" from 1 to (dzn_civen_trafficPerLocation - count (_curTraffic) ) do {
				_trafficLocationList pushBack _x;
			};		
		};	
	} forEach (synchronizedObjects dzn_civen_core);
	
	_trafficLocationList
};

dzn_fnc_civen_getTrafficEndedElements = {
	// call dzn_fnc_civen_getTrafficEndedElements
	// RETURN: Array of groups to delete
	
	private[
		"_listOfTraffic"
		,"_v"
		,"_dest"
		,"_trafficGrp"
	];
	
	_listOfTraffic = [];
	
	{
		{
			_v = _x;;
			_dest = _v getVariable "dzn_civen_destination";
			
			if (
				[getPosASL _v, GetLP(_dest, "area")] call dzn_fnc_isInLocation 
				&& { !(_dest call dzn_fnc_civen_checkNearPlayers) }
			) then {
				_listOfTraffic pushBack _v;
			};			
		
		} forEach ( GetLP(_x, "currenttraffic") );
	} forEach (synchronizedObjects dzn_civen_core);
	
	_listOfTraffic
};



/*
	Traffic Element handling
*/

dzn_fnc_civen_createTrafficElement = {
	if (isNil "dzn_civen_trafficGroup") then { dzn_civen_trafficGroup = createGroup civillian; };
	
	params["_loc"];
	
	private _destination = selectRandom ( (synchronizedObjects dzn_civen_core) - [_loc] );	
	
	/*
		Vehicle
	*/
	private _road = selectRandom ( GetLP(_loc, "roads") );
	private _dir = [
		_road
		, if !(isNil { (roadsConnectedTo _road) select (round(random 1)) }) then { 
			(roadsConnectedTo _road) select (round(random 1))	
		} else {
			(roadsConnectedTo _road) select 0	
		}
	] call BIS_fnc_DirTo;	
	_dir = (if (isNil {_dir}) then { 0 } else { _dir });	
	
	private _vConfig = if (random 10 > 5) then {
		GetLP(_loc, "vehicleType")
	} else {
		( [dzn_civen_vehicleTypes, selectRandom dzn_civen_trafficVehicleType] call dzn_fnc_getValueByKey )		
	};
	
	private _v = [
		[(_road modelToWorld [5, 0, 0]), _dir]
		, selectRandom (_vConfig select 0)
	] call dzn_fnc_createVehicle;
	
	// Assign Cargo Gear
	if !((_vehicleConfig select 1) isEqualTo []) then {
		[_v, selectRandom (_vehicleConfig select 1), true] call dzn_fnc_gear_assignKit;
	};
	private _vSettings = (_vehicleConfig select 3);
	[_v, [_vSettings select 0, 0, _vSettings select 0]] spawn dzn_fnc_civen_randomizeParkedVehicle;		
	
	/*
		Vehicle crew
	*/
	private _uType = GetLP(_loc, "populationType");	
	private _grpSize = if (round(random 10) > 7) then { round(random 4) } else { 1 };
	private _crew = [];			
	for "_i" from 1 to _grpSize do {
		private _u = dzn_civen_trafficGroup createUnit [selectRandom (_uType select 0), [0,0,0], [], 0, "NONE"];
		_u allowDamage false;
		
		_u setSkill 0;
		_u disableAI "TARGET";
		_u disableAI "AUTOTARGET";		
		_u setBehaviour "CARELESS";
		_u setSpeedMode "LIMITED";
		_u setCombatMode "GREEN";
		
		if !((_uType select 1) isEqualTo []) then {
			[_u, selecRandom (_uType select 1)] call dzn_fnc_gear_assignKit;
		};
		
		[
			_u
			, _v
			, if (_i == 1) then { "driver" } else { "cargo" }
		] call dzn_fnc_assignInVehicle;
		
		_u allowDamage true;
		
		_crew pushBack _u;
	};
	
	{
		_v setVariable [_x select 0, _x select 1];
	} forEach [
		["dzn_civen_ownerLoc"			, _loc]
		,["dzn_civen_destination"		, _destination]
		,["dzn_civen_assignedCrew"		, _crew]		
	];
	
	_loc setVariable [
		"dzn_civen_currentTraffic"
		, (_loc getVariable "dzn_civen_currentTraffic") + [_v]
	];
	
	
	/*
		Move traffic element	
	*/
	private _areaPos =  [_destination, "areapos"] call dzn_fnc_civen_getLocProperty;	
	
	sleep round(20 + random 60 + (random 10)*20); 
	// setDestination ??
	(driver _v) doMove (_areaPos select 0);
	
	sleep 60;
	[_v] spawn dzn_fnc_civen_handleTrafficElementDestination;
};

dzn_fnc_civen_handleTrafficElementDestination = {
	params["_v"];

	private _initLoc = [ _v getVariable "dzn_civen_ownerLoc" , "area"] call dzn_fnc_civen_getLocProperty;
		
	if (DEBUG) then { 
		player sideChat format ["Vehicle %1 -- initLoc is %2", _v, _initLoc];
		debuglog format ["Vehicle %1 -- initLoc is %2", _v, _initLoc];
	};
		
	waitUntil {
		sleep 60; 
		!canMove _v 
		|| !(
			[getPosATL _v, _initLoc] call dzn_fnc_isInLocation				
			&& speed _v < 10
		)
	};		
	
	waitUntil { sleep 30; !([_v, 1000] call dzn_fnc_isPlayerNear) };
	_v call dzn_fnc_civen_deleteTrafficElement;		
};

dzn_fnc_civen_deleteTrafficElement = {
	// @Group call dzn_fnc_civen_deleteTrafficElement
	params ["_v"];
	
	private _crew = _v getVariable "dzn_civen_assignedCrew";	
	{_v deleteVehicleCrew _x} forEach (crew _v);	
	if !(_crew isEqualTo []) then {
		{ deleteVehicle _x; } forEach _crew;
	};
	
	_v call dzn_fnc_civen_excludeTrafficElement;
	deleteVehicle _v;	
};

dzn_fnc_civen_excludeTrafficElement = {
	// @Vehicle call dzn_fnc_civen_excludeTrafficElement	
	private _loc = _this getVariable "dzn_civen_ownerLoc";	
	_loc setVariable [
		"dzn_civen_currentTraffic"
		, (_loc getVariable "dzn_civen_currentTraffic") - [_this]
	];
};





