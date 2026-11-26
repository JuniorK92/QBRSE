lastPointRunner = {
	if (roundCounter > 4) exitWith {};
	_hum = _this select 0;
	_rad = _this select 1;
	_combatModeR = floor random(count behaviourModeArray);
	_combatModeR = combatModeArray select _combatModeR;
	
	_behaviourR = floor random(count combatModeArray);
	_behaviourR =  behaviourModeArray select _behaviourR;
	
	_speedModeR = floor random (count speedModeArray);
	_speedModeR = speedModeArray select _speedModeR;
	if(roundCounter > 4) then {
	_rad        = 0;          
	_behaviourR = "AWARE";    
	_combatModeR = "RED";   
	_speedModeR = "NORMAL";  
	};
	_grp = group _hum;
	_grp setBehaviour _behaviourR;     
	_wp = _grp addWaypoint [LastPosition, _rad];       
	_wp setWaypointType "MOVE";
	_grp setSpeedMode _speedModeR;
	_wp setWaypointCombatMode _combatModeR;
};

