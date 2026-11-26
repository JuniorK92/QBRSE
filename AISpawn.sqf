changeCurrentStatsCounters = {
	pointUpdateReason = _this select 0;
	_updateModifier = 0;
	switch (BRSEAISkill) do{
		case 0: {_updateModifier = 2;};
		case 1: {_updateModifier = 1.5;};
		case 2: {_updateModifier = 1;};
		case 3: {_updateModifier = 0.8;};
		case 4: {_updateModifier = 1.2;};
	};
	switch (pointUpdateReason) do {
		case "kill": {statsLastKills = statsLastKills + 1; statsLastPoints = statsLastPoints + 100 * _updateModifier;};
		case "death": {statsTotalDeaths = statsTotalDeaths + 1; statsLastPoints = statsLastPoints - 100 * _updateModifier};
		case "round": {statsLastPoints = statsLastPoints + 100 * _updateModifier;};
		case "win": {statsLastPoints = statsLastPoints + 300 * _updateModifier;};
		default {};
	};
};

MySpawnAI = {
_playerBanArray = +banArr;
_marker ="";
_playerMarkerName ="player_marker_111";
_expRange = (AreasArray select roundCounter-1);
_playerSpawnSafeLimit = spawnDensityPlayerArray select roundCounter;
_aiSpawnSafeLimit = spawnDensityAIArray select roundCounter;

_playerPos = [position EndTr, _expRange, banArr, 300] call BRSE_fnc_randomLandPos;
if (_playerPos isEqualTo []) exitWith {
	diag_log "QBRSE: Could not find dry, unblocked terrain for the player spawn.";
	hint "Unable to find a valid player spawn on this terrain.";
};
player setPosATL _playerPos;

0 = createMarkerLocal [_playerMarkerName, _playerPos];
_playerMarkerName setMarkerSize [_playerSpawnSafeLimit, _playerSpawnSafeLimit]; 
_playerMarkerName setMarkerShape "ELLIPSE";
_playerMarkerName setMarkerAlpha 0;
_playerBanArray pushBack (_playerMarkerName);

while {ExpectedPlayerCount > 1} do {
_red = createGroup east;  
_skill = 0; 
_playerMarkerName = "player_marker_" + str ExpectedPlayerCount; 

switch (BRSEAISkill) do {
	case 0: { _skill = 1.0 };                  
	case 1: { _skill = 0.85 + random 0.1 };    
	case 2: { _skill = 0.65 + random 0.1 };    
	case 3: { _skill = 0.4 + random 0.1 };     
	case 4: { _skill = 0.4 + random 0.6 };     
};

_heroChooser = count MainHeroesArray;
_heroPlayAg = floor random (_heroChooser);
_heroPlayAg = configName (MainHeroesArray select _heroPlayAg);

_heroPosValue = [position EndTr, _expRange, _playerBanArray, 300] call BRSE_fnc_randomLandPos;
if (_heroPosValue isEqualTo []) exitWith {
	diag_log "QBRSE: Could not find dry, unblocked terrain for an AI spawn.";
	hint "Unable to find a valid AI spawn on this terrain.";
};
_unit = _red createUnit [_heroPlayAg, _heroPosValue, [], 0, "FORM"];

 
0 = createMarkerLocal [_playerMarkerName, _heroPosValue];   
_playerMarkerName setMarkerSize [_aiSpawnSafeLimit, _aiSpawnSafeLimit]; 
_playerMarkerName setMarkerShape "ELLIPSE";
_playerMarkerName setMarkerAlpha 0;

_playerBanArray pushBack (_playerMarkerName);
[_unit] join grpNull;
removeAllWeapons _unit;
removeAllItems _unit;
_unit removeWeapon "throw";
_redblue = createGroup east;  
[_unit] join _redblue;
_unit setSkill _skill;
_unit setskill ["aimingAccuracy",_skill];
_unit setskill ["aimingSpeed",_skill];
_unit setskill ["spotTime",_skill];
_unit setskill ["aimingShake",_skill];
_unit setskill ["courage",1];
_grp = group _unit;

_unit addRating -9999;
_unit addEventHandler ["killed", "if ((name (_this select 1)) isEqualTo (name player)) then {KillsCounter = KillsCounter +1;['kill'] call changeCurrentStatsCounters;}; MyPlayersCount = MyPlayersCount -1; plalive = MyPlayersCount; (_this select 0) globalChat format ['%1 was killed by %2. Players alive: %3', (name (_this select 0)), (name (_this select 1)), MyPlayersCount]; call updateUI;"];
[_unit] call BRSE_initBotAggroData; 

_unit addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source"];
    
    private _aliveBots = {alive (_x select 0)} count BRSE_BotAggroData;
    private _isEndGame = (roundCounter > 4) || (_aliveBots <= BRSE_AliveBots);
    
    
    if (_isEndGame && {!isPlayer _source} && {side group _source == side group _unit}) exitWith {0};
    
    
    
    
    if (
        (_unit getVariable ["IsHuntingPlayer", false]) &&
        {!isPlayer _source} &&
        {side group _source == side group _unit}
    ) exitWith {0};  
    
    [_unit, _source] call BRSE_HandleAggroOnDamage;
}];

if(SpawnData > 0) then {
	[_unit] call myfuncNoobGift;
};
_grp setBehaviour "CARELESS";	

ExpectedPlayerCount = ExpectedPlayerCount - 1;
};

sleep 1;
"LoadingScreen" cutFadeOut 0.3;
IsSpawnLoaded = true;
runNumb = 0;
};








EndTrGenerator = {
private _spawnTriggers = allSpawnTriggers select {!isNull _x};
private _spawnCenter = BRSE_MapCenter;
private _LasPosPossibleRad = BRSE_MapSize * 0.45;
if (count BRSE_MapSpawnPositions > 0) then {
	_spawnCenter = selectRandom BRSE_MapSpawnPositions;
	_LasPosPossibleRad = 400;
}
else {
	if (worldName == "Altis" && {count _spawnTriggers > 0}) then {
	private _spawnPointTrig = selectRandom _spawnTriggers;
	_spawnCenter = getPosATL _spawnPointTrig;
	_LasPosPossibleRad = 100;
	};
};
LastPosition = [_spawnCenter, _LasPosPossibleRad, banArr, 300] call BRSE_fnc_randomLandPos;
if (LastPosition isEqualTo []) then {
	LastPosition = [BRSE_MapCenter, BRSE_MapSize, banArr, 1000] call BRSE_fnc_randomLandPos;
};
if (LastPosition isEqualTo []) exitWith {
	diag_log format ["QBRSE: Could not find dry, unblocked terrain on %1.", worldName];
	hint "Unable to find a valid play area on this terrain.";
};
EndTr setPos LastPosition;
lootspawntrigger setPos LastPosition;
{
	private _trigger = missionNamespace getVariable [_x, objNull];
	if (!isNull _trigger) then {
		_trigger setPosATL LastPosition;
	};
} forEach [
	"EndTr",
	"WinCondition",
	"damage_trigger",
	"gameplay_trig_3",
	"gameplay_trig_4",
	"round_tigger_1",
	"round_tigger_2",
	"round_tigger_2_helper_2",
	"round_tigger_3",
	"round_tigger_4",
	"round_tigger_5",
	"round_tigger_6",
	"lootspawntrigger"
];


LoadingPleaseWait = "Loading. Please wait."; 
"LoadingScreen" cutText [LoadingPleaseWait, "BLACK", -1];
if(SpawnData != 1) then {
	0 = [] spawn {
	sleep 1;
	enableLootSpawn = true;
	};
};

0= (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call CheckButton"];
if (EnableCustomHudMode>0) then {
hudScrLbl = cutRsc ["BRSEMissionInfoUI", "PLAIN"];
call updateUI;
};

call greyMarkterCreator;
};

userAction1Handler ={
0= [] spawn {
while {true} do {
	waitUntil {inputAction "User1" == 1;};  
		if (!flag_pressed && (EnableCustomHudMode<1)) then {
			disableSerialization;
			_ok = (findDisplay 46) createDisplay "BRSEMissionInfo";
			flag_pressed = true;
		};
	};
};
};

PlaneXOffset = 0;

#define DIK_F2 0x3C
CheckButton = {
_button = _this select 1;
if (_button == DIK_F2 && !flag_pressed && (EnableCustomHudMode<1)) then {
	_ok = (findDisplay 46) createDisplay "BRSEMissionInfo";
	flag_pressed = true;
};
if (_button == inputAction "user1" && !flag_pressed && (EnableCustomHudMode<1)) then {
	_ok = (findDisplay 46) createDisplay "BRSEMissionInfo";
	flag_pressed = true;
};
if (_button == 0) then {
	closeDialog 0;
};
};

if (addGPS > 0) then {
   player addItem "ItemGPS";
   player assignItem "ItemGPS";
};

if (isFatigueEnabled < 1) then {
	player enableFatigue false;
};

resetLastStats = {
	statsLastKills = 0;
	statsLastPoints = 0;
};

switch(SpawnData) do{
	case 0: {[true] call initSpawnTriggers;};
	case 1: {[false] call initSpawnTriggers;};
	case 2: {[false] call initSpawnTriggers;};
	default { hint "ERROR - WRONG SPAWNTYPE !"};
};

call saveProps;
call resetLastStats;
call ChangeWeatherOrTime;
roundCounter = 1;
ExpectedPlayerCount = 35;
MyPlayersCount = ExpectedPlayerCount;
call EndTrGenerator;


call roundTiggerUpdater;
call MySpawnAI;
call playerConfigSetter;
0 = [] spawn {
    MyPlayersCount = (sideEnemy countSide allUnits);
    sleep 1;
    call EventHandlerAdder;
    sleep 0.1;
    call updateUI;
};
call userAction1Handler;