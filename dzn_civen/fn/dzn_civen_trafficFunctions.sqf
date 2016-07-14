#define	DEBUG		false
#define GetLP(LOC,PROP)						[LOC, PROP] call dzn_fnc_civen_getLocProperty


dzn_fnc_civen_createTrafficElement = {
	if (isNil "dzn_civen_trafficGroup") then { dzn_civen_trafficGroup = createGroup civillian; };
	
	params["_loc"];
	
	private _destination = ( (synchronizedObjects dzn_civen_core) - [_loc] ) call BIS_fnc_selectRandom;
	
	private _road = ( GetLP(_loc, "roads") ) call BIS_fnc_selectRandom;
	private _dir = [
		_road
		, if !(isNil { (roadsConnectedTo _road) select (round(random 1)) }) then { 
			(roadsConnectedTo _road) select (round(random 1))	
		} else {
			(roadsConnectedTo _road) select 0	
		}
	] call BIS_fnc_DirTo;	
	
	
	private _vType = if (random 10 > 5) then {
		GetLP(_loc, "vehicleType")
	} else {
		[selectRandom dzn_civen_trafficVehicleType, 
	};
	private _vClass = 
	
	
	
	
	
	
	
	
	
	
	
	private _vClass = 
		( (GetLP(_loc, "vehicleType")) select 0) call BIS_fnc_selectRandom
	} else {
		dzn_civen_trafficVehicleType
		
		
		call BIS_fnc_selectRandom
	};



	
	private _v = createVehicle [_vClass, (_road modelToWorld [5, 0, 0]),[], 0, "FORM"];
	
	_v setDir (if (isNil {_dir}) then { 0 } else { _dir });
	
	
	
	private _uType = GetLP(_loc, "populationType");	
	private _uClass = (_uType select 0) call BIS_fnc_selectRandom;
	private _uKit = _uType select 1;
	
	private _grpSize = if (round(random 10) > 7) then { round(random 4) } else { 1 };
	
	
};
