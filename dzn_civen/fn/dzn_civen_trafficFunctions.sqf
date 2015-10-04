#define	DEBUG		false

dzn_fnc_civen_checkNearPlayers = {
	// @Boolean = @Loc call dzn_fnc_civen_checkNearPlayers;
	private["_areaPos"];
	
	_areaPos =  ([_this, "areapos"] call dzn_fnc_civen_getLocProperty) select 0; // <<Pos3d>>, xMin, yMin, xMax, yMax
	if (DEBUG) then { player sideChat format ["dest: %1",  str(_this)]; };	
	
	[_areaPos, 600] call dzn_fnc_isPlayerNear
};

dzn_fnc_civen_getTrafficNeededLocations = {
	// call dzn_fnc_civen_getTrafficNeededLocations
	// RETURN: Array of locaions where to spawn
	private["_curTraffic","_trafficLocationList","_i"];
	
	_trafficLocationList = [];
	
	{
		_curTraffic = [_x, "currentTraffic"] call dzn_fnc_civen_getLocProperty;
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
		,"_destLoc"
		,"_trafficGrp"
	];
	
	_listOfTraffic = [];
	
	{
		{
			_trafficGrp = _x;
			_v = _trafficGrp getVariable "dzn_civen_assignedVehicle";
			_dest = _trafficGrp getVariable "dzn_civen_destination";
			_destLoc = [ _dest, "area"] call dzn_fnc_civen_getLocProperty;
			
			if (
				[getPosASL _v, _destLoc] call dzn_fnc_isInLocation 
				&& { !(_dest call dzn_fnc_civen_checkNearPlayers) }
			) then {
				_listOfTraffic pushBack _trafficGrp;
			};			
		
		} forEach ([_x, "currenttraffic"] call dzn_fnc_civen_getLocProperty);
	} forEach (synchronizedObjects dzn_civen_core);
	
	_listOfTraffic
};

dzn_fnc_civen_createTrafficElement = {
	// @Loc spawn dzn_fnc_civen_createTrafficElement
	private[
		"_loc"
		,"_destination"
		,"_road"
		,"_uType"
		,"_vType"
		,"_vClass"
		,"_v"
		,"_uClass"
		,"_trafficGrp"
		,"_grpSize"
		,"_i"
		,"_u"
		,"_uRole"
		,"_areaPos"
		,"_dir"
	];
	
	_loc = _this;
	
	_destination = ( (synchronizedObjects dzn_civen_core) - [_loc] ) call BIS_fnc_selectRandom;
	
	//_vClass = (([dzn_civen_vehicleTypes, dzn_civen_vehicleTypes] call dzn_fnc_getValueByKey) select 0) call BIS_fnc_selectRandom;
	_road = ([_loc, "roads"] call dzn_fnc_civen_getLocProperty) call BIS_fnc_selectRandom;
	_uType = [_loc, "populationType"] call dzn_fnc_civen_getLocProperty;
	_vType = [_loc, "vehicleType"] call dzn_fnc_civen_getLocProperty;
	
	_vClass = (_vType select 0) call BIS_fnc_selectRandom;
	
	_uClass = (_uType select 0) call BIS_fnc_selectRandom;
	_trafficGrp = createGroup civilian;	
	
	_grpSize = if (round(random 10) > 7) then { round(random 4) } else { 1 };
	_v = createVehicle [_vClass, (_road modelToWorld [5, 0, 0]),[], 0, "FORM"];
	_dir = [
		_road
		, if !(isNil { (roadsConnectedTo _road) select (round(random 1)) }) then { 
			(roadsConnectedTo _road) select (round(random 1))	
		} else {
			(roadsConnectedTo _road) select 0	
		}
	] call BIS_fnc_DirTo;	
	_v setDir (if (isNil {_dir}) then { 0 } else { _dir });
	
	_trafficGrp setVariable ["dzn_civen_ownerLoc", _loc];
	_trafficGrp setVariable ["dzn_civen_destination", _destination];
	_trafficGrp setVariable ["dzn_civen_assignedVehicle", _v];
	
	_loc setVariable [
		"dzn_civen_currentTraffic"
		, (_loc getVariable "dzn_civen_currentTraffic") + [_trafficGrp]
	];
	
	for "_i" from 1 to _grpSize do {
		_u = _trafficGrp createUnit [_uClass, [0,0,0], [], 0, "NONE"];
		_u allowDamage false;
		
		_u setSkill 0;
		_u disableAI "TARGET";
		_u disableAI "AUTOTARGET";
		
		_u setBehaviour "CARELESS";
		_u setSpeedMode "LIMITED";
		_u setCombatMode "GREEN";			
	
		_uRole = if (_i == 1) then { "driver" } else { "cargo" };		
		[_u, _v, _uRole] call dzn_fnc_assignInVehicle;
		_u allowDamage true;
	};
	
	_areaPos =  [_destination, "areapos"] call dzn_fnc_civen_getLocProperty;	
	
	sleep round(20 + random 60 + (random 10)*20); 
	_trafficGrp addWaypoint [_areaPos select 0, 100];
	
	sleep 60;
	[_v,_trafficGrp] spawn {
		private["_v","_trafficGrp","_initArea","_initLoc"];
		_v = _this select 0;
		_trafficGrp = _this select 1;
		_initArea = _trafficGrp getVariable "dzn_civen_ownerLoc";
		_initLoc = [ _initArea, "area"] call dzn_fnc_civen_getLocProperty;
		
		waitUntil {
			!canMove _v 
			|| (
				[getPosASL _v, _initLoc] call dzn_fnc_isInLocation				
				&& speed _v < 15
			)
		};
		
		waitUntil { !([_v, 1200] call dzn_fnc_isPlayerNear) };
		_trafficGrp call dzn_fnc_civen_deleteTrafficElement;		
	};
};

dzn_fnc_civen_excludeTrafficElement = {
	// @Group call dzn_fnc_civen_excludeTrafficElement
	private["_loc"];	
	
	_loc = _this getVariable "dzn_civen_ownerLoc";	
	_loc setVariable [
		"dzn_civen_currentTraffic"
		, (_loc getVariable "dzn_civen_currentTraffic") - [_this]
	];
};

dzn_fnc_civen_deleteTrafficElement = {
	// @Group call dzn_fnc_civen_deleteTrafficElement
	private[
		"_trafficGrp"		
		,"_v"
	];
	_trafficGrp = _this;
	
	_trafficGrp call dzn_fnc_civen_excludeTrafficElement;	
	_v = _trafficGrp getVariable "dzn_civen_assignedVehicle";	
	{_v deleteVehicleCrew _x} forEach crew _v;
	deleteVehicle _v;
	
	if !((units _trafficGrp) isEqualTo []) then {
		{ deleteVehicle _x; } forEach (units _trafficGrp);
	};
};
