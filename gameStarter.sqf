[] spawn {  
sleep 0.5;
[] execVM "weatherList.sqf";
_ok = createDialog "MissionConfigurator";  waitUntil {!dialog}; 
execVM "AISpawn.sqf";  
};