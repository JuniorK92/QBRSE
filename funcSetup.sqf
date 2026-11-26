playerConfigSetter = {
	player addRating -9999;
	
	[player] call myfuncNoobGift;
};

EventHandlerAdder ={
player addEventHandler ["killed", "MyPlayersCount = MyPlayersCount -1;['death'] call changeCurrentStatsCounters; call saveStats; (_this select 0) globalChat format ['%1 was killed by %2. Players alive: %3', (name (_this select 0)), (name (_this select 1)), MyPlayersCount];"];
player addEventHandler ["Dammaged", "call updateUI"];
player addEventHandler ["HandleHeal", "0 = _this spawn {params ['_injured','_healer'];_damage = damage _injured; if (_injured == _healer) then {waitUntil {damage _injured != _damage}; call updateUI;};}"];
};

saveProps = {
	if (RememberSettings > 0) then {
		profileNamespace setVariable ["listBoxWeatherProp",BRSEWeather];
		profileNamespace setVariable ["AIVarProp",BRSEAICount];
		profileNamespace setVariable ["TimeVarProp", BRSETime];
		profileNamespace setVariable ["DifficultyVarProp", BRSEAISkill];
	    profileNamespace setVariable ["SpawnVarProp", SpawnData];
		profileNamespace setVariable ["SkinVarProp", SkinData];
		profileNamespace setVariable ["ChbxFatigueBoolProp", isFatigueEnabled];
		profileNamespace setVariable ["ChbxHUDBoolProp", EnableCustomHudMode];
		profileNamespace setVariable ["ChbxGPSBoolProp", addGPS];
		profileNamespace setVariable ["rememberMeProp", RememberSettings];
		saveProfileNamespace;
	}
	else {
		profileNamespace setVariable ["rememberMeProp", RememberSettings];
		saveProfileNamespace;
	}
};