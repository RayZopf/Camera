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
string g_sTitle = "RequestCameraData";     // title
string g_sVersion = "0.5";            // version
string g_sAuthors = "Zopf";

// Constants

// Variables
vector pos;
key target;
string targetFirstName;
string g_sOwnerName;
string ownerFirstName;
list avatars;


//===============================================
//LSLForge MODULES
//===============================================

//general modules
//-----------------------------------------------
$import Debug2.lslm(m_sScriptName=g_sScriptName);
$import MemoryManagement2.lslm(m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_iVerbose=verbose);

//project specific modules
//-----------------------------------------------
$import CameraMessageMap.lslm();


//===============================================
//PREDEFINED FUNCTIONS
//===============================================


// pragma inline
initExtension()
{
	if (!silent) llOwnerSay(g_sTitle +" ("+ g_sVersion +") written/enhanced by "+g_sAuthors);
	if (!silent && verbose) MemInfo(FALSE);

	llSetLinkPrimitiveParamsFast(5, [PRIM_TEXT, "", ZERO_VECTOR, 0]);
	llMessageLinked(LINK_THIS, 2, "0", "");
	g_sOwnerName = llKey2Name(g_kOwner);
	ownerFirstName = llGetSubString(g_sOwnerName, 0, llSubStringIndex(g_sOwnerName, " ")-1);
}


// pragma inline
toggleSyncCtrl(key id)
{
	if(id == target)
	{
		llOwnerSay(targetFirstName + " has requested that you stop viewing their camera. Your camera is being returned to you.");
		llInstantMessage(target, "At your request, " + ownerFirstName + " has stopped viewing your camera and permissions have been revoked.");
		llSetLinkPrimitiveParamsFast(5, [PRIM_TEXT, "", ZERO_VECTOR, 0]);
		llMessageLinked(LINK_THIS, REMOTE_CH, "0", "");
	} else {
		llOwnerSay("Stopping. Your camera has been returned to you.");
		llInstantMessage(target, ownerFirstName + " has stopped viewing your camera.");
		llSetLinkPrimitiveParamsFast(5, [PRIM_TEXT, "", ZERO_VECTOR, 0]);
		llMessageLinked(LINK_THIS, REMOTE_CH, "0", "");
	}

	llResetScript();
}


// pragma inline
dialogScans()
{
	llListenRemove(g_iHandle);
	g_iHandle = llListen(CH, "", g_kOwner, "");
	llDialog(llGetOwner(), "Who's camera would you like to view?", llList2ListStrided(avatars, 0, -1, 2), CH);
}


// pragma inline
setupListen()
{
	g_iHandle = llListen(AVI_CH, "", target, ""); // listen avi
	llInstantMessage(target, g_sOwnerName + " is requesting permission to share your camera. Please accept if you wish to allow this. You may stop this at any time by typing/shouting \"/"+(string)AVI_CH+" stop\"");
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
		CH = (integer)(llFrand(-1000000000.0) - 1000000000.0);;

		g_kOwner = llGetOwner();
		g_sScriptName = llGetScriptName();

		MemRestrict(24000, FALSE);
		if (debug) Debug("state_entry", TRUE, TRUE);

		llSleep(1);
		initExtension();
	}


	link_message(integer link, integer num, string str, key id)
	{
		if (COMMAND_CH != num) return;
		
		str = llToLower(str);
		if("stop" == str) toggleSyncCtrl(id);
			else if ("start" == str) llSensor("", NULL_KEY, AGENT, 96, PI); // Scan for nearby avatars to populate avatar picker dialog
	}


//listen to usercommands
//gain permissions to use camera
//-----------------------------------------------
	listen(integer channel, string name, key id, string message)
	{
		if (AVI_CH == channel && "stop" == llToLower(message)) toggleSyncCtrl(id);
		
		if(CH == channel) {
			llListenRemove(g_iHandle);

			integer index = llListFindList(avatars, [message]);
			if(index != -1)
			{
				target = llList2Key(avatars, index+1);
				targetFirstName = llGetSubString(message, 0, llSubStringIndex(message, " ")-1);

				llOwnerSay("Requesting " + targetFirstName + "'s permission to view their camera... give them a moment to answer the dialog.");
				llRequestPermissions(target, PERMISSION_TRACK_CAMERA);
				setupListen();
			}
		}
	}


	sensor(integer num)
	{
		integer i;
		avatars = [];

		for(i=0; i<num&&i<12; i++) // 12 max
		{
			string name = llDetectedName(i);
			if (24 < llStringLength(name)) name = llGetSubString(name, 0, 23);
			avatars += [name];
			avatars += [llDetectedKey(i)];
		}
		dialogScans();
	}


	no_sensor()
	{
		llOwnerSay("No nearby avatars were found.");
		//llMessageLinked(LINK_THIS, 2, "0", "");   // don't do this, let timer catch it - maybe user want's a second try
	}


	timer()
	{
		pos = llGetCameraPos();
		llMessageLinked(LINK_THIS, CAM_CH, (string)pos, (string)(pos+llRot2Fwd(llGetCameraRot())));
	}


	run_time_permissions(integer perm)
	{
		if(perm & PERMISSION_TRACK_CAMERA)
		{
			llOwnerSay(targetFirstName + " accepted your request to track their camera. You are now viewing their camera. If this is not working, press ESC twice to exit your alt-cam.");
			llMessageLinked(LINK_THIS, REMOTE_CH, "1", "");
			llSetLinkPrimitiveParamsFast(5, [PRIM_TEXT, "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t["+targetFirstName+"]", <1,1,1>, 1]);
			g_iSyncPerms = TRUE;
			llInstantMessage(target, g_sOwnerName + " has started viewing your camera. Say /"+(string)AVI_CH+" stop at any time to revoke permission.");
			llSetTimerEvent(0.05);
		}
		else
		{
			llOwnerSay(targetFirstName + " declined your request to view their camera.");
			llMessageLinked(LINK_THIS, REMOTE_CH, "0", "");
		}
	}


	changed(integer change)
	{
		if (change & CHANGED_OWNER) llResetScript();
	}


	attach(key id)
	{
		if (id) { if (id == g_kOwner) initExtension(); }
			else if (id==NULL_KEY && g_iSyncPerms) {
				llInstantMessage(target, g_sOwnerName + " has stopped viewing your camera.");
				llResetScript();
			}

		llSetTimerEvent(0);
	}

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}