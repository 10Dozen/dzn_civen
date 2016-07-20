# dzn_civen
##### Version: 0.3

### Dependencies
- dzn_commonFunctions v.0.65 (https://github.com/10Dozen/dzn_commonFunctions)
- dzn_gear v.2.2 (https://github.com/10Dozen/dzn_gear)
<hr>

### How To
1. Place "GameLogic"-"Object"-"Game Logic" and name it - <tt>dzn_civen_core</tt> 
2. Place "GameLogic"-"Locations"-"..." object (e.g. "Town") and copy classname of the object (e.g. "LocationCity_F")
3. Synchronize GameLogic-Location to <tt>dzn_civen_core</tt>
4. Place one or several triggers with default settings at your town area.
5. Synchonize triggers with GameLogic-Location
6. Open <tt>dzn_civen\Settings.sqf</tt> file and set-up dzn_civen:
7. Open <tt>dzn_civen\Configs.sqf</tt> file to set-up location, civilians and vehicle configuration:
<br> - <tt>dzn_civen_locationSettings</tt> - array of settings for GameLogic-Location classname
<br> - <tt>dzn_civen_civilianTypes</tt> - array of civilian template
<br> - <tt>dzn_civen_vehicleTypes</tt> - array of civilian vehicles template

## Overview

### How it works
For each synchronized with <tt>dzn_civen_core</tt> objects - function will be spawned. It will grab setting of area from <tt>dzn_civen_locationSettings</tt> (which is related to <tt>dzn_civen_civilianTypes</tt> and <tt>dzn_civen_vehicleTypes</tt> arrays), convert linked to GameLogic-Location triggers to Locations and start to spawn civilian units and vehicles.
After town population created - traffic will be spawned too.

#### Setting File
See <tt>dzn_civen\Settings.sqf</tt> and <tt>dzn_civen\Configs.sqf</tt>.

#### Location Config
Locations where population should be spawned is fully user-defined. You can simply place any object from GameLogic-Locations or place any GameLogic object and set any custom name to <tt>Description</tt>.
Location *should be* synchronized with triggers(1...n) and <tt>dzn_civen_core</tt> object.
<br>**Location Settings** are defined in <tt>**dzn_civen_locationSettings**</tt> array. Format of the array is next:
<br> <tt>[ "LocationCity_F",	[ "CivilianType1", [1,6] "VehicleType1", [5,6]	] ]</tt>
<br>where:
<br><tt>"LocationCity_F"</tt> - classname of the editor-placed GameLogic-Location, or custom name from <tt>Description</tt> field
<br><tt>"CivilianType1"</tt> - name of the civilian template (see <tt>dzn_civen_civilianTypes</tt>)
<br><tt>[1,6]</tt> - min and max number of civilians per location (random will be chosen).
<br><tt>"VehicleType1"</tt> - name of the vehicles template (see <tt>dzn_civen_vehicleTypes</tt>)
<br><tt>0.3</tt> or <tt>[5,6]</tt> - quantity of parked vehicles per civilian - 0.3 means that there will be 3 parked vehicles per 10 spawned civilians OR min and max number of parked vehicles per locations.

##### Location Config: Config line
You can add variable to Location object to customize location config for certain location:
    
    this setVariable ["dzn_civen_configLine", 'civAmount=[1,5]; vehAmount=[1,5]; civType="greececivil"; vehType="GreeceVehicles";']


#### Population Config
Civilians have 2 behaviours: *safe* and *danger*. Behavior is the same for all civilians of one location. If anyone is shooting near civilians, location become *danger* - civilians are falls to the ground or start to run in panic. After time, defined as <tt>dzn_civen_cooldownTimer</tt>, is passed - location become *safe*. In *safe* state civilians can walk from street to street, enter buildings or simply stant and watch around.
<br>**Population Settings** are defined in <tt>**dzn_civen_civilianTypes**</tt> array. Format of the array is next:
<br> <tt>[ "CivilianType1", [	["C_man_1", "C_man_polo_1_F_afro"], ["kit_civRandom"], { }	]</tt>
<br>where:
<br><tt>"CivilianType1"</tt> - name of the civilian template
<br><tt>["C_man_1", "C_man_polo_1_F_afro"]</tt> - array of classnames used to spawn population (will be picked randomly for each unit)
<br><tt>["kit_civRandom"]</tt> - array of custom dzn_gear kits to assign to spawned population (will be picked randomly for each unit)
<br><tt>{ }</tt> - code which will be called for each created unit, *_this* will reffer to unit

#### Parked Vehicles
**Quantity** of parked vehicles is defined in <tt>dzn_civen_locationSettings</tt> (density of parked vehicles). If no vehicles should be spawned - set density to 0.
<br>Parked vehicles will be spawned at road sides. **Fuel**, **Damage** and **Locked chance** of the vehicle can be defined in <tt>dzn_civen_vehicleTypes</tt> settings or overwriten by <tt>dzn_civen_parked_gFuelMax</tt>, <tt>dzn_civen_parked_gLockedChance</tt>, <tt>dzn_civen_parked_gDamage</tt> settings. Given value is top value for random (e.g. Fuel = 0.5 means that vehicle's fuel can be from 0 to 0.5).
<br>**Vehicle Settings** are defined in <tt>**dzn_civen_vehicleTypes**</tt> array. Format of the array is next:
<br> <tt>[ "VehicleType1", [	["C_Offroad_01_F", "C_Hatchback_01_F","C_SUV_01_F"], ["kit_civVehicle"], { }, [.7,.1,.1] ]</tt>
<br>where:
<br><tt>"VehicleType1"</tt> - name of the vehicle template
<br><tt>["C_Offroad_01_F", "C_Hatchback_01_F","C_SUV_01_F"]</tt> - array of classnames used to spawn vehicles (will be picked randomly for each unit)
<br><tt> ["kit_civVehicle"]</tt> - array of custom dzn_gear cargo kits to assign to spawned vehicle (will be picked randomly for each unit)
<br><tt>{ }</tt> - code which will be called for each created vehicle, *_this* will reffer to vehicle
<br><tt>[.7,.1,.1]</tt> - *fuel*, *locked chance* and *damage* limits (for damage - 0 means no damage, 1 - destroyed)

#### Traffic Config
Traffic will be created for each location - from location to all other locations. After vehicle reaches position of location object and there is no players near - vehicle and crew will be deleted and new traffic vehicle will be spawned instead. If vehicle stucked or cannot move anymore - it will be deleted too.
<br>Next **options** are available:
<br><tt>dzn_civen_allowTraffic</tt> - <tt>true</tt> to enable traffic between location, <tt>false</tt> to disable
<br><tt>dzn_civen_trafficPerLocation</tt> - **quantity** of vehicles from each location (how many vehicles will move from each location to others)
<br><tt>dzn_civen_trafficVehicleType</tt> - array of vehicle template names (for each vehicle will be chosen *random classname* from *random template* from given templates)
