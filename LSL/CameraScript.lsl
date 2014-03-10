// LSL script generated: Camera.LSL.CameraScript.lslp Mon Mar 10 16:48:48 Mitteleuropäische Zeit 2014
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




//internal variables
//-----------------------------------------------
string g_sTitle = "CameraScript";
string g_sVersion = "1.2";
string g_sScriptName;
string g_sAuthors = "Zopf";

// Constants
list MENU_MAIN = ["Centre","Right","Left","Cam ON","Cam OFF"];
list MENU_2 = ["More...","...Back"];

//SCRIPT MESSAGE MAP
integer CH;

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

initExtension(integer conf){
    setup_listen();
    if (conf) llRequestPermissions(g_kOwner,2048);
    llOwnerSay(((((g_sTitle + " (") + g_sVersion) + ") Enhancements by ") + g_sAuthors));
    {
        
        llOwnerSay(((((((((("\n\t-used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
    }
}


//most important function
//-----------------------------------------------
take_camera_control(key id){
    llOwnerSay("take_camera_control");
    llOwnerSay(((string)id));
    llRequestPermissions(id,2048);
    llSetCameraParams([12,1]);
    (g_iOn = 1);
}


release_camera_control(key id){
    llOwnerSay("release_camera_control");
    llClearCameraParams();
    (g_iOn = 0);
}


default_cam(){
    llClearCameraParams();
    llSetCameraParams([12,1]);
}


shoulder_cam2(){
    llOwnerSay("Right Shoulder");
    default_cam();
    llSetCameraParams([12,1,8,0.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
}


shoulder_cam(){
    llOwnerSay("shoulder_cam");
    default_cam();
    llSetCameraParams([12,1,8,5.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,-0.5,0.75>]);
}


shoulder_cam3(){
    llOwnerSay("Left Shoulder");
    default_cam();
    llSetCameraParams([12,1,8,5.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,0.5,0.75>]);
}


centre_cam(){
    llOwnerSay("centre_cam");
    default_cam();
    llSetCameraParams([12,1,8,0.0,9,0.0,7,0.5,6,1.0e-2,22,0,11,0.0,0,15.0,5,0.1,21,0,10,0.0,1,<-0.5,0.0,0.75>]);
}


drop_camera_5_seconds(){
    llOwnerSay("drop_camera_5_seconds");
    llSetCameraParams([12,1,8,0.0,9,0.5,7,3.0,6,2.0,22,0,11,0.0,0,0.0,5,5.0e-2,21,1,10,0.0,1,<0.0,0.0,0.0>]);
    llSleep(5);
    default_cam();
}


worm_cam(){
    llOwnerSay("worm_cam");
    llSetCameraParams([12,1,8,180.0,9,0.0,7,8.0,6,0.0,22,0,11,4.0,0,-45.0,5,1.0,21,0,10,1.0,1,<0.0,0.0,0.0>]);
}


spin_cam(){
    llSetCameraParams([12,1,8,180.0,9,0.5,6,5.0e-2,22,0,11,0.0,0,30.0,5,0.0,21,0,10,0.0,1,<0.0,0.0,0.0>]);
    float i;
    vector camera_position;
    for ((i = 0); (i < 12.5663706); (i += 5.0e-2)) {
        (camera_position = (llGetPos() + (<0.0,4.0,0.0> * llEuler2Rot(<0.0,0.0,i>))));
        llSetCameraParams([13,camera_position]);
    }
    default_cam();
}


setup_listen(){
    llListenRemove(1);
    llListenRemove(g_iHandle);
    (CH = (-50000 - llRound((llFrand(1) * 100000))));
    (g_iHandle = llListen(CH,"",g_kOwner,""));
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

	state_entry() {
        integer rc = 0;
        (rc = llSetMemoryLimit(24000));
        if ((1 && (!rc))) {
            llOwnerSay((((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - could not set memory limit"));
        }
        (g_kOwner = llGetOwner());
        (g_sScriptName = llGetScriptName());
        
        initExtension(0);
    }



//listen for linked messages from other scripts and devices
//-----------------------------------------------
	link_message(integer sender_num,integer num,string str,key id) {
        if ((str == "cam")) {
            integer perm = llGetPermissions();
            if ((perm & 2048)) llDialog(id,"What do you want to do?",MENU_MAIN,CH);
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
                take_camera_control(id);
            }
            else  if ((message == "Cam OFF")) {
                release_camera_control(id);
            }
            else  if ((message == "Default")) {
                default_cam();
            }
            else  if ((message == "Right")) {
                shoulder_cam2();
            }
            else  if ((message == "Worm Cam")) {
                worm_cam();
            }
            else  if ((message == "Centre")) {
                centre_cam();
            }
            else  if ((message == "Left")) {
                shoulder_cam3();
            }
            else  if ((message == "Shoulder")) {
                shoulder_cam();
            }
            else  if ((message == "Drop Cam")) {
                drop_camera_5_seconds();
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
                spin_cam();
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
        if ((change & 32)) {
            key id = llAvatarOnSitTarget();
            if (id) {
                initExtension(1);
            }
        }
        if ((change & 128)) llResetScript();
    }



	attach(key id) {
        if ((id == g_kOwner)) {
            initExtension(1);
            shoulder_cam();
        }
        else  llResetScript();
    }
}
