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
//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: Abillity to save cam positions, gesture support, visual feedback
//23. Mrz. 2014
//v2.6.2
//

//Files:
//CameraScript.lsl
//
//NAME OF NOTEDACRD
//
//
//Prequisites: Gestures
//Notecard format: ----
//basic help: /8374 help
//
//Changelog
// Formatting
// LSL Forge modules
// code cleanup
// new features

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
string g_sVersion = "2.6.2";            // version
string g_sScriptName;
string g_sAuthors = "Dan Linden, Penny Patton, Core Taurog, Zopf";

//SCRIPT MESSAGE MAP
integer CH; // dialog channel

// Constants
list MENU_MAIN = ["More...", "help", "CLOSE",
	"Left", "Shoulder", "Right",
	"DELETE", "Distance", "CLEAR", "ON", "verbose", "OFF"]; // the main menu
//list MENU_2 = ["...Back", "---", "CLOSE", "Worm", "Drop", "Spin"]; // menu 2, commented out, as long as iy only used once
string MSG_DIALOG = "\n\nWhat do you want to do?\n\tverbose: ";
string MSG_VER = "Script version: ";
string MSG_EMPTY = "no position saved on slot ";
string MSG_CYCLE = ", cycling to next one";
float DIST_NEAR = 0.5;
float DIST_FAR = 2.0;


// Variables
integer verbose = TRUE;         // show more/less info during startup
key g_kOwner;                      // object owner
//key g_kUser;                       // key of last avatar to touch object
//key g_kQuery = NULL_KEY;
float g_fTouchTimer = 1.3;
integer perm;

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
integer g_iMsg2 = TRUE;
vector g_vPos1;
vector g_vFoc1;
integer g_iCam1 = FALSE;
vector g_vPos2;
vector g_vFoc2;
integer g_iCam2 = FALSE;
vector g_vPos3;
vector g_vFoc3;
integer g_iCam3 = FALSE;
vector g_vPos4;
vector g_vFoc4;
integer g_iCam4 = FALSE;
integer g_iCamPos = FALSE;
integer g_iCamNr = 0;
integer g_iCamLock = FALSE;


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

defCam()
{
	shoulderCamRight();
	//changedefault The above is what you need to change to change the default camera view you see whenever you first attach the HUD. For example, change it to centreCam(); to have the default view be centered behind your avatar!
}


// pragma inline
initExtension(integer conf)
{
	setupListen();
	if (conf && g_iOn) llRequestPermissions(g_kOwner, PERMISSION_CONTROL_CAMERA | PERMISSION_TRACK_CAMERA);
		else {
			g_iNr = -1;
			setButtonCol(FALSE);
		}
	setCol(g_iOn);
	llOwnerSay(g_sTitle +" ("+ g_sVersion +") written/enhanced by "+g_sAuthors);
	if (verbose) MemInfo(FALSE);
	infoLines(FALSE);
}


// pragma inline
infoLines(integer help)
{
	llOwnerSay("HUD listens on channel: "+(string)CH);
	if (verbose || help) {
		llOwnerSay("*Long touch on colored buttons to save current view*\n*long touch on death sign to delete current positions,\n\teven longer touch to clear all saved positions and turn off*");
		llOwnerSay("Long touch on CameraControl button for on/default view\ntouch death sign to get SL standard\n\nPressing ESC key resets camera perspective to default/last chosen one,\nuse this to end manual mode after camerawalking");
		llOwnerSay("available chat commands:\n'cam1' to 'cam4' to recall saved camera positions,\n '1' to '4' to recall that camera or the next stored,\ncycling trough saved positions or given perspectives with 'cam' 'cycle' cycle2'\n'distance' to change distance and switch on/off, or use 'default', 'delete', 'clear', 'help' and all other menu entries");
	}
}


// pragma inline
dialogTurnOn(string status)
{
	llDialog(g_kOwner, MSG_VER +g_sVersion+"\n\nHUD is disabled\nDo you want to enable CameraControl?\n\tverbose: "+status, ["verbose", "help", "CLOSE", "ON"], CH);
}


// pragma inline
dialogPerms(string status)
{
	llDialog(g_kOwner, MSG_VER +g_sVersion+"\n\nHUD has not all needed permissions\nDo you want to let CameraControl HUD take over your camera?\n\tverbose: "+status, ["verbose", "help", "CLOSE", "ON"], CH); // present dialog on click
}


//most important function
//-----------------------------------------------
takeCamCtrl(key id)
{
	if (verbose) llOwnerSay("enabling CameraControl HUD"); // say function name for debugging
	if (id) {
		g_iNr = -1;
		setButtonCol(FALSE);
		llRequestPermissions(id, PERMISSION_CONTROL_CAMERA | PERMISSION_TRACK_CAMERA);
	} else {
			llSetCameraParams([CAMERA_ACTIVE, TRUE]); // 1 is active, 0 is inactive
			g_iOn = TRUE;
			setCol(g_iOn);
	}
}


releaseCamCtrl()
{
	llOwnerSay("release CamCtrl"); // say function name for debugging
	llClearCameraParams();
	g_iCamLock = g_iFar = g_iOn = FALSE;
	g_fDist = DIST_NEAR;
	setCol(g_iOn);
}


setCol(integer on)
{
	if (on) {
		llSetLinkPrimitiveParamsFast(2, [PRIM_COLOR, ALL_SIDES, <1,1,1>, 1]);
		llSetLinkPrimitiveParamsFast(3, [PRIM_COLOR, ALL_SIDES, <0.7,1,1>, 1]);
	} else {
		llSetLinkPrimitiveParamsFast(2, [PRIM_COLOR, ALL_SIDES, <0.5,0.5,0.5>, 0.85]);
		llSetLinkPrimitiveParamsFast(3, [PRIM_COLOR, ALL_SIDES, <0.75,0.75,0.75>, 0.95]);
	}
}


setButtonCol(integer on)
{
	if (1 == g_iNr) return;

	if (1 == on) {
		if (2 == g_iNr) llSetLinkPrimitiveParamsFast(2, [PRIM_COLOR, ALL_SIDES, <1,1,1>, 1]);
		else if (3 == g_iNr) llSetLinkPrimitiveParamsFast(3, [PRIM_COLOR, ALL_SIDES, <0.7,1,1>, 1]);
		else llSetLinkPrimitiveParamsFast(g_iNr, [PRIM_COLOR, ALL_SIDES, <0,1,1>, 1]);
	} else if (!on) {
		if (3 <= g_iNr) llSetLinkPrimitiveParamsFast(g_iNr, [PRIM_COLOR, ALL_SIDES, <0.75,0.75,0.75>, 0.95]);
		else {
			integer i = 4;
			do
				llSetLinkPrimitiveParamsFast(i, [PRIM_COLOR, ALL_SIDES, <0.75,0.75,0.75>, 0.95]);
			while (7 > i++ );
		}
	} else llSetLinkPrimitiveParamsFast(g_iNr, [PRIM_COLOR, ALL_SIDES, <1,0,1>, 1]);
}


resetCamPos()
{
	integer NrTmp = g_iNr;
	g_vPos1 = g_vFoc1 = ZERO_VECTOR;
	g_vPos2 = g_vFoc2 = ZERO_VECTOR;
	g_vPos3 = g_vFoc3 = ZERO_VECTOR;
	g_vPos4 = g_vFoc4 = ZERO_VECTOR;
	g_iCam1 = g_iCam2 = g_iCam3 = g_iCam4 = g_iCamPos = FALSE;
	if (verbose) llOwnerSay("Saved cam positions deleted");
	g_iNr = -1;
	setButtonCol(FALSE);
	g_iNr = NrTmp;
}


// pragma inline
slCam()
{
	llClearCameraParams(); // reset camera to default
	llSetCameraParams([CAMERA_ACTIVE, TRUE]);
	g_iCamLock = FALSE;
	llOwnerSay("Resetting view to SL standard");
}


savedCam(vector foc, vector pos)
{
	llClearCameraParams(); // reset camera to default
	llSetCameraParams([
		CAMERA_ACTIVE, TRUE, // 1 is active, 0 is inactive
		//CAMERA_BEHINDNESS_ANGLE, 180.0, // (0 to 180) degrees
		//CAMERA_BEHINDNESS_LAG, 0.5, // (0 to 3) seconds
		//CAMERA_DISTANCE, 10.0, // ( 0.5 to 10) meters
		CAMERA_FOCUS, foc, // region relative position
		CAMERA_FOCUS_LAG, 0.0, // (0 to 3) seconds
		CAMERA_FOCUS_LOCKED, TRUE, // (TRUE or FALSE)
		//CAMERA_FOCUS_OFFSET, <0.0,0.0,0.0>, // <-10,-10,-10> to <10,10,10> meters
		//CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
		//CAMERA_PITCH, 30.0, // (-45 to 80) degrees
		CAMERA_POSITION, pos, // region relative position
		CAMERA_POSITION_LAG, 0.0, // (0 to 3) seconds
		CAMERA_POSITION_LOCKED, TRUE // (TRUE or FALSE)
		//CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
	]);
	g_iCamLock = TRUE;
	if (debug) Debug("restored pos: "+(string)pos+" foc: "+(string)foc, FALSE,FALSE);
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
	g_iCamLock = FALSE;
	g_iPersNr = 0;
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
	g_iCamLock = FALSE;
	g_iPersNr = 0;
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
	g_iCamLock = FALSE;
	g_iPersNr = 0;
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
	g_iCamLock = FALSE;
	g_iPersNr = 1;
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
	g_iCamLock = TRUE;
	g_iPersNr = 1;
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
	g_iCamLock = FALSE;
	g_iPersNr = 1;
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
	g_iCamLock = TRUE;
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
	g_iCamLock = FALSE;
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
	g_iCamLock = TRUE;
	defCam();
}


// pragma inline
toggleCam()
{
	++g_iCamNr;
	if (g_iCamNr > 4) g_iCamNr = 1;

	setCam((string)g_iCamNr);
}


setCam(string cam)
{
	if (debug) Debug("setCam", FALSE, FALSE);
	integer i;
	integer j = 0;
	if (g_iCamPos) do {
		i = FALSE;
		if ("cam1" == cam || "cam 1" == cam || "1" == cam) {
			if (g_iCam1) {
				g_iNr = 4;
				setButtonCol(FALSE);
				savedCam(g_vFoc1, g_vPos1);
				llSleep(0.2);
				setButtonCol(TRUE);
				g_iCamNr = 1;
			} else if ("1" == cam) {
					if (verbose) llOwnerSay(MSG_EMPTY + cam + MSG_CYCLE);
					++g_iCamNr;
					cam = "2";
					i = TRUE;
			} else g_iCamNr = 0;
		} else if ("cam2" == cam || "cam 2" == cam || "2" == cam) {
			if (g_iCam2) {
				g_iNr = 5;
				setButtonCol(FALSE);
				savedCam(g_vFoc2, g_vPos2);
				llSleep(0.2);
				setButtonCol(TRUE);
				g_iCamNr = 2;
			} else if ("2" == cam) {
					if (verbose) llOwnerSay(MSG_EMPTY + cam + MSG_CYCLE);
					++g_iCamNr;
					cam = "3";
					i = TRUE;
			} else g_iCamNr = 0;
		} else if ("cam3" == cam || "cam 3" == cam || "3" == cam) {
			if (g_iCam3) {
				g_iNr = 6;
				setButtonCol(FALSE);
				savedCam(g_vFoc3, g_vPos3);
				llSleep(0.2);
				setButtonCol(TRUE);
				g_iCamNr = 3;
			} else if ("3" == cam) {
					if (verbose) llOwnerSay(MSG_EMPTY + cam + MSG_CYCLE);
					++g_iCamNr;
					cam = "4";
					i = TRUE;
			} else g_iCamNr = 0;
		} else if ("cam4" == cam || "cam 4" == cam || "4" == cam) {
			if (g_iCam4) {
				g_iNr = 7;
				setButtonCol(FALSE);
				savedCam(g_vFoc4, g_vPos4);
				llSleep(0.2);
				setButtonCol(TRUE);
				g_iCamNr = 4;
			} else if ("4" == cam) {
					if (verbose) llOwnerSay(MSG_EMPTY + cam + MSG_CYCLE);
					g_iCamNr = 1;
					cam = "1";
					i = TRUE;
			} else g_iCamNr = 0;
		} else {
			g_iCamNr = 0;
			if (verbose) llOwnerSay("Incorrect camera chosen ("+cam+")");
			return;
		}

		if (debug) Debug("end of do while, cam set to: "+cam+"-"+(string)i+(string)j, FALSE, FALSE);
	} while (i && (++j < 4));

	if (g_iCamNr) { if (verbose) llOwnerSay("Camera "+(string)g_iCamNr); }
		else llOwnerSay(MSG_EMPTY +cam);
	if (debug) Debug("end setCam", FALSE, FALSE);
}


// pragma inline
toggleDist()
{
	if (g_iFar) {
		g_iOn = FALSE;
		g_iFar = FALSE;
		releaseCamCtrl();
	} else if (!g_iOn) {
		takeCamCtrl("");
	} else g_iFar = TRUE;

	if (g_iFar) g_fDist = DIST_FAR;
		else g_fDist = DIST_NEAR;

	if (g_iOn) setPers();
}


// pragma inline
togglePers()
{
	++g_iPerspective;
	if (g_iPerspective > 1) g_iPerspective = -1;
	setPers();
}


setPers()
{
	if (g_iPersNr) {
		if (g_iPerspective == -1) focusCamMe();
		else if (g_iPerspective == 0) wormCam();
		else if (g_iPerspective == 1) centreCam();
		else {
			g_iPerspective = 0;
			defCam();
		}
	} else {
		if (g_iPerspective == -1) shoulderCamLeft();
		else if (g_iPerspective == 0) shoulderCam();
		else if (g_iPerspective == 1) shoulderCamRight();
		else {
			g_iPerspective = 0;
			defCam();
		}
	}
}


// pragma inline
setupListen()
{
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
	state_entry()
	{
		//debug=TRUE; // set to TRUE to enable Debug messages
		CH = 8374;

		g_kOwner = llGetOwner();
		g_sScriptName = llGetScriptName();

		MemRestrict(50000, FALSE);
		if (debug) Debug("state_entry", TRUE, TRUE);

		initExtension(FALSE);
	}


	touch_start(integer num_detected)
	{
		if (verbose) llOwnerSay("*Long touch to save/delete/reset*");
		llResetTime();
		g_iNr= llDetectedLinkNumber(0);
		if (2 < g_iNr && g_iOn) setButtonCol(FALSE);
		perm = llGetPermissions();
		if (debug) Debug("prim/link number: "+ (string)g_iNr, FALSE, FALSE);
	}


	touch(integer num_detected)
	{
		if (g_iMsg) {
			if (!((perm & PERMISSION_CONTROL_CAMERA) && (perm & PERMISSION_TRACK_CAMERA))) {
				g_iMsg = FALSE;
				g_iOn = FALSE;
				g_iNr = 1;
				do {
					setButtonCol(-1);
				} while (7 > g_iNr++);
				llOwnerSay("To work camera permissions are needed\nend clicking to get menu");
				return;
			}
			
			float time = llGetTime();
			if (time > g_fTouchTimer) {
				if (g_iMsg2) {
					g_iMsg2 = FALSE;
					if (verbose) llOwnerSay("touch registered");
					if (1 < g_iNr) setButtonCol(-1);
				} else if (time >= (g_fTouchTimer + 1.5)) {
					g_iMsg = FALSE;
					if (verbose) llOwnerSay("long touch registered");
					if (3 == g_iNr) {
						setButtonCol(FALSE);
					}
				}
			}
		}
	}


	touch_end(integer num_detected)
	{
		g_iMsg = g_iMsg2 = TRUE;
		float time = llGetTime();
		string status = "off";

		if (time > g_fTouchTimer && 3 < g_iNr && (perm & PERMISSION_TRACK_CAMERA)) {
			if (4 == g_iNr) {
				g_vPos1 = llGetCameraPos();
				g_vFoc1 = g_vPos1 + llRot2Fwd(llGetCameraRot());
				g_iCam1 = TRUE;
				if (debug) Debug("save pos: "+(string)g_vPos1+" foc: "+(string)g_vFoc1, FALSE,FALSE);
			} else if (5 == g_iNr) {
				g_vPos2 = llGetCameraPos();
				g_vFoc2 = g_vPos2 + llRot2Fwd(llGetCameraRot());
				g_iCam2 = TRUE;
				if (debug) Debug("save pos: "+(string)g_vPos2+" foc: "+(string)g_vFoc2, FALSE,FALSE);
			} else if (6 == g_iNr) {
				g_vPos3 = llGetCameraPos();
				g_vFoc3 = g_vPos3 + llRot2Fwd(llGetCameraRot());
				g_iCam3 = TRUE;
				if (debug) Debug("save pos: "+(string)g_vPos3+" foc: "+(string)g_vFoc3, FALSE,FALSE);
			} else if (7 == g_iNr) {
				g_vPos4 = llGetCameraPos();
				g_vFoc4 = g_vPos4 + llRot2Fwd(llGetCameraRot());
				g_iCam4 = TRUE;
				if (debug) Debug("save pos: "+(string)g_vPos4+" foc: "+(string)g_vFoc4, FALSE,FALSE);
			} else return;

			if (verbose) llOwnerSay("Cam position saved");
			setButtonCol(TRUE);
			g_iCamPos = TRUE;
		} else if (perm & PERMISSION_CONTROL_CAMERA) {
			if (time < g_fTouchTimer) {
				if (3 == g_iNr) { if (g_iOn) setButtonCol(TRUE); slCam(); }
				else if (g_iOn) {
					if (2 == g_iNr) {
					// not using key of num_detected avi, as this is a HUD and we only want to talk to owner
						if (verbose) status = "on";
						llDialog(g_kOwner, MSG_VER + g_sVersion + MSG_DIALOG + status, MENU_MAIN, CH); // present dialog on click
					} else if (4 == g_iNr) setCam("cam1");
					else if (5 == g_iNr) setCam("cam2");
					else if (6 == g_iNr) setCam("cam3");
					else if (7 == g_iNr) setCam("cam4");
				}
				else {
					if (verbose) status = "on";
					dialogTurnOn(status);
				}

			} else if (3 == g_iNr) {
				resetCamPos();
				if (time < (g_fTouchTimer + 1.5)) {
					if (debug) Debug("Button: "+(string)g_iNr +" - " +(string)g_iOn+"=g_iOn, time:"+(string)time+" variable: "+(string)g_fTouchTimer+" calc: "+(string)(g_fTouchTimer + 1.5),FALSE,FALSE);
					if (g_iOn) setButtonCol(TRUE);
						else setButtonCol(FALSE);
				} else releaseCamCtrl();

			} else if (2 >= g_iNr) {
				if (g_iOn) {
					setButtonCol(TRUE);
					defCam();
					if (verbose) llOwnerSay("Setting default view");
				} else {
					takeCamCtrl("");
					defCam();
				}
			}

		} else {
			if (verbose) status = "on";
			dialogPerms(status);
		}
	}


//listen to usercommands
//-----------------------------------------------
	listen(integer channel, string name, key id, string message)
	{
			message = llToLower(message);
			string status = "off";
			if (verbose) status = "on";

			if ("more..." == message) llDialog(id, "Pick an option!",
				["...Back", "help", "CLOSE",
				"Me", "Worm", "Drop",
				"Spin", "Spaz", "---", "DEFAULT","Center", "STANDARD"], CH); // present submenu on request
			else if ("...back" == message) llDialog(id, MSG_VER + g_sVersion + MSG_DIALOG + status, MENU_MAIN, CH); // present main menu on request to go back
			else if ("help" == message) { infoLines(TRUE); }
			else if ("verbose" == message) {
				verbose = !verbose;
				if (verbose) llOwnerSay("Verbose messages turned ON");
					else llOwnerSay("Verbose messages turned OFF");
			} else if ("---" == message || "close" == message) return;
			else if ("distance" == message) {
				perm = llGetPermissions();
				if (perm & PERMISSION_CONTROL_CAMERA) toggleDist();
					else dialogPerms(status);
			} else if ("on" == message) {
				if (!g_iOn) {
					perm = llGetPermissions();
					if ((perm & PERMISSION_CONTROL_CAMERA) && (perm & PERMISSION_TRACK_CAMERA)) {
						takeCamCtrl("");
						defCam();
					} else takeCamCtrl(id);
				}
			} else if ("off" == message) { releaseCamCtrl(); }
			else if ("clear" == message) {
				resetCamPos();
				releaseCamCtrl();
			} else if ("delete" == message) {
				g_iNr = 3;
				setButtonCol(-1);
				llSleep(0.2);
				setButtonCol(TRUE);
				resetCamPos();
			} else if ("standard" == message) {
				if (g_iOn) {
					g_iNr = 3;
					setButtonCol(FALSE);
					slCam();
					llSleep(0.2);
					setButtonCol(TRUE);
				} else releaseCamCtrl();
			} else if (g_iOn) {
				if ((~llSubStringIndex(message, "cam")) || ((string)((integer)message) == message)) {
					if (g_iCamPos) {
						if ("cam" == message) toggleCam();
							else setCam(message);
					} else llOwnerSay("No camera positions saved");
				} else if ("cycle" == message) {
					g_iPersNr = 0;
					togglePers();
				} else if ("cycle2" == message) {
					g_iPersNr = 1;
					togglePers();
				} else if ("left" == message) { shoulderCamLeft(); }
				else if ("shoulder" == message) { shoulderCam(); }
				else if ("right" == message) { shoulderCamRight(); }
				else if ("center" == message) { centreCam(); }
				else if ("me" == message) { focusCamMe(); }
				else if ("worm" == message) { wormCam(); }
				else if ("drop" == message) { dropCam(); }
				else if ("spin" == message) { spinCam(); }
				else if ("spaz" == message) { spazCam(); }
				else if ("default" == message) {
					g_iNr = 2;
					setButtonCol(-1);
					defCam();
					llSleep(0.2);
					setButtonCol(TRUE);
				} else llOwnerSay("Invalid option picked (" + message + ").\n"); // not a valid dialog choice
			} else if (!g_iOn) {
				if (verbose) status = "on";
				if ((perm & PERMISSION_CONTROL_CAMERA) && (perm & PERMISSION_TRACK_CAMERA)) dialogTurnOn(status);
					else dialogPerms(status);
			} else llOwnerSay("something went wrong");
	}


	run_time_permissions(integer perm)
	{
		if (perm & PERMISSION_CONTROL_CAMERA) {
			llSetCameraParams([CAMERA_ACTIVE, TRUE]); // 1 is active, 0 is inactive
			g_iOn = TRUE;
			setCol(g_iOn);
			llOwnerSay("Camera permissions have been taken \nAvatar key: "+(string)llGetPermissionsKey());
			setPers();
		}
	}


	changed(integer change)
	{
		if (change & CHANGED_REGION) {
			if (g_iCamLock) defCam();
			if (g_iCamPos) resetCamPos();
		}
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