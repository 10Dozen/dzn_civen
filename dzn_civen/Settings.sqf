/*
 *	Town Civils
 */
// Seconds too return from DANGER to SAFE behavior
dzn_civen_cooldownTimer			= 	30;

// Parked vehicles global settings (values will be randomized from 0 to given max value, if ther is no vehoicleType specific)
dzn_civen_parked_gFuelMax 		= 	0.7;
dzn_civen_parked_gLockedChance		=	0.5;
dzn_civen_parked_gDamage		=	0.3;	// 0 - no damage

// To override vehcile type settings - set this ones to TRUE
dzn_civen_parked_gFuelMaxForced		=	false;
dzn_civen_parked_gLockedChanceForced	=	false;
dzn_civen_parked_gDamageForced		=	false;


/*
 * 	Traffic
 */
dzn_civen_allowTraffic			=	true;
dzn_civen_trafficPerLocation		=	3;
dzn_civen_trafficVehicleType		=	["GreeceVehicles"];	// Array of vehicle types (will be randomly chosed)
