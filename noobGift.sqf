params [["_myhuman", objNull]];
if (isNull _myhuman) exitWith { diag_log "Error: _myhuman is null in noobGift.sqf"; };
if (isNil "userHelmetsListForSpawn") exitWith { diag_log "Error: userHelmetsListForSpawn is undefined in noobGift.sqf"; };


_helmSize = count userHelmetsListForSpawn;
_helmR = floor (random _helmSize);
_my_helm = configName (userHelmetsListForSpawn select _helmR);
if (!isNil "_my_helm" && {_my_helm != ""}) then {
    _myhuman addHeadgear _my_helm;
};


_backpackSize = count userBackPacksListForSpawn;
_backpackR = floor random(_backpackSize);
_mybackpack = configName (userBackPacksListForSpawn select _backpackR);
if (!isNil "_mybackpack" && {_mybackpack != ""}) then {
    _myhuman addBackpack _mybackpack;
};


if (SkinData != 4) then {
    _vestSize = count userVestListForSpawn;
    _vestR = floor random(_vestSize);
    _myvest = configName (userVestListForSpawn select _vestR);
    if (!isNil "_myvest" && {_myvest != ""} && (_myhuman != player || SkinData < 4)) then {
        _myhuman addVest _myvest;
    };
};


generateGifts = {
    _gift = _this select 0;
    _itemR = 0;
    switch (_gift) do {
        case 1: {_itemR = floor (random (count expSkinGifts)); if(_itemR == 1) then {player addWeapon "Binocular";} else {player addItem (expSkinGifts select _itemR);};};
        case 2: {_itemR = floor (random (count vetSkinGifts)); player addItem (expSkinGifts select 0); player addWeapon (vetSkinGifts select _itemR);};
        case 3: {_itemR = floor (random (count masterSkingGifts)); player addItem (expSkinGifts select 0); player addWeapon (vetSkinGifts select 1); if(_itemR == 0) then {player addWeapon "Rangefinder";} else {player addItem (masterSkingGifts select _itemR);};};
        case 4: {_itemR = floor (random (count kingSkingGifts)); player AddVest "V_PlateCarrier2_rgr"; player addItem (expSkinGifts select 0); player addWeapon (vetSkinGifts select 1); player addWeapon (vetSkinGifts select 0); player addItem (kingSkingGifts select _itemR);};
        default {};
    };
};

switch (SkinData) do { 
    case 0: {};
    case 1: {player addUniform (expiriencedSkin select 0); player addGoggles (expiriencedSkin select 1); player addHeadgear (expiriencedSkin select 2); [1] call generateGifts;};
    case 2: {player addUniform (veteranSkin select 0); player addGoggles (veteranSkin select 1); [2] call generateGifts;};
    case 3: {player addUniform (masterSkin select 0); player addGoggles (masterSkin select 1); [3] call generateGifts;};
    case 4: {player addUniform (kingSkin select 0); [4] call generateGifts;};
    default { hint "ERROR - WRONG SKINTYPE !"};
};


_weaponsSize = count userRiflesListForSpawn;
_weaponR = floor random(_weaponsSize);
_myweapon = configName (userRiflesListForSpawn select _weaponR);

if (!isNil "_myweapon" && {_myweapon != ""}) then {
    _myhuman addWeapon _myweapon;
    _myhuman addPrimaryWeaponItem "optic_Arco";
    _mymagazinearray = getArray (configFile >> 'CfgWeapons' >> _myweapon >> 'magazines');
    _tracerMag = "";
    {
        if (_x find "Tracer" != -1 && _x find "100Rnd" != -1) exitWith { _tracerMag = _x; };
    } forEach _mymagazinearray;

    if (_tracerMag == "") then {
        _tracerMag = switch (_myweapon) do {
            case "arifle_MX_SW_F": { "100Rnd_65x39_caseless_mag_Tracer" };
            case "LMG_Mk200_F": { "200Rnd_65x39_cased_Box_Tracer" };
            case "LMG_Zafir_F": { "150Rnd_762x54_Box_Tracer" };
            default { _mymagazinearray select 0 };
        };
    };

    if (_tracerMag != "") then {
        for "_i" from 1 to 7 do {
            _myhuman addMagazine [_tracerMag, 100];
        };
    };
};


if (!isNil "userPistolsListForSpawn") then {
    _pistolSize = count userPistolsListForSpawn;
    if (_pistolSize > 0) then {
        _pistolR = floor random _pistolSize;
        _myPistol = configName (userPistolsListForSpawn select _pistolR);
        if (!isNil "_myPistol" && {_myPistol != ""}) then {
            _myhuman addWeapon _myPistol;
            _pistolMags = getArray (configFile >> 'CfgWeapons' >> _myPistol >> 'magazines');
            if (count _pistolMags > 0) then {
                _pistolMag = _pistolMags select 0;
                for "_i" from 1 to 2 do {
                    _myhuman addMagazine _pistolMag;
                };
            };
        };
    };
};


for "_i" from 1 to 2 do {
    if (_myhuman canAdd "FirstAidKit") then {
        _myhuman addItemToUniform "FirstAidKit" || _myhuman addItemToVest "FirstAidKit" || _myhuman addItemToBackpack "FirstAidKit";
    };
};


_grp = group _myhuman;
_grp setBehaviour 'SAFE';