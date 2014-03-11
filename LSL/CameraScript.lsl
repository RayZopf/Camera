// LSL script generated: Camera.LSL.CameraScript.lslp Tue Mar 11 15:51:57 Mitteleuropäische Zeit 2014
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
//v1.43
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

//FIXME: on script changes, one need toreattach HUD to get workinh cam menu
//FIXME: on first start, using "off" throws script error: Script trying to clear camera parameters but PERMISSION_CONTROL_CAMERA permission not set!

//TODO: add notecard, so one can set up camera views per specific place
//TODO: use fix listen channel, so that user can change options via chat
//TODO: maybe use llDetectedTouchFace/llDetectedTouchPos/llDetectedLinkNumber/llDetectedTouchST instead of link messages
//TODO: reset view on teleport if it is on a presaved one
//TODO: less message spamming
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
string g_sVersion = "1.43";
string g_sScriptName;
string g_sAuthors = "Dan Linden, Penny Patton, Zopf";

// Constants
list MENU_MAIN = ["More...","---","CLOSE","Left","Centre","Right","ON","OFF","---"];
//list MENU_2 = ["...Back", "---", "CLOSE", "Worm", "Drop", "Spin"]; // menu 2, commented out, as long as iy only used once


// Variables
key g_kOwner;

integer g_iHandle = 0;
integer g_iOn = 0;
integer trap = 0;

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
    llOwnerSay(((((((g_sTitle + " (") + g_sVersion) + ") written/enhanced by ") + g_sAuthors) + "\nHUD listens on channel: ") + ((string)CH)));
    if (verbose) {
        
        llOwnerSay(((((((((("\n\t-used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
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
    llOwnerSay("Right Shoulder");
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
        (verbose = 1);
        (CH = -987444);
        (g_kOwner = llGetOwner());
        (g_sScriptName = llGetScriptName());
        integer rc = 0;
        (rc = llSetMemoryLimit(32000));
        if (verbose) if ((!rc)) {
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
        llOwnerSay("*Long touch on colored buttons, to save current view*");
        llResetTime();
        (g_iNr = llDetectedLinkNumber(0));
        
    }



	touch(integer num_detected) {
        if ((g_iMsg && (llGetTime() > 1.3))) {
            if (((3 == g_iNr) || (4 == g_iNr))) llOwnerSay("Cam position saved");
            else  if ((5 == g_iNr)) llOwnerSay("Saved cam position deleted");
            (g_iMsg = 0);
        }
    }


	touch_end(integer num_detected) {
        (g_iMsg = 1);
        integer perm = llGetPermissions();
        if ((perm & 2048)) {
            if ((llGetTime() < 1.3)) {
                if ((2 == g_iNr)) {
                    llDialog(g_kOwner,"What do you want to do?",MENU_MAIN,CH);
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
    }



//user interaction
//listen to usercommands
//-----------------------------------------------
	listen(integer channel,string name,key id,string message) {
        (message = llToLower(message));
        if (("more..." == message)) llDialog(id,"Pick an option!",["...Back","---","CLOSE","Worm","Drop","Spin"],CH);
        else  if (("...back" == message)) llDialog(id,"What do you want to do?",MENU_MAIN,CH);
        else  if (("on" == message)) {
            llOwnerSay(("take CamCtrl\nAvatar key: " + ((string)id)));
            llRequestPermissions(id,3072);
            llSetCameraParams([12,1]);
            (g_iOn = 1);
        }
        else  if (("off" == message)) {
            llOwnerSay("release CamCtrl");
            llClearCameraParams();
            (g_iOn = 0);
        }
        else  if (("default" == message)) {
            llClearCameraParams();
            llSetCameraParams([12,1]);
        }
        else  if (("right" == message)) {
            llOwnerSay("Right Shoulder");
            llClearCameraParams();
            llSetCameraParams([12,1,8,0.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
        }
        else  if (("worm" == message)) {
            llOwnerSay("Worm Cam");
            llClearCameraParams();
            llSetCameraParams([12,1,8,180.0,9,0.0,7,8.0,6,0.0,22,0,11,4.0,0,-45.0,5,1.0,21,0,10,1.0,1,<0.0,0.0,0.0>]);
        }
        else  if (("centre" == message)) {
            llOwnerSay("Center Cam");
            llClearCameraParams();
            llSetCameraParams([12,1,8,0.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,0.0,0.75>]);
        }
        else  if (("left" == message)) {
            llOwnerSay("Left Shoulder");
            llClearCameraParams();
            llSetCameraParams([12,1,8,5.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,0.5,0.75>]);
        }
        else  if (("shoulder" == message)) {
            llOwnerSay("Shoulder Cam");
            llClearCameraParams();
            llSetCameraParams([12,1,8,5.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
        }
        else  if (("drop" == message)) {
            llOwnerSay("drop camera 5 seconds");
            llSetCameraParams([12,1,8,0.0,9,0.5,7,3.0,6,2.0,22,0,11,0.0,0,0.0,5,5.0e-2,21,1,10,0.0,1,<0.0,0.0,0.0>]);
            llSleep(5);
            defCam();
        }
        else  if ((message == "Trap Toggle")) {
            (trap = (!trap));
            if ((trap == 1)) {
                llOwnerSay("trap is on");
            }
            else  {
                llOwnerSay("trap is off");
            }
        }
        else  if (("spin" == message)) {
            llClearCameraParams();
            llSetCameraParams([12,1,8,180.0,9,0.5,6,5.0e-2,22,0,11,0.0,0,30.0,5,0.0,21,0,10,0.0,1,<0.0,0.0,0.0>]);
            float i;
            vector camera_position;
            for ((i = 0); (i < 12.5663706); (i += 5.0e-2)) {
                (camera_position = (llGetPos() + (<0.0,4.0,0.0> * llEuler2Rot(<0.0,0.0,i>))));
                llSetCameraParams([13,camera_position]);
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
