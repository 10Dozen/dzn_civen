/*
	Timers
*/
dzn_civen_InitTime				=	15; // seconds after mission start
dzn_civen_UnitSpawnTimeout		= 	2;
dzn_civen_ParkedSpawnTimeout	=	2;

/*
 *	Town Civils
 */
dzn_civen_allowCivils			= true; 
dzn_civen_behavior_walkStandChance = [	
										20 /* % Go to Random house */	
										, 70 /* % Go to Random point */
										, 20 /* % Stand on current pos */
									];

// Seconds too return from DANGER to SAFE behavior
dzn_civen_enableUnsafeBehaviour	=	true;
dzn_civen_cooldownTimer			= 	30;

/*
 *	Town Parked Vehicles
 */
 
dzn_civen_allowParkedVehicles				= true;
dzn_civen_parked_forceAmountPerLocation		= true;	// Is qunatity of parked vehicles calculated according to population of area?
dzn_civen_parked_forceAmountLimit			= [1,3]; // Min and max amount of parked vehicles per location
 
// Parked vehicles global settings (values will be randomized from 0 to given max value, if ther is no vehoicleType specific)

dzn_civen_parked_gFuelMaxForced			=	false;
dzn_civen_parked_gLockedChanceForced	=	false;
dzn_civen_parked_gDamageForced			=	false;

dzn_civen_parked_gFuelMax 				= 	0.7;
dzn_civen_parked_gLockedChance			=	0.5;
dzn_civen_parked_gDamage				=	0.3;




/*
 * 	Traffic
 */
dzn_civen_allowTraffic				=	true;
dzn_civen_trafficPerLocation		=	3;
dzn_civen_trafficVehicleType		=	["GreeceVehicles"];	// Array of vehicle types (will be randomly chosed)
