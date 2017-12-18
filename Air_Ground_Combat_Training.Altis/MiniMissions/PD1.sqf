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



//Public Variables
//Create group to add crew to
airCrew = createGroup west;
publicKilledCrew = 0;

//Finding suitable location to place wrecked helicopter
//*** Eventually needs blacklist locations or to check that it isn't too near enemy locations

_wreckLocation = [];

while {(count _wreckLocation) == 0} do {
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
	_randomSpot = _wreckLocation getPos[(floor random [(_minCrewDist), ((_minCrewDist + _maxCrewDist)/2),(_maxCrewDist)] ), ((floor random 90) * 4)];
	_crewPosition = _randomSpot findEmptyPosition[1,10];
};

//The stars of the show

for [{_i=1}, {_i<=_crewCount}, {_i=_i+1}] do
{
	"B_helicrew_F" createUnit [_crewPosition, airCrew];
};


//**** Eventually need to make sexier wounded/ treating setup. Would like to require team to bring advanced medical support
//removeAllWeapons _gunner;
//removeHeadgear _gunner;
//removeGoggles _gunner;

//_gunner playMove "AinjPpneMstpSnonWnonDnon";

//_gunner setUnconscious true;	
//_gunner setBleedingRemaining 10000;
//_gunner addAction["Provide Emergency Medicine", "_this setUnconscious false"];

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





//Setting up the crew members 

{
	_x removeItems "Firstaidkit";
	_x setUnitPosWeak "Middle";
	_x setCombatMode "GREEN";
	_x setDamage 0.5;
	_x setHitPointDamage ["hitBody", .5, true];
	_x setRank "PRIVATE";
	_x addAction ["Come with me", { _this join (group player); group player selectLeader player}]; //Need to revisit removeAction
	_x addMPEventHandler ["MPKilled", { publicKilledCrew = publicKilledCrew + 1; if (publicKilledCrew >= ((Count units airCrew))) then { crewTask setTaskState "Failed";};}];
										
} forEach units airCrew;


_Wreck addMPEventHandler ["MPKilled", { wreckTask setTaskState "Succeeded";}];




//SOME SORT OF ENEMY CREATION

if (_enemyEnable) then {};



