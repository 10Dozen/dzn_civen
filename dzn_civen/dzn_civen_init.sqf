if !(isServer || isDedicated) exitWith {};

dzn_civen_initialized = false;

//  **************** SETTINGS ********************

// Should be 100 in total
dzn_civen_behavior_walkStandChance = [	
	20 /* % Go to Random house */	
	, 70 /* % Go to Random point */
	, 20 /* % Stand on current pos */
];

// Seconds too return from DANGER to SAFE behavior
dzn_civen_cooldownTimer			= 	30;

// Parked vehicles global settings (values will be randomized from 0 to given max value, if ther is no vehoicleType specific)
dzn_civen_parked_gFuelMax 		= 	0.7;
dzn_civen_parked_gLockedChance		=	0.5;
dzn_civen_parked_gDamage		=	0.3;	// 0 - no damage

// To overwright vehcile type settings - set this ones to TRUE
dzn_civen_parked_gFuelMaxForced		=	false;
dzn_civen_parked_gLockedChanceForced	=	false;
dzn_civen_parked_gDamageForced		=	false;

// Traffic
dzn_civen_allowTraffic			=	true;
dzn_civen_trafficPerLocation		=	3;
dzn_civen_trafficVehicleType		=	["VehicleType1"];	// Array of vehicle types (will be randomly chosed)



//  **************** SETTINGS - MAPPINGS ********************
// [ @Location (typeOf object or roleDescription), [ @CivilianType, @VehicleType, @VehiclesPerPopulation ] ]
dzn_civen_locationSettings = [
	[ 
		"LocationCity_F",	
		[ 
			/* Civilian Type */	"CivilianType1"
			/* Vehicle Type */	, "VehicleType1"
			/* Vehicles Density */ 	, 0.3
		] 
	]
	, [ 
		"CustomTown1",	
		[ 
			/* Civilian Type */	"CivilianType1"
			/* Vehicle Type */	, "VehicleType1"
			/* Vehicles Density */ 	, 0.2 
		] 
	]

];

// [ @CivilianTypename, [ @Classnames, @dzn_gear Kits, @Custom code to execute ] ]
dzn_civen_civilianTypes = [
	[
		"CivilianType1"
		, [
			/* ClassNames */ 		["C_man_1", "C_man_polo_1_F_afro"]
			/* Kits */			, []
			/* Code to execute */ 		, { }
		]
	]

];

// [ @VehicleType, [ @Classnames, @dzn_gear Cargo kit, @Custom code to execute, @Fuel-Locked-Damage random] ]
dzn_civen_vehicleTypes = [
	[
		"VehicleType1"
		, [
			["C_Offroad_01_F", "C_Hatchback_01_F","C_SUV_01_F"]	/* ClassNames */ 
			, []				/* Kits */
			, { }				/* Code to execute */
			, [.7,.1,.1]			/* Fuel,Locked Chance,Damage, nil - if used global */
		]
	]
];


//  **************** INITIALIZATION ********************
call compile preProcessFileLineNumbers "dzn_civen\fn\dzn_civen_functions.sqf";
call compile preProcessFileLineNumbers "dzn_civen\fn\dzn_civen_behaviorFunctions.sqf";
call compile preProcessFileLineNumbers "dzn_civen\fn\dzn_civen_trafficFunctions.sqf";

// ***************** START ****************************

[] spawn {
	waitUntil { time > 5 };
	[] call dzn_fnc_civen_initialize;
};