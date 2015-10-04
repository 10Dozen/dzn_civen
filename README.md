# dzn_civen
### Dependencies
- dzn_commonFunctions
- dzn_gear
<hr>

### How To
1. Place "GameLogic"-"Object"-"Game Logic" and name it - <tt>dzn_civen_core</tt> 
2. Place "GameLogic"-"Locations"-"..." object (e.g. "Town") and copy classname of the object (e.g. "LocationCity_F")
3. Turn 'Azimuth' circle to set population of the area (or enter number)
4. Synchronize GameLogic-Location to <tt>dzn_civen_core</tt>
5. Place one or several triggers with default settings at your town area.
6. Synchonize triggers with GameLogic-Location
7. Open <tt>dzn_civen\dzn_civen_init.sqf</tt> file and set-up dzn_civen:
<br> - <tt>dzn_civen_locationSettings</tt> - array of settings for GameLogic-Location classname
<br> - <tt>dzn_civen_civilianTypes</tt> - array of civilian template
<br> - <tt>dzn_civen_vehicleTypes</tt> - array of civilian vehicles template
<br> - <tt>Other settings</tt> - overall settings for behavior of civilians and parked civilian vehicles

## Overview

### How it works
For each synchronized with <tt>dzn_civen_core</tt> objects - function will be spawned. It will grab setting of area from <tt>dzn_civen_locationSettings</tt> (which is related to <tt>dzn_civen_civilianTypes</tt> and <tt>dzn_civen_vehicleTypes</tt> arrays), convert linked to GameLogic-Location triggers to Locations and start to spawn civilian units and vehicles.
After town population created - traffic will be spawned too.

#### Setting File
See <tt>dzn_civen\dzn_civen_init.sqf</tt>.

#### Population

**Population limit** can be defined via <tt>Azimuth</tt> control from editor menu. If you do not want to spawn any civilian - set value to negative (e.g. *-1*).
Civilians have 2 behaviours: *safe* and *danger*. Behavior is the same for all civilians of one location. If anyone is shooting near civilians, location become *danger* - civilians are falling to the ground or start to running in panic. After time defined as <tt>dzn_civen_cooldownTimer</tt> 


