//Original Camera Script
//Linden Lab
//Dan Linden
//Hijacked by Penny Patton to show what SL looks like with better camera placement!
//Higherjacked by Core Taurog, 'cause I do what I'm told!

integer channel;
integer GESTURE_CHANNEL = 8374;

string TOGGLE_PERSPECTIVE = "Cycle";
string TOGGLE_DISTANCE = "Distance";
list MENU_MAIN = ["Left", "Center", "Right", "Cam ON", "Cam OFF", TOGGLE_PERSPECTIVE, TOGGLE_DISTANCE]; // the main menu

integer on = FALSE;
integer far = FALSE;
float NEAR_DISTANCE = 0.5;
float FAR_DISTANCE = 2.0;
float distance = NEAR_DISTANCE;

integer perspective = 0;

//An alternative icon set with darker colors is available as well. If you would like to try those, simply uncomment the currently commented SQUARE_CAMERA lines below, and comment out the current two.
string SQUARE_CAMERA_OFF = "99fbe5c9-276f-f5c1-7aae-ceb1a3fb3690";
//string SQUARE_CAMERA_OFF = "587fde27-58e6-31b0-bf0e-117708f96e9b";

string SQUARE_CAMERA_ON  = "4c328cae-3e7c-4821-8def-2fe0bedea25c";
//string SQUARE_CAMERA_ON  = "0a9ea110-32e9-27b1-dca9-c9eeae8f1acb";

integer
get_channel_id()
{
    integer chan = 0;
    do
    {
        chan = ((integer) llFrand(3) - 1) * ((integer) llFrand(2147483647)); 
    }
    while(chan == 0);

    return chan;
}

init()
{
    llSetTexture(SQUARE_CAMERA_OFF, ALL_SIDES);
    llRequestPermissions(llGetOwner(), PERMISSION_CONTROL_CAMERA);
    llClearCameraParams(); // reset camera to default
    llSetCameraParams([CAMERA_ACTIVE, 0]);
    llReleaseCamera(llGetOwner());
}

take_camera_control(key agent)
{
    //llOwnerSay("take_camera_control"); // say function name for debugging
    llRequestPermissions(agent, PERMISSION_CONTROL_CAMERA);
    llSetCameraParams([CAMERA_ACTIVE, 1]); // 1 is active, 0 is inactive
    on = TRUE;
    llSetTexture(SQUARE_CAMERA_ON, ALL_SIDES);
}
 
release_camera_control(key agent)
{
    //llOwnerSay("release_camera_control"); // say function name for debugging
    llSetCameraParams([CAMERA_ACTIVE, 0]); // 1 is active, 0 is inactive
    llReleaseCamera(agent);
    on = FALSE;
    llSetTexture(SQUARE_CAMERA_OFF, ALL_SIDES);
}
 
shoulder_cam_left()
{
    //llOwnerSay("Left Shoulder"); // say function name for debugging
    llSetTexture(SQUARE_CAMERA_ON, ALL_SIDES);
    llSetCameraParams([
        CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
        CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
        CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
        CAMERA_DISTANCE, distance, // ( 0.5 to 10) meters
        //CAMERA_FOCUS, <0.0,0.0,5.0>, // region relative position
        CAMERA_FOCUS_LAG, 0.01 , // (0 to 3) seconds
        CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
        CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
        CAMERA_PITCH, 15.0, // (-45 to 80) degrees
        //CAMERA_POSITION, <0.0,0.0,0.0>, // region relative position
        CAMERA_POSITION_LAG, 0.1, // (0 to 3) seconds
        CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
        CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
        CAMERA_FOCUS_OFFSET, <-0.5,0.5,0.75> // <-10,-10,-10> to <10,10,10> meters
    ]);
    perspective = -1;
}
 
center_cam()
{
    //llOwnerSay("center_cam"); // say function name for debugging
    llSetTexture(SQUARE_CAMERA_ON, ALL_SIDES);
    llSetCameraParams([
        CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
        CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
        CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
        CAMERA_DISTANCE, distance, // ( 0.5 to 10) meters
        //CAMERA_FOCUS, <0.0,0.0,5.0>, // region relative position
        CAMERA_FOCUS_LAG, 0.01 , // (0 to 3) seconds
        CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
        CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
        CAMERA_PITCH, 15.0, // (-45 to 80) degrees
        //CAMERA_POSITION, <0.0,0.0,0.0>, // region relative position
        CAMERA_POSITION_LAG, 0.1, // (0 to 3) seconds
        CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
        CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
        CAMERA_FOCUS_OFFSET, <-0.5,0,0.75> // <-10,-10,-10> to <10,10,10> meters
    ]);
    perspective = 0;
}
 
shoulder_cam_right()
{
    //llOwnerSay("Right Shoulder"); // say function name for debugging
    llSetTexture(SQUARE_CAMERA_ON, ALL_SIDES);
    llSetCameraParams([
        CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
        CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
        CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
        CAMERA_DISTANCE, distance, // ( 0.5 to 10) meters
        //CAMERA_FOCUS, <0.0,0.0,5.0>, // region relative position
        CAMERA_FOCUS_LAG, 0.01 , // (0 to 3) seconds
        CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
        CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
        CAMERA_PITCH, 15.0, // (-45 to 80) degrees
        //CAMERA_POSITION, <0.0,0.0,0.0>, // region relative position
        CAMERA_POSITION_LAG, 0.1, // (0 to 3) seconds
        CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
        CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
        CAMERA_FOCUS_OFFSET, <-0.5,-0.5,0.75> // <-10,-10,-10> to <10,10,10> meters
    ]);
    perspective = 1;
}

toggle_distance()
{
    if (far)
    {
        on = FALSE;
        far = FALSE;
    }
    else if (!far && !on)
    {
        on = TRUE;
        far = FALSE;
    }
    else
    {
        on = TRUE;
        far = TRUE;
    }

    if (far)
    {
        distance = FAR_DISTANCE;
    }
    else
    {
        distance = NEAR_DISTANCE;
    }

    set_perspective();
}

toggle_perspective()
{
    ++perspective;
    if (perspective > 1)
    {
        perspective = -1;
    }
    set_perspective();
}

set_perspective()
{
    if (!on)
    {
        release_camera_control(llGetOwner());
        return;
    }
    
    if (perspective == -1)
    {
        shoulder_cam_left();
    }
    else if (perspective == 0)
    {
        center_cam();
    }
    else if (perspective == 1)
    {
        shoulder_cam_right();
    }
    else
    {
        release_camera_control(llGetOwner());
    }
}

default
{
    state_entry()
    {
        channel = get_channel_id();
        init();
        if (llGetAttached() == 0)
        {
            state not_attached;
        }
        else
        {
            state ready;
        }
    }
    changed(integer change)
    {
        if (change & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}

state ready
{
    state_entry()
    {
        init();
        llListen(channel, "", NULL_KEY, "");
        llListen(GESTURE_CHANNEL, "", NULL_KEY, "");
        //If you would rather not have the HUD say anything when you equip it, comment out the line below.
        llOwnerSay("Listening for gesture commands on channel " + (string)GESTURE_CHANNEL);
    }

    touch_start(integer detected)
    {
        llDialog(llDetectedKey(0), "What do you want to do?", MENU_MAIN, channel); // present dialog on click
    }
 
    listen(integer channel, string name, key id, string message)
    {
        if (llGetOwner() != llGetOwnerKey(id))
        {
            return;
        }

        if (message == "Cam ON")
        {
            take_camera_control(id);
        }

        else if (message == "Cam OFF")
        {
            release_camera_control(id);
        }

        else if (message == "Right")
        {
            shoulder_cam_right();
        }

        else if (message == "Center")
        {
            center_cam();
        }

        else if (message == "Left")
        {
            shoulder_cam_left();
        }

        else if (message == TOGGLE_PERSPECTIVE)
        {
            toggle_perspective();
        }

        else if (message == TOGGLE_DISTANCE)
        {
            toggle_distance();
        }
    }
 
    run_time_permissions(integer perm) {
        if (perm & PERMISSION_CONTROL_CAMERA) {
            llSetCameraParams([CAMERA_ACTIVE, 1]); // 1 is active, 0 is inactive
            //llOwnerSay("Camera permissions have been taken");
        }
    }
 
    changed(integer change)
    {
        if (change & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
 
    attach(key id)
    {
        if (llGetAttached() == 0)
        {
            state not_attached;
        }
    }

}

state not_attached
{
    attach(key id)
    {
        if (llGetAttached() != 0)
        {
            state ready;
        }
    }
    changed(integer change)
    {
        if (change & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}
