// LSL script generated: LSL.CameraScript.lslp Thu Mar 13 18:36:01 Mitteleuropäische Zeit 2014
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
//13. Mrz. 2014
//v1.46
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
string g_sVersion = "1.46";
string g_sScriptName;
string g_sAuthors = "Dan Linden, Penny Patton, Zopf";

// Constants
list MENU_MAIN = ["More...","help","CLOSE","Left","Shoulder","Right","ON","Center","OFF"];
//list MENU_2 = ["...Back", "---", "CLOSE", "Worm", "Drop", "Spin"]; // menu 2, commented out, as long as iy only used once


// Variables
key g_kOwner;

integer g_iHandle = 0;
integer g_iOn = 0;

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
    llOwnerSay(((((g_sTitle + " (") + g_sVersion) + ") written/enhanced by ") + g_sAuthors));
    if (verbose) {
        
        llOwnerSay(((((((((("\n\t-used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
    }
    llOwnerSay(("HUD listens on channel: " + ((string)CH)));
    if ((verbose || 0)) llOwnerSay("*Long touch on colored buttons to save current view*\n*long touch on death sign to delete current positions,\n\teven longer touch to clear all saved positions*\n\nPressing ESC key resets camera perspective to default/last chosen one,\nuse this to end manual mode after camerawalking");
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
    if (verbose) llOwnerSay("Right Shoulder");
    llClearCameraParams();
    llSetCameraParams([12,1,8,0.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
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
        (CH = 987444);
        (g_kOwner = llGetOwner());
        (g_sScriptName = llGetScriptName());
        integer rc = 0;
        (rc = llSetMemoryLimit(30000));
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
        if (("more..." == message)) llDialog(id,"Pick an option!",["...Back","help","CLOSE","Me","Worm","Drop","Spin","Spaz","DEFAULT"],CH);
        else  if (("...back" == message)) llDialog(id,(("Script version: " + g_sVersion) + "\n\nWhat do you want to do?"),MENU_MAIN,CH);
        else  if (("help" == message)) {
            llOwnerSay(("HUD listens on channel: " + ((string)CH)));
            if ((verbose || 1)) llOwnerSay("*Long touch on colored buttons to save current view*\n*long touch on death sign to delete current positions,\n\teven longer touch to clear all saved positions*\n\nPressing ESC key resets camera perspective to default/last chosen one,\nuse this to end manual mode after camerawalking");
        }
        else  if (("on" == message)) {
            if (verbose) llOwnerSay(("take CamCtrl\nAvatar key: " + ((string)id)));
            llRequestPermissions(id,3072);
            llSetCameraParams([12,1]);
            (g_iOn = 1);
        }
        else  if (("off" == message)) {
            llOwnerSay("release CamCtrl");
            llClearCameraParams();
            (g_iOn = 0);
        }
        else  if (("left" == message)) {
            if (verbose) llOwnerSay("Left Shoulder");
            llClearCameraParams();
            llSetCameraParams([12,1,8,5.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,0.5,0.75>]);
        }
        else  if (("shoulder" == message)) {
            if (verbose) llOwnerSay("Shoulder Cam");
            llClearCameraParams();
            llSetCameraParams([12,1,8,5.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
        }
        else  if (("right" == message)) {
            if (verbose) llOwnerSay("Right Shoulder");
            llClearCameraParams();
            llSetCameraParams([12,1,8,0.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
        }
        else  if (("center" == message)) {
            if (verbose) llOwnerSay("Center Cam");
            llClearCameraParams();
            llSetCameraParams([12,1,8,0.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,0.0,0.75>]);
        }
        else  if (("default" == message)) {
            llClearCameraParams();
            llSetCameraParams([12,1]);
        }
        else  if (("me" == message)) {
            if (verbose) llOwnerSay("Focussing on yourself");
            llClearCameraParams();
            vector here = llGetPos();
            llSetCameraParams([12,1,8,0.0,9,0.0,7,0.0,17,here,6,0.0,22,1,11,0.0,13,(here + <3.0,3.0,3.0>),5,0.0,21,1,10,0.0,1,ZERO_VECTOR]);
        }
        else  if (("worm" == message)) {
            if (verbose) llOwnerSay("Worm Cam");
            llClearCameraParams();
            llSetCameraParams([12,1,8,180.0,9,0.0,7,8.0,6,0.0,22,0,11,2.5,0,-35.0,5,1.0,21,0,10,1.0,1,<0.0,0.0,0.0>]);
        }
        else  if (("drop" == message)) {
            if (verbose) llOwnerSay("Dropping camera");
            llSetCameraParams([12,1,8,0.0,9,0.5,7,3.0,6,2.0,22,0,11,0.0,0,0.0,5,5.0e-2,21,1,10,0.0,1,<0.0,0.0,0.0>]);
        }
        else  if (("spin" == message)) {
            llClearCameraParams();
            llSetCameraParams([12,1,8,180.0,9,0.5,6,5.0e-2,22,0,11,0.0,0,30.0,5,0.0,21,0,10,0.0,1,<0.0,0.0,0.0>]);
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
            float _i12;
            for ((_i12 = 0); (_i12 < 70); (_i12 += 1)) {
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
