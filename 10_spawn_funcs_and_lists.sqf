initSpawnList = {
_wordToSearch = _this select 0;
_userListForSpawn = [];
_dlcItems = []; 
_configText= "";

_configText = format ["((configName (_x)) isKindof ['%1', configFile >> 'cfgWeapons']) && ((getText (_x >> 'DLC') isEqualTo '') || !((getText (_x >> 'author') isEqualTo 'Bohemia Interactive') || (getText (_x >> 'author') isEqualTo 'Bravo Zero One Studios'))) && (getText (_x >> 'displayName') != '' && getnumber (_x >> 'scope') isEqualTo 2)", _wordToSearch]; 
_userListForSpawn = _configText configClasses (configFile >> "cfgWeapons");

if (count userDLCConfigListForSpawn > 0) then {
	{	
	 _configText = format ["((configName (_x)) isKindof ['%1', configFile >> 'cfgWeapons']) && (getText (_x >> 'DLC') isEqualTo '%2') && (getText (_x >> 'displayName') != '' && getnumber (_x >> 'scope') isEqualTo 2)",_wordToSearch ,_x];
	 _dlcItems = _configText configClasses (configFile >> "cfgWeapons");
	 if( count _dlcItems > 0) then {
	 _userListForSpawn = _userListForSpawn + _dlcItems;
	 };
	}forEach userDLCConfigListForSpawn;
};
_userListForSpawn;
};

initBackPacks = {
_defaultBackpacksForSpawn = [];
_dlcBackpacks = []; 
_configText= "";
findRes = false;
staticWeaponFilter ="";
staticWeaponFilter = "((getText (_x >> '_generalMacro')) find 'Mortar' < 0) && ((getText (_x >> '_generalMacro')) find 'Parachute' < 0) && ((getText (_x >> '_generalMacro')) find 'HMG' < 0)";

_defaultBackpacksForSpawn = (format ["%1 && !((configName (_x)) isKindof ['Weapon_Bag_Base', configFile >> 'cfgVehicles']) && ((configName (_x)) isKindof ['Bag_Base', configFile >> 'cfgVehicles']) && ((getText (_x >> 'DLC') isEqualTo '') || !((getText (_x >> 'author') isEqualTo 'Bohemia Interactive') || (getText (_x >> 'author') isEqualTo 'Bravo Zero One Studios'))) && getText (_x >> 'displayName') != '' && getnumber (_x >> 'scope') isEqualTo 2", staticWeaponFilter]) configClasses (configFile >> "cfgVehicles");

if (count userDLCConfigListForSpawn > 0) then {
	{	
	 _configText = format ["%1 && !((configName (_x)) isKindof ['Weapon_Bag_Base', configFile >> 'cfgVehicles']) && ((configName (_x)) isKindof ['Bag_Base', configFile >> 'cfgVehicles']) && (getText (_x >> 'DLC') isEqualTo '%2') && getText (_x >> 'displayName') != '' && getnumber (_x >> 'scope') isEqualTo 2",staticWeaponFilter, _x];
	 _dlcBackpacks = _configText configClasses (configFile >> "cfgVehicles");
	 if( count _dlcBackpacks > 0) then {
	 _defaultBackpacksForSpawn = _defaultBackpacksForSpawn + _dlcBackpacks;
	 };
	}forEach userDLCConfigListForSpawn;
};
_defaultBackpacksForSpawn;
};

initHeroes = {
_defaultHeroes = [];
_dlcHeroes = []; 
staticFilter = "((getText (_x >> '_generalMacro')) find 'Virtual' < 0) && ((getText (_x >> '_generalMacro')) find 'Client' < 0)";
_configText = format ["%1 && !((configName (_x)) isKindof ['Animal', configFile >> 'cfgVehicles']) && ((configName (_x)) isKindof ['Man', configFile >> 'cfgVehicles']) && ((getText (_x >> 'DLC') isEqualTo '') || !((getText (_x >> 'author') isEqualTo 'Bohemia Interactive') || (getText (_x >> 'author') isEqualTo 'Bravo Zero One Studios'))) && (getText (_x >> 'displayName') != '' && getnumber (_x >> 'scope') isEqualTo 2)", staticFilter];
_defaultHeroes = _configText configClasses (configFile >> "cfgVehicles");
if (count userDLCConfigListForSpawn > 0) then {
	{	
	 _configText = format ["%1 && !((configName (_x)) isKindof ['Animal', configFile >> 'cfgVehicles']) && ((configName (_x)) isKindof ['Man', configFile >> 'cfgVehicles']) && (getText (_x >> 'DLC') isEqualTo '%2') && (getText (_x >> 'displayName') != '' && getnumber (_x >> 'scope') isEqualTo 2)", staticFilter, _x];
	 _dlcHeroes = _configText configClasses (configFile >> "cfgVehicles");
	 if( count _dlcBackpacks > 0) then {
	 _defaultHeroes = _defaultHeroes + _dlcHeroes;
	 };
	}forEach userDLCConfigListForSpawn;
};
_defaultHeroes;
};

MainHeroesArray = call initHeroes;


call initUsersDLCList;
userRiflesListForSpawn = ['Rifle'] call initSpawnList;
userPistolsListForSpawn = ['Pistol'] call initSpawnList;
userBackPacksListForSpawn = call initBackPacks;

userVestsListForSpawn_Camo = ['Vest_Camo_Base'] call initSpawnList;
userVestsListForSpawn_NoCamo = ['Vest_NoCamo_Base'] call initSpawnList;
userVestListForSpawn = userVestsListForSpawn_Camo + userVestsListForSpawn_NoCamo;

userUniformsListForSpawn = ['Uniform_Base'] call initSpawnList;

userHelmetsListForSpawn_Helmet1b = ['H_HelmetB'] call initSpawnList;
userHelmetsListForSpawn_HelmetBase = ['HelmetBase'] call initSpawnList;
userHelmetsListForSpawn = userHelmetsListForSpawn_Helmet1b + userHelmetsListForSpawn_HelmetBase;

