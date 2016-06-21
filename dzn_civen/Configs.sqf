//  **************** SETTINGS - MAPPINGS ********************
// [ @Location (typeOf object or roleDescription), [ @CivilianType, @VehicleType, @VehiclesPerPopulation ] ]
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

// [ @CivilianTypename, [ @Classnames, @dzn_gear Kits, @Custom code to execute ] ]
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

// [ @VehicleType, [ @Classnames, @dzn_gear Cargo kit, @Custom code to execute, @Fuel-Locked-Damage random] ]
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
