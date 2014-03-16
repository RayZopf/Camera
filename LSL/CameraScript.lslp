///////////////////////////////////////////////////////////////////////////////////////////////////
//Camera Control
//
//parts from:
//Original Camera Script
//Linden Lab
//Dan Linden
//Hijacked by Penny Patton to show what SL looks like with better camera placement!
//Search script for "changedefault" to find the line you need to alter to change the default view you see when first attaching the HUD!
//Higherjacked by Core Taurog, 'cause I do what I'm told!
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
//16. Mrz. 2014
//v2.47
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

//FIXME: ---

//TODO: add notecard, so one can set up camera views per specific place
//TODO: reset view on teleport if it is on a presaved one - save positions as strided list together with SIM to make more persistent
//TODO: Link Numbers
/*Each prim that makes up an object has an address, a link number. To access a specific prim in the object, the prim's link number must be known. In addition to prims having link numbers, avatars seated upon the object do as well.
If an object consists of only one prim, and there are no avatars seated upon it, the (root) prim's link number is zero.
However, if the object is made up of multiple prims or there is an avatar seated upon the object, the root prim's link number is one.*/
//TODU: cycling to focusCamMe does not work reliablely - same with saved positions
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//GLOBAL VARIABLES
//===============================================

//internal variables
//-----------------------------------------------
string g_sTitle = "CameraScript";     // title
string g_sVersion = "2.47";            // version
string g_sScriptName;
string g_sAuthors = "Dan Linden, Penny Patton, Core Taurog, Zopf";

//SCRIPT MESSAGE MAP
integer CH; // dialog channel

// Constants
list MENU_MAIN = ["More...", "help", "CLOSE",
	"Left", "Shoulder", "Right",
	"ON", "Distance", "OFF"]; // the main menu
//list MENU_2 = ["...Back", "---", "CLOSE", "Worm", "Drop", "Spin"]; // menu 2, commented out, as long as iy only used once
float DIST_NEAR = 0.5;
float DIST_FAR = 2.0;


// Variables
integer verbose;         // show more/less info during startup
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

// for gesture support
integer g_iPersNr = 0;
integer g_iPerspective = 1;
integer g_iFar = FALSE;
float g_fDist = DIST_NEAR;

// for saving positions
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
	setColor(g_iOn);
	llOwnerSay(g_sTitle +" ("+ g_sVersion +") written/enhanced by "+g_sAuthors);
	if (verbose) MemInfo(FALSE);
	infoLines(FALSE);
}


// pragma inline
infoLines(integer help)
{
	llOwnerSay("HUD listens on channel: "+(string)CH);
	if (verbose || help) llOwnerSay("*Long touch on colored buttons to save current view*\n*long touch on death sign to delete current positions,\n\teven longer touch to clear all saved positions*\n\nPressing ESC key resets camera perspective to default/last chosen one,\nuse this to end manual mode after camerawalking");
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
	setColor(g_iOn);
}


releaseCamCtrl(key id)
{
	llOwnerSay("release CamCtrl"); // say function name for debugging
	llClearCameraParams();
	llSetCameraParams([CAMERA_ACTIVE, FALSE]); // 1 is active, 0 is inactive
	g_iOn = FALSE;
	setColor(g_iOn);
}


setColor(integer on)
{
	if (on) {
		llSetLinkPrimitiveParamsFast(2, [PRIM_COLOR, ALL_SIDES, <1,1,1>, 1]);
		llSetLinkPrimitiveParamsFast(3, [PRIM_COLOR, ALL_SIDES, <0.7,1,1>, 1]);
	} else {
		llSetLinkPrimitiveParamsFast(2, [PRIM_COLOR, ALL_SIDES, <0.5,0.5,0.5>, 0.85]);
		llSetLinkPrimitiveParamsFast(3, [PRIM_COLOR, ALL_SIDES, <0.75,0.75,0.75>, 0.95]);		
	}
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


// pragma inline
shoulderCamLeft()
{
	if (verbose) llOwnerSay("Left Shoulder"); // say function name for debugging
	llClearCameraParams(); // reset camera to default
	llSetCameraParams([
		CAMERA_ACTIVE, TRUE, // 1 is active, 0 is inactive
		CAMERA_BEHINDNESS_ANGLE, 5.0, // (0 to 180) degrees
		CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
		CAMERA_DISTANCE, g_fDist, // ( 0.5 to 10) meters
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
	g_iPerspective = -1;
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
		CAMERA_DISTANCE, g_fDist, // ( 0.5 to 10) meters
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
	g_iPerspective = 0;
}


shoulderCamRight()
{
	if (verbose) llOwnerSay("Right Shoulder"); // say function name for debugging
	llClearCameraParams(); // reset camera to default
	llSetCameraParams([
		CAMERA_ACTIVE, TRUE, // 1 is active, 0 is inactive
		CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
		CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
		CAMERA_DISTANCE, g_fDist, // ( 0.5 to 10) meters
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
	g_iPerspective = 1;
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
		CAMERA_DISTANCE, g_fDist, // ( 0.5 to 10) meters
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
	g_iPerspective = 1;
}


// pragma inline
focusCamMe()
{
	if (verbose) llOwnerSay("Focussing on yourself"); // say function name for debugging
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
		CAMERA_POSITION, here + <1.5+(2*g_fDist),1.5+(2*g_fDist),1.5+(2*g_fDist)>, // region relative position
		CAMERA_POSITION_LAG, 0.0, // (0 to 3) seconds
		CAMERA_POSITION_LOCKED, TRUE, // (TRUE or FALSE)
		CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
		CAMERA_FOCUS_OFFSET, ZERO_VECTOR // <-10,-10,-10> to <10,10,10> meters
	]);
	g_iPerspective = -1;
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
		CAMERA_DISTANCE, g_fDist + 4, // ( 0.5 to 10) meters
		//CAMERA_FOCUS, <0.0,0.0,5.0>, // region relative position
		CAMERA_FOCUS_LAG, 0.0 , // (0 to 3) seconds
		CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
		CAMERA_FOCUS_THRESHOLD, 2.5, // (0 to 4) meters
		CAMERA_PITCH, -35.0, // (-45 to 80) degrees
		//CAMERA_POSITION, <0.0,0.0,0.0>, // region relative position
		CAMERA_POSITION_LAG, 1.0, // (0 to 3) seconds
		CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
		CAMERA_POSITION_THRESHOLD, 1.0, // (0 to 4) meters
		CAMERA_FOCUS_OFFSET, <0.0,0.0,0.0> // <-10,-10,-10> to <10,10,10> meters
	]);
	g_iPerspective = 0;
}


// pragma inline
dropCam()
{
	if (verbose) llOwnerSay("Dropping camera"); // say function name for debugging
	llSetCameraParams([
		CAMERA_ACTIVE, TRUE, // 1 is active, 0 is inactive
		CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
		CAMERA_BEHINDNESS_LAG, 0.5, // (0 to 3) seconds
		CAMERA_DISTANCE, g_fDist + 1, // ( 0.5 to 10) meters
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
	for (i=0; i< 2*TWO_PI; i+=.025)
	{
		camera_position = llGetPos() + <0.0, 3.0+g_fDist, 0.0> * llEuler2Rot(<0.0, 0.0, i>);
		llSetCameraParams([CAMERA_POSITION, camera_position]);
		llSleep(0.020);
	}
	defCam();
}


// pragma inline
spazCam()
{
	if (verbose) llOwnerSay("Spaz cam for 7 seconds"); // say function name for debugging
	float i;
	for (i=0; i< 70; i+=1)
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
toggleDist()
{
	if (g_iFar) {
		g_iOn = FALSE;
		g_iFar = FALSE;
		releaseCamCtrl(llGetOwner());
	} else if (!g_iOn) {
		g_iOn = TRUE;
		takeCamCtrl(llGetOwner());
	} else g_iFar = TRUE;

	if (g_iFar) g_fDist = DIST_FAR;
		else g_fDist = DIST_NEAR;

	if (g_iOn) setPers();
}


// pragma inline
togglePers()
{
	++g_iPerspective;
	if (g_iPerspective > 1)	{
		g_iPerspective = -1;
	}
	setPers();
}


setPers()
{
	if (g_iPersNr) {
		if (g_iPerspective == -1) {
			focusCamMe();
		} else if (g_iPerspective == 0) {
			wormCam();
		} else if (g_iPerspective == 1) {
			centreCam();
		} else {
			g_iPerspective = 0;
			defCam();
		}
	} else {
		if (g_iPerspective == -1) {
			shoulderCamLeft();
		} else if (g_iPerspective == 0) {
			shoulderCam();
		} else if (g_iPerspective == 1) {
			shoulderCamRight();
		} else {
			g_iPerspective = 0;
			defCam();
		}
	}
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
		verbose = FALSE;
		CH = 8374;

		g_kOwner = llGetOwner();
		g_sScriptName = llGetScriptName();

		MemRestrict(42000, FALSE);
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
		if (verbose) llOwnerSay("*Long touch to save/delete*");
		llResetTime();
		g_iNr= llDetectedLinkNumber(0);
		if (debug) Debug("prim/link number: "+ (string)g_iNr, FALSE, FALSE);
	}


	touch(integer num_detected)
	{
		if (g_iMsg && llGetTime() > g_fTouchTimer) {
			if (3 == g_iNr || 4 == g_iNr) llOwnerSay("Cam position saved");
				else if (5 == g_iNr) llOwnerSay("Saved cam positions deleted");
			g_iMsg = FALSE;
		}
	}

	touch_end(integer num_detected)
	{
		g_iMsg = TRUE;
		integer perm = llGetPermissions();
		if (perm & PERMISSION_CONTROL_CAMERA) {
			// is the above line causing the bug that menu is not shown?
			if (llGetTime() < g_fTouchTimer) {
				if (2 == g_iNr) {
					// not using key of num_detected avi, as this is a HUD and we only want to talk to owner
					llDialog(g_kOwner, "Script version: "+g_sVersion+"\n\nWhat do you want to do?", MENU_MAIN, CH); // present dialog on click
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
		} else llDialog(g_kOwner, "Script version: "+g_sVersion+"\n\nDo you want to enable CameraControl?", ["---", "help", "CLOSE", "ON"], CH); // present dialog on click
	}


//listen to usercommands
//-----------------------------------------------
	listen(integer channel, string name, key id, string message)
	{
			message = llToLower(message);
			if ("more..." == message) llDialog(id, "Pick an option!", ["...Back", "help", "CLOSE",
				"Me", "Worm", "Drop",
				"Spin", "Spaz", "---", "Center","---", "DEFAULT"], CH); // present submenu on request
			else if ("...back" == message) llDialog(id, "Script version: "+g_sVersion+"\n\nWhat do you want to do?", MENU_MAIN, CH); // present main menu on request to go back
			else if ("help" == message) {
				infoLines(TRUE);
			}
			else if ("cycle" == message) {
				g_iPersNr = 0;
				togglePers();
			}
			else if ("cycle2" == message) {
				g_iPersNr = 1;
				togglePers();
			}
			else if ("distance" == message) {
				toggleDist();
			}
			else if ("on" == message) {
				takeCamCtrl(id);
			}
			else if ("off" == message) {
				releaseCamCtrl(id);
			}
			else if ("left" == message) {
				shoulderCamLeft();
			}
			else if ("shoulder" == message) {
				shoulderCam();
			}
			else if ("right" == message) {
				shoulderCamRight();
			}
			else if ("center" == message) {
				centreCam();
			}
			else if ("default" == message) {
				llClearCameraParams(); // reset camera to default
				llSetCameraParams([CAMERA_ACTIVE, TRUE]);
			}
			else if ("me" == message) {
				focusCamMe();
			}
			else if ("worm" == message) {
				wormCam();
			}
			else if ("drop" == message) {
				dropCam();
			}
			/*else if (message == "Trap Toggle") {
				trap = !trap;
				if (trap == 1) {
					llOwnerSay("trap is on");
				} else {
					llOwnerSay("trap is off");
				}
			}*/
			else if ("spin" == message) {
				spinCam();
			}
			else if ("spaz" == message) {
				spazCam();
			}
			else if (!("---" == message || "close" == message)) llOwnerSay(name + " picked invalid option '" + message + "'.\n"); // not a valid dialog choice
	}


	run_time_permissions(integer perm)
	{
		if (perm & PERMISSION_CONTROL_CAMERA) {
			llSetCameraParams([CAMERA_ACTIVE, TRUE]); // 1 is active, 0 is inactive
			llOwnerSay("Camera permissions have been taken");
			setPers();
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
