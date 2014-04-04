// LSL script generated - patched Render.hs (0.1.3.2): LSL.RequestCameraData2.lslp Fri Apr  4 14:22:31 Mitteleuropäische Sommerzeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Sync Control
//
//parts from:
// Camera Sharing v0.3
// Original written by Adeon Writer and idea by Sylvie Link
// This script is open source. Wall of Text here:
// http://www.opensource.org/licenses/gpl-3.0.html
//
//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: link messages
//04. Apr. 2014
//v0.5
//

//Files:
//RequestCameraData2.lsl
//
//NAME OF NOTEDACRD
//
//
//Prequisites: CameraScript.lsl
//Notecard format: ----
//basic help: ----
//
//Changelog
// Formatting
// LSL Forge modules
// code cleanup

//FIXME: ---

//TODO: ---
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//GLOBAL VARIABLES
//===============================================

//internal variables
//-----------------------------------------------
string g_sTitle = "RequestCameraData";
string g_sVersion = "0.5";
string g_sAuthors = "Zopf";

// Constants

// Variables
vector pos;
key target;
string targetFirstName;
string g_sOwnerName;
string ownerFirstName;
list avatars;
integer verbose = 1;
string g_sScriptName;
integer silent = 0;
key g_kOwner;
integer g_iHandle = 0;
integer g_iSyncPerms = 0;
integer CH;
integer COMMAND_CH = 1;
integer REMOTE_CH = 2;
integer CAM_CH = 0;
integer AVI_CH = 1010;



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================

//-----------------------------------------------

default {

	state_entry() {
        CH = (integer)(llFrand(-1.0e9) - 1.0e9);
        
        g_kOwner = llGetOwner();
        g_sScriptName = llGetScriptName();
        integer rc = 0;
        rc = llSetMemoryLimit(24000);
        if (verbose && !rc) {
            llOwnerSay("(v) " + g_sTitle + "/" + g_sScriptName + " - could not set memory limit");
        }
        
        llSleep(1);
        if (!silent) llOwnerSay(g_sTitle + " (" + g_sVersion + ") written/enhanced by " + g_sAuthors);
        if (!silent && verbose) {
            
            llOwnerSay("\n\t-used/max available memory: " + (string)llGetUsedMemory() + "/" + (string)llGetMemoryLimit() + " - free: " + (string)llGetFreeMemory() + "-\n(v) " + g_sTitle + "/" + g_sScriptName);
        }
        llSetLinkPrimitiveParamsFast(5,[26,"",ZERO_VECTOR,0]);
        llMessageLinked(-4,2,"0","");
        g_sOwnerName = llKey2Name(g_kOwner);
        ownerFirstName = llGetSubString(g_sOwnerName,0,llSubStringIndex(g_sOwnerName," ") - 1);
    }



	link_message(integer link,integer num,string str,key id) {
        if (COMMAND_CH != num) return;
        str = llToLower(str);
        if ("stop" == str) {
            if (id == target) {
                llOwnerSay(targetFirstName + " has requested that you stop viewing their camera. Your camera is being returned to you.");
                llInstantMessage(target,"At your request, " + ownerFirstName + " has stopped viewing your camera and permissions have been revoked.");
                llSetLinkPrimitiveParamsFast(5,[26,"",ZERO_VECTOR,0]);
                llMessageLinked(-4,REMOTE_CH,"0","");
            }
            else  {
                llOwnerSay("Stopping. Your camera has been returned to you.");
                llInstantMessage(target,ownerFirstName + " has stopped viewing your camera.");
                llSetLinkPrimitiveParamsFast(5,[26,"",ZERO_VECTOR,0]);
                llMessageLinked(-4,REMOTE_CH,"0","");
            }
            llResetScript();
        }
        else  if ("start" == str) llSensor("",NULL_KEY,1,96,3.14159265);
    }



//listen to usercommands
//gain permissions to use camera
//-----------------------------------------------
	listen(integer channel,string name,key id,string message) {
        if (AVI_CH == channel && "stop" == llToLower(message)) {
            if (id == target) {
                llOwnerSay(targetFirstName + " has requested that you stop viewing their camera. Your camera is being returned to you.");
                llInstantMessage(target,"At your request, " + ownerFirstName + " has stopped viewing your camera and permissions have been revoked.");
                llSetLinkPrimitiveParamsFast(5,[26,"",ZERO_VECTOR,0]);
                llMessageLinked(-4,REMOTE_CH,"0","");
            }
            else  {
                llOwnerSay("Stopping. Your camera has been returned to you.");
                llInstantMessage(target,ownerFirstName + " has stopped viewing your camera.");
                llSetLinkPrimitiveParamsFast(5,[26,"",ZERO_VECTOR,0]);
                llMessageLinked(-4,REMOTE_CH,"0","");
            }
            llResetScript();
        }
        if (CH == channel) {
            llListenRemove(g_iHandle);
            integer index = llListFindList(avatars,[message]);
            if (index != -1) {
                target = llList2Key(avatars,index + 1);
                targetFirstName = llGetSubString(message,0,llSubStringIndex(message," ") - 1);
                llOwnerSay("Requesting " + targetFirstName + "'s permission to view their camera... give them a moment to answer the dialog.");
                llRequestPermissions(target,1024);
                g_iHandle = llListen(AVI_CH,"",target,"");
                llInstantMessage(target,g_sOwnerName + " is requesting permission to share your camera. Please accept if you wish to allow this. You may stop this at any time by typing/shouting \"/" + (string)AVI_CH + " stop\"");
            }
        }
    }



	sensor(integer num) {
        integer i;
        avatars = [];
        for (i = 0; i < num && i < 12; i++) {
            string name = llDetectedName(i);
            if (24 < llStringLength(name)) name = llGetSubString(name,0,23);
            avatars += [name];
            avatars += [llDetectedKey(i)];
        }
        llListenRemove(g_iHandle);
        g_iHandle = llListen(CH,"",g_kOwner,"");
        llDialog(llGetOwner(),"Who's camera would you like to view?",llList2ListStrided(avatars,0,-1,2),CH);
    }



	no_sensor() {
        llOwnerSay("No nearby avatars were found.");
    }



	timer() {
        pos = llGetCameraPos();
        llMessageLinked(-4,CAM_CH,(string)pos,(string)(pos + llRot2Fwd(llGetCameraRot())));
    }



	run_time_permissions(integer perm) {
        if (perm & 1024) {
            llOwnerSay(targetFirstName + " accepted your request to track their camera. You are now viewing their camera. If this is not working, press ESC twice to exit your alt-cam.");
            llMessageLinked(-4,REMOTE_CH,"1","");
            llSetLinkPrimitiveParamsFast(5,[26,"\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t[" + targetFirstName + "]",<1.0,1.0,1.0>,1]);
            g_iSyncPerms = 1;
            llInstantMessage(target,g_sOwnerName + " has started viewing your camera. Say /" + (string)AVI_CH + " stop at any time to revoke permission.");
            llSetTimerEvent(5.0e-2);
        }
        else  {
            llOwnerSay(targetFirstName + " declined your request to view their camera.");
            llMessageLinked(-4,REMOTE_CH,"0","");
        }
    }



	changed(integer change) {
        if (change & 128) llResetScript();
    }



	attach(key id) {
        if (id) {
            if (id == g_kOwner) {
                if (!silent) llOwnerSay(g_sTitle + " (" + g_sVersion + ") written/enhanced by " + g_sAuthors);
                if (!silent && verbose) {
                    
                    llOwnerSay("\n\t-used/max available memory: " + (string)llGetUsedMemory() + "/" + (string)llGetMemoryLimit() + " - free: " + (string)llGetFreeMemory() + "-\n(v) " + g_sTitle + "/" + g_sScriptName);
                }
                llSetLinkPrimitiveParamsFast(5,[26,"",ZERO_VECTOR,0]);
                llMessageLinked(-4,2,"0","");
                g_sOwnerName = llKey2Name(g_kOwner);
                ownerFirstName = llGetSubString(g_sOwnerName,0,llSubStringIndex(g_sOwnerName," ") - 1);
            }
        }
        else  if (id == NULL_KEY && g_iSyncPerms) {
            llInstantMessage(target,g_sOwnerName + " has stopped viewing your camera.");
            llResetScript();
        }
        llSetTimerEvent(0);
    }
}
