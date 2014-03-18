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
//18. Mrz. 2014
//v2.55
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
//TODO: choosing perspective does enable scrpt - but not change color of hud... think about what we want
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//GLOBAL VARIABLES
//===============================================

//internal variables
//-----------------------------------------------
string g_sTitle = "CameraScript";     // title
string g_sVersion = "2.55";            // version
string g_sScriptName;
string g_sAuthors = "Dan Linden, Penny Patton, Core Taurog, Zopf";

//SCRIPT MESSAGE MAP
integer CH; // dialog channel

// Constants
list MENU_MAIN = ["More...", "help", "CLOSE",
	"Left", "Shoulder", "Right",
	"---", "Distance", "---", "ON", "verbose", "OFF"]; // the main menu
//list MENU_2 = ["...Back", "---", "CLOSE", "Worm", "Drop", "Spin"]; // menu 2, commented out, as long as iy only used once
float DIST_NEAR = 0.5;
float DIST_FAR = 2.0;


// Variables
integer verbose;         // show more/less info during startup
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

// pragma inline
initExtension(integer conf)
{
	setupListen();
	if (conf) llRequestPermissions(g_kOwner, PERMISSION_CONTROL_CAMERA | PERMISSION_TRACK_CAMERA);
		else setButtonCol();
	setCol(g_iOn);
	llOwnerSay(g_sTitle +" ("+ g_sVersion +") written/enhanced by "+g_sAuthors);
	if (verbose) MemInfo(FALSE);
	infoLines(FALSE);
}


// pragma inline
infoLines(integer help)
{
	llOwnerSay("HUD listens on channel: "+(string)CH);
	if (verbose || help) llOwnerSay("*Long touch on colored buttons to save current view*\n*long touch on death sign to delete current positions,\n\teven longer touch to clear all saved positions*");
	if (verbose || help) llOwnerSay("Long touch on CameraControl button for default view\ntouch on death sign to get back to SL standard\n\nPressing ESC key resets camera perspective to default/last chosen one,\nuse this to end manual mode after camerawalking");
	if (verbose || help) llOwnerSay("available chat commands:\n'cam1' to 'cam4' to recall saved camera positions,\n cycling trough saved positions or given perspectives with 'cam' 'cycle' cycle2'\n'distance' to change distance and switch on/off, or use 'default', 'delete', 'help' and all other menu entries");
}


// pragma inline
dialogTurnOn(string status)
{
	llDialog(g_kOwner, "Script version: "+g_sVersion+"\n\nHUD is disabled\nDo you want to enable CameraControl?\n\tverbose: "+status, ["verbose", "help", "CLOSE", "ON"], CH);
}


// pragma inline
dialogPerms(string status)
{
	llDialog(g_kOwner, "Script version: "+g_sVersion+"\n\nHUD has not all needed permissions\nDo you want to let CameraControl HUD take over your camera?\n\tverbose: "+status, ["verbose", "help", "CLOSE", "ON"], CH); // present dialog on click
}


// pragma inline
//most important function
//-----------------------------------------------
takeCamCtrl(key id)
{
	if (verbose) llOwnerSay("enabling CameraControl HUD"); // say function name for debugging
	if (id) llRequestPermissions(id, PERMISSION_CONTROL_CAMERA | PERMISSION_TRACK_CAMERA);
		else {
			llSetCameraParams([CAMERA_ACTIVE, TRUE]); // 1 is active, 0 is inactive
			g_iOn = TRUE;
			setCol(g_iOn);
		}
}


releaseCamCtrl()
{
	llOwnerSay("release CamCtrl"); // say function name for debugging
	llClearCameraParams();
	//llSetCameraParams([CAMERA_ACTIVE, FALSE]); // 1 is active, 0 is inactive
	g_iCamLock = FALSE;
	g_iFar = FALSE;
	g_fDist = DIST_NEAR;
	g_iOn = FALSE;
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


setButtonCol()
{
	integer i = 4;
	do
		llSetLinkPrimitiveParamsFast(i, [PRIM_COLOR, ALL_SIDES, <0.75,0.75,0.75>, 0.95]);
	while (++i <= 7);
}


resetCamPos()
{
	g_vPos1 = g_vFoc1 = ZERO_VECTOR;
	g_vPos2 = g_vFoc2 = ZERO_VECTOR;
	g_vPos3 = g_vFoc3 = ZERO_VECTOR;
	g_vPos4 = g_vFoc4 = ZERO_VECTOR;
	g_iCam1 = g_iCam2 = g_iCam3 = g_iCam4 = FALSE;
	g_iCamPos = FALSE;
	setButtonCol();
}


// pragma inline
slCam()
{
	llClearCameraParams(); // reset camera to default
	llSetCameraParams([CAMERA_ACTIVE, TRUE]);
	g_iCamLock = FALSE;
	llOwnerSay("Resetting view to SL standard");
}


defCam()
{
	shoulderCamRight();
	//changedefault The above is what you need to change to change the default camera view you see whenever you first attach the HUD. For example, change it to centreCam(); to have the default view be centered behind your avatar!
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
		if ("cam1" == cam || "1" == cam) {
			if (g_iCam1) savedCam(g_vFoc1, g_vPos1);
				else if ("1" == cam) {
					if (verbose) llOwnerSay("no position saved on slot " +cam+", cycling to next one");
					++g_iCamNr;
					cam = "2";
					i = TRUE;
				}
		}
		else if ("cam2" == cam || "2" == cam) {
			if (g_iCam2) savedCam(g_vFoc2, g_vPos2);
				else if ("2" == cam) {
					if (verbose) llOwnerSay("no position saved on slot " +cam+", cycling to next one");
					++g_iCamNr;
					cam = "3";
					i = TRUE;
				}
		}
		else if ("cam3" == cam || "3" == cam) {
			if (g_iCam3) savedCam(g_vFoc3, g_vPos3);
				else if ("3" == cam) {
					if (verbose) llOwnerSay("no position saved on slot " +cam+", cycling to next one");
					++g_iCamNr;
					cam = "4";
					i = TRUE;
				}
		}
		else if ("cam4" == cam || "4" == cam) {
			if (g_iCam4) savedCam(g_vFoc4, g_vPos4);
				else if ("4" == cam) {
					if (verbose) llOwnerSay("no position saved on slot " +cam+", cycling to next one");
					g_iCamNr = 1;
					cam = "1";
					i = TRUE;
				}
		} else llOwnerSay("0");

		if (debug) Debug("end of do while, cam set to: "+cam+"-"+(string)i+(string)j, FALSE, FALSE);
	} while (i && (++j < 4));
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
	if (g_iPerspective > 1) {
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

		MemRestrict(48000, FALSE);
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
		if (verbose) llOwnerSay("*Long touch to save/delete/reset*");
		llResetTime();
		g_iNr= llDetectedLinkNumber(0);
		perm = llGetPermissions();
		if (debug) Debug("prim/link number: "+ (string)g_iNr, FALSE, FALSE);
	}


	touch(integer num_detected)
	{
		if (g_iMsg && llGetTime() > g_fTouchTimer) {
			if ((perm & PERMISSION_TRACK_CAMERA) && 4 <= g_iNr) {
				if (verbose) llOwnerSay("Cam position saved");
				llSetLinkPrimitiveParamsFast(g_iNr, [PRIM_COLOR, ALL_SIDES, <0,1,1>, 1]);
			} else if (perm & PERMISSION_CONTROL_CAMERA) {
				if (3 > g_iNr) llOwnerSay("Setting default view");
					else if (3 == g_iNr) llOwnerSay("Saved cam positions deleted");
			} else llOwnerSay("To work amera permissions are needed\nend clicking to get menu");
			g_iMsg = FALSE;
		}
	}

	touch_end(integer num_detected)
	{
		g_iMsg = TRUE;
		float time = llGetTime();
		string status = "off";
		if (time > g_fTouchTimer && 4 <= g_iNr && (perm & PERMISSION_TRACK_CAMERA)) {
			if (4 == g_iNr) {
				g_vPos1 = llGetCameraPos();
				g_vFoc1 = g_vPos1 + llRot2Fwd(llGetCameraRot());
				g_iCam1 = TRUE;
				if (debug) Debug("save pos: "+(string)g_vPos1+" foc: "+(string)g_vFoc1, FALSE,FALSE);
			}
			else if (5 == g_iNr) {
				g_vPos2 = llGetCameraPos();
				g_vFoc2 = g_vPos2 + llRot2Fwd(llGetCameraRot());
				g_iCam2 = TRUE;
				if (debug) Debug("save pos: "+(string)g_vPos2+" foc: "+(string)g_vFoc2, FALSE,FALSE);
			}
			else if (6 == g_iNr) {
				g_vPos3 = llGetCameraPos();
				g_vFoc3 = g_vPos3 + llRot2Fwd(llGetCameraRot());
				g_iCam3 = TRUE;
				if (debug) Debug("save pos: "+(string)g_vPos3+" foc: "+(string)g_vFoc3, FALSE,FALSE);
			}
			else if (7 == g_iNr) {
				g_vPos4 = llGetCameraPos();
				g_vFoc4 = g_vPos4 + llRot2Fwd(llGetCameraRot());
				g_iCam4 = TRUE;
				if (debug) Debug("save pos: "+(string)g_vPos4+" foc: "+(string)g_vFoc4, FALSE,FALSE);
			}
			g_iCamPos = TRUE;
		} else if (perm & PERMISSION_CONTROL_CAMERA) {
			// is the above line causing the bug that menu is not shown?
			if (time < g_fTouchTimer) {
				if (2 == g_iNr) {
					// not using key of num_detected avi, as this is a HUD and we only want to talk to owner
					if (g_iOn) {
						if (verbose) status = "on";
						llDialog(g_kOwner, "Script version: "+g_sVersion+"\n\nWhat do you want to do?\n\tverbose: "+status, MENU_MAIN, CH); // present dialog on click
					} else {
						takeCamCtrl("");
						defCam();
					}
				}
				else if (3 == g_iNr) { slCam(); }
				else if (g_iOn) {
					if (4 == g_iNr) { if (g_iCam1) savedCam(g_vFoc1, g_vPos1); }
					else if (5 == g_iNr) { if (g_iCam2) savedCam(g_vFoc2, g_vPos2); }
					else if (6 == g_iNr) { if (g_iCam3) savedCam(g_vFoc3, g_vPos3); }
					else if (7 == g_iNr) { if (g_iCam4) savedCam(g_vFoc4, g_vPos4); }
				}
				else if (!g_iOn) { 
					if (verbose) status = "on";
					dialogTurnOn(status);
				}
			} else if (3 == g_iNr) {
				resetCamPos();
				releaseCamCtrl();

			} else if (2 >= g_iNr) {
				if (g_iOn) defCam();
					else {
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
			if ("more..." == message) llDialog(id, "Pick an option!", ["...Back", "help", "CLOSE",
				"Me", "Worm", "Drop",
				"Spin", "Spaz", "---", "Center","---", "STANDARD"], CH); // present submenu on request
			else if ("...back" == message) llDialog(id, "Script version: "+g_sVersion+"\n\nWhat do you want to do?", MENU_MAIN, CH); // present main menu on request to go back
			else if ("help" == message) { infoLines(TRUE); }
			else if ("verbose" == message) {
				verbose = !verbose;
				if (verbose) llOwnerSay("Verbose messages turned ON");
					else llOwnerSay("Verbose messages turned OFF");
			}
			else if ("---" == message || "close" == message) return;
			else if ("distance" == message) {
				perm = llGetPermissions();
				if (perm & PERMISSION_CONTROL_CAMERA) toggleDist();
					else {
						if (verbose) status = "on";
						dialogPerms(status);
					}
			}
			else if ("on" == message) {
				if (!g_iOn) {
					perm = llGetPermissions();
					if ((perm & PERMISSION_CONTROL_CAMERA) && (perm & PERMISSION_TRACK_CAMERA)) takeCamCtrl("");
						else takeCamCtrl(id);
				}
				defCam();
			}
			else if ("off" == message) { releaseCamCtrl(); }
			else if ("standard" == message) {
				if (g_iOn) slCam();
					else releaseCamCtrl();
			}
			else if ("delete" == message) { resetCamPos(); }
			else if (g_iOn) {
				if (-1 != llSubStringIndex(message, "cam")) {
					if (g_iCamPos) {
						if ("cam" == message) toggleCam();
							else setCam(message);
					} else llOwnerSay("No camera positions saved");
				}
				else if ("cycle" == message) {
					g_iPersNr = 0;
					togglePers();
				}
				else if ("cycle2" == message) {
					g_iPersNr = 1;
					togglePers();
				}
				else if ("left" == message) { shoulderCamLeft(); }
				else if ("shoulder" == message) { shoulderCam(); }
				else if ("right" == message) { shoulderCamRight(); }
				else if ("center" == message) { centreCam(); }
				else if ("me" == message) { focusCamMe(); }
				else if ("worm" == message) { wormCam(); }
				else if ("drop" == message) { dropCam(); }
				/*else if (message == "Trap Toggle") {
					trap = !trap;
					if (trap == 1) {
						llOwnerSay("trap is on");
					} else {
						llOwnerSay("trap is off");
					}
				}*/
				else if ("spin" == message) { spinCam(); }
				else if ("spaz" == message) { spazCam(); }
				else if ("default" == message) { defCam(); }
			}
			else if (!g_iOn) {
				if (verbose) status = "on";
				dialogTurnOn(status);
			}
			else llOwnerSay(name + " picked invalid option '" + message + "'.\n"); // not a valid dialog choice
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