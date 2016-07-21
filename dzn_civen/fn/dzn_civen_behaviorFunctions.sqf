dzn_fnc_civen_isLocationSafe = {
	[_this, "safe"] call dzn_fnc_civen_getLocProperty
};


dzn_fnc_civen_switchToSafe = {
	// @Unit call dzn_fnc_civen_switchToSafe
	// Switch unit to safe state
	_this stop false;
	_this call dzn_fnc_civen_playAnimStandUp;
	
	_this setBehaviour "CARELESS";
	_this setSpeedMode "LIMITED";
	_this setCombatMode "GREEN";	
	
	_unit setVariable ["dzn_civen_inDanger", false];
	_this disableConversation false;
};


dzn_fnc_civen_switchToDanger = {
	// @Unit call dzn_fnc_civen_switchToDanger
	// Switch unit to DANGER state
	
	if (round(random 100) > 75) then { 
		_this doMove ((_unit getVariable "dzn_civen_home") buildingPos 0);
		_this spawn {
			waitUntil { _this distance ((_this getVariable "dzn_civen_home") buildingPos 0) < 5 };
			_this spawn dzn_fnc_civen_playAnimKeepLying;
		};
	} else {		
		_this spawn dzn_fnc_civen_playAnimKeepLying;
		
	};
	
	_this disableConversation true;
	
	_this setBehaviour "COMBAT";
	_this setSpeedMode "FULL";
	_this setCombatMode "RED";
};

dzn_fnc_civen_playIdleAnimation = {
	// @True = @Unit call dzn_fnc_civen_playIdleAnimation
	if (dzn_civen_enableIdleAnimation) then {
		[
			_this
			, ["STAND_U1","STAND_U2","STAND_U3"] call BIS_fnc_selectRandom
			, "ASIS"
		] call BIS_fnc_ambientAnim;
	};
	
	dzn_civen_enableIdleAnimation
};

dzn_fnc_civen_playAnimKeepLying = {
	_this stop true;	
	while { behaviour _this != "CARELESS" } do { 
		_this playMove 'AmovPpneMstpSnonWnonDnon_healed'; 
		sleep 3; 
	};
};

dzn_fnc_civen_playAnimStandUp = {
	if (behaviour _this == "COMBAT") then {
		_this switchMove "AfdsPpneMstpSnonWnonDnon_AfdsPercMstpSnonWnonDnon";
	};
};


/*
	Civ Control
*/

dzn_fnc_civen_civCon_handleUnits = {
	dzn_fnc_civen_civCon_waitToHanldeUnitList = {
		dzn_civen_civCon_canHandleUnitList = false;
		sleep 60;
		dzn_civen_civCon_canHandleUnitList = true;
	};
	
	dzn_civen_civCon_canHandleUnitList = true;
	
	["dzn_civen_civCon_handleUnitList", "onEachFrame", {
		if !(dzn_civen_civCon_canHandleUnitList) exitWith {};
		
		dzn_civen_allUnits = [
			dzn_civen_allUnits
			, {
				private _existAlive = !(isNull _x) && {alive _x};
				if (_existAlive) then {					
					
					
					
				} else {
				
				};
				_existAlive
			}
		] call BIS_fnc_conditionalSelect;
		
		dzn_civen_allUnits = [dzn_civen_allUnits, { !(isNull _x) && {alive _x} }] call BIS_fnc_conditionalSelect;
		
		
		
		
		call dzn_fnc_civen_civCon_waitToHanldeUnitList;
	}] call BIS_fnc_addStackedEventHandler;

};

