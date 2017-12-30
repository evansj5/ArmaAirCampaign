//Script for placing heli crew and wreck
//Also assigns tasks to all players

//Ideally this code will continue to execute randomly on the server generating tasks for connected players
// my goal is to make a variety of these mini missions via script and then just have them randomly fire, possibly one at a time, possibly as multiples.



//Gotta be the server BRO
if (!isServer) exitWith {};

//Only allow one instance
if (PDRunning) exitWith {};




//Some constants to make tweaking easier
_cleanupTimer = 300;

//_base = _this select 0;
_base = "ftravel_PassengerTerminal";




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

crewCount = 2;
publicKilledCrew = 0;
publicCrewRescued = 0;

PDCount = PDCount + 1;
PDRunning = true;

wTaskName = "wTask" + str (PDCount);
cTaskName = "cTask" + str (PDCount);
rescueTask = false;

/*
RD_fnc_enemiesNear = 	{
						//_enemiesNear = [_base,_radius] call RD_fnc_enemiesNear;
						private _location = _this select 0;
						private _radius = _this select 1;

						_returnValue = false;

						_list = _location nearEntities ["Man", _radius];
						_nearEnemies = select {side _x == side "EAST"};

						_returnValue = false;
						if (_list > 0) then { _returnValue = true;};


						_returnValue;
};

*/


RD_fnc_pdCleanup = {

					//_cTask =  toLower ([cTaskName] call BIS_fnc_taskState);
					//_wTask =  toLower ([wTaskName] call BIS_fnc_taskState);
					hint "Running Cleanup";

					deleteMarker "Task";
					deleteMarker "WreckLocation";
					PDRunning = false;
					airCrew deleteGroupWhenEmpty true;
					//[wTaskName] call BIS_fnc_deleteTask;
					//[cTaskName] call BIS_fnc_deleteTask;

					deleteVehicle _Wreck;
					{
						deleteVehicle _x;
					}forEach units airCrew;




};

RD_fnc_checkTasks = {

						_cTask =  toLower ([cTaskName] call BIS_fnc_taskState);
						_wTask =  toLower ([wTaskName] call BIS_fnc_taskState);
						if (((_cTask == "succeeded") or (_cTask == "failed")) && (_wTask == "succeeded") ) then {call RD_fnc_pdCleanup;};



};







RD_fnc_setTasks = {
					
					hint "SET TASKS RUNNING";
					if (publicKilledCrew >= crewCount) then { [cTaskName,"FAILED", true] call BIS_fnc_taskSetState;};

					if (!alive _Wreck) then {[wTaskName,"SUCCEEDED", true] call BIS_fnc_taskSetState;};

					//if units in trigger >= units in air crew then blah blah blah
					if (rescueTask) then {cTaskName, "SUCCEEDED", true} call BIS_fnc_taskState;};

					call RD_fnc_checkTasks;








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
/*
for [{_i=1}, {_i<=_crewCount}, {_i=_i+1}] do
{
	"B_helicrew_F" createUnit [_crewPosition, airCrew];
};
*/

pilot = airCrew createUnit ["B_helicrew_F", _crewPosition,[],0,"FORM"];
coPilot = airCrew createUnit ["B_helicrew_F", _crewPosition,[],0,"FORM"];






//Creates marker roughly near where the helicopter was "last seen"
_taskLocation = _wreckLocation	getPos [(random [2,5,8]) * 100, (random [2,5,8]) * 100];
createMarker ["Task", _taskLocation];
"Task" setMarkerShape "ELLIPSE";
"Task" setMarkerSize [_searchArea,_searchArea];
"Task" setMarkerBrush "SolidFull";
"Task" setMarkerAlpha .3;
"Task" setMarkerColor "ColorGreen";



// New Task Creation System
[west,[wTaskName],["Locate and destroy the damaged vehicle","Destroy Wreck","Destroy Wreck"],(getmarkerPos "Task"),true,0,true,"destroy",true] call BIS_fnc_taskCreate;
[west,[cTaskName],["Locate and rescue as many of the vehicle crew as you can","Rescue Crew","Rescue Crew"],(getmarkerPos "Task"),true,0,true,"meet",true] call BIS_fnc_taskCreate;




// ["crewTask","FAILED", true] call BIS_fnc_taskSetState;



//Setting up the crew members


{

	_x removeItems "Firstaidkit";
	_x setUnitPosWeak "Middle";
	_x setCombatMode "GREEN";
	_x setDamage 0.5;
	_x setHitPointDamage ["hitBody", .5, true];
	_x setRank "PRIVATE";
	_x addAction ["Come with me", { _this join (group player); group player selectLeader player}]; //Need to revisit removeAction
	//_x addMPEventHandler ["MPKilled", { publicKilledCrew = publicKilledCrew + 1; if (publicKilledCrew >= ((Count units airCrew))) then { crewTask setTaskState "Failed";}; null = execVM "MiniMissions\CleanUp_PD.sqf";}];
	_x addMPEventHandler ["MPKilled", { publicKilledCrew = publicKilledCrew + 1; call RD_fnc_setTasks}];


} forEach units airCrew;


_Wreck addMPEventHandler ["MPKilled", {call RD_fnc_setTasks;}];

_rescue = createTrigger ["EMPTYDETECTOR", getmarkerPos _base,true];
_rescue setTriggerArea [50,50,0,false];
_rescue setTriggerActivation ["WEST", "PRESENT",true];
_rescue setTriggerStatements ["{[thisTrigger, _x]call BIS_fnc_inTrigger} count [pilot, coPilot] >= (crewCount - publicKilledCrew);","rescueTask = true; call RD_fnc_setTasks;",""];












//SOME SORT OF ENEMY CREATION

if (_enemyEnable) then {};



