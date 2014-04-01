// Camera Sharing v0.3
// Original written by Adeon Writer and idea by Sylvie Link
// This script is open source. Wall of Text here:
// http://www.opensource.org/licenses/gpl-3.0.html

// Script name: "1.) Request Camera Data"
// This script goes into a prim along with the script called "2.) Track their Camera"
// Once both scripts are in the same prim, wear it.

vector pos;
key target;
string targetFirstName;
string ownerFirstName;
//string cameraScript = "2.) Track their Camera"; // Name of the script that controls camera position/rotation. (Must be in with this script)
list avatars;


any_state_on_rez(integer start)
{
    llResetScript();
}

any_state_listen(integer channel, string name, key id, string message)
{
    if(channel == 1)
    {
        if(llToLower(message) == "stop")
        {
            // Only listen to two people who say stop on channel 1: Either the owner, or the current target.
            if(id==llGetOwner())
            {
                llOwnerSay("Stopping. Your camera has been returned to you.");
                llInstantMessage(target, ownerFirstName + " has stopped viewing your camera.");
                llMessageLinked(LINK_THIS, 2, "0", "");
                llResetScript();
            }
            else if(id==target)
            {
                llOwnerSay(targetFirstName + " has requested that you stop viewing their camera. Your camera is being returned to you.");
                llInstantMessage(target, "At your request, " + ownerFirstName + " has stopped viewing your camera and permissions have been revoked.");
                llMessageLinked(LINK_THIS, 2, "0", "");
                llResetScript();
            }
        }
    }
}

default
{
    on_rez(integer start)
    {
        any_state_on_rez(start);
    }
    
    state_entry()
    {
            llOwnerSay("Type /1 start to begin viewing someone's camera.");
            llListen(1, "", llGetOwner(), "start");
            ownerFirstName = llGetSubString(llKey2Name(llGetOwner()), 0, llSubStringIndex(llKey2Name(llGetOwner()), " ")-1); // Note to self: Request a llGetFirstName function
        if(llGetAttached() != 0)
        {
            //llResetOtherScript(cameraScript); // Housekeeping. All llResetScripts();'s in this script rely on the fact that it will also reset this script too.
        }
    }
    
    sensor(integer num)
    {
        integer i;
        avatars = [];
        for(i=0; i<num&&i<12; i++) // 12 max
        {
            avatars += [llDetectedName(i)];
            avatars += [llDetectedKey(i)];
        }
        llListen(317341, "", llGetOwner(), "");
        llDialog(llGetOwner(), "Who's camera would you like to view?", llList2ListStrided(avatars, 0, -1, 2), 317341);
    }
    
    no_sensor()
    {
        llOwnerSay("No nearby avatars were found.");
    }


    link_message(integer link, integer num, string str, key id)
    {
        if(num == 1)
        {
            if(llToLower(str)=="start")
            {
                llSensor("", NULL_KEY, AGENT, 96, PI); // Scan for nearby avatars to populate avatar picker dialog
            }
        }
    }

    
    listen(integer channel, string name, key id, string message)
    {
    	llOwnerSay((string)channel + "-" + name +"-"+ (string)id + " " + message);
        if(channel == 1)
        {
            if(llToLower(message)=="start")
            {
                llSensor("", NULL_KEY, AGENT, 96, PI); // Scan for nearby avatars to populate avatar picker dialog
            }
        }
        else if(channel == 317341)
        {
            integer index = llListFindList(avatars, [message]);
            if(index != -1)
            {
                target = llList2Key(avatars, index+1);
                targetFirstName = llGetSubString(message, 0, llSubStringIndex(message, " ")-1);
                state avatarChosen;
            }
        }
    }
}

state avatarChosen // assumes target, targetFirstName, and ownerFirstName have expected values.
{
    on_rez(integer start)
    {
        any_state_on_rez(start);
    }


    link_message(integer link, integer num, string str, key id)
    {
        any_state_listen(num, id, id, str); // global listen event
    }


    listen(integer channel, string name, key id, string message)
    {
        any_state_listen(channel, name, id, message); // global listen event
    }
    
    state_entry()
    {
        llListen(1, "", NULL_KEY, "stop"); // Listen for stop command
        llOwnerSay("Requesting " + targetFirstName + "'s permission to view their camera... give them a moment to answer the dialog. To cancel this request, type /1 stop");
        llRequestPermissions(target, PERMISSION_TRACK_CAMERA);
        llInstantMessage(target, llKey2Name(llGetOwner()) + " is requesting permission to share your camera. Please accept if you wish to allow this. You may stop this at any time by typing/shouting \"/1 stop\"");
    }
    
    run_time_permissions(integer perm)
    {
        if(perm & PERMISSION_TRACK_CAMERA)
        {
            llOwnerSay(targetFirstName + " accepted your request to track their camera. You are now viewing their camera. If this is not working, press ESC twice to exit your alt-cam. To stop viewing their camera, type /1 stop");
            llMessageLinked(LINK_THIS, 2, "1", "");
            state tracking;
        }
        else
        {
            llOwnerSay(targetFirstName + " declined your request to view their camera.");
            llMessageLinked(LINK_THIS, 2, "0", "");
            llResetScript();
        }
    }
}

state tracking // Assumes target, targetFirstName, and ownerFirstName have expected values, and that script has obtained PERMISSION_TRACK_CAMERA from target
{
    on_rez(integer start)
    {
        any_state_on_rez(start);
    }
    
    
    link_message(integer link, integer num, string str, key id)
    {
        any_state_listen(num, id, id, str); // global listen event
    }
    
    
    listen(integer channel, string name, key id, string message)
    {
        any_state_listen(channel, name, id, message); // global listen event
    }
    
    state_entry()
    {
        llListen(1, "", NULL_KEY, "stop"); // Listen for stop command
        llInstantMessage(target, llKey2Name(llGetOwner()) + " has started viewing your camera. Say /1 stop at any time to revoke permission.");
        llSetTimerEvent(0.05);
    }
    
    attach(key id)
    {
        if(id==NULL_KEY)
        {
            llInstantMessage(target, llKey2Name(llGetOwner()) + " has stopped viewing your camera.");
            llSetTimerEvent(0);
        }
    }
        
    timer()
    {
        pos = llGetCameraPos();
        llMessageLinked(LINK_THIS, 0, (string)pos, (string)(pos+llRot2Fwd(llGetCameraRot())));
    }
}