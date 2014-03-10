// LSL script generated: Camera.LSL.CameraButton.lslp Mon Mar 10 18:20:21 Mitteleuropäische Zeit 2014




default {

	state_entry() {
        integer rc = 0;
        (rc = llSetMemoryLimit(8192));
        
    }



	touch_start(integer num_detected) {
        llMessageLinked(1,0,"cam",llDetectedKey(0));
    }
}
