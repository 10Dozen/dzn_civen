//  **************** SETTINGS - MAPPINGS ********************

/*
 *	Locations
 *
 *	[ @Location (typeOf object or roleDescription), [ @CivilianType, @VehicleType, @VehicleAmount ] ]
 *	@Location 	- (string) classname or role description of the game logic
 *	@CivilianType	- (string) name of the dzn_civen_civilianTypes item
 *	@VehicleType	- (string) name of the dzn_civen_vehicleTypes item
 *	@VehicleAmount	- (number) amount of parked vehicles per 1 location's civilian (e.g. 0.3 means that there will be 1 car per each 3 civilians)
 *				or (array) in format [min, max] of vehicles per 1 location (e.g. [1,5] means that there will be spawned random from 1 to 5 cars, no matter how many civilians in location)
 */
 
dzn_civen_locationSettings = [
	[ 
		"LocationCity_F",	
		[ 
			/* Civilian Type */	"GreeceCivil"
			/* Vehicle Type */	, "GreeceVehicles"
			/* Vehicles Density */ 	, 0.3
		] 
	]
	,[ 
		"LocationVillage_F",	
		[ 
			/* Civilian Type */	"GreeceCivil"
			/* Vehicle Type */	, "GreeceVehicles"
			/* Vehicles Density */ 	, 0
		] 
	]
];



/*
 *	Civilians
 *
 *	[ @CivilianTypename, [ @Classnames, @dzn_gear Kits, @Custom code to execute ] ]
 *	@CivilianTypename	- (string) name of the type
 *	@Classnames		- (array) list of the classnames for civilians units
 *	@dzn_gear Kits		- (array) list of the dzn_gear kits that will be applied randomly to spawned units
 *	@Custom code to execute	- (code) code that whill be executed once civilian unit was spawned (use _this as refernece to unit itself)
 */
dzn_civen_civilianTypes = [
	[
		"GreeceCivil"
		, [
			/* ClassNames */ 		["C_man_hunter_1_F"]
			/* Kits */			, ["kit_civ_greece"]
			/* Code to execute */ 		, { }
		]
	]

];

/*
 *	Vehicles
 *
 *	[ @VehicleType, [ @Classnames, @dzn_gear Cargo kit, @Custom code to execute, @Fuel-Locked-Damage random] ]
 *	@VehicleType		- (string) name of the type
 *	@Classnames		- (array) list of the classnames for vehicles
 *	@dzn_gear Cargo Kits	- (array) list of the dzn_gear cargo kits that will be applied randomly to spawned vehicles
 *	@Custom code to execute	- (code) code that whill be executed once vehicle was spawned (use _this as refernece to vehicle itself)
 *	@Fuel-Locked-Damage random	- (nil) or (array) in format [Max.fuel, Max.locked chance, Max.damage]. 
 *						Random fuel, locked chance and damage will be applied to vehicle on spawn. 
 *						If nil - global settings will be used.
 *				
 */
dzn_civen_vehicleTypes = [
	[
		"GreeceVehicles"
		, [
			[
				"CUP_C_Golf4_black_Civ"
				,"CUP_C_Golf4_camodark_Civ"
				,"CUP_C_Golf4_kitty_Civ"
				,"CUP_C_Golf4_crowe_Civ"
				,"CUP_C_Golf4_red_Civ"
				,"CUP_C_Golf4_white_Civ"
				,"CUP_C_Golf4_yellow_Civ"
				
				,"C_Hatchback_01_F"
				,"C_Offroad_01_F"				
				,"C_SUV_01_F"
				,"CUP_C_Octavia_CIV"
				,"CUP_C_SUV_CIV"
				,"C_Hatchback_01_F"
				,"C_Offroad_01_F"				
				,"C_SUV_01_F"
				,"CUP_C_Octavia_CIV"
				,"CUP_C_SUV_CIV"
				
				,"C_Van_01_box_F"
				,"C_Van_01_transport_F"
				,"C_Van_01_box_F"
				,"C_Van_01_transport_F"
				
				,"C_Truck_02_transport_F"
				,"C_Truck_02_covered_F"
				,"C_Offroad_01_repair_F"
				
			]	/* ClassNames */ 
			, []				/* Kits */
			, { }				/* Code to execute */
			, [.7,.5,.2]			/* Fuel,Locked Chance,Damage, nil - if used global */
		]
	]
];
