



BRSE_AggroRadiusDefault     = 30;    
BRSE_AggroSightRadius       = 400;   
BRSE_AggroSoundRadius       = 300;   
BRSE_AggroTimeout           = 60;    
BRSE_AggroCheckInterval     = 0.5;     
BRSE_AggroBotBotReset       = 5;     
BRSE_EvacuationRadius       = 180;
BRSE_EvacuationCheckInterval = 5;
BRSE_EvacuationEdgeDist     = 20;    
BRSE_AliveBots     	    = 6;    
BRSE_HealCheckInterval = 10;   
BRSE_HuntRoles = ["charger", "flanker", "suppressor", "ambusher"];
BRSE_RoleUpdateInterval = 2;   
BRSE_FlankAngle = 90;          
BRSE_SuppressionDistance = 80; 
BRSE_LastGlobalFireCheck = 0;


BRSE_AssignHuntRole = {
    params ["_unit"];
    private _roleIndex = floor random 4;  
    private _role = BRSE_HuntRoles select _roleIndex;
    _unit setVariable ["BRSE_HuntRole", _role, true];
    _unit setVariable ["BRSE_LastRoleUpdate", time, true];
    
    _unit setVariable ["BRSE_CoverPos", [0,0,0], true];
    _unit setVariable ["BRSE_LastHuntUpdate", 0, true];
};

BRSE_HuntUpdate = {
    params ["_unit"];
    if (!alive _unit) exitWith {};
    private _role = _unit getVariable ["BRSE_HuntRole", "charger"];
    private _player = player;
    if (isNull _player || !alive _player) exitWith {};
    
    private _grp = group _unit;
    
    while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
    
    _grp setBehaviour "COMBAT";
    _grp setCombatMode "RED";
    
    switch (_role) do {
        case "charger": {
            _grp setSpeedMode "FULL";
            private _wp = _grp addWaypoint [position _player, 0];
            _wp setWaypointType "MOVE";
            _wp setWaypointCompletionRadius 3;
            _unit doTarget _player;
        };
        case "flanker": {
            _grp setSpeedMode "FULL";
            private _angle = (_unit getDir _player) + BRSE_FlankAngle;
            private _flankPos = [
                (position _player select 0) + (sin _angle * 40),
                (position _player select 1) + (cos _angle * 40),
                0
            ];
            private _wp = _grp addWaypoint [_flankPos, 10];
            _wp setWaypointType "MOVE";
            _unit doTarget _player;
        };
	case "suppressor": {
	    _grp setSpeedMode "NORMAL";
	    private _dist = _unit distance2D _player;
	    if (_dist < BRSE_SuppressionDistance * 0.7) then {
	        
	        private _dir = (_unit getDir _player) + 180;
	        private _fallbackPos = [
	            (position _unit select 0) + (sin _dir * 20),
	            (position _unit select 1) + (cos _dir * 20),
	            0
	        ];
	        private _wp = _grp addWaypoint [_fallbackPos, 10];
	        _wp setWaypointType "MOVE";
	    } else {
	        if (_dist > BRSE_SuppressionDistance * 1.3) then {
	            
	            private _wp = _grp addWaypoint [position _player, BRSE_SuppressionDistance];
	            _wp setWaypointType "MOVE";
	        } else {
	            
	            _unit doWatch _player;
	            _unit forceWeaponFire [currentWeapon _unit, "FullAuto"];
	        };
	    };
	};
	case "ambusher": {
	    _grp setSpeedMode "LIMITED";
	    _grp setBehaviour "STEALTH";
	    private _coverCandidates = nearestObjects [_player, ["House", "Building", "Wall", "Rock"], 50];
	    if (count _coverCandidates > 0) then {
	        private _bestCover = _coverCandidates select 0;
	        private _bestDist = _bestCover distance2D _unit;
	        { if ((_x distance2D _unit) < _bestDist) then { _bestCover = _x; _bestDist = _x distance2D _unit; }; } forEach _coverCandidates;
	        private _wp = _grp addWaypoint [getPosATL _bestCover, 5];
	        _wp setWaypointType "MOVE";
	    } else {
	        private _wp = _grp addWaypoint [position _player, 20];
	        _wp setWaypointType "MOVE";
	    };
	    _unit setUnitPos "UP";
	    _unit doTarget _player;
	    _unit doWatch _player;
	};
    };
    _unit setVariable ["BRSE_LastHuntUpdate", time];
};



BRSE_BotAggroData = [];


BRSE_initBotAggroData = {
    params ["_unit"];
    private _entry = [
        _unit, false, 0, [0,0,0], BRSE_AggroRadiusDefault,
        false, [0,0,0], false, 0
    ];
    BRSE_BotAggroData pushBack _entry;
    



      
   _unit addEventHandler ["FiredMan", {
       params ["_unit", "_wep", "_muzzle", "_mode", "_ammo", "_mag"];
       _unit addMagazine _mag;
   }];
 };

BRSE_SuppressLastKnown = {
    params ["_unit", "_lastKnownPlayerPos"];
    private _grp = group _unit;
    while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
    _grp setBehaviour "COMBAT";
    _grp setCombatMode "RED";
    _grp setSpeedMode "FULL";
    _unit doWatch _lastKnownPlayerPos;
    for "_i" from 1 to (5 + floor random 3) do {
        if (!(_unit getVariable ["Aggressive", false]) || !alive _unit) exitWith {};
        _unit forceWeaponFire [currentWeapon _unit, "Burst"];
        sleep (0.8 + random 0.7);
    };
};

BRSE_HandleAggroOnDamage = {
    params ["_unit", "_source"];
    if (roundCounter < 5 && {_unit getVariable ["IsEvacuating", false]}) exitWith {};
    if (_unit getVariable ["IsEvacuating", false]) exitWith {};
    if (isNull _unit || {isNull _source}) exitWith {};
    if (!isPlayer _source) exitWith {};
    private _idx = BRSE_BotAggroData findIf { _x select 0 isEqualTo _unit };
    if (_idx < 0) exitWith {};
    private _entry = BRSE_BotAggroData select _idx;
    _entry set [3, position _source];
    _entry set [2, time + BRSE_AggroTimeout];
    playSound "bullethit";
    if (_entry select 1) exitWith {
        private _grp = group _unit;
        while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
        private _wp = _grp addWaypoint [position _source, 0];
        _wp setWaypointType "MOVE";
        _grp setBehaviour "COMBAT";
        _grp setCombatMode "RED";
        _grp setSpeedMode "FULL";
        { _unit forgetTarget _x; } forEach (allUnits - [_unit, player]);  
        _unit doTarget player;  
        _unit doWatch player;
    };
    _entry set [1, true];
    _unit setVariable ["Aggressive", true, true];
    _unit setVariable ["IsHuntingPlayer", true, true];
    _unit doTarget _source;
    _unit doWatch _source;
    _unit doFire _source;
    _unit setVariable ["PatrolInProgress", false];
    private _grp = group _unit;
    while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
    private _wp = _grp addWaypoint [position _source, 0];
    _wp setWaypointType "MOVE";
    _grp setBehaviour "COMBAT";
    _grp setCombatMode "RED";
    _grp setSpeedMode "FULL";
    _unit doTarget _source;
    _unit doWatch _source;
    _unit doFire _source;
};


if (isNil "BRSE_BotsUnified") then { BRSE_BotsUnified = false; };


BRSE_HealUnit = {
    params ["_unit"];
    if (!alive _unit) exitWith {};
    if (_unit getVariable ["BRSE_IsHealing", false]) exitWith {};
    
    _unit setVariable ["BRSE_IsHealing", true, true];
    
    
    private _eh = _unit addEventHandler ["HandleDamage", {
        params ["_unit"];
        _unit setVariable ["BRSE_HealingInterrupted", true, true];
    }];
    
    
    private _oldBehaviour = behaviour _unit;
    private _oldCombatMode = combatMode group _unit;
    private _oldSpeedMode = speedMode group _unit;
    
    
    _unit disableAI "MOVE";
    _unit disableAI "AUTOTARGET";
    _unit disableAI "TARGET";
    _unit setBehaviour "CARELESS";
    _unit setUnitPos "MIDDLE";
    
    
    _unit playMoveNow "AinvPknlMstpSnonWnonDnon_healed_1";
    
    
    private _startTime = time;
    waitUntil {
        sleep 0.2;
        (animationState _unit != "AinvPknlMstpSnonWnonDnon_healed_1") || 
        (time - _startTime > 10) || 
        !alive _unit ||
        (_unit getVariable ["BRSE_HealingInterrupted", false])
    };
    
    
    if (alive _unit && !(_unit getVariable ["BRSE_HealingInterrupted", false])) then {
        if ("FirstAidKit" in (items _unit)) then {
            _unit removeItem "FirstAidKit";
            _unit setDamage 0;
        };
    };
    
    
    _unit removeEventHandler ["HandleDamage", _eh];
    _unit setVariable ["BRSE_HealingInterrupted", nil];
    
    
    _unit enableAI "MOVE";
    _unit enableAI "AUTOTARGET";
    _unit enableAI "TARGET";
    _unit setBehaviour _oldBehaviour;
    (group _unit) setCombatMode _oldCombatMode;
    (group _unit) setSpeedMode _oldSpeedMode;
    _unit setUnitPos "AUTO";
    
    _unit setVariable ["BRSE_IsHealing", false, true];
};

BRSE_AggroLoop = {
    private _lastBotReset = 0;
    private _lastHealCheck = 0;
    while {true} do {
        private _aliveBots = {alive (_x select 0)} count BRSE_BotAggroData;
        
        
        if ((roundCounter > 4 || _aliveBots <= BRSE_AliveBots) && !BRSE_BotsUnified) then {
            {
                private _unit = _x select 0;
                if (!isNull _unit && alive _unit) then {
                    
                    if (_unit getVariable ["BRSE_IsHealing", false]) then { continue };
                    
                    _unit setDamage 0;
                    for "_i" from 1 to 3 do { _unit addItem "FirstAidKit"; };
                    _unit setVariable ["Aggressive", true, true];
                    _x set [1, true];
                    _unit setVariable ["IsHuntingPlayer", true, true];
                    _unit setVariable ["PatrolInProgress", false];
                    [_unit] call BRSE_AssignHuntRole;
                    [_unit] call BRSE_HuntUpdate;
                    _unit setSide east;
                };
            } forEach BRSE_BotAggroData;
            BRSE_BotsUnified = true;
        };
        
        
        if ((roundCounter > 4 || _aliveBots <= BRSE_AliveBots) && BRSE_BotsUnified) then {
            private _now = time;
            
            
            if (_now - _lastBotReset >= 15) then {
                private _allUnitsExceptPlayer = allUnits select { _x != player };
                {
                    private _unit = _x select 0;
                    if (!isNull _unit && alive _unit) then {
                        { _unit forgetTarget _x; } forEach _allUnitsExceptPlayer;
                    };
                } forEach BRSE_BotAggroData;
                _lastBotReset = _now;
            };
            
            
            {
                private _unit = _x select 0;
                if (!isNull _unit && alive _unit) then {
                    
                    if (_unit getVariable ["BRSE_IsHealing", false]) then { continue };
                    
                    private _lastUpdate = _unit getVariable ["BRSE_LastHuntUpdate", 0];
                    private _wpCount = count waypoints group _unit;
                    private _isStuck = (speed _unit < 0.5) && (_wpCount > 0) && {_unit distance2D (getWPPos [group _unit, 0]) < 2};
                    if (_now - _lastUpdate > BRSE_RoleUpdateInterval || _isStuck) then {
                        [_unit] call BRSE_HuntUpdate;
                    };
                    _unit doTarget player;
                    _unit doWatch player;
                };
            } forEach BRSE_BotAggroData;
        };
        
        
        if (roundCounter <= 4) then {
            {
                private _unit = _x select 0;
                if (isNull _unit || !alive _unit) then { continue };
                
                if (_unit getVariable ["BRSE_IsHealing", false]) then { continue };
                
                private _entry = _x;
                private _isAggro = _entry select 1;
                private _aggroEnd = _entry select 2;
                private _isEvacuating = _entry select 5;
                private _evacuationPos = _entry select 6;
                private _hasEvacuatedThisRound = _entry select 7;
                private _distToBorder = (_unit distance2D LastPosition) - (AreasArray select (roundCounter min (count AreasArray - 1)));
                
                
                private _player = player;
                if ((_unit distance2D _player) <= BRSE_AggroSightRadius) then {
                    private _eyePos = eyePos _unit;
                    private _targetPos = eyePos _player;
                    private _losArr = lineIntersectsSurfaces [_eyePos, _targetPos, _unit, _player, true, 1, "FIRE", "NONE"];
                    private _hasLOS = count _losArr == 0;
                    private _coefVis = 1;
                    if (!_hasLOS) then {
                        {
                            private _mat = _x select 2;
                            if (["tree", "bush", "grass"] findIf { (typeName _mat == "STRING") && { _mat find _x > -1 } } > -1) exitWith { _coefVis = 0.5; };
                        } forEach _losArr;
                    };
                    if (!_isAggro && (_hasLOS || {_coefVis == 0.5 && random 1 < 0.1})) then {
                        _entry set [3, position _player];
                        _entry set [2, time + BRSE_AggroTimeout];
                        _entry set [1, true];
                        _unit setVariable ["Aggressive", true, true];
                        _unit setVariable ["IsHuntingPlayer", true, true];
                        private _grp = group _unit;
                        while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
                        private _wp = _grp addWaypoint [position _player, 0];
                        _wp setWaypointType "MOVE";
                        _grp setBehaviour "COMBAT";
                        _grp setCombatMode "RED";
                        _grp setSpeedMode "FULL";
                        _unit doTarget _player;
                        _unit doWatch _player;
                        _unit doFire _player;
                        continue;
                    };
                };
                
                
                if (_isEvacuating) then {
                    
                    if (_distToBorder <= 0 || _unit distance2D _evacuationPos < BRSE_EvacuationRadius) then {
                        _entry set [5, false];
                        _entry set [6, [0,0,0]];
                        _entry set [7, true];
                        _unit enableAI "AUTOCOMBAT";
                        _unit enableAI "COVER";
                        _unit enableAI "SUPPRESSION";
                        _unit setUnitPos "AUTO";
                        _unit setVariable ["IsEvacuating", false, true];
                        _unit setVariable ["LastEvacUpdate", 0];
                        private _grp = group _unit;
                        while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
                        _grp setBehaviour "AWARE";
                        _grp setCombatMode "YELLOW";
                        _grp setSpeedMode "NORMAL";
                        [_unit, 30] call lastPointRunner;
                        continue;
                    } else {
                        
                        private _lastUpdate = _unit getVariable ["LastEvacUpdate", 0];
                        if (time - _lastUpdate >= 5) then {
                            private _grp = group _unit;
                            while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
                            private _wp = _grp addWaypoint [_evacuationPos, BRSE_EvacuationRadius];
                            _wp setWaypointType "MOVE";
                            _grp setBehaviour "SAFE";
                            _grp setCombatMode "YELLOW";
                            _grp setSpeedMode "FULL";
                            _unit setVariable ["LastEvacUpdate", time];
                        };
                    };
                    continue; 
                };
                
                
                private _evacNeeded = (_distToBorder > 0 && !_hasEvacuatedThisRound);
                if (_evacNeeded) then {
                    private _timeToBorder = abs(_distToBorder) / 3 + random [20, 40, 60];
                    private _timeToShrink = (TimeArray select (roundCounter - 1)) - (time - (missionNamespace getVariable ["RoundStartTime", 0]));
                    if (_timeToShrink < _timeToBorder) then {
                        private _botPos = getPosATL _unit;
                        private _center = LastPosition;
                        private _safeRadius = AreasArray select roundCounter;
                        if ((_unit distance2D _center) < (_safeRadius - 1)) exitWith {};
                        private _vec = [(_center select 0) - (_botPos select 0), (_center select 1) - (_botPos select 1)];
                        private _distToCenter = sqrt ((_vec select 0)^2 + (_vec select 1)^2);
                        private _vecNorm = [(_vec select 0) / _distToCenter, (_vec select 1) / _distToCenter];
                        private _distToBorderRaw = (_unit distance2D _center) - _safeRadius;
                        private _moveDistance = _distToBorderRaw + BRSE_EvacuationEdgeDist;
                        private _targetPos = [
                            (_botPos select 0) + (_vecNorm select 0) * _moveDistance,
                            (_botPos select 1) + (_vecNorm select 1) * _moveDistance,
                            0
                        ];
                        _unit setDamage 0;
                        _entry set [5, true];
                        _entry set [6, _targetPos];
                        _unit setVariable ["IsEvacuating", true, true];
                        _entry set [1, false];
                        _unit setVariable ["Aggressive", false];
                        _unit setVariable ["IsHuntingPlayer", false];
                        _unit setUnitPos "UP";
                        _unit disableAI "AUTOCOMBAT";
                        _unit disableAI "COVER";
                        _unit disableAI "SUPPRESSION";
                        { _unit forgetTarget _x; } forEach (allUnits - [_unit]);
                        _unit doWatch objNull;
                        _unit doTarget objNull;
                        _unit setVariable ["LastEvacUpdate", time];
                        private _grp = group _unit;
                        while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
                        private _wp = _grp addWaypoint [_targetPos, BRSE_EvacuationRadius];
                        _wp setWaypointType "MOVE";
                        _grp setBehaviour "SAFE";
                        _grp setCombatMode "YELLOW";
                        _grp setSpeedMode "FULL";
                        continue;
                    };
                };
                
            } forEach BRSE_BotAggroData;
        };
        
        
        if (time - _lastHealCheck >= BRSE_HealCheckInterval) then {
            {
                private _unit = _x select 0;
                if (!isNull _unit && alive _unit) then {
                    private _dmg = damage _unit;
                    if (_dmg > 0.5) then {
                        if ("FirstAidKit" in (items _unit) && !(_unit getVariable ["BRSE_IsHealing", false])) then {
                            [_unit] spawn BRSE_HealUnit;
                        };
                    };
                };
            } forEach BRSE_BotAggroData;
            _lastHealCheck = time;
            
            
            if (time - BRSE_LastGlobalFireCheck >= 2) then {
                {
                    private _unit = _x select 0;
                    if (!isNull _unit && alive _unit) then {
                        if (_unit getVariable ["Aggressive", false]) then {
                            _unit doTarget player;
                            _unit doFire player;
                        };
                    };
                } forEach BRSE_BotAggroData;
                BRSE_LastGlobalFireCheck = time;
            };
        };
        sleep BRSE_AggroCheckInterval;
    };
};

BRSE_PatrolLastKnown = {
    params ["_unit", "_centerPos"];
    if (_unit getVariable ["PatrolInProgress", false]) exitWith {};
    _unit setVariable ["PatrolInProgress", true];
    private _patrolRadius = BRSE_AggroRadiusDefault;
    private _maxPatrolCycles = 3;
    private _idx = BRSE_BotAggroData findIf { _x select 0 isEqualTo _unit };
    if (_idx < 0) exitWith {};
    private _entry = BRSE_BotAggroData select _idx;
    _entry set [2, time + 60];
    private _cycleCount = 0;
    while {(_entry select 1) && {time < (_entry select 2)} && {_cycleCount < _maxPatrolCycles}} do {
        private _rndDir = random 360;
        private _rndDist = random _patrolRadius;
        private _patrolPos = [
            (_centerPos select 0) + _rndDist * cos _rndDir,
            (_centerPos select 1) + _rndDist * sin _rndDir,
            (_centerPos select 2)
        ];
        private _grp = group _unit;
        while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
        private _wp = _grp addWaypoint [_patrolPos, 0];
        _wp setWaypointType "MOVE";
        _grp setBehaviour "AWARE";
        _grp setCombatMode "YELLOW";
        _grp setSpeedMode "NORMAL";
        sleep (8 + random 4);
        _cycleCount = _cycleCount + 1;
        if (!(_entry select 1) || time > (_entry select 2)) exitWith {};
    };
    _unit setVariable ["PatrolInProgress", false];
};


player addEventHandler ["Fired", {
    {
        private _bot = _x select 0;
        if (_bot getVariable ["IsEvacuating", false]) then { continue };
        if (!isNull _bot && {alive _bot} && {_bot distance player <= BRSE_AggroSoundRadius}) then {
            private _isAggressive = _bot getVariable ["Aggressive", false];
            if (_isAggressive) then {
                [_bot, player] call BRSE_HandleAggroOnDamage;
                _bot setVariable ["IsHuntingPlayer", true, true];
            } else {
                if (random 1 < 0.3) then {
                    [_bot, player] call BRSE_HandleAggroOnDamage;
                };
            };
        };
    } forEach BRSE_BotAggroData;
}];