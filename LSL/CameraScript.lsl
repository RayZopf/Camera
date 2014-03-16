// LSL script generated: LSL.CameraScript.lslp Sun Mar 16 16:06:29 Mitteleuropäische Zeit 2014
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
//v2.46
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
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//GLOBAL VARIABLES
//===============================================

//user changeable variables
//-----------------------------------------------
integer verbose;

//SCRIPT MESSAGE MAP
integer CH;


//internal variables
//-----------------------------------------------
string g_sTitle = "CameraScript";
string g_sVersion = "2.46";
string g_sScriptName;
string g_sAuthors = "Dan Linden, Penny Patton, Zopf";

// Constants
list MENU_MAIN = ["More...","help","CLOSE","Left","Shoulder","Right","ON","Distance","OFF"];


// Variables
key g_kOwner;

integer g_iHandle = 0;
integer g_iOn = 0;
integer g_iPerspective = 0;

// for gesture support
integer g_iFar = 0;
float g_fDist = 0.5;

// for saving positions
integer g_iNr;
integer g_iMsg = 1;
vector g_vPos1;
vector g_vFoc1;
vector g_vPos2;
vector g_vFoc2;
integer g_iCamPos = 0;

//project specific modules
//-----------------------------------------------


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

initExtension(integer conf){
    llListenRemove(1);
    llListenRemove(g_iHandle);
    (g_iHandle = llListen(CH,"",g_kOwner,""));
    if (conf) llRequestPermissions(g_kOwner,3072);
    setColor(g_iOn);
    llOwnerSay(((((g_sTitle + " (") + g_sVersion) + ") written/enhanced by ") + g_sAuthors));
    if (verbose) {
        
        llOwnerSay(((((((((("\n\t-used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
    }
    llOwnerSay(("HUD listens on channel: " + ((string)CH)));
    if ((verbose || 0)) llOwnerSay("*Long touch on colored buttons to save current view*\n*long touch on death sign to delete current positions,\n\teven longer touch to clear all saved positions*\n\nPressing ESC key resets camera perspective to default/last chosen one,\nuse this to end manual mode after camerawalking");
}


setColor(integer on){
    if (on) {
        llSetLinkPrimitiveParamsFast(2,[18,-1,<1.0,1.0,1.0>,1]);
        llSetLinkPrimitiveParamsFast(3,[18,-1,<0.7,1.0,1.0>,1]);
    }
    else  {
        llSetLinkPrimitiveParamsFast(2,[18,-1,<0.5,0.5,0.5>,0.85]);
        llSetLinkPrimitiveParamsFast(3,[18,-1,<0.75,0.75,0.75>,0.95]);
    }
}


resetCamPos(){
    (g_vPos1 = ZERO_VECTOR);
    (g_vFoc1 = ZERO_VECTOR);
    (g_vPos2 = ZERO_VECTOR);
    (g_vFoc2 = ZERO_VECTOR);
    (g_iCamPos = 0);
    defCam();
}


defCam(){
    shoulderCamRight();
}


shoulderCamRight(){
    if (verbose) llOwnerSay("Right Shoulder");
    llClearCameraParams();
    llSetCameraParams([12,1,8,0.0,9,0.0,7,g_fDist,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
    (g_iPerspective = 1);
}


setPers(){
    if ((!g_iOn)) {
        key id = llGetOwner();
        llOwnerSay("release CamCtrl");
        llClearCameraParams();
        (g_iOn = 0);
        setColor(g_iOn);
        return;
    }
    if ((g_iPerspective == -1)) {
        if (verbose) llOwnerSay("Left Shoulder");
        llClearCameraParams();
        llSetCameraParams([12,1,8,5.0,9,0.0,7,g_fDist,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,0.5,0.75>]);
        (g_iPerspective = -1);
    }
    else  if ((g_iPerspective == 0)) {
        if (verbose) llOwnerSay("Shoulder Cam");
        llClearCameraParams();
        llSetCameraParams([12,1,8,5.0,9,0.0,7,g_fDist,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
        (g_iPerspective = 0);
    }
    else  if ((g_iPerspective == 1)) {
        shoulderCamRight();
    }
    else  {
        key _id4 = llGetOwner();
        llOwnerSay("release CamCtrl");
        llClearCameraParams();
        (g_iOn = 0);
        setColor(g_iOn);
    }
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================

//-----------------------------------------------

default {

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

	state_entry() {
        (verbose = 0);
        (CH = 8374);
        (g_kOwner = llGetOwner());
        (g_sScriptName = llGetScriptName());
        integer rc = 0;
        (rc = llSetMemoryLimit(42000));
        if ((verbose && (!rc))) {
            llOwnerSay((((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - could not set memory limit"));
        }
        
        initExtension(0);
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

	touch_start(integer num_detected) {
        if (verbose) llOwnerSay("*Long touch to save/delete*");
        llResetTime();
        (g_iNr = llDetectedLinkNumber(0));
        
    }



	touch(integer num_detected) {
        if ((g_iMsg && (llGetTime() > 1.3))) {
            if (((3 == g_iNr) || (4 == g_iNr))) llOwnerSay("Cam position saved");
            else  if ((5 == g_iNr)) llOwnerSay("Saved cam positions deleted");
            (g_iMsg = 0);
        }
    }


	touch_end(integer num_detected) {
        (g_iMsg = 1);
        integer perm = llGetPermissions();
        if ((perm & 2048)) {
            if ((llGetTime() < 1.3)) {
                if ((2 == g_iNr)) {
                    llDialog(g_kOwner,(("Script version: " + g_sVersion) + "\n\nWhat do you want to do?"),MENU_MAIN,CH);
                }
                else  if ((3 == g_iNr)) {
                    llClearCameraParams();
                    llSetCameraParams([12,1,17,g_vFoc1,6,0.0,22,1,13,g_vPos1,5,0.0,21,1]);
                    (g_iCamPos = 1);
                    
                }
                else  if ((4 == g_iNr)) {
                    llClearCameraParams();
                    llSetCameraParams([12,1,17,g_vFoc2,6,0.0,22,1,13,g_vPos2,5,0.0,21,1]);
                    (g_iCamPos = 1);
                    
                }
                else  if ((5 == g_iNr)) defCam();
            }
            else  {
                if ((3 == g_iNr)) {
                    (g_vPos1 = llGetCameraPos());
                    (g_vFoc1 = (g_vPos1 + llRot2Fwd(llGetCameraRot())));
                    
                }
                else  if ((4 == g_iNr)) {
                    (g_vPos2 = llGetCameraPos());
                    (g_vFoc2 = (g_vPos2 + llRot2Fwd(llGetCameraRot())));
                    
                }
                else  if ((5 == g_iNr)) resetCamPos();
            }
        }
        else  llDialog(g_kOwner,(("Script version: " + g_sVersion) + "\n\nDo you want to enable CameraControl?"),["---","help","CLOSE","ON"],CH);
    }



//listen to usercommands
//-----------------------------------------------
	listen(integer channel,string name,key id,string message) {
        (message = llToLower(message));
        if (("more..." == message)) llDialog(id,"Pick an option!",["...Back","help","CLOSE","Me","Worm","Drop","Spin","Spaz","---","Center","---","DEFAULT"],CH);
        else  if (("...back" == message)) llDialog(id,(("Script version: " + g_sVersion) + "\n\nWhat do you want to do?"),MENU_MAIN,CH);
        else  if (("help" == message)) {
            llOwnerSay(("HUD listens on channel: " + ((string)CH)));
            if ((verbose || 1)) llOwnerSay("*Long touch on colored buttons to save current view*\n*long touch on death sign to delete current positions,\n\teven longer touch to clear all saved positions*\n\nPressing ESC key resets camera perspective to default/last chosen one,\nuse this to end manual mode after camerawalking");
        }
        else  if (("cycle" == message)) {
            (++g_iPerspective);
            if ((g_iPerspective > 1)) {
                (g_iPerspective = -1);
            }
            setPers();
        }
        else  if (("cycle2" == message)) {
            (++g_iPerspective);
            if ((g_iPerspective > 1)) {
                (g_iPerspective = -1);
            }
            setPers();
        }
        else  if (("distance" == message)) {
            if (g_iFar) {
                (g_iOn = 0);
                (g_iFar = 0);
            }
            else  if (((!g_iFar) && (!g_iOn))) {
                (g_iOn = 1);
                (g_iFar = 0);
            }
            else  {
                (g_iOn = 1);
                (g_iFar = 1);
            }
            if (g_iFar) (g_fDist = 2.0);
            else  (g_fDist = 0.5);
            setPers();
        }
        else  if (("on" == message)) {
            if (verbose) llOwnerSay(("take CamCtrl\nAvatar key: " + ((string)id)));
            llRequestPermissions(id,3072);
            llSetCameraParams([12,1]);
            (g_iOn = 1);
            setColor(g_iOn);
        }
        else  if (("off" == message)) {
            llOwnerSay("release CamCtrl");
            llClearCameraParams();
            (g_iOn = 0);
            setColor(g_iOn);
        }
        else  if (("left" == message)) {
            if (verbose) llOwnerSay("Left Shoulder");
            llClearCameraParams();
            llSetCameraParams([12,1,8,5.0,9,0.0,7,g_fDist,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,0.5,0.75>]);
            (g_iPerspective = -1);
        }
        else  if (("shoulder" == message)) {
            if (verbose) llOwnerSay("Shoulder Cam");
            llClearCameraParams();
            llSetCameraParams([12,1,8,5.0,9,0.0,7,g_fDist,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
            (g_iPerspective = 0);
        }
        else  if (("right" == message)) {
            shoulderCamRight();
        }
        else  if (("center" == message)) {
            if (verbose) llOwnerSay("Center Cam");
            llClearCameraParams();
            llSetCameraParams([12,1,8,0.0,9,0.0,7,g_fDist,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,0.0,0.75>]);
        }
        else  if (("default" == message)) {
            llClearCameraParams();
            llSetCameraParams([12,1]);
        }
        else  if (("me" == message)) {
            if (verbose) llOwnerSay("Focussing on yourself");
            llClearCameraParams();
            vector here = llGetPos();
            llSetCameraParams([12,1,8,0.0,9,0.0,7,g_fDist,17,here,6,0.0,22,1,11,0.0,13,(here + <3.0,3.0,3.0>),5,0.0,21,1,10,0.0,1,ZERO_VECTOR]);
        }
        else  if (("worm" == message)) {
            if (verbose) llOwnerSay("Worm Cam");
            llClearCameraParams();
            llSetCameraParams([12,1,8,180.0,9,0.0,7,(g_fDist + 4),6,0.0,22,0,11,2.5,0,-35.0,5,1.0,21,0,10,1.0,1,<0.0,0.0,0.0>]);
        }
        else  if (("drop" == message)) {
            if (verbose) llOwnerSay("Dropping camera");
            llSetCameraParams([12,1,8,0.0,9,0.5,7,(g_fDist + 1),6,2.0,22,0,11,0.0,0,0.0,5,5.0e-2,21,1,10,0.0,1,<0.0,0.0,0.0>]);
        }
        else  if (("spin" == message)) {
            llClearCameraParams();
            llSetCameraParams([12,1,8,180.0,9,0.5,7,(g_fDist + 6),6,5.0e-2,22,0,11,0.0,0,30.0,5,0.0,21,0,10,0.0,1,<0.0,0.0,0.0>]);
            float i;
            vector camera_position;
            for ((i = 0); (i < 12.5663706); (i += 2.5e-2)) {
                (camera_position = (llGetPos() + (<0.0,4.0,0.0> * llEuler2Rot(<0.0,0.0,i>))));
                llSetCameraParams([13,camera_position]);
                llSleep(2.0e-2);
            }
            defCam();
        }
        else  if (("spaz" == message)) {
            if (verbose) llOwnerSay("Spaz cam for 7 seconds");
            float _i14;
            for ((_i14 = 0); (_i14 < 70); (_i14 += 1)) {
                vector xyz = (llGetPos() + <(llFrand(80.0) - 40),(llFrand(80.0) - 40),llFrand(10.0)>);
                vector xyz2 = (llGetPos() + <(llFrand(80.0) - 40),(llFrand(80.0) - 40),llFrand(10.0)>);
                llSetCameraParams([12,1,8,180.0,9,llFrand(3.0),7,llFrand(10.0),6,llFrand(3.0),22,1,11,llFrand(4.0),0,(llFrand(125.0) - 45),13,xyz2,5,llFrand(3.0),21,1,10,llFrand(4.0),1,<(llFrand(20.0) - 10),(llFrand(20.0) - 10),(llFrand(20) - 10)>]);
                llSleep(0.1);
            }
            defCam();
        }
        else  if ((!(("---" == message) || ("close" == message)))) llOwnerSay((((name + " picked invalid option '") + message) + "'.\n"));
    }



	run_time_permissions(integer perm) {
        if ((perm & 2048)) {
            llSetCameraParams([12,1]);
            llOwnerSay("Camera permissions have been taken");
            defCam();
        }
    }



	changed(integer change) {
        if ((change & 256)) if (g_iCamPos) resetCamPos();
        if ((change & 128)) llResetScript();
    }



	attach(key id) {
        if ((id == g_kOwner)) {
            initExtension(1);
        }
        else  llResetScript();
    }
}
