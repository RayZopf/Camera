Improved CameraControl (CameraScript)
=====================================================================
_Version 2.5 (Script 2.7.1)_  
Aims
----
bugfixes, general improvements, new features  

Todo
----
Readme for HUD functions, help lines in script are probably not enough  
make changing views always work (looks like some SL glitch when trying to change perspectives too fast/to the previous one)  
further code cleanup  
modularize  
let HUD save camera positions per SIM  
have settings notecard for camera positions and/or perspectives  

Comparison
----
***|CameraControl HUD|Firestorm Phototools camera -- Advanced phototools camera controls|Black Dragon Viewer
:-----------------:|-------------------|-------------------|-------------------
_Speed_|slow, depending on server load and lag even slower - changing perspective sometimes needs several tries/several changes between different perspectives, esp. with manually saved ones|fast|fast
_Script count_|1 (one), currently around 50kB - needs to use workaround for noscript areas (e.g. another script - [vitality](http://wiki.secondlife.com/wiki/Script_Vitality_plug-in) (1 script, reports 64kB, uses less)|none, Firestrom function, works everywhere - same as FS AO| none, Black Dragon function
_Interface_|small HUD, gesture support (__use of hotkeys__)|big popup (way to big to keep open all the time), many preferences (Firestorm settings)|small camera UI
_Saved positions_|4 (four) resetting on region change (e.g. teleport), persisting relog if region is not changed (login to last location)|1 (one), persisting relog _added in Firestorm 4.6.1_|??? need to check
_Setting up perspectives_|useful presets (right/left shoulder) - for further changes edit those in script (nasty)| 3 (three) - if 'rear view' is not good enough you need to use/change debug settings, as described in [Penny Patton's blog entry](http://pennycow.blogspot.de/2011/07/matter-of-perspective.html), [more detailed by Ciaran Laval](http://sl.governormarley.com/?p=483) or [modified  by Mona Eberhardt](https://monaeberhardt.wordpress.com/2014/02/10/revisiting-the-issue-of-camera-placement/)|five slots for presets, adjustable via sliders
_Camera perspectives_|also some dynamic presets (spin, spaz)|only static ones, machinima stuff|static ones, massive machinima stuff

Improved CameraControl by Vaelissa Cortes/Core Taurog has less perspectives and features, but therefore takes less display space and may be easier to use 
(see branch _original_, __yet not released__)


Components
==========
Script-base
-------
see script header  
[assuming this is the base of all](http://wiki.secondlife.com/wiki/FollowCam)  

Objects
-------
The prims representing the HUD are currently not found in this repo, only used textures.  
Basically the HUD is constructed like this
 - Original HUD: Hidden/Invisible root prim holding main script, long CameraControl prim below holding a Button script to communicate via linked_message
 - Enhanced HUD:  
  - Hidden/invisible root prim holding main script, vitality script, gestures to put into inventory for activation
  - below: broad CameraControl prim, without scripts (link number = root +1)
  - right sided: Kill Button prim (link number = root +2)
  - below: four Buttons for camera postions, each one prim  

Gestures are not all found in this repo
 - currently using 5:
  - switch between saved camera positions
  - switch back to default view
  - 2 * cycle trough camera perspective presets
  - toggle distance/on/off

Tools
-------
modified LSLForge.exe
 - [patch (less parenthesis/ OpenSim compatibility)](https://code.google.com/p/lslforge/issues/detail?id=3)
 - two more additions to have changed version number in script (*.lsl) output


Licensing
========
