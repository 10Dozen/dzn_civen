dzn_fnc_civen_civCon_waitToGetUnits = {
	dzn_civen_civCon_canGetUnits = false;
	sleep 60;
	dzn_civen_civCon_canGetUnits = true;
};

dzn_fnc_civen_addUnitsControls = {
	waitUntil {!isNil "dzn_civen_initialized"};
	dzn_civen_civCon_canGetUnits = true;	
	
	waitUntil { time > 30 };	
	["dzn_civen_civCon_getAllUnits", "onEachFrame", {
		if !(dzn_civen_civCon_canGetUnits) exitWith {};
		
		[missionNamespace, "dzn_civen_allUnits"] call BIS_fnc_getServerVariable;		
	
		{
			if (isNil {_x getVariable "dzn_civen_civCon_actionStop"}) then {
				_x setVariable [
					"dzn_civen_civCon_actionStop"
					, _x addAction [
						"<t color='#cc0000'>- Stop!</t>"
						, {
							systemChat "- Stop! Don't move!";
							
							dzn_civen_civCon_unitToStop = _x;
							publicVariableServer "dzn_civen_civCon_unitToStop";
						}		
					]
				];
			};		
		} forEach dzn_civen_allUnits;
		
		call dzn_fnc_civen_civCon_waitToGetUnits;
	}] call BIS_fnc_addStackedEventHandler;	
};
