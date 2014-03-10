// LSL script generated: Camera.LSL.CameraButton.lslp Mon Mar 10 13:50:44 Mitteleuropäische Zeit 2014
default {

    touch_start(integer total_number) {
        llMessageLinked(1,0,"cam",llDetectedKey(0));
    }
}
