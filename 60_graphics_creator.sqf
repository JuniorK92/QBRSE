graphicsCreator = {
_bigCircleSize = _this select 1;
_smallCircleSize = _this select 0;
"EndTrMarker" setMarkerSize [_smallCircleSize, _smallCircleSize]; 
"EndTrMarker" setMarkerPos LastPosition;

"EndTrMarker2" setMarkerSize [_bigCircleSize, _bigCircleSize]; 
"EndTrMarker2" setMarkerPos position EndTr;

};

graphicsCreatorEnd = {
	
_bigCircleSize = _this select 1;
_smallCircleSize = _this select 0;

"EndTrMarker" setMarkerSize [_bigCircleSize, _bigCircleSize]; 
"EndTrMarker" setMarkerPos position EndTr;

deleteMarkerLocal "EndTrMarker2";

};

triggerLogicCreator = {
    damageEnabled = true;
    missionNamespace setVariable ["RoundStartTime", time]; 
    0 = [] spawn {
        _BigCircleS = AreasArray select (roundCounter-1);
        _SmallCircleS = AreasArray select roundCounter;
        _LasPosPossibleRad = _BigCircleS - _SmallCircleS;
        

        
        EndTr setPos LastPosition;
        
        _flagPos = LastPosition;
        _flagPos set [2,0];
        final_flag setPosATL _flagPos;
        
        _timeNote = 0;
        EndTr setTriggerArea [_BigCircleS,_BigCircleS,0,false]; 

        if(roundCounter < 5) then {
            private _nextPosition = [position EndTr, _LasPosPossibleRad, banArr, 300] call BRSE_fnc_randomLandPos;
            if (_nextPosition isEqualTo []) then {
                diag_log "QBRSE: Could not find dry, unblocked terrain for the next circle center.";
            }
            else {
                LastPosition = _nextPosition;
            };
        };
        if (roundCounter < 6) then {
            [_SmallCircleS, _BigCircleS] call graphicsCreator;
        }
        else {
            [_SmallCircleS, _BigCircleS] call graphicsCreatorEnd;
        };

        _SmallCircleS = _SmallCircleS * 0.6; 
        _timeNote = TimeArray select (roundCounter);
        
        
        {
            private _unit = _x select 0;
            if (!isNull _unit && {alive _unit}) then {
                _x set [5, false]; 
                _x set [6, [0,0,0]]; 
                _x set [7, false]; 
                _unit setVariable ["IsEvacuating", false, true];
                _unit setVariable ["LastEvacUpdate", 0]; 
                private _grp = group _unit;
                while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
                _grp setBehaviour "AWARE";
                _grp setCombatMode "YELLOW";
                _grp setSpeedMode "NORMAL";
            };
        } forEach BRSE_BotAggroData;

        ['round'] call changeCurrentStatsCounters;
        if (roundCounter < 6) then {
            [_timeNote] call notifyGenerator;
        };

        {
            sleep 0.1;
            _xHumanPos = getPosWorld _x; 
            _dist = _xHumanPos distance2D LastPosition;
            if ((_x != player) && ((side _x) == sideEnemy)) then {
                if ((currentWeapon _x)=="" or (currentWeapon _x)=="throw") then {[_x] call myfuncNoobGift};  
                _grp = group _x;               
                while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0);};  
                
                
		if (roundCounter <= 4) then {
		    _grp setBehaviour "COMBAT";
		    [_x, _SmallCircleS] call lastPointRunner;
		} else {
		    _grp setBehaviour "AWARE";
		    
		};
            };
        } forEach allUnits;


        roundCounter = roundCounter +1;
    };
};