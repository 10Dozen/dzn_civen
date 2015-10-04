# dzn_civen
#### Dependencies
- dzn_commonFunctions
- dzn_gear

### How To
1. Place "GameLogic"-"Object"-"Game Logic" and name it - <tt>dzn_civen_core</tt> 
2. Place "GameLogic"-"Locations"-"..." object (e.g. "Town") and copy classname of the object (e.g. "LocationCity_F")
3. Turn 'Azimuth' circle to set population of the area (or enter number)
4. Synchronize GameLogic-Location to <tt>dzn_civen_core</tt>
5. Place one or several triggers with default settings at your town area.
6. Synchonize triggers with GameLogic-Location
7. Open <tt>dzn_civen\dzn_civen_init.sqf</tt> file and set-up dzn_civen:
- <tt>dzn_civen_locationSettings</tt> - array of settings for GameLogic-Location classname
- <tt>dzn_civen_civilianTypes</tt> - array of civilian template
- <tt>dzn_civen_vehicleTypes</tt> - array of civilian vehicles template
- <tt>Other settings</tt> - overall settings for behavior of civilians and parked civilian vehicles
- 
