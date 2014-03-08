///////////////////////////////////////////////////////////////////////////////////////////////////
//Camera Control
//
//parts from:
//Original Camera Script
//Linden Lab
//Dan Linden
//Hijacked by Penny Patton to show what SL looks like with better camera placement!
//Search script for "changedefault" to find the line you need to alter to change the default view you see when first attaching the HUD!
//
//parts from:
// Script Vitality - keeps the script itself and all scripts in same prim 
// running also in 'dead' areas, those areas where scrpts are not allowed.
// This works simply by taking avatar controls. 
// Author  Jenna Felton
// Version 1.0

//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: when reusing some older code
//04. Jan. 2014
//v1.0

//Files:
//CameraScript.lsl
//NAME OF NOTEDACRD
//
//
//Prequisites: ---
//Notecard format: when storing settings
//basic help:
//

//Changelog
//	NOTECARD NAME, LINK, GIT, SHORT DESCRIPTION, ETC.
//	TEXT

//bug:

//todo:
// 
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//FIRESTORM SPECIFIC DEBUG STUFF
//===============================================

//#define FSDEBUG
//#include "fs_debug.lsl"


//===============================================
//GLOBAL VARIABLES
//===============================================

//debug variables
//-----------------------------------------------
integer g_iDebugMode=FALSE; // set to TRUE to enable Debug messages


//user changeable variables
//-----------------------------------------------
integer g_iVerbose = TRUE;         // show more/less info during startup


//internal variables
//-----------------------------------------------
string g_sTitle = "SCRIPT NAME";			// title
string g_sVersion = "VERSION NUMBER";		// version
string g_sScriptName;


// Constants
integer iCONSTANT;

//SCRIPT MESSAGE MAP


// Variables
key g_kOwner;                      // object owner
key g_kUser;                       // key of last avatar to touch object
key g_kQuery = NULL_KEY;

integer CHANNEL; // dialog channel
list MENU_MAIN = ["Centre", "Right", "Left", "Cam ON", "Cam OFF"]; // the main menu
list MENU_2 = ["More...", "...Back"]; // menu 2
 
integer on = FALSE;
integer flying;
integer falling;
integer spaz = 0;
integer trap = 0;
 

 
list LISTENERS; // list of hud channel handles we are listening for, for building lists
 
//===============================================
//PREDEFINED FUNCTIONS
//===============================================

//NG lets send pings here and listen for pong replys
SendCommand(key id)
{
    if (llGetListLength(LISTENERS) >= 60) return;  // lets not cause "too many listen" error
    
    integer channel = getPersonalChannel(id, 1111);
    llRegionSayTo(id, channel, (string)id+ ":ping");
    LISTENERS += [ llListen(channel, "", NULL_KEY, "" )] ;// if we have a reply on the channel lets see what it is.
    llSetTimerEvent(5.0);// no reply by now, lets kick off the timer
}

//===============================================================================
//= parameters   :    string    sMsg    message string received
//=
//= return        :    none
//=
//= description  :    output debug messages
//=
//===============================================================================
Debug(string sMsg)
{
    if (!g_iDebugMode) return;
    llOwnerSay("DEBUG: "+ g_sScriptName + "; " + sMsg);
}

//most important function
//-----------------------------------------------
 
take_camera_control(key agent)
{
    llOwnerSay("take_camera_control"); // say function name for debugging
    llOwnerSay( (string)agent);
    llRequestPermissions(agent, PERMISSION_CONTROL_CAMERA);
    llSetCameraParams([CAMERA_ACTIVE, 1]); // 1 is active, 0 is inactive
    on = TRUE;
}
 
release_camera_control(key agent)
{
    llOwnerSay("release_camera_control"); // say function name for debugging
    llSetCameraParams([CAMERA_ACTIVE, 0]); // 1 is active, 0 is inactive
    llReleaseCamera(agent);
    on = FALSE;
}
 
focus_on_me()
{
    llOwnerSay("focus_on_me"); // say function name for debugging
    //    llClearCameraParams(); // reset camera to default
    vector here = llGetPos();
    llSetCameraParams([
        CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
        CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
        CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
        CAMERA_DISTANCE, 0.0, // ( 0.5 to 10) meters
        CAMERA_FOCUS, here, // region relative position
        CAMERA_FOCUS_LAG, 0.0 , // (0 to 3) seconds
        CAMERA_FOCUS_LOCKED, TRUE, // (TRUE or FALSE)
        CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
//        CAMERA_PITCH, 80.0, // (-45 to 80) degrees
        CAMERA_POSITION, here + <4.0,4.0,4.0>, // region relative position
        CAMERA_POSITION_LAG, 0.0, // (0 to 3) seconds
        CAMERA_POSITION_LOCKED, TRUE, // (TRUE or FALSE)
        CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
        CAMERA_FOCUS_OFFSET, ZERO_VECTOR // <-10,-10,-10> to <10,10,10> meters
    ]);
}
 
default_cam()
{
//    llOwnerSay("default_cam"); // say function name for debugging
   llClearCameraParams(); // reset camera to default
    llSetCameraParams([CAMERA_ACTIVE, 1]);


}
 
 
shoulder_cam2()
{
    llOwnerSay("Right Shoulder"); // say function name for debugging
    default_cam();
    llSetCameraParams([
        CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
        CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
        CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
        CAMERA_DISTANCE, 0.5, // ( 0.5 to 10) meters
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
}
 
 
shoulder_cam()
{
    llOwnerSay("shoulder_cam"); // say function name for debugging
    default_cam();
    llSetCameraParams([
        CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
        CAMERA_BEHINDNESS_ANGLE, 5.0, // (0 to 180) degrees
        CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
        CAMERA_DISTANCE, 0.5, // ( 0.5 to 10) meters
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
}
 
shoulder_cam3()
{
    llOwnerSay("Left Shoulder"); // say function name for debugging
    default_cam();
    llSetCameraParams([
        CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
        CAMERA_BEHINDNESS_ANGLE, 5.0, // (0 to 180) degrees
        CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
        CAMERA_DISTANCE, 0.5, // ( 0.5 to 10) meters
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
}
 
centre_cam()
{
    llOwnerSay("centre_cam"); // say function name for debugging
    default_cam();
    llSetCameraParams([
        CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
        CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
        CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
        CAMERA_DISTANCE, 0.5, // ( 0.5 to 10) meters
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
}
 
 
drop_camera_5_seconds()
{
    llOwnerSay("drop_camera_5_seconds"); // say function name for debugging
    llSetCameraParams([
        CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
        CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
        CAMERA_BEHINDNESS_LAG, 0.5, // (0 to 3) seconds
        CAMERA_DISTANCE, 3.0, // ( 0.5 to 10) meters
        //CAMERA_FOCUS, <0.0,0.0,5.0>, // region relative position
        CAMERA_FOCUS_LAG, 2.0, // (0 to 3) seconds
        CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
        CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
        CAMERA_PITCH, 0.0, // (-45 to 80) degrees
        //CAMERA_POSITION, <0.0,0.0,0.0>, // region relative position
        CAMERA_POSITION_LAG, 0.05, // (0 to 3) seconds
        CAMERA_POSITION_LOCKED, TRUE, // (TRUE or FALSE)
        CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
        CAMERA_FOCUS_OFFSET, <0.0,0.0,0.0> // <-10,-10,-10> to <10,10,10> meters
    ]);
    llSleep(5);
    default_cam();
}
 
 
 
worm_cam()
{
    llOwnerSay("worm_cam"); // say function name for debugging
    llSetCameraParams([
        CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
        CAMERA_BEHINDNESS_ANGLE, 180.0, // (0 to 180) degrees
        CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
        CAMERA_DISTANCE, 8.0, // ( 0.5 to 10) meters
        //CAMERA_FOCUS, <0.0,0.0,5.0>, // region relative position
        CAMERA_FOCUS_LAG, 0.0 , // (0 to 3) seconds
        CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
        CAMERA_FOCUS_THRESHOLD, 4.0, // (0 to 4) meters
        CAMERA_PITCH, -45.0, // (-45 to 80) degrees
        //CAMERA_POSITION, <0.0,0.0,0.0>, // region relative position
        CAMERA_POSITION_LAG, 1.0, // (0 to 3) seconds
        CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
        CAMERA_POSITION_THRESHOLD, 1.0, // (0 to 4) meters
        CAMERA_FOCUS_OFFSET, <0.0,0.0,0.0> // <-10,-10,-10> to <10,10,10> meters
    ]);
}
 
spaz_cam()
{
    llOwnerSay("spaz_cam for 5 seconds"); // say function name for debugging
    float i;
    for (i=0; i< 50; i+=1)
    {
        vector xyz = llGetPos() + <llFrand(80.0) - 40, llFrand(80.0) - 40, llFrand(10.0)>;
        //        llOwnerSay((string)xyz);
        vector xyz2 = llGetPos() + <llFrand(80.0) - 40, llFrand(80.0) - 40, llFrand(10.0)>;
        llSetCameraParams([
            CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
            CAMERA_BEHINDNESS_ANGLE, 180.0, // (0 to 180) degrees
            CAMERA_BEHINDNESS_LAG, llFrand(3.0), // (0 to 3) seconds
            CAMERA_DISTANCE, llFrand(10.0), // ( 0.5 to 10) meters
            //CAMERA_FOCUS, xyz, // region relative position
            CAMERA_FOCUS_LAG, llFrand(3.0), // (0 to 3) seconds
            CAMERA_FOCUS_LOCKED, TRUE, // (TRUE or FALSE)
            CAMERA_FOCUS_THRESHOLD, llFrand(4.0), // (0 to 4) meters
            CAMERA_PITCH, llFrand(125.0) - 45, // (-45 to 80) degrees
            CAMERA_POSITION, xyz2, // region relative position
            CAMERA_POSITION_LAG, llFrand(3.0), // (0 to 3) seconds
            CAMERA_POSITION_LOCKED, TRUE, // (TRUE or FALSE)
            CAMERA_POSITION_THRESHOLD, llFrand(4.0), // (0 to 4) meters
            CAMERA_FOCUS_OFFSET, <llFrand(20.0) - 10, llFrand(20.0) - 10, llFrand(20) - 10> // <-10,-10,-10> to <10,10,10> meters
        ]);
        llSleep(0.1);
    }
    default_cam();
}
 
spin_cam()
{
    llSetCameraParams([
        CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
        CAMERA_BEHINDNESS_ANGLE, 180.0, // (0 to 180) degrees
        CAMERA_BEHINDNESS_LAG, 0.5, // (0 to 3) seconds
        //CAMERA_DISTANCE, 10.0, // ( 0.5 to 10) meters
        //CAMERA_FOCUS, <0.0,0.0,5.0>, // region relative position
        CAMERA_FOCUS_LAG, 0.05 , // (0 to 3) seconds
        CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
        CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
        CAMERA_PITCH, 30.0, // (-45 to 80) degrees
        //CAMERA_POSITION, <0.0,0.0,0.0>, // region relative position
        CAMERA_POSITION_LAG, 0.0, // (0 to 3) seconds
        CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
        CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
        CAMERA_FOCUS_OFFSET, <0.0,0.0,0.0> // <-10,-10,-10> to <10,10,10> meters
    ]);
 
    float i;
    vector camera_position;
    for (i=0; i< 2*TWO_PI; i+=.05)
    {
        camera_position = llGetPos() + <0.0, 4.0, 0.0> * llEuler2Rot(<0.0, 0.0, i>);
        llSetCameraParams([CAMERA_POSITION, camera_position]);
    }
    default_cam();
}
 
setup_listen()
{
    llListenRemove(1);
    CHANNEL = -50000 -llRound(llFrand(1) * 100000);
    integer x = llListen(CHANNEL, "", "", ""); // listen for dialog answers
}


//===============================================
//===============================================
//MAIN
//===============================================
//===============================================

//-----------------------------------------------

default
{

		state_entry() {
		g_kOwner = llGetOwner();
		g_sScriptName = llGetScriptName();
		
        Debug((string)llGetFreeMemory() + " bytes free");
		llWhisper(0, g_sTitle +" ("+ g_sVersion +") Enhancements by "+g_sAuthor);
	    llWhisper(0, "INSTRUCTIONS");
		if (g_iVerbose) llWhisper(0, "Loading notecard...");
		;
		        listener=llListen(getPersonalChannel(wearer,1111),"","",""); //lets listen here

	}
	
	timer()//clear things after ping
    {
        llSetTimerEvent(0);
        AGENTS = [];
        integer n = llGetListLength(LISTENERS) - 1;
        for (; n >= 0; n--)
        {
            llListenRemove(llList2Integer(LISTENERS,n));
        }
        LISTENERS = [];
    }
	

	on_rez(integer i) {
		;
	}
	
	changed(integer change) {
		if(change & CHANGED_INVENTORY) ;
		if(change & CHANGED_REGION) ;
		if(change & CHANGED_OWNER) llResetScript();
	}

//let it run in noscript areas
//-----------------------------------------------
	run_time_permissions(integer perms) {
		if (perms & PERMISSION_TAKE_CONTROLS) { 
			llOwnerSay("Automatic Group Changer runs in noscript-areas");
			llTakeControls(CONTROL_DOWN, TRUE, TRUE);
        }
	}
	
	//  This is the magic. Even if empty the event handler makes the script
	//  to keep the avatar's control. The script itself does not use it.
    control(key name, integer levels, integer edges)
    {
        ;
    }
	
	//make sure that we always have permissions
    timer() {
        if(llGetPermissions() & PERMISSION_TAKE_CONTROLS) return;
        llRequestPermissions(kOwner, PERMISSION_TAKE_CONTROLS);
    }

	
    state_entry()
    {
        llSitTarget(<0.0, 0.0, 0.1>, ZERO_ROTATION);
        setup_listen();
        llSetTimerEvent(2.0);
    }
 
//listen for linked messages from other RealFire scripts and devices
//-----------------------------------------------
    link_message(integer sender_num, integer num, string str, key id)
    {
        if(str == "cam")
        {
            integer perm = llGetPermissions();
            if (perm & PERMISSION_CONTROL_CAMERA)
                llDialog(id, "What do you want to do?", MENU_MAIN, CHANNEL); // present dialog on click
        }
    }
 
//user interaction
//listen to usercommands
//-----------------------------------------------
    listen(integer channel, string name, key id, string message)
    {
        if (~llListFindList(MENU_MAIN + MENU_2, [message]))  // verify dialog choice
//        if (~llListFindList(MENU_MAIN, [message]))  // verify dialog choice
        {
//            llOwnerSay(name + " picked the option '" + message + "'."); // output the answer
            if (message == "More...")
                llDialog(id, "Pick an option!", MENU_2, CHANNEL); // present submenu on request
            else if (message == "...Back")
                llDialog(id, "What do you want to do?", MENU_MAIN, CHANNEL); // present main menu on request to go back
 
 
            else if (message == "Cam ON")
            {
                take_camera_control(id);
            }
 
            else if (message == "Cam OFF")
            {
                release_camera_control(id);
            }
 
            else if (message == "Default")
            {
                default_cam();
            }
 
            else if (message == "Right")
            {
                shoulder_cam2();
            }
 
            else if (message == "Worm Cam")
            {
                worm_cam();
            }
 
            else if (message == "Centre")
            {
                centre_cam();
            }
 
            else if (message == "Left")
            {
                shoulder_cam3();
            }
 
            else if (message == "Shoulder")
            {
                shoulder_cam();
            }
 
            else if (message == "Drop Cam")
            {
                drop_camera_5_seconds();
            }
 
            else if (message == "Trap Toggle")
            {
                trap = !trap;
                if (trap == 1) {
                    llOwnerSay("trap is on");
                }
                else {
                    llOwnerSay("trap is off");
                }
            }
 
            else if (message == "Spin Cam")
            {
                spin_cam();
            }
 
        } else
        llOwnerSay(name + " picked invalid option '" + llToLower(message) + "'."); // not a valid dialog choice
    }
 
    run_time_permissions(integer perm) {
        if (perm & PERMISSION_CONTROL_CAMERA) {
            llSetCameraParams([CAMERA_ACTIVE, 1]); // 1 is active, 0 is inactive
            llOwnerSay("Camera permissions have been taken");
        }
    }
 
    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            key agent = llAvatarOnSitTarget();
            if (agent)
            {
                setup_listen();
                llRequestPermissions(agent, PERMISSION_CONTROL_CAMERA);
            }
        }
    }
 
    attach(key agent)
    {
        if (agent)
        {
            setup_listen();
            llRequestPermissions(agent, PERMISSION_CONTROL_CAMERA);
            shoulder_cam();
            //changedefault The above is what you need to change to change the default camera view you see whenever you first attach the HUD. For example, change it to centre_cam(); to have the default view be centered behind your avatar!
        }
    }
 
    timer()
    {
        if (trap == 1)
        {
            focus_on_me();
        }
    }
	
//-----------------------------------------------
//END STATE: default
//-----------------------------------------------	
}