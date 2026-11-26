notifyGenerator = { 
_TotalSec = _this select 0; 
0 = [_TotalSec] spawn { 
_TotalSec = _this select 0; 
PutTimerSleep =0; 
_TotalSec = _TotalSec - 4;
sleep 4;
while {_TotalSec > 0} do { 
_infohint = "none"; 
_exptimeSec = _TotalSec; 
if(_TotalSec >= 60) then {	
_exptimeMin = floor (_TotalSec / 60); 
_actSec = _TotalSec % 60; 
_checkDif = _TotalSec - 60; 
if(_checkDif < 10) then {if (_checkDif > 0) then {sleep _checkDif; _actSec = _actSec - _checkDif;}; _TotalSec = _TotalSec - _checkDif; PutTimerSleep = 10; _TotalSec = _TotalSec-10;} 
else { if (_actSec != 0) then {_TotalSec = _TotalSec - _actSec; PutTimerSleep = _actSec;} else { 
_TotalSec = _TotalSec-60; PutTimerSleep=60;}; 
}; 
_infohint = format ["THE PLAY AREA WILL BE RESTRICTED IN %1 MIN %2 SEC",_exptimeMin, _actSec]; 
} 
else { 
if (_TotalSec > 9) then { 
_sleeptime = _TotalSec%10; 
if (_sleeptime > 0 ) then {sleep _sleeptime;}; 
_SecToShow = _TotalSec - _sleeptime; 
_infohint = format ["THE PLAY AREA WILL BE RESTRICTED IN %1 SEC",_SecToShow]; 
_TotalSec = _TotalSec - 10; 
PutTimerSleep = 10; 
};}; 
if (_infohint isEqualTo "none") then {} else {1 cutText [_infohint, "PLAIN DOWN", 0.7];}; 
if (PutTimerSleep >0) then {sleep PutTimerSleep}; 
};
if (roundCounter < 6) then {
_infohint = format ["THE PLAY AREA HAS BEEN RESTRICTED"]; 1 cutText [_infohint, "PLAIN DOWN", 0.7]; 
}
else {
_infohint = format ["THE PLAY AREA IS STABLE NOW. KILL THEM ALL"]; 1 cutText [_infohint, "PLAIN DOWN", 0.7];
};
};}; 
 
