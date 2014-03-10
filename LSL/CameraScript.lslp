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
//
//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: when reusing some older code
//10. Mrz. 2014
//v1.2
//

//Files:
//CameraScript.lsl
//
//NAME OF NOTEDACRD
//
//
//Prequisites: ----
//Notecard format: ----
//basic help: ----
//
//Changelog
// Formatting

//FIXME: llListens() - too many listeners

//TODO: ----
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//GLOBAL VARIABLES
//===============================================

//user changeable variables
//-----------------------------------------------
integer verbose = TRUE;         // show more/less info during startup


//internal variables
//-----------------------------------------------
string g_sTitle = "CameraScript";     // title
string g_sVersion = "1.2";            // version
string g_sScriptName;
string g_sAuthors = "Zopf";

// Constants
list MENU_MAIN = ["Centre", "Right", "Left", "Cam ON", "Cam OFF"]; // the main menu
list MENU_2 = ["More...", "...Back"]; // menu 2

//SCRIPT MESSAGE MAP
integer CH; // dialog channel

// Variables
key g_kOwner;                      // object owner
key g_kUser;                       // key of last avatar to touch object
key g_kQuery = NULL_KEY;

integer g_iHandle = 0;
integer g_iOn = FALSE;
integer flying;
integer falling;
integer spaz = 0;
integer trap = 0;


list LISTENERS; // list of hud channel handles we are listening for, for building lists


//===============================================
//LSLForge MODULES
//===============================================

//general modules
//-----------------------------------------------
$import Debug2.lslm(m_sScriptName=g_sScriptName);
$import MemoryManagement2.lslm(m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_iVerbose=verbose);

//project specific modules
//-----------------------------------------------


//===============================================
//PREDEFINED FUNCTIONS
//===============================================
/*
//XXX
//NG lets send pings here and listen for pong replys
SendCommand(key id)
{
	if (llGetListLength(LISTENERS) >= 60) return;  // lets not cause "too many listen" error

	integer channel = getPersonalChannel(id, 1111);
	llRegionSayTo(id, channel, (string)id+ ":ping");
	LISTENERS += [ llListen(channel, "", NULL_KEY, "" )] ;// if we have a reply on the channel lets see what it is.
	llSetTimerEvent(5.0);// no reply by now, lets kick off the timer
}
*/

initExtension(integer conf)
{
	setupListen();
	if (conf) llRequestPermissions(g_kOwner, PERMISSION_CONTROL_CAMERA);
	llOwnerSay(g_sTitle +" ("+ g_sVersion +") Enhancements by "+g_sAuthors);
	if (verbose) MemInfo(FALSE);
}


// pragma inline 
//most important function
//-----------------------------------------------
takeCamCtrl(key id)
{
	llOwnerSay("takeCamCtrl"); // say function name for debugging
	llOwnerSay( (string)id);
	llRequestPermissions(id, PERMISSION_CONTROL_CAMERA);
	llSetCameraParams([CAMERA_ACTIVE, 1]); // 1 is active, 0 is inactive
	g_iOn = TRUE;
}


// pragma inline
releaseCamCtrl(key id)
{
	llOwnerSay("releaseCamCtrl"); // say function name for debugging
	llClearCameraParams();
	g_iOn = FALSE;
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


defCam()
{
//    llOwnerSay("defCam"); // say function name for debugging
	llClearCameraParams(); // reset camera to default
	llSetCameraParams([CAMERA_ACTIVE, 1]);
}


// pragma inline
shoulderCamRight()
{
	llOwnerSay("Right Shoulder"); // say function name for debugging
	defCam();
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


shoulderCam()
{
	llOwnerSay("shoulderCam"); // say function name for debugging
	defCam();
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


// pragma inline
shoulderCamLeft()
{
	llOwnerSay("Left Shoulder"); // say function name for debugging
	defCam();
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

// pragma inline
centreCam()
{
	llOwnerSay("centreCam"); // say function name for debugging
	defCam();
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
	defCam();
}


wormCam()
{
	llOwnerSay("wormCam"); // say function name for debugging
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
	defCam();
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
	defCam();
}

 // pragma inline
setupListen()
{
	llListenRemove(1);
	llListenRemove(g_iHandle);
	CH = -50000 -llRound(llFrand(1) * 100000);
	g_iHandle = llListen(CH, "", g_kOwner, ""); // listen for dialog answers
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================

//-----------------------------------------------

default
{
/*
//XXX
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

//XXX
	on_rez(integer i)
	{
		;
	}

//XXX
	changed(integer change)
	{
		if(change & CHANGED_INVENTORY) ;
		if(change & CHANGED_REGION) ;
		if(change & CHANGED_OWNER) llResetScript();
	}

//XXX
//let it run in noscript areas
//-----------------------------------------------
	run_time_permissions(integer perms)
	{
		if (perms & PERMISSION_TAKE_CONTROLS) {
			llOwnerSay("Automatic Group Changer runs in noscript-areas");
			llTakeControls(CONTROL_DOWN, TRUE, TRUE);
		}
	}

//XXX
	//  This is the magic. Even if empty the event handler makes the script
	//  to keep the avatar's control. The script itself does not use it.
	control(key name, integer levels, integer edges)
	{
		;
	}

//XXX
	//make sure that we always have permissions
	timer()
	{
		if(llGetPermissions() & PERMISSION_TAKE_CONTROLS) return;
		llRequestPermissions(kOwner, PERMISSION_TAKE_CONTROLS);
	}
*/

	state_entry()
	{
		//debug=TRUE; // set to TRUE to enable Debug messages
		
		MemRestrict(24000, FALSE);
		g_kOwner = llGetOwner();
		g_sScriptName = llGetScriptName();
		if (debug) Debug("state_entry", TRUE, TRUE);

		initExtension(FALSE);
	}


//listen for linked messages from other scripts and devices
//-----------------------------------------------
	link_message(integer sender_num, integer num, string str, key id)
	{
		if(str == "cam") {
			integer perm = llGetPermissions();
			if (perm & PERMISSION_CONTROL_CAMERA) llDialog(id, "What do you want to do?", MENU_MAIN, CH); // present dialog on click
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
			if (message == "More...") llDialog(id, "Pick an option!", MENU_2, CH); // present submenu on request
			else if (message == "...Back") llDialog(id, "What do you want to do?", MENU_MAIN, CH); // present main menu on request to go back
			else if (message == "Cam ON") {
				takeCamCtrl(id);
			}
			else if (message == "Cam OFF") {
				releaseCamCtrl(id);
			}
			else if (message == "Default") {
				defCam();
			}
			else if (message == "Right") {
				shoulderCamRight();
			}
			else if (message == "Worm Cam") {
				wormCam();
			}
			else if (message == "Centre") {
				centreCam();
			}
			else if (message == "Left") {
				shoulderCamLeft();
			}
			else if (message == "Shoulder") {
				shoulderCam();
			}
			else if (message == "Drop Cam") {
				drop_camera_5_seconds();
			}
			else if (message == "Trap Toggle") {
				trap = !trap;
				if (trap == 1) {
					llOwnerSay("trap is on");
				} else {
					llOwnerSay("trap is off");
				}
			} else if (message == "Spin Cam") {
				spin_cam();
			}
		} else llOwnerSay(name + " picked invalid option '" + llToLower(message) + "'."); // not a valid dialog choice
	}


	run_time_permissions(integer perm) {
		if (perm & PERMISSION_CONTROL_CAMERA) {
			llSetCameraParams([CAMERA_ACTIVE, 1]); // 1 is active, 0 is inactive
			llOwnerSay("Camera permissions have been taken");
		}
	}


	changed(integer change)
	{
		if (change & CHANGED_LINK) {
			key id = llAvatarOnSitTarget();
			if (id) {
			initExtension(TRUE);
			}
		}
		if (change & CHANGED_OWNER) llResetScript();
	}


	attach(key id)
	{
		if (id == g_kOwner) {
			initExtension(TRUE);
			shoulderCam();
			//changedefault The above is what you need to change to change the default camera view you see whenever you first attach the HUD. For example, change it to centreCam(); to have the default view be centered behind your avatar!
		} else llResetScript();
	}

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}