// LSL script generated: Camera.LSL.CameraScript.lslp Tue Mar 11 00:07:57 Mitteleuropäische Zeit 2014
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
//Additions: ----
//10. Mrz. 2014
//v1.21
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

//FIXME: ----

//TODO: add notecard, so one can set up camera views per specific place
//TODO: use fix listen channel, so that user can change options via chat
//TODO: maybe use llDetectedTouchFace/llDetectedTouchPos/llDetectedLinkNumber/llDetectedTouchST instead of link messages
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
string g_sVersion = "1.21";
string g_sScriptName;
string g_sAuthors = "Dan Linden, Penny Patton, Zopf";

// Constants
list MENU_MAIN = ["More ...","---","CLOSE","Centre","Right","Left","Cam ON","Cam OFF","---"];
list MENU_2 = ["...Back","---","CLOSE","Worm Cam","Drop Cam","Spin Cam"];


// Variables
key g_kOwner;

integer g_iHandle = 0;
integer g_iOn = 0;
integer trap = 0;

//project specific modules
//-----------------------------------------------


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

initExtension(integer conf){
    llListenRemove(1);
    llListenRemove(g_iHandle);
    (g_iHandle = llListen(CH,"",g_kOwner,""));
    if (conf) llRequestPermissions(g_kOwner,2048);
    llOwnerSay(((((g_sTitle + " (") + g_sVersion) + ") written/enhanced by ") + g_sAuthors));
    if (verbose) {
        
        llOwnerSay(((((((((("\n\t-used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
    }
    llClearCameraParams();
}


shoulderCam(){
    llOwnerSay("Shoulder Cam");
    llClearCameraParams();
    llSetCameraParams([12,1,8,5.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
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
        (CH = -987444);
        (g_kOwner = llGetOwner());
        (g_sScriptName = llGetScriptName());
        integer rc = 0;
        (rc = llSetMemoryLimit(30000));
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

	touch_end(integer num_detected) {
        integer nr = llDetectedLinkNumber(0);
        if ((1 == nr)) {
            integer perm = llGetPermissions();
            if ((perm & 2048)) llDialog(g_kOwner,"What do you want to do?",MENU_MAIN,CH);
        }
    }



//user interaction
//listen to usercommands
//-----------------------------------------------
	listen(integer channel,string name,key id,string message) {
        if ((~llListFindList((MENU_MAIN + MENU_2),[message]))) {
            if ((message == "More...")) llDialog(id,"Pick an option!",MENU_2,CH);
            else  if ((message == "...Back")) llDialog(id,"What do you want to do?",MENU_MAIN,CH);
            else  if ((message == "Cam ON")) {
                llOwnerSay(("take CamCtrl\n" + ((string)id)));
                llRequestPermissions(id,2048);
                llSetCameraParams([12,1]);
                (g_iOn = 1);
            }
            else  if ((message == "Cam OFF")) {
                llOwnerSay("release CamCtrl");
                llClearCameraParams();
                (g_iOn = 0);
            }
            else  if ((message == "Default")) {
                llClearCameraParams();
                llSetCameraParams([12,1]);
            }
            else  if ((message == "Right")) {
                llOwnerSay("Right Shoulder");
                llClearCameraParams();
                llSetCameraParams([12,1,8,0.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
            }
            else  if ((message == "Worm Cam")) {
                llOwnerSay("Worm Cam");
                llClearCameraParams();
                llSetCameraParams([12,1,8,180.0,9,0.0,7,8.0,6,0.0,22,0,11,4.0,0,-45.0,5,1.0,21,0,10,1.0,1,<0.0,0.0,0.0>]);
            }
            else  if ((message == "Centre")) {
                llOwnerSay("Center Cam");
                llClearCameraParams();
                llSetCameraParams([12,1,8,0.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,0.0,0.75>]);
            }
            else  if ((message == "Left")) {
                llOwnerSay("Left Shoulder");
                llClearCameraParams();
                llSetCameraParams([12,1,8,5.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,0.5,0.75>]);
            }
            else  if ((message == "Shoulder")) {
                shoulderCam();
            }
            else  if ((message == "Drop Cam")) {
                llOwnerSay("drop camera 5 seconds");
                llSetCameraParams([12,1,8,0.0,9,0.5,7,3.0,6,2.0,22,0,11,0.0,0,0.0,5,5.0e-2,21,1,10,0.0,1,<0.0,0.0,0.0>]);
                llSleep(5);
                llClearCameraParams();
                llSetCameraParams([12,1]);
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
            else  if ((message == "Spin Cam")) {
                llSetCameraParams([12,1,8,180.0,9,0.5,6,5.0e-2,22,0,11,0.0,0,30.0,5,0.0,21,0,10,0.0,1,<0.0,0.0,0.0>]);
                float i;
                vector camera_position;
                for ((i = 0); (i < 12.5663706); (i += 5.0e-2)) {
                    (camera_position = (llGetPos() + (<0.0,4.0,0.0> * llEuler2Rot(<0.0,0.0,i>))));
                    llSetCameraParams([13,camera_position]);
                }
                llClearCameraParams();
                llSetCameraParams([12,1]);
            }
        }
        else  llOwnerSay((((name + " picked invalid option '") + llToLower(message)) + "'."));
    }



	run_time_permissions(integer perm) {
        if ((perm & 2048)) {
            llSetCameraParams([12,1]);
            llOwnerSay("Camera permissions have been taken");
        }
    }



	changed(integer change) {
        if ((change & 128)) llResetScript();
    }



	attach(key id) {
        if ((id == g_kOwner)) {
            initExtension(1);
            llOwnerSay("Right Shoulder");
            llClearCameraParams();
            llSetCameraParams([12,1,8,0.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
        }
        else  llResetScript();
    }
}
