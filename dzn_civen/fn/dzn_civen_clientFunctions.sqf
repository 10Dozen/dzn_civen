dzn_fnc_civen_addUnitsControls = {
	waitUntil {!isNil "dzn_civen_initialized"};
	
	waitUntil { time > 30 };
	private _allCivenUnits = [];	
	
	for "_i" from 1 to 3 do {
		[missionNamespace, "dzn_civen_allUnits"] call BIS_fnc_getServerVariable;
		
		private _unitsWithoutAction = dzn_civen_allUnits - _allCivenUnits;		
		_allCivenUnits = _unitsWithoutAction;
		
		{
			_x addAction [
				"<t color='#cc0000'>- Stop!</t>"
				, {
					systemChat "- Stop! Don't move!";
					(_this select 0) setVariable ["dzn_civen_inDanger", true, true];
				}		
			];	
		} forEach _unitsWithoutAction;		

		sleep 60;
	};
	
	dzn_civen_allUnits = nil;
};
