// LSL script generated: Camera.LSL.CameraButton.lslp Mon Mar 10 17:08:27 Mitteleuropäische Zeit 2014
default {

	touch_start(integer num_detected) {
        llMessageLinked(1,0,"cam",llDetectedKey(0));
    }
}
