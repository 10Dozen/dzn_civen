dzn_fnc_civen_civCon_waitForUpdateUnits = {
	dzn_civen_civCon_canUpdateUnits = false;
	sleep 30;
	dzn_civen_civCon_canUpdateUnits = true;
};

dzn_fnc_civen_civCon_waitForDoStopAction = {
	dzn_civen_civCon_canDoStopAction = false;
	sleep 5;
	dzn_civen_civCon_canDoStopAction = true;
};


dzn_fnc_civen_civCon_addUnitsControls = {
	waitUntil {!isNil "dzn_civen_initialized"};
	dzn_civen_civCon_canUpdateUnits = true;
	dzn_civen_civCon_canDoStopAction = true;

	waitUntil { time > 30 };
	
	["dzn_civen_clientActionHandler", "onEachFrame", {
		if !(dzn_civen_civCon_canUpdateUnits) exitWith {};
		[] spawn dzn_fnc_civen_civCon_waitForUpdateUnits;

		_allCivilUnits = [
			allUnits
			, { side _x == civilian && alive _x && isNil {_x getVariable "dzn_civen_civCon_actionStop"} }
		] call BIS_fnc_conditionalSelect;

	        {
			_x setVariable [
				"dzn_civen_civCon_actionStop"
				, _x addAction [
					"<t color='#cc0000'>- Stop!</t>"
					, {
						if !(dzn_civen_civCon_canDoStopAction) exitWith {};
						[] spawn dzn_fnc_civen_civCon_waitForDoStopAction;
		
		                        	systemChat "- Stop! Don't move!";
						if (isMultiplayer) then {
							 dzn_civen_civCon_unitToStop = _this select 0;
							publicVariableServer "dzn_civen_civCon_unitToStop"
						} else {
							(_this select 0) call dzn_fnc_civen_civCon_stopUnit;
						};
					}
		                ]
			];
		} forEach _allCivilUnits;
	}] call BIS_fnc_addStackedEventHandler;
};
