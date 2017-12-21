
_cTask =  taskState crewTask;
_wTask =  taskState wreckTask;

if ((_cTask == "Succeeded" or _cTask == "Failed") && (_wTask == "Succeeded" or _wTask == "Failed")) then {
	deleteMarker "Task";
	deleteMarker "WreckLocation";
		
	airCrew deleteGroupWhenEmpty true;

	{
		deleteVehicle _x;
	}forEach units airCrew;

	};