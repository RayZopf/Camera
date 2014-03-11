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
//Additions: Abillity to save cam positions
//11. Mrz. 2014
//v1.44
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
// LSL Forge modules
// code cleanup

//FIXME: on script changes, one need to reattach HUD to get workinh cam menu
//FIXME: on first start, using "off" throws script error: Script trying to clear camera parameters but PERMISSION_CONTROL_CAMERA permission not set!

//TODO: add notecard, so one can set up camera views per specific place
//TODO: reset view on teleport if it is on a presaved one - save positions as strided list together with SIM to make more persistent
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//GLOBAL VARIABLES
//===============================================

//user changeable variables
//-----------------------------------------------
integer verbose;         // show more/less info during startup

//SCRIPT MESSAGE MAP
integer CH; // dialog channel


//internal variables
//-----------------------------------------------
string g_sTitle = "CameraScript";     // title
string g_sVersion = "1.44";            // version
string g_sScriptName;
string g_sAuthors = "Dan Linden, Penny Patton, Zopf";

// Constants
list MENU_MAIN = ["More...", "---", "CLOSE",
	"Left", "Centre", "Right",
	"ON", "OFF", "---"]; // the main menu
//list MENU_2 = ["...Back", "---", "CLOSE", "Worm", "Drop", "Spin"]; // menu 2, commented out, as long as iy only used once


// Variables
key g_kOwner;                      // object owner
//key g_kUser;                       // key of last avatar to touch object
//key g_kQuery = NULL_KEY;
float g_fTouchTimer = 1.3;

integer g_iHandle = 0;
integer g_iOn = FALSE;
integer flying;
integer falling;
integer spaz = 0;
integer trap = 0;

integer g_iNr;
integer g_iMsg = TRUE;
vector g_vPos1;
vector g_vFoc1;
vector g_vPos2;
vector g_vFoc2;
integer g_iCamPos = FALSE;


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

initExtension(integer conf)
{
	setupListen();
	if (conf) llRequestPermissions(g_kOwner, PERMISSION_CONTROL_CAMERA | PERMISSION_TRACK_CAMERA);
	llOwnerSay(g_sTitle +" ("+ g_sVersion +") written/enhanced by "+g_sAuthors+"\nHUD listens on channel: "+(string)CH);
	if (verbose) MemInfo(FALSE);
}


// pragma inline 
//most important function
//-----------------------------------------------
takeCamCtrl(key id)
{
	if (verbose) llOwnerSay("take CamCtrl\nAvatar key: "+(string)id); // say function name for debugging
	llRequestPermissions(id, PERMISSION_CONTROL_CAMERA | PERMISSION_TRACK_CAMERA);
	llSetCameraParams([CAMERA_ACTIVE, TRUE]); // 1 is active, 0 is inactive
	g_iOn = TRUE;
}


// pragma inline
releaseCamCtrl(key id)
{
	llOwnerSay("release CamCtrl"); // say function name for debugging
	llClearCameraParams();
	g_iOn = FALSE;
}


resetCamPos()
{
	g_vPos1 = ZERO_VECTOR;
	g_vFoc1 = ZERO_VECTOR;
	g_vPos2 = ZERO_VECTOR;
	g_vFoc2 = ZERO_VECTOR;
	g_iCamPos = FALSE;
	defCam();
}


defCam()
{
	shoulderCamRight();
	//changedefault The above is what you need to change to change the default camera view you see whenever you first attach the HUD. For example, change it to centreCam(); to have the default view be centered behind your avatar!
}


focus_on_me()
{
	if (verbose) llOwnerSay("focus_on_me"); // say function name for debugging
	llClearCameraParams(); // reset camera to default
	vector here = llGetPos();
	llSetCameraParams([
		CAMERA_ACTIVE, TRUE, // 1 is active, 0 is inactive
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


// pragma inline
shoulderCamRight()
{
	if (verbose) llOwnerSay("Right Shoulder"); // say function name for debugging
	llClearCameraParams(); // reset camera to default
	llSetCameraParams([
		CAMERA_ACTIVE, TRUE, // 1 is active, 0 is inactive
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


// pragma inline
shoulderCam()
{
	if (verbose) llOwnerSay("Shoulder Cam"); // say function name for debugging
	llClearCameraParams(); // reset camera to default
	llSetCameraParams([
		CAMERA_ACTIVE, TRUE, // 1 is active, 0 is inactive
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
	if (verbose) llOwnerSay("Left Shoulder"); // say function name for debugging
	llClearCameraParams(); // reset camera to default
	llSetCameraParams([
		CAMERA_ACTIVE, TRUE, // 1 is active, 0 is inactive
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
	if (verbose) llOwnerSay("Center Cam"); // say function name for debugging
	llClearCameraParams(); // reset camera to default
	llSetCameraParams([
		CAMERA_ACTIVE, TRUE, // 1 is active, 0 is inactive
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


// pragma inline
dropCam()
{
	if (verbose) llOwnerSay("drop camera 5 seconds"); // say function name for debugging
	llSetCameraParams([
		CAMERA_ACTIVE, TRUE, // 1 is active, 0 is inactive
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


// pragma inline
wormCam()
{
	if (verbose) llOwnerSay("Worm Cam"); // say function name for debugging
	llClearCameraParams(); // reset camera to default
	llSetCameraParams([
		CAMERA_ACTIVE, TRUE, // 1 is active, 0 is inactive
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
	if (verbose) llOwnerSay("spaz_cam for 5 seconds"); // say function name for debugging
	float i;
	for (i=0; i< 50; i+=1)
	{
		vector xyz = llGetPos() + <llFrand(80.0) - 40, llFrand(80.0) - 40, llFrand(10.0)>;
		//        llOwnerSay((string)xyz);
		vector xyz2 = llGetPos() + <llFrand(80.0) - 40, llFrand(80.0) - 40, llFrand(10.0)>;
		llSetCameraParams([
			CAMERA_ACTIVE, TRUE, // 1 is active, 0 is inactive
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


// pragma inline
spinCam()
{
	llClearCameraParams(); // reset camera to default
	llSetCameraParams([
		CAMERA_ACTIVE, TRUE, // 1 is active, 0 is inactive
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
	//CH = -50000 -llRound(llFrand(1) * 100000);
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
		verbose = TRUE;
		CH = -987444;
		
		g_kOwner = llGetOwner();
		g_sScriptName = llGetScriptName();
		
		MemRestrict(32000, FALSE);
		if (debug) Debug("state_entry", TRUE, TRUE);

		initExtension(FALSE);
	}

/*
//listen for linked messages from other scripts and devices
//-----------------------------------------------
	link_message(integer sender_num, integer num, string str, key id)
	{
		if(str == "cam") {
			integer perm = llGetPermissions();
			if (perm & PERMISSION_CONTROL_CAMERA) llDialog(id, "What do you want to do?", MENU_MAIN, CH); // present dialog on click
		}
	}
*/

	touch_start(integer num_detected)
	{
		if (verbose) llOwnerSay("*Long touch on colored buttons, to save current view*");
		llResetTime();
		g_iNr= llDetectedLinkNumber(0);
		if (debug) Debug("prim/link number: "+ (string)g_iNr, FALSE, FALSE);
	}


	touch(integer num_detected)
	{
		if (g_iMsg && llGetTime() > g_fTouchTimer) {
			if (3 == g_iNr || 4 == g_iNr) llOwnerSay("Cam position saved");
				else if (5 == g_iNr) llOwnerSay("Saved cam position deleted");
			g_iMsg = FALSE;
		}
	}

	touch_end(integer num_detected)
	{
		g_iMsg = TRUE;
		integer perm = llGetPermissions();
		if (perm & PERMISSION_CONTROL_CAMERA) {
			if (llGetTime() < g_fTouchTimer) {
				if (2 == g_iNr) {
					// not using key of num_detected avi, as this is a HUD and we only want to talk to owner
					llDialog(g_kOwner, "What do you want to do?", MENU_MAIN, CH); // present dialog on click
				}
				else if (3 == g_iNr) {
					llClearCameraParams(); // reset camera to default
					llSetCameraParams([
						CAMERA_ACTIVE, TRUE, // 1 is active, 0 is inactive
						//CAMERA_BEHINDNESS_ANGLE, 180.0, // (0 to 180) degrees
						//CAMERA_BEHINDNESS_LAG, 0.5, // (0 to 3) seconds
						//CAMERA_DISTANCE, 10.0, // ( 0.5 to 10) meters
						CAMERA_FOCUS, g_vFoc1, // region relative position
						CAMERA_FOCUS_LAG, 0.0, // (0 to 3) seconds
						CAMERA_FOCUS_LOCKED, TRUE, // (TRUE or FALSE)
						//CAMERA_FOCUS_OFFSET, <0.0,0.0,0.0>, // <-10,-10,-10> to <10,10,10> meters
						//CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
						//CAMERA_PITCH, 30.0, // (-45 to 80) degrees
						CAMERA_POSITION, g_vPos1, // region relative position
						CAMERA_POSITION_LAG, 0.0, // (0 to 3) seconds
						CAMERA_POSITION_LOCKED, TRUE // (TRUE or FALSE)
						//CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
					]);
					g_iCamPos = TRUE;
					if (debug) Debug("restored pos: "+(string)g_vPos1+" foc: "+(string)g_vFoc1, FALSE,FALSE);
				}
				else if (4 == g_iNr) {
					llClearCameraParams(); // reset camera to default
					llSetCameraParams([
						CAMERA_ACTIVE, TRUE, // 1 is active, 0 is inactive
						//CAMERA_BEHINDNESS_ANGLE, 180.0, // (0 to 180) degrees
						//CAMERA_BEHINDNESS_LAG, 0.5, // (0 to 3) seconds
						//CAMERA_DISTANCE, 10.0, // ( 0.5 to 10) meters
						CAMERA_FOCUS, g_vFoc2, // region relative position
						CAMERA_FOCUS_LAG, 0.0, // (0 to 3) seconds
						CAMERA_FOCUS_LOCKED, TRUE, // (TRUE or FALSE)
						//CAMERA_FOCUS_OFFSET, <0.0,0.0,0.0>, // <-10,-10,-10> to <10,10,10> meters
						//CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
						//CAMERA_PITCH, 30.0, // (-45 to 80) degrees
						CAMERA_POSITION, g_vPos2, // region relative position
						CAMERA_POSITION_LAG, 0.0, // (0 to 3) seconds
						CAMERA_POSITION_LOCKED, TRUE // (TRUE or FALSE)
						//CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
					]);
					g_iCamPos = TRUE;
					if (debug) Debug("restored pos: "+(string)g_vPos2+" foc: "+(string)g_vFoc2, FALSE,FALSE);
				}
				else if (5 == g_iNr) defCam();
			} else {
				if (3 ==g_iNr) {
					g_vPos1 = llGetCameraPos();
					g_vFoc1 = g_vPos1 + llRot2Fwd(llGetCameraRot());
					if (debug) Debug("save pos: "+(string)g_vPos1+" foc: "+(string)g_vFoc1, FALSE,FALSE);
				}
				else if (4 == g_iNr) {
					g_vPos2 = llGetCameraPos();
					g_vFoc2 = g_vPos2 + llRot2Fwd(llGetCameraRot());
					if (debug) Debug("save pos: "+(string)g_vPos1+" foc: "+(string)g_vFoc1, FALSE,FALSE);
				}
				else if (5 == g_iNr) resetCamPos();
			}
		}
	}


//user interaction
//listen to usercommands
//-----------------------------------------------
	listen(integer channel, string name, key id, string message)
	{
			message = llToLower(message);
			if ("more..." == message) llDialog(id, "Pick an option!", ["...Back", "---", "CLOSE",
				"Worm", "Drop", "Spin"], CH); // present submenu on request
			else if ("...back" == message) llDialog(id, "What do you want to do?", MENU_MAIN, CH); // present main menu on request to go back
			else if ("on" == message) {
				takeCamCtrl(id);
			}
			else if ("off" == message) {
				releaseCamCtrl(id);
			}
			else if ("default" == message) {
				llClearCameraParams(); // reset camera to default
				llSetCameraParams([CAMERA_ACTIVE, TRUE]);
			}
			else if ("right" == message) {
				shoulderCamRight();
			}
			else if ("worm" == message) {
				wormCam();
			}
			else if ("centre" == message) {
				centreCam();
			}
			else if ("left" == message) {
				shoulderCamLeft();
			}
			else if ("shoulder" == message) {
				shoulderCam();
			}
			else if ("drop" == message) {
				dropCam();
			}
			else if (message == "Trap Toggle") {
				trap = !trap;
				if (trap == 1) {
					llOwnerSay("trap is on");
				} else {
					llOwnerSay("trap is off");
				}
			} else if ("spin" == message) {
				spinCam();
			}
			else if (!("---" == message || "close" == message)) llOwnerSay(name + " picked invalid option '" + message + "'.\n"); // not a valid dialog choice
	}


	run_time_permissions(integer perm)
	{
		if (perm & PERMISSION_CONTROL_CAMERA) {
			llSetCameraParams([CAMERA_ACTIVE, TRUE]); // 1 is active, 0 is inactive
			llOwnerSay("Camera permissions have been taken");
			defCam();
		}
	}


	changed(integer change)
	{
		if (change & CHANGED_REGION) if (g_iCamPos) resetCamPos();
		if (change & CHANGED_OWNER) llResetScript();
	}


	attach(key id)
	{
		if (id == g_kOwner) {
			initExtension(TRUE);
		} else llResetScript();
	}

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}
