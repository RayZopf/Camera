// LSL script generated: LSL.CameraScript.lslp Sat Mar 22 23:30:12 Mitteleuropäische Zeit 2014
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
//22. Mrz. 2014
//v2.6.1
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
string g_sTitle = "CameraScript";
string g_sVersion = "2.6.1";
string g_sScriptName;
string g_sAuthors = "Dan Linden, Penny Patton, Core Taurog, Zopf";

//SCRIPT MESSAGE MAP
integer CH;

// Constants
list MENU_MAIN = ["More...","help","CLOSE","Left","Shoulder","Right","DELETE","Distance","CLEAR","ON","verbose","OFF"];


// Variables
integer verbose = 1;
key g_kOwner;
integer perm;

integer g_iHandle = 0;
integer g_iOn = 0;

// for gesture support
integer g_iPersNr = 0;
integer g_iPerspective = 1;
integer g_iFar = 0;
float g_fDist = 0.5;

// for saving positions
integer g_iNr;
integer g_iMsg = 1;
integer g_iMsg2 = 1;
vector g_vPos1;
vector g_vFoc1;
integer g_iCam1 = 0;
vector g_vPos2;
vector g_vFoc2;
integer g_iCam2 = 0;
vector g_vPos3;
vector g_vFoc3;
integer g_iCam3 = 0;
vector g_vPos4;
vector g_vFoc4;
integer g_iCam4 = 0;
integer g_iCamPos = 0;
integer g_iCamNr = 0;
integer g_iCamLock = 0;

//project specific modules
//-----------------------------------------------


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

defCam(){
    shoulderCamRight();
}


//most important function
//-----------------------------------------------
takeCamCtrl(key id){
    if (verbose) llOwnerSay("enabling CameraControl HUD");
    if (id) {
        (g_iNr = -1);
        setButtonCol(0);
        llRequestPermissions(id,3072);
    }
    else  {
        llSetCameraParams([12,1]);
        (g_iOn = 1);
        setCol(g_iOn);
    }
}


releaseCamCtrl(){
    llOwnerSay("release CamCtrl");
    llClearCameraParams();
    (g_iCamLock = (g_iFar = (g_iOn = 0)));
    (g_fDist = 0.5);
    setCol(g_iOn);
}


setCol(integer on){
    if (on) {
        llSetLinkPrimitiveParamsFast(2,[18,-1,<1.0,1.0,1.0>,1]);
        llSetLinkPrimitiveParamsFast(3,[18,-1,<0.7,1.0,1.0>,1]);
    }
    else  {
        llSetLinkPrimitiveParamsFast(2,[18,-1,<0.5,0.5,0.5>,0.85]);
        llSetLinkPrimitiveParamsFast(3,[18,-1,<0.75,0.75,0.75>,0.95]);
    }
}


setButtonCol(integer on){
    if ((1 == g_iNr)) return;
    if ((1 == on)) {
        if ((2 == g_iNr)) llSetLinkPrimitiveParamsFast(2,[18,-1,<1.0,1.0,1.0>,1]);
        else  if ((3 == g_iNr)) llSetLinkPrimitiveParamsFast(3,[18,-1,<0.7,1.0,1.0>,1]);
        else  llSetLinkPrimitiveParamsFast(g_iNr,[18,-1,<0.0,1.0,1.0>,1]);
    }
    else  if ((!on)) {
        if ((3 <= g_iNr)) llSetLinkPrimitiveParamsFast(g_iNr,[18,-1,<0.75,0.75,0.75>,0.95]);
        else  {
            integer i = 4;
            do  llSetLinkPrimitiveParamsFast(i,[18,-1,<0.75,0.75,0.75>,0.95]);
            while ((7 > (i++)));
        }
    }
    else  llSetLinkPrimitiveParamsFast(g_iNr,[18,-1,<1.0,0.0,1.0>,1]);
}


resetCamPos(){
    integer NrTmp = g_iNr;
    (g_vPos1 = (g_vFoc1 = ZERO_VECTOR));
    (g_vPos2 = (g_vFoc2 = ZERO_VECTOR));
    (g_vPos3 = (g_vFoc3 = ZERO_VECTOR));
    (g_vPos4 = (g_vFoc4 = ZERO_VECTOR));
    (g_iCam1 = (g_iCam2 = (g_iCam3 = (g_iCam4 = (g_iCamPos = 0)))));
    if (verbose) llOwnerSay("Saved cam positions deleted");
    (g_iNr = -1);
    setButtonCol(0);
    (g_iNr = NrTmp);
}


savedCam(vector foc,vector pos){
    llClearCameraParams();
    llSetCameraParams([12,1,17,foc,6,0.0,22,1,13,pos,5,0.0,21,1]);
    (g_iCamLock = 1);
    
}


shoulderCamRight(){
    if (verbose) llOwnerSay("Right Shoulder");
    llClearCameraParams();
    llSetCameraParams([12,1,8,0.0,9,0.0,7,g_fDist,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
    (g_iCamLock = 0);
    (g_iPersNr = 0);
    (g_iPerspective = 1);
}


setCam(string cam){
    
    integer i;
    integer j = 0;
    if (g_iCamPos) do  {
        (i = 0);
        if (((("cam1" == cam) || ("cam 1" == cam)) || ("1" == cam))) {
            if (g_iCam1) {
                (g_iNr = 4);
                setButtonCol(0);
                savedCam(g_vFoc1,g_vPos1);
                llSleep(0.2);
                setButtonCol(1);
                (g_iCamNr = 1);
            }
            else  if (("1" == cam)) {
                if (verbose) llOwnerSay((("no position saved on slot " + cam) + ", cycling to next one"));
                (++g_iCamNr);
                (cam = "2");
                (i = 1);
            }
            else  (g_iCamNr = 0);
        }
        else  if (((("cam2" == cam) || ("cam 2" == cam)) || ("2" == cam))) {
            if (g_iCam2) {
                (g_iNr = 5);
                setButtonCol(0);
                savedCam(g_vFoc2,g_vPos2);
                llSleep(0.2);
                setButtonCol(1);
                (g_iCamNr = 2);
            }
            else  if (("2" == cam)) {
                if (verbose) llOwnerSay((("no position saved on slot " + cam) + ", cycling to next one"));
                (++g_iCamNr);
                (cam = "3");
                (i = 1);
            }
            else  (g_iCamNr = 0);
        }
        else  if (((("cam3" == cam) || ("cam 3" == cam)) || ("3" == cam))) {
            if (g_iCam3) {
                (g_iNr = 6);
                setButtonCol(0);
                savedCam(g_vFoc3,g_vPos3);
                llSleep(0.2);
                setButtonCol(1);
                (g_iCamNr = 3);
            }
            else  if (("3" == cam)) {
                if (verbose) llOwnerSay((("no position saved on slot " + cam) + ", cycling to next one"));
                (++g_iCamNr);
                (cam = "4");
                (i = 1);
            }
            else  (g_iCamNr = 0);
        }
        else  if (((("cam4" == cam) || ("cam 4" == cam)) || ("4" == cam))) {
            if (g_iCam4) {
                (g_iNr = 7);
                setButtonCol(0);
                savedCam(g_vFoc4,g_vPos4);
                llSleep(0.2);
                setButtonCol(1);
                (g_iCamNr = 4);
            }
            else  if (("4" == cam)) {
                if (verbose) llOwnerSay((("no position saved on slot " + cam) + ", cycling to next one"));
                (g_iCamNr = 1);
                (cam = "1");
                (i = 1);
            }
            else  (g_iCamNr = 0);
        }
        else  {
            (g_iCamNr = 0);
            if (verbose) llOwnerSay((("Incorrect camera chosen (" + cam) + ")"));
        }
        
    }
    while ((i && ((++j) < 4)));
    if ((verbose && g_iCamNr)) llOwnerSay(("Camera " + ((string)g_iCamNr)));
    
}


setPers(){
    if (g_iPersNr) {
        if ((g_iPerspective == -1)) {
            if (verbose) llOwnerSay("Focussing on yourself");
            llClearCameraParams();
            vector here = llGetPos();
            llSetCameraParams([12,1,8,0.0,9,0.0,7,0.0,17,here,6,0.0,22,1,11,0.0,13,(here + <(1.5 + (2 * g_fDist)),(1.5 + (2 * g_fDist)),(1.5 + (2 * g_fDist))>),5,0.0,21,1,10,0.0,1,ZERO_VECTOR]);
            (g_iCamLock = 1);
            (g_iPersNr = 1);
            (g_iPerspective = -1);
        }
        else  if ((g_iPerspective == 0)) {
            if (verbose) llOwnerSay("Worm Cam");
            llClearCameraParams();
            llSetCameraParams([12,1,8,180.0,9,0.0,7,(g_fDist + 4),6,0.0,22,0,11,2.5,0,-35.0,5,1.0,21,0,10,1.0,1,<0.0,0.0,0.0>]);
            (g_iCamLock = 0);
            (g_iPersNr = 1);
            (g_iPerspective = 0);
        }
        else  if ((g_iPerspective == 1)) {
            if (verbose) llOwnerSay("Center Cam");
            llClearCameraParams();
            llSetCameraParams([12,1,8,0.0,9,0.0,7,g_fDist,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,0.0,0.75>]);
            (g_iCamLock = 0);
            (g_iPersNr = 1);
            (g_iPerspective = 1);
        }
        else  {
            (g_iPerspective = 0);
            defCam();
        }
    }
    else  {
        if ((g_iPerspective == -1)) {
            if (verbose) llOwnerSay("Left Shoulder");
            llClearCameraParams();
            llSetCameraParams([12,1,8,5.0,9,0.0,7,g_fDist,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,0.5,0.75>]);
            (g_iCamLock = 0);
            (g_iPersNr = 0);
            (g_iPerspective = -1);
        }
        else  if ((g_iPerspective == 0)) {
            if (verbose) llOwnerSay("Shoulder Cam");
            llClearCameraParams();
            llSetCameraParams([12,1,8,5.0,9,0.0,7,g_fDist,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
            (g_iCamLock = 0);
            (g_iPersNr = 0);
            (g_iPerspective = 0);
        }
        else  if ((g_iPerspective == 1)) shoulderCamRight();
        else  {
            (g_iPerspective = 0);
            defCam();
        }
    }
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================

//-----------------------------------------------

default {

	state_entry() {
        (CH = 8374);
        (g_kOwner = llGetOwner());
        (g_sScriptName = llGetScriptName());
        integer rc = 0;
        (rc = llSetMemoryLimit(50000));
        if ((verbose && (!rc))) {
            llOwnerSay((((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - could not set memory limit"));
        }
        
        llListenRemove(g_iHandle);
        (g_iHandle = llListen(CH,"",g_kOwner,""));
        if ((0 && g_iOn)) llRequestPermissions(g_kOwner,3072);
        else  {
            (g_iNr = -1);
            setButtonCol(0);
        }
        setCol(g_iOn);
        llOwnerSay(((((g_sTitle + " (") + g_sVersion) + ") written/enhanced by ") + g_sAuthors));
        if (verbose) {
            
            llOwnerSay(((((((((("\n\t-used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
        }
        llOwnerSay(("HUD listens on channel: " + ((string)CH)));
        if ((verbose || 0)) {
            llOwnerSay("*Long touch on colored buttons to save current view*\n*long touch on death sign to delete current positions,\n\teven longer touch to clear all saved positions and turn off*");
            llOwnerSay("Long touch on CameraControl button for on/default view\ntouch death sign to get SL standard\n\nPressing ESC key resets camera perspective to default/last chosen one,\nuse this to end manual mode after camerawalking");
            llOwnerSay("available chat commands:\n'cam1' to 'cam4' to recall saved camera positions,\n '1' to '4' to recall that camera or the next stored,\ncycling trough saved positions or given perspectives with 'cam' 'cycle' cycle2'\n'distance' to change distance and switch on/off, or use 'default', 'delete', 'clear', 'help' and all other menu entries");
        }
    }



	touch_start(integer num_detected) {
        if (verbose) llOwnerSay("*Long touch to save/delete/reset*");
        llResetTime();
        (g_iNr = llDetectedLinkNumber(0));
        if (((2 < g_iNr) && g_iOn)) setButtonCol(0);
        (perm = llGetPermissions());
        
    }



	touch(integer num_detected) {
        if (g_iMsg) {
            if ((!((perm & 2048) && (perm & 1024)))) {
                (g_iMsg = 0);
                (g_iOn = 0);
                (g_iNr = 1);
                do  {
                    setButtonCol(-1);
                }
                while ((7 > (g_iNr++)));
                llOwnerSay("To work camera permissions are needed\nend clicking to get menu");
                return;
            }
            float time = llGetTime();
            if ((time > 1.3)) {
                if (g_iMsg2) {
                    (g_iMsg2 = 0);
                    if (verbose) llOwnerSay("touch registered");
                    if ((1 < g_iNr)) setButtonCol(-1);
                }
                else  if ((time >= 2.8)) {
                    (g_iMsg = 0);
                    if (verbose) llOwnerSay("long touch registered");
                    if ((3 == g_iNr)) {
                        setButtonCol(0);
                    }
                }
            }
        }
    }



	touch_end(integer num_detected) {
        (g_iMsg = (g_iMsg2 = 1));
        float time = llGetTime();
        string status = "off";
        if ((((time > 1.3) && (3 < g_iNr)) && (perm & 1024))) {
            if ((4 == g_iNr)) {
                (g_vPos1 = llGetCameraPos());
                (g_vFoc1 = (g_vPos1 + llRot2Fwd(llGetCameraRot())));
                (g_iCam1 = 1);
                
            }
            else  if ((5 == g_iNr)) {
                (g_vPos2 = llGetCameraPos());
                (g_vFoc2 = (g_vPos2 + llRot2Fwd(llGetCameraRot())));
                (g_iCam2 = 1);
                
            }
            else  if ((6 == g_iNr)) {
                (g_vPos3 = llGetCameraPos());
                (g_vFoc3 = (g_vPos3 + llRot2Fwd(llGetCameraRot())));
                (g_iCam3 = 1);
                
            }
            else  if ((7 == g_iNr)) {
                (g_vPos4 = llGetCameraPos());
                (g_vFoc4 = (g_vPos4 + llRot2Fwd(llGetCameraRot())));
                (g_iCam4 = 1);
                
            }
            else  return;
            if (verbose) llOwnerSay("Cam position saved");
            setButtonCol(1);
            (g_iCamPos = 1);
        }
        else  if ((perm & 2048)) {
            if ((time < 1.3)) {
                if ((3 == g_iNr)) {
                    if (g_iOn) setButtonCol(1);
                    llClearCameraParams();
                    llSetCameraParams([12,1]);
                    (g_iCamLock = 0);
                    llOwnerSay("Resetting view to SL standard");
                }
                else  if (g_iOn) {
                    if ((2 == g_iNr)) {
                        if (verbose) (status = "on");
                        llDialog(g_kOwner,((("Script version: " + g_sVersion) + "\n\nWhat do you want to do?\n\tverbose: ") + status),MENU_MAIN,CH);
                    }
                    else  if ((4 == g_iNr)) setCam("cam1");
                    else  if ((5 == g_iNr)) setCam("cam2");
                    else  if ((6 == g_iNr)) setCam("cam3");
                    else  if ((7 == g_iNr)) setCam("cam4");
                }
                else  {
                    if (verbose) (status = "on");
                    llDialog(g_kOwner,((("Script version: " + g_sVersion) + "\n\nHUD is disabled\nDo you want to enable CameraControl?\n\tverbose: ") + status),["verbose","help","CLOSE","ON"],CH);
                }
            }
            else  if ((3 == g_iNr)) {
                resetCamPos();
                if ((time < 2.8)) {
                    
                    if (g_iOn) setButtonCol(1);
                    else  setButtonCol(0);
                }
                else  releaseCamCtrl();
            }
            else  if ((2 >= g_iNr)) {
                if (g_iOn) {
                    setButtonCol(1);
                    defCam();
                    if (verbose) llOwnerSay("Setting default view");
                }
                else  {
                    takeCamCtrl("");
                    defCam();
                }
            }
        }
        else  {
            if (verbose) (status = "on");
            llDialog(g_kOwner,((("Script version: " + g_sVersion) + "\n\nHUD has not all needed permissions\nDo you want to let CameraControl HUD take over your camera?\n\tverbose: ") + status),["verbose","help","CLOSE","ON"],CH);
        }
    }



//listen to usercommands
//-----------------------------------------------
	listen(integer channel,string name,key id,string message) {
        (message = llToLower(message));
        string status = "off";
        if (("more..." == message)) llDialog(id,"Pick an option!",["...Back","help","CLOSE","Me","Worm","Drop","Spin","Spaz","---","DEFAULT","Center","STANDARD"],CH);
        else  if (("...back" == message)) llDialog(id,(("Script version: " + g_sVersion) + "\n\nWhat do you want to do?"),MENU_MAIN,CH);
        else  if (("help" == message)) {
            llOwnerSay(("HUD listens on channel: " + ((string)CH)));
            if ((verbose || 1)) {
                llOwnerSay("*Long touch on colored buttons to save current view*\n*long touch on death sign to delete current positions,\n\teven longer touch to clear all saved positions and turn off*");
                llOwnerSay("Long touch on CameraControl button for on/default view\ntouch death sign to get SL standard\n\nPressing ESC key resets camera perspective to default/last chosen one,\nuse this to end manual mode after camerawalking");
                llOwnerSay("available chat commands:\n'cam1' to 'cam4' to recall saved camera positions,\n '1' to '4' to recall that camera or the next stored,\ncycling trough saved positions or given perspectives with 'cam' 'cycle' cycle2'\n'distance' to change distance and switch on/off, or use 'default', 'delete', 'clear', 'help' and all other menu entries");
            }
        }
        else  if (("verbose" == message)) {
            (verbose = (!verbose));
            if (verbose) llOwnerSay("Verbose messages turned ON");
            else  llOwnerSay("Verbose messages turned OFF");
        }
        else  if ((("---" == message) || ("close" == message))) return;
        else  if (("distance" == message)) {
            (perm = llGetPermissions());
            if ((perm & 2048)) {
                if (g_iFar) {
                    (g_iOn = 0);
                    (g_iFar = 0);
                    releaseCamCtrl();
                }
                else  if ((!g_iOn)) {
                    takeCamCtrl("");
                }
                else  (g_iFar = 1);
                if (g_iFar) (g_fDist = 2.0);
                else  (g_fDist = 0.5);
                if (g_iOn) setPers();
            }
            else  {
                if (verbose) (status = "on");
                llDialog(g_kOwner,((("Script version: " + g_sVersion) + "\n\nHUD has not all needed permissions\nDo you want to let CameraControl HUD take over your camera?\n\tverbose: ") + status),["verbose","help","CLOSE","ON"],CH);
            }
        }
        else  if (("on" == message)) {
            if ((!g_iOn)) {
                (perm = llGetPermissions());
                if (((perm & 2048) && (perm & 1024))) {
                    takeCamCtrl("");
                    defCam();
                }
                else  takeCamCtrl(id);
            }
        }
        else  if (("off" == message)) {
            releaseCamCtrl();
        }
        else  if (("clear" == message)) {
            resetCamPos();
            releaseCamCtrl();
        }
        else  if (("delete" == message)) {
            (g_iNr = 3);
            setButtonCol(-1);
            llSleep(0.2);
            setButtonCol(1);
            resetCamPos();
        }
        else  if (("standard" == message)) {
            if (g_iOn) {
                (g_iNr = 3);
                setButtonCol(0);
                llClearCameraParams();
                llSetCameraParams([12,1]);
                (g_iCamLock = 0);
                llOwnerSay("Resetting view to SL standard");
                llSleep(0.2);
                setButtonCol(1);
            }
            else  releaseCamCtrl();
        }
        else  if (g_iOn) {
            if (((~llSubStringIndex(message,"cam")) || (((string)((integer)message)) == message))) {
                if (g_iCamPos) {
                    if (("cam" == message)) {
                        (++g_iCamNr);
                        if ((g_iCamNr > 4)) (g_iCamNr = 1);
                        setCam(((string)g_iCamNr));
                    }
                    else  setCam(message);
                }
                else  llOwnerSay("No camera positions saved");
            }
            else  if (("cycle" == message)) {
                (g_iPersNr = 0);
                (++g_iPerspective);
                if ((g_iPerspective > 1)) (g_iPerspective = -1);
                setPers();
            }
            else  if (("cycle2" == message)) {
                (g_iPersNr = 1);
                (++g_iPerspective);
                if ((g_iPerspective > 1)) (g_iPerspective = -1);
                setPers();
            }
            else  if (("left" == message)) {
                if (verbose) llOwnerSay("Left Shoulder");
                llClearCameraParams();
                llSetCameraParams([12,1,8,5.0,9,0.0,7,g_fDist,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,0.5,0.75>]);
                (g_iCamLock = 0);
                (g_iPersNr = 0);
                (g_iPerspective = -1);
            }
            else  if (("shoulder" == message)) {
                if (verbose) llOwnerSay("Shoulder Cam");
                llClearCameraParams();
                llSetCameraParams([12,1,8,5.0,9,0.0,7,g_fDist,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
                (g_iCamLock = 0);
                (g_iPersNr = 0);
                (g_iPerspective = 0);
            }
            else  if (("right" == message)) {
                shoulderCamRight();
            }
            else  if (("center" == message)) {
                if (verbose) llOwnerSay("Center Cam");
                llClearCameraParams();
                llSetCameraParams([12,1,8,0.0,9,0.0,7,g_fDist,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,0.0,0.75>]);
                (g_iCamLock = 0);
                (g_iPersNr = 1);
                (g_iPerspective = 1);
            }
            else  if (("me" == message)) {
                if (verbose) llOwnerSay("Focussing on yourself");
                llClearCameraParams();
                vector here = llGetPos();
                llSetCameraParams([12,1,8,0.0,9,0.0,7,0.0,17,here,6,0.0,22,1,11,0.0,13,(here + <(1.5 + (2 * g_fDist)),(1.5 + (2 * g_fDist)),(1.5 + (2 * g_fDist))>),5,0.0,21,1,10,0.0,1,ZERO_VECTOR]);
                (g_iCamLock = 1);
                (g_iPersNr = 1);
                (g_iPerspective = -1);
            }
            else  if (("worm" == message)) {
                if (verbose) llOwnerSay("Worm Cam");
                llClearCameraParams();
                llSetCameraParams([12,1,8,180.0,9,0.0,7,(g_fDist + 4),6,0.0,22,0,11,2.5,0,-35.0,5,1.0,21,0,10,1.0,1,<0.0,0.0,0.0>]);
                (g_iCamLock = 0);
                (g_iPersNr = 1);
                (g_iPerspective = 0);
            }
            else  if (("drop" == message)) {
                if (verbose) llOwnerSay("Dropping camera");
                llSetCameraParams([12,1,8,0.0,9,0.5,7,(g_fDist + 1),6,2.0,22,0,11,0.0,0,0.0,5,5.0e-2,21,1,10,0.0,1,<0.0,0.0,0.0>]);
                (g_iCamLock = 1);
            }
            else  if (("spin" == message)) {
                llClearCameraParams();
                llSetCameraParams([12,1,8,180.0,9,0.5,6,5.0e-2,22,0,11,0.0,0,30.0,5,0.0,21,0,10,0.0,1,<0.0,0.0,0.0>]);
                float i;
                vector camera_position;
                for ((i = 0); (i < 12.5663706); (i += 2.5e-2)) {
                    (camera_position = (llGetPos() + (<0.0,(3.0 + g_fDist),0.0> * llEuler2Rot(<0.0,0.0,i>))));
                    llSetCameraParams([13,camera_position]);
                    llSleep(2.0e-2);
                }
                (g_iCamLock = 0);
                defCam();
            }
            else  if (("spaz" == message)) {
                if (verbose) llOwnerSay("Spaz cam for 7 seconds");
                float _i15;
                for ((_i15 = 0); (_i15 < 70); (_i15 += 1)) {
                    vector xyz = (llGetPos() + <(llFrand(80.0) - 40),(llFrand(80.0) - 40),llFrand(10.0)>);
                    vector xyz2 = (llGetPos() + <(llFrand(80.0) - 40),(llFrand(80.0) - 40),llFrand(10.0)>);
                    llSetCameraParams([12,1,8,180.0,9,llFrand(3.0),7,llFrand(10.0),6,llFrand(3.0),22,1,11,llFrand(4.0),0,(llFrand(125.0) - 45),13,xyz2,5,llFrand(3.0),21,1,10,llFrand(4.0),1,<(llFrand(20.0) - 10),(llFrand(20.0) - 10),(llFrand(20) - 10)>]);
                    llSleep(0.1);
                }
                (g_iCamLock = 1);
                defCam();
            }
            else  if (("default" == message)) {
                (g_iNr = 2);
                setButtonCol(-1);
                defCam();
                llSleep(0.2);
                setButtonCol(1);
            }
        }
        else  if ((!g_iOn)) {
            if (verbose) (status = "on");
            if (((perm & 2048) && (perm & 1024))) llDialog(g_kOwner,((("Script version: " + g_sVersion) + "\n\nHUD is disabled\nDo you want to enable CameraControl?\n\tverbose: ") + status),["verbose","help","CLOSE","ON"],CH);
            else  llDialog(g_kOwner,((("Script version: " + g_sVersion) + "\n\nHUD has not all needed permissions\nDo you want to let CameraControl HUD take over your camera?\n\tverbose: ") + status),["verbose","help","CLOSE","ON"],CH);
        }
        else  llOwnerSay((("Invalid option picked (" + message) + ").\n"));
    }



	run_time_permissions(integer _perm0) {
        if ((_perm0 & 2048)) {
            llSetCameraParams([12,1]);
            (g_iOn = 1);
            setCol(g_iOn);
            llOwnerSay(("Camera permissions have been taken \nAvatar key: " + ((string)llGetPermissionsKey())));
            setPers();
        }
    }



	changed(integer change) {
        if ((change & 256)) {
            if (g_iCamLock) defCam();
            if (g_iCamPos) resetCamPos();
        }
        if ((change & 128)) llResetScript();
    }



	attach(key id) {
        if ((id == g_kOwner)) {
            llListenRemove(g_iHandle);
            (g_iHandle = llListen(CH,"",g_kOwner,""));
            if ((1 && g_iOn)) llRequestPermissions(g_kOwner,3072);
            else  {
                (g_iNr = -1);
                setButtonCol(0);
            }
            setCol(g_iOn);
            llOwnerSay(((((g_sTitle + " (") + g_sVersion) + ") written/enhanced by ") + g_sAuthors));
            if (verbose) {
                
                llOwnerSay(((((((((("\n\t-used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
            }
            llOwnerSay(("HUD listens on channel: " + ((string)CH)));
            if ((verbose || 0)) {
                llOwnerSay("*Long touch on colored buttons to save current view*\n*long touch on death sign to delete current positions,\n\teven longer touch to clear all saved positions and turn off*");
                llOwnerSay("Long touch on CameraControl button for on/default view\ntouch death sign to get SL standard\n\nPressing ESC key resets camera perspective to default/last chosen one,\nuse this to end manual mode after camerawalking");
                llOwnerSay("available chat commands:\n'cam1' to 'cam4' to recall saved camera positions,\n '1' to '4' to recall that camera or the next stored,\ncycling trough saved positions or given perspectives with 'cam' 'cycle' cycle2'\n'distance' to change distance and switch on/off, or use 'default', 'delete', 'clear', 'help' and all other menu entries");
            }
        }
        else  llResetScript();
    }
}
