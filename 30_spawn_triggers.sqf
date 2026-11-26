initSpawnTriggers = { 
_lootBoxOnly = _this select 0;
_wordToSearch = "_spawn";

if(_lootBoxOnly) then {
_wordToSearch = "city_spawn"
};

{ 
if (!isNull _x) then {
	private _triggerName = vehicleVarName _x;
	if ((_triggerName find _wordToSearch) >= 0) then {
		allSpawnTriggers pushBack _x;
	};
}; 
} forEach (allMissionObjects "EmptyDetector")
};

roundTiggerUpdater = {
	
		for [{_i=1}, {_i < roundCounter}, {_i = _i + 1}] do {   
			ConstStrToDelete = "round_tigger_" + (str _i);	
			_obj = missionNamespace getVariable [ConstStrToDelete, objNull];
			TriggersArray deleteAt (TriggersArray find _obj);
			deleteVehicle _obj;
		};	
	
	if (SpawnData > 0) then {
		_obj = missionNamespace getVariable ["gameplay_trig_4", objNull];
		deleteVehicle _obj;
		_obj = missionNamespace getVariable ["gameplay_trig_3", objNull];
		deleteVehicle _obj;
		StartTimeToAdd = 3;
	}
	else {
		StartTimeToAdd = 30;
	};
	
	
	
	round_tigger_2_helper_2 setTriggerTimeout [StartTimeToAdd-1, StartTimeToAdd-1, StartTimeToAdd-1, false];
	
	
	counterArrays = roundCounter;
	{
		_x setTriggerTimeout [StartTimeToAdd,StartTimeToAdd,StartTimeToAdd,false];
		StartTimeToAdd = StartTimeToAdd + (TimeArray select counterArrays); 
		counterArrays = counterArrays + 1;
	}forEach TriggersArray;
};

blueMarkerCreator = {
_markerExpectedSize = (AreasArray select roundCounter);
0 = createMarkerLocal ["EndTrMarker", EndTr];    
"EndTrMarker" setMarkerSize [_markerExpectedSize, _markerExpectedSize];    
"EndTrMarker" setMarkerShape "ELLIPSE";    
"EndTrMarker" setMarkerColorLocal "ColorBlue";    
};

greyMarkterCreator = {
_markerExpectedSize = (AreasArray select (roundCounter - 1));
0 = createMarkerLocal ["EndTrMarker2", position EndTr]; 
"EndTrMarker2" setMarkerSize [_markerExpectedSize, _markerExpectedSize]; 
"EndTrMarker2" setMarkerShape "ELLIPSE"; 
"EndTrMarker2" setMarkerColorLocal "ColorBlack";
};

initialRoundSmokeCreator = {
_markerExpectedSize = (AreasArray select (roundCounter - 1));


};

ChangeWeatherOrTime = {
    
    switch (BRSEWeather) do {
        case 0: {}; 
        case 1: { 99999 setFog (random [0.4,0.5,1]); forceWeatherChange; };
        case 2: { 10 setOvercast 0.9; forceWeatherChange; };
        case 3: { 10 setOvercast 1; 10 setRain 1; forceWeatherChange; };
        case 4: {
            _rainRandom = random 1;
            _rainbowRandom = random 1;
            _fogRandom = random 1;
            _overcastRandom = random 1;
            10 setOverCast _overcastRandom;
            10 setRain _rainRandom;
            if (_overcastRandom > 0.7 && _rainRandom < 0.2) then { 10 setFog _fogRandom };
            10 setRainbow _rainbowRandom;
            forceWeatherChange;
        };
        default { hint "ERROR - WRONG BRSEWeather !" };
    };
    
    switch (BRSETime) do {
        case 0: {};
        case 1: { skipTime 12; };
        case 2: { skipTime 16; };
        case 3: { skipTime 2; };
        case 4: { _rTimeTS = floor random 25; skipTime _rTimeTS; };
        default { hint "ERROR - WRONG BRSETime !" };
    };
    
    
};


updateUI = {
if (EnableCustomHudMode>0) then {
disableSerialization;

_display = uiNamespace getVariable "hudScrDisplay";
_textPlayersAlive = _display displayCtrl 1905;
_textPlayersAlive ctrlSetText format["%1",MyPlayersCount];

_textKillsCounter = _display displayCtrl 1908;
_textKillsCounter ctrlSetText format["%1",KillsCounter];

_textHP = _display displayCtrl 1902;
playerDmg = (damage player)*100;
playerDmg = floor (100 - playerDmg);
_textHP ctrlSetText format["HP: %1/100",playerDmg];	

_textBlack = _display displayCtrl 1900;
_WidthAr = ctrlPosition _textBlack;
_Width = _WidthAr select 2;

_textHPRed = _display displayCtrl 1901;
_textHPRedpos = ctrlPosition _textHPRed;
_textHPRedposX= _textHPRedpos select 0;
_textHPRedposY= _textHPRedpos select 1;
_textHPRedWidth = _textHPRedpos select 2;
_textHPRedHeight = _textHPRedpos select 3;
_textHPRedWidth = (_Width/100) * playerDmg;
_textHPRed ctrlSetPosition [_textHPRedposX,_textHPRedposY,_textHPRedWidth,_textHPRedHeight];
_textHPRed ctrlCommit 0;
};
};

myfuncLS = compile preprocessFileLineNumbers "lootspawn.sqf";
LootSpawnRandomizer = {
_LStrigger = _this select 0;
_ExpRange = (AreasArray select roundCounter-1);
{   
_checkType = typeOf _x;  
_resultPump = _checkType find "_pump";  
_resultKiosk = _checkType find "Land_Kiosk";  
_resultTransformer = _checkType find "Land_spp_Transformer";   
_resultPier = _checkType find "Land_Pier"; 
_lootPlaces = _x buildingPos -1;   
if (count _lootPlaces > 0) then {   
  
if ((_resultPump < 0) && (_resultKiosk < 0) && (_resultTransformer < 0) && (_resultPier < 0)) then {  
  
{if (!surfaceIsWater _x) then {_amishouldSpawn = floor random (5); if(_amishouldSpawn == 0) then {0 = [_x] call myfuncLS;}}}foreach _lootPlaces;   
};  
};  
}foreach (_LStrigger nearObjects ["house", _ExpRange]); 
};

TriggersArray = [round_tigger_1, round_tigger_2, round_tigger_3, round_tigger_4, round_tigger_5, round_tigger_6];
StartTimeToAdd = 600;
ExtendedTimeMode = 0;
LootBots = objNull;

_mapScale = BRSE_MapStartRadius / 1000;
AreasArray = [1000, 800, 600, 400, 200, 10, 10] apply {round (_x * _mapScale)};
TimeArray = [240, 240, 240, 240, 240, 240, 240];

