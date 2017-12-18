//Script for placing heli crew and wreck
//Also assigns tasks to all players

//Ideally this code will continue to execute randomly on the server generating tasks for connected players
// my goal is to make a variety of these mini missions via script and then just have them randomly fire, possibly one at a time, possibly as multiples.

//Some constants to make tweaking easier
_cleanupTimer = 300;
_base = "ftravel_PassengerTerminal";

_crewCount = 2;
_minCrewDist = 150;
_maxCrewDist = 400;

_minWreckDist = 1500;
_maxWreckDist = 10000;

_searchArea = 800;

_enemyEnable = false;
_minEnemyDist = 1000;
_maxEnemyDist = 1500;


_wreckType = "B_Heli_Attack_01_F";




//Create group to add crew to
_airCrew = createGroup west;


//Finding suitable location to place wrecked helicopter
//*** Eventually needs blacklist locations or to check that it isn't too near enemy locations

_wreckLocation = [];

while {(count _wreckLocation) == 0} do {
	//changed temp for testing remove before flight
	_randomSpot = (getmarkerPos _base) getPos [(floor random [(_minWreckDist), ((_minWreckDist + _maxWreckDist)/2),(_maxWreckDist)]) , ((floor random 90) * 4)];
	_wreckLocation = _randomSpot findEmptyPosition[5,50,"Land_Wreck_Heli_Attack_01_F"];
}; 

//Create wrecked vehicle
_Wreck =  createVehicle[_wreckType, _wreckLocation,[],0,"NONE"];
_Wreck setDamage .9;
_Wreck setFuel 0;
_Wreck lock true;



//Troubleshooting marker, will be disabled in game later
_PD1Marker = createMarker ["WreckLocation", _wreckLocation];
_PD1Marker setMarkerType "hd_objective";
_PD1Marker setMarkerColor "ColorGreen";



//finding suitable location for crew near the helicopter
// ** also needs blacklist/ safe from enemies type condition
_crewPosition = [];

while {(count _crewPosition) ==0 } do {
	//remove before flight
	//_randomSpot = _wreckLocation getPos[ ((floor random 4) * 50) + 50, ((floor random 90)* 4)];
	_randomSpot = _wreckLocation getPos[(floor random [(_minCrewDist), ((_minCrewDist + _maxCrewDist)/2),(_maxCrewDist)] ), ((floor random 90) * 4)];
	_crewPosition = _randomSpot findEmptyPosition[1,10];
};

//The stars of the show
//_pilot = _airCrew createUnit ["B_helicrew_F", _crewPosition, [],2,"NONE"];
//_gunner = _airCrew createUnit ["B_helicrew_F", _crewPosition, [],2,"NONE"];


for [{_i=1}, {_i<=_crewCount}, {_i=_i+1}] do
{
	"B_helicrew_F" createUnit [_crewPosition, _airCrew];
};



//**** Eventually need to make sexier wounded/ treating setup. Would like to require team to bring advanced medical support
//removeAllWeapons _gunner;
//removeHeadgear _gunner;
//removeGoggles _gunner;

//_gunner playMove "AinjPpneMstpSnonWnonDnon";

//_gunner setUnconscious true;	
//_gunner setBleedingRemaining 10000;
//_gunner addAction["Provide Emergency Medicine", "_this setUnconscious false"];


//Setting up the crew members 

{
	_x removeItems "Firstaidkit";
	_x setUnitPosWeak "Middle";
	_x setCombatMode "GREEN";
	_x setDamage 0.5;
	_x setHitPointDamage ["hitBody", .5, true];
	_x setRank "PRIVATE";
	_x addAction ["Come with me", { _this join (group player); group player selectLeader player}];
} forEach units _airCrew;

	
//Adds the ability to have team joint players squad for control
// *** need to revist "removeAction" conditions
	
//_gunner addAction ["Come with me", { _this join (group player); group player selectLeader player}];
//_pilot addAction ["Come with me", { _this join (group player); group player selectLeader player}];



//Creates marker roughly near where the helicopter was "last seen"
_taskLocation = _wreckLocation	getPos [(random [2,5,8]) * 100, (random [2,5,8]) * 100];
createMarker ["Task", _taskLocation];
"Task" setMarkerShape "ELLIPSE";
"Task" setMarkerSize [_searchArea,_searchArea];
"Task" setMarkerBrush "SolidFull";
"Task" setMarkerAlpha .5;
"Task" setMarkerColor "ColorGreen";


//Creating task list for all playbable units (in theory this will work on dedicated server)
{
		crewTask = _x createSimpleTask ["Rescue Helicopter Crew"];
		crewTask setSimpleTaskDescription ["Rescue as many of the helicopter crew as you can","Rescue Crew", "Rescue Crew"];
		crewTask setSimpleTaskDestination _taskLocation;
		
		wreckTask = _x createSimpleTask ["Locate and Destroy Helicopter Wreck"];
		wreckTask setSimpleTaskDescription ["Locate and Destroy the wrecked helicopter to prevent enemy from seizing intel. The last known location of the helicopter is shown on the map.", "Destroy Wreck", "Destroy Wreck"];
		wreckTask setSimpleTaskDestination _taskLocation;
} forEach playableUnits;

_Wreck addMPEventHandler ["MPKilled", { wreckTask setTaskState "Succeeded";}];
//_Wreck addMPEventHandler ["MPKilled", {hint "Wreck Destroyed";}];



//SOME SORT OF ENEMY CREATION

if (_enemyEnable) then {};



//HERE'S WHERE I'M STUCK



//Not sure I need this, this is a legacy idea
_tasksComplete = 0;

//might not need this either, this is the beginnning of trouble
//if (isTouchingGround _pilot) then {_pilotDist = _pilot distance2D (getMarkerpos "ftravel_PassengerTerminal");};
//if (isTouchingGround _gunner) then {_gunnerDist = _gunner distance2D (getMarkerpos "ftravel_PassengerTerminal");};



//and I'm very stuck at this point.
/*
while {(alive _pilot) or (alive _gunner) or (alive _wreck)} do {

	if (isTouchingGround _pilot) then {_pilotDist = _pilot distance2D (getMarkerpos "ftravel_PassengerTerminal");};
	if (isTouchingGround _gunner_ then {_gunnerDist = _gunner distance2D (getMarkerpos "ftravel_PassengerTerminal");};
	
	if ( !alive _pilot) or (!alive _gunner) then {
		if ( !alive _pilot) && (!alive _gunner) then{
			_crewTask setTaskState "Failed";
			_tasksComplete = _tasksComplete + 1;
			}};
	
	if (!alive _Wreck) then { 
		_wreckTask setTaskState "Succeeded";
		_tasksComplete = _tasksComplete + 1;
		}
	
};	
*/

	

//legacy testing thing gonna delete
//waitUntil {(!alive _PD1Wreck)};



//once we'ere out of the loop I'll clean stuff up so this code can be re run randomly by the server





/*


sleep _cleanupTimer;

//Cleanup  markers and units
deleteMarker "WreckLocation";
deleteMarker "Task";
deleteVehicle _wreck;
deleteVehicle _pilot;
deleteVehicle _gunner;
*/



/* DISABLED FOR NOW

//Cleanup tasks for all players
{

	removeSimpleTask _crewTask;
	removeSimpleTask _wreckTask;
}forEach playableUnits;

*/


