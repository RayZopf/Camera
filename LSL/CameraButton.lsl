// LSL script generated: Camera.LSL.CameraButton.lslp Mon Mar 10 18:10:52 Mitteleuropäische Zeit 2014

string g_sScriptName;



default {

	state_entry() {
        (g_sScriptName = llGetScriptName());
        integer rc = 0;
        (rc = llSetMemoryLimit(8192));
        
    }

	
	
	touch_start(integer num_detected) {
        llMessageLinked(1,0,"cam",llDetectedKey(0));
    }
}
