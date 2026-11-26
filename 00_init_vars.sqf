MyPlayersCount = "N/A";
firstTimerRun = true;
myplayers =0;
LastPosition = [0,0,0];
IsSpawnLoaded = false;
YouAreGettingDamage = parseText "<t color='#F7C69B' size='1.5'>You are getting damage! <br/> Move inside the play area</t>"; 
banArr = ["water"];
BRSE_MapSize = worldSize;
BRSE_MapCenter = [BRSE_MapSize / 2, BRSE_MapSize / 2, 0];
BRSE_MapBounds = [0, BRSE_MapSize, 0, BRSE_MapSize];
BRSE_MapAllowedCenter = BRSE_MapCenter;
BRSE_MapAllowedRadius = -1;
BRSE_MapStartRadius = 1000 * (BRSE_MapSize / 30720);
BRSE_MapSpawnPositions = [];
switch (worldName) do {
	case "Stratis": {
		BRSE_MapCenter = [4096, 4096, 0];
		BRSE_MapAllowedCenter = [3800, 4200, 0];
		BRSE_MapAllowedRadius = 3600;
		BRSE_MapStartRadius = 3200;
		BRSE_MapSpawnPositions = [
			[2980, 6000, 0],
			[5010, 5880, 0],
			[4330, 3810, 0],
			[6440, 5350, 0],
			[2040, 2720, 0],
			[1960, 3530, 0],
			[3280, 2930, 0]
		];
	};
	case "Malden": {
		BRSE_MapCenter = [5500, 6200, 0];
		BRSE_MapBounds = [0, 9000, 0, BRSE_MapSize];
		BRSE_MapStartRadius = 4800;
		BRSE_MapSpawnPositions = [
			[7100, 7000, 0],
			[8050, 10150, 0],
			[8080, 3230, 0],
			[5430, 4340, 0],
			[3530, 2670, 0],
			[4680, 7800, 0],
			[5610, 8680, 0],
			[6020, 5650, 0],
			[5370, 6950, 0]
		];
	};
	case "Tanoa": {
		BRSE_MapCenter = [7680, 7680, 0];
		BRSE_MapStartRadius = 6500;
		BRSE_MapSpawnPositions = [
			[5740, 10250, 0],
			[13500, 12100, 0],
			[11600, 2660, 0],
			[1800, 11900, 0],
			[5400, 4050, 0],
			[9400, 4100, 0],
			[11700, 3150, 0],
			[7050, 7250, 0],
			[5050, 8700, 0]
		];
	};
	case "Enoch": {
		BRSE_MapCenter = [6400, 6400, 0];
		BRSE_MapBounds = [400, 12400, 400, 12400];
		BRSE_MapStartRadius = 5800;
		BRSE_MapSpawnPositions = [
			[1500, 7400, 0],
			[6000, 4200, 0],
			[9300, 10900, 0],
			[11400, 4400, 0],
			[3600, 11600, 0],
			[1500, 9600, 0],
			[3300, 2000, 0],
			[11300, 9500, 0],
			[9700, 8600, 0],
			[10700, 11200, 0]
		];
	};
	case "SefrouRamal": {
		BRSE_MapCenter = [5120, 5120, 0];
		BRSE_MapBounds = [300, BRSE_MapSize - 300, 300, BRSE_MapSize - 300];
		BRSE_MapStartRadius = 4600;
		BRSE_MapSpawnPositions = [
			[4300, 4800, 0],
			[6100, 5400, 0],
			[2800, 7200, 0],
			[5200, 8100, 0],
			[4900, 2100, 0]
		];
	};
};
BRSE_fnc_randomLandPos = {
	params [
		["_center", BRSE_MapCenter, [[]]],
		["_radius", BRSE_MapSize, [0]],
		["_excludedMarkers", [], [[]]],
		["_attempts", 100, [0]]
	];
	private _result = [];
	for "_attempt" from 1 to _attempts do {
		private _distance = sqrt (random 1) * _radius;
		private _angle = random 360;
		private _candidate = [
			(_center select 0) + (sin _angle * _distance),
			(_center select 1) + (cos _angle * _distance),
			0
		];
		private _insideMap = (_candidate select 0) >= 0
			&& {(_candidate select 0) >= (BRSE_MapBounds select 0)}
			&& {(_candidate select 0) < (BRSE_MapBounds select 1)}
			&& {(_candidate select 1) >= (BRSE_MapBounds select 2)}
			&& {(_candidate select 1) < (BRSE_MapBounds select 3)};
		private _insidePlayableRadius = BRSE_MapAllowedRadius <= 0
			|| {_candidate distance2D BRSE_MapAllowedCenter <= BRSE_MapAllowedRadius};
		private _isExcluded = false;
		{
			if ((getMarkerColor _x) != "" && {_candidate inArea _x}) exitWith {
				_isExcluded = true;
			};
		} forEach _excludedMarkers;
		if (_insideMap && {_insidePlayableRadius} && {!surfaceIsWater _candidate} && {!_isExcluded}) exitWith {
			_result = _candidate;
		};
	};
	_result
};
BRSEWeather = 0;
combatBehav = "COMBAT";
MainHeroesArray = [];

BRSETime =0;
isFatigueEnabled = 1;
EnableCustomHudMode = 1;
ExpectedPlayerCount = 50;
flag_pressed = false;
plalive =0;
addGPS = 0;
IsWeatherVariable = false;
IsTimeVariable = false;
KillsCounter = 0;
RememberSettings=0;
SpawnData = 0;
SkinData = 0;
roundCounter = 1;
allSpawnTriggers = []; 
enableLootSpawn = false; 
damageEnabled = false;
behaviourModeArray = ["SAFE", "AWARE", "AWARE", "COMBAT"];
combatModeArray = ["YELLOW", "YELLOW", "YELLOW", "RED"];
speedModeArray = ["NORMAL", "FULL"];
spawnDensityPlayerArray = [120, 100, 80, 50, 30];
spawnDensityAIArray = [75, 80, 80, 30, 10];


userDLCConfigListForSpawn = [];
userRiflesListForSpawn = [];
userPistolsListForSpawn = [];
userBackPacksListForSpawn = [];
userVestsListForSpawn = []; 
userVestsListForSpawn_Camo = [];
userVestsListForSpawn_NoCamo = [];
userUniformsListForSpawn = [];
userHelmetsListForSpawn = [];
userHelmetsListForSpawn_Helmet1b = [];
userHelmetsListForSpawn_HelmetBase = [];

 
statsRankArray = ["Recruit", "Experienced", "Veteran", "Master", "King"]; 
statsCurrentProgress = 0;
statsCurrentRank = "";
statsKillDeadRatio = 0;
statsTotalPoints = profileNamespace getVariable "statsTotalPoints";
statsTotalKills = profileNamespace getVariable "statsTotalKills";
statsTotalDeaths = profileNamespace getVariable "statsTotalDeaths";
statsLastKills = profileNamespace getVariable "statsLastKills";
statsLastPoints = profileNamespace getVariable "statsLastPoints";
pointUpdateReason = "";
gameStatsProp ="";


updateTotalStats = {
	statsTotalKills = statsTotalKills + statsLastKills;
	statsTotalPoints = statsTotalPoints + statsLastPoints;
	if (statsTotalPoints < 0) then {
		statsTotalPoints =0;
	};
};

saveStats = {
	call updateTotalStats;
	profileNamespace setVariable ["statsTotalPoints", statsTotalPoints];
	profileNamespace setVariable ["statsTotalKills", statsTotalKills];
	profileNamespace setVariable ["statsTotalDeaths", statsTotalDeaths];
	profileNamespace setVariable ["statsLastKills", statsLastKills];
	profileNamespace setVariable ["statsLastPoints", statsLastPoints];
	saveProfileNamespace;
	
	_rank = call getCurrentUserRank;
	_rankProgress = (str ((call getCurrentUserProgress)*100)) + "%";
	gameStatsProp = format ["<center>Gameplay stats</center><br/> Current Kills: %1 <br/> Current Points: %2 <br/> Total Points: %3 <br/> Current rank: %4 <br/> Rank progress: %5 <br/>", str statsLastKills, str statsLastPoints, str statsTotalPoints, _rank, _rankProgress];
	missionNamespace setVariable ["gameStatsProp", gameStatsProp];
};
 

expiriencedSkin = ["U_I_G_resistanceLeader_F", "G_Aviator", "H_Watchcap_blk"];
veteranSkin = ["U_I_OfficerUniform", "G_Balaclava_Blk"]; 
masterSkin = ["U_I_Protagonist_VR", "Land_VRGoggles_01_F"]; 
kingSkin = ["U_I_GhillieSuit"]; 

expSkinGifts = ["FirstAidKit", "Binocular", "Chemlight_green"];
vetSkinGifts = ["Rangefinder", "NVGoggles"];
masterSkingGifts = ["Rangefinder", "optic_tws"];
kingSkingGifts = ["optic_tws", "APERSMine_Range_Mag"]; 

myfuncNoobGift = compile preprocessFileLineNumbers "noobGift.sqf";

initUsersDLCList = {
_dlcArr = getDLCs 1;
{
switch(_x) do {
case 275700: {_x = "Curator";}; 
case 288520: {_x = "Kart";}; 
case 332350: {_x = "Mark";}; 
case 395180: {_x = "Expansion";}; 
case 571710: {_x = "ORANGE";}; 
default {_x = ""};
};
if (!(_x isEqualTo ""))then {
 userDLCConfigListForSpawn pushBack (_x);	
};
}forEach _dlcArr;	
};