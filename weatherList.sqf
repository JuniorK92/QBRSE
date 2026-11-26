disableSerialization;
_display = findDisplay 2025;

weatherVar = 0;
TimeVar = 0;
statsCurrentProgress = 0;
DifficultyVar = 1;
PlSkinVar = 0;
ChbxFatigueBool = true;
ChbxHUDBool = true;
ChbxGPSBool = false;
ChbxRememberMe = false;
rememberMePropVar = profileNamespace getVariable "rememberMeProp";


SpawnData = 2;                 
BRSEAICount = 0;               
BRSEWeather = weatherVar;
BRSETime = TimeVar;
if (BRSEWeather == 5) then { BRSEWeather = 0; };
if (BRSETime == 5) then { BRSETime = 0; };
BRSEAISkill = DifficultyVar;

if (!isNil {rememberMePropVar}) then {
	if (rememberMePropVar > 0) then {
		weatherVar = (profileNamespace getVariable "listBoxWeatherProp");
		BRSEWeather = weatherVar;
		TimeVar = (profileNamespace getVariable "TimeVarProp");
		BRSETime = TimeVar; 
		DifficultyVar = (profileNamespace getVariable "DifficultyVarProp");
		BRSEAISkill = DifficultyVar;
		PlSkinVar = (profileNamespace getVariable "SkinVarProp");
		SkinData = PlSkinVar;
		if ((profileNamespace getVariable "ChbxFatigueBoolProp")>0) then {ChbxFatigueBool=true; isFatigueEnabled = 1;} else {ChbxFatigueBool=false; isFatigueEnabled = 0;};
		if ((profileNamespace getVariable "ChbxHUDBoolProp")>0) then {ChbxHUDBool=true;EnableCustomHudMode =1; } else {ChbxHUDBool=false; EnableCustomHudMode =0;};
		if ((profileNamespace getVariable "ChbxGPSBoolProp")>0) then {ChbxGPSBool=true;addGPS = 1; } else {ChbxGPSBool=false; addGPS =0;};
        ChbxRememberMe = true;
        RememberSettings = 1;	
	};
};

if (isNil {statsTotalPoints}) then 
{
	statsTotalPoints = 0;
	statsTotalKills = 0;
	statsTotalDeaths = 0;
	statsLastKills = 0;
	statsLastPoints = 0;
};

getCurrentUserRank = {
	if (statsTotalPoints < 10000) then {
		statsCurrentRank = statsRankArray select 0;
	}
	else {
		if (statsTotalPoints < 50000) then {
			statsCurrentRank = statsRankArray select 1;
		}
		else {
			if (statsTotalPoints < 120000) then {
				statsCurrentRank = statsRankArray select 2;
			}
			else {
				if (statsTotalPoints < 290000) then {
					statsCurrentRank = statsRankArray select 3;
				}
				else{
					statsCurrentRank = statsRankArray select 4;
				}
			}
		}		
	};
	statsCurrentRank;
};

getCurrentUserProgress = {
	switch (statsCurrentRank) do {
		case "Recruit": {statsCurrentProgress =  (statsTotalPoints /10000);};
		case "Experienced": {statsCurrentProgress = (statsTotalPoints /50000);};
		case "Veteran": {statsCurrentProgress = (statsTotalPoints /120000);};
		case "Master": {statsCurrentProgress = (statsTotalPoints /290000);};
		case "King": {statsCurrentProgress = 1;};
		default {statsCurrentProgress = 0;};
	};
	statsCurrentProgress;
};

getUserKDRatio = {
	if (statsTotalDeaths > 0) then {
		statsKillDeadRatio =  (statsTotalKills/statsTotalDeaths) toFixed 1;
	}
	else {
		statsKillDeadRatio = str 0;
	};
	statsKillDeadRatio;
};

drawStats = {
	disableSerialization;
	_display = findDisplay 2025;
	_rankText = _display displayCtrl 2030;
	_rankText ctrlSetText call getCurrentUserRank;
	_lastPointsText = _display displayCtrl 2031;
	_lastPointsText ctrlSetText str statsLastPoints;
	_lastKillsText = _display displayCtrl 2032;
	_lastKillsText ctrlSetText str statsLastKills;
	_totalKills = _display displayCtrl 2033;
	_totalKills ctrlSetText str statsTotalKills;
	_averageKDText = _display displayCtrl 2034;
	_averageKDText ctrlSetText call getUserKDRatio;	
	_totalPointsText = _display displayCtrl 2035;
	_totalPointsText ctrlSetText str statsTotalPoints;
	_pointsToNextRankText = _display displayCtrl 2036;
	_pointsToNextRankText ctrlSetText (str ((call getCurrentUserProgress)*100)) + "%";
};

drawSkins = {
	disableSerialization;
	_display = findDisplay 2025;
	_listBoxSkin = _display displayCtrl 1543;
	lbClear _listBoxSkin;
	_listBoxSkin lbAdd "Recruit";
	switch (statsCurrentRank) do {
		case "Experienced": {_listBoxSkin lbAdd "Experienced";};
		case "Veteran": {_listBoxSkin lbAdd "Experienced"; _listBoxSkin lbAdd "Veteran"; _listBoxSkin lbAdd "Master";};
		case "Master": {_listBoxSkin lbAdd "Experienced"; _listBoxSkin lbAdd "Veteran"; _listBoxSkin lbAdd "Master";};
		case "King": {_listBoxSkin lbAdd "Experienced"; _listBoxSkin lbAdd "Veteran"; _listBoxSkin lbAdd "Master"; _listBoxSkin lbAdd "King";};
		default {};
	};
	_listBoxSkin lbSetCurSel PlSkinVar;
};

call drawStats; 
call drawSkins;

resetStats = {
	statsTotalPoints = 0;
	statsTotalKills = 0;
	statsTotalDeaths = 0;
	statsLastKills = 0;
	statsLastPoints = 0;
	PlSkinVar = 0;
	call drawStats;
	call drawSkins;
	call saveStats;
};

drawNoWeaponMode = {
	disableSerialization;
	_display = findDisplay 2025;
};


_ctrl = _display displayCtrl 1501; 
if (!isNull _ctrl) then { _ctrl ctrlShow false; };
_ctrl = _display displayCtrl 1533; 
if (!isNull _ctrl) then { _ctrl ctrlShow false; };

_listBoxWeather = _display displayCtrl 1500;
lbClear _listBoxWeather;
_listBoxWeather lbAdd "Sunny";
_listBoxWeather lbAdd "Fog";
_listBoxWeather lbAdd "Rain";
_listBoxWeather lbAdd "Overcast";
_listBoxWeather lbAdd "Random";

_listBoxWeather lbSetCurSel weatherVar;

_listBoxTime = _display displayCtrl 1502;
lbClear _listBoxTime;
_listBoxTime lbAdd "Evening";
_listBoxTime lbAdd "Morning";
_listBoxTime lbAdd "Day";
_listBoxTime lbAdd "Night";
_listBoxTime lbAdd "Random";

_listBoxTime lbSetCurSel TimeVar;

_listBoxDifficulty = _display displayCtrl 1503;
lbClear _listBoxDifficulty;
_listBoxDifficulty lbAdd "Super AI";
_listBoxDifficulty lbAdd "Expert";
_listBoxDifficulty lbAdd "Veteran";
_listBoxDifficulty lbAdd "Recruit";
_listBoxDifficulty lbAdd "Mixed";
_listBoxDifficulty lbSetCurSel DifficultyVar;

_checkBoxFatigue = _display displayCtrl 1504;
_checkBoxFatigue cbSetChecked ChbxFatigueBool;

_checkBoxHUD = _display displayCtrl 1508;
_checkBoxHUD cbSetChecked ChbxHUDBool;

_checkBoxGPS = _display displayCtrl 1505;
_checkBoxGPS cbSetChecked ChbxGPSBool;

_checkBoxRememberMe = _display displayCtrl 1558;
_checkBoxRememberMe cbSetChecked ChbxRememberMe;

call drawNoWeaponMode;

"LoadingScreen" cutFadeOut 0.3;