initBanMarkersTriggers = { 
{ 
if ((getMarkerColor _x) != "" && {(_x find "ban_marker_") >= 0}) then 
{ 
_x setMarkerAlpha 0;
if (worldName == "Altis") then {
	banArr pushBackUnique _x;
};
}; 
} forEach allMapMarkers;
};
call initBanMarkersTriggers; 

