
dzn_fnc_civen_initZones = {

	_cities = entities "LocationCityCapital_F";
	_towns = entities "LocationCity_F";
	_villages = entities "LocationVillage_F";
	
	{		
		_dist = 0;
		_maxPopulation = 0;		
		
		switch (typeOf _x) do {
			case "LocationCityCapital_F": {
				_dist = dzn_civen_citySize;
				_maxPopulation = dzn_civen_cityPopulation;
			};
			case "LocationCity_F": {			
				_dist = dzn_civen_townSize;
				_maxPopulation = dzn_civen_townPopulation;
			};
			case "LocationVillage_F": {
				_dist = dzn_civen_villageSize;
				_maxPopulation = dzn_civen_villagePopulation;			
			};
		};
		
		_pos = getPosASL _x;		
		_structures =  nearestObjects [_pos, ["House"], _dist];
		_buildings = [];
		
		{
			if !((_x buildingPos 0) isEqualTo []) then {
				_buildings = _buildings + [_x];
			};
		} forEach _structures;
		
		if (count _buildings <_maxPopulation) then {
			_maxPopulation = round( _maxPopulation * ((count _buildings) / _maxPopulation));
		};
		
		_x setVariable ["maxPopulation", _maxPopulation];
		_x setVariable ["buildings", _buildings];
		_x setVariable ["position", _pos];
		
		player globalChat format ["| Location (%1) - max popul: %2", str(_x), _maxPopulation];
	
	} forEach _cities + _towns + _villages;

};

dzn_spawn = {
	// loc
	_pos = getPosASL loc;
	_center = createCenter CIVILIAN;
	
	_houses = loc getVariable "buildings";
	_maxPopulation = loc getVariable "maxPopulation";
	
	for "_i" from 0 to _maxPopulation do {
		_home = _houses call BIS_fnc_selectRandom;
		_grp = createGroup CIVILIAN;
		_unit = _grp createUnit ["C_man_shorts_2_F", _home buildingPos round(random 1), [], 0, "NONE"];
		_unit setVariable ["home", _home];
	};	

};
