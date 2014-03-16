Improved CameraControl CameraScript
=====================================================================
Aims
----
bugfixes, general improvements, new features  

Todo
----
further code cleanup  
modularize  
let HUD save camera positions per SIM  

Comparison
----
***|CameraControl HUD|Firestorm Phototools camera -- Advanced phototools camera controls|Black Dragon Viewer
:-----------------:|-------------------|-------------------|-----------------
_Speed_|slow, depending on server load and lag even slower|fast|fast
_Script count_|1 (one), currently around 32kB - needs to use workaround for noscript areas|none, Firestrom function, works everywhere - same as FS AO| none, Black Dragon function
_Saved positions_|4 (four) resetting on region change (e.g. teleport)|1 (one), persisting relog _added in Firestorm 4.6.1_|??? need to check
_Setting up perspectives_|useful presets (right/left shoulder) - for further changes edit those in script (nasty)| 3 (three) - if 'rear view' is not good enough you need to use/change debug settings, as described in [Penny Patton's blog entry](http://pennycow.blogspot.de/2011/07/matter-of-perspective.html), [more detailed by Ciaran Laval](http://sl.governormarley.com/?p=483) or [modified  by Mona Eberhardt](https://monaeberhardt.wordpress.com/2014/02/10/revisiting-the-issue-of-camera-placement/)|five slots for presets, adjustable via sliders
_Camera perspectives_|also some dynamic presets (spin, spaz)|only static ones|static ones, machinima stuff
_Interface_|small HUD, gesture support|big popup (way to big to keep open all the time), many preferences (Firestorm settings)|small camera UI


Components
==========
Script-base
-------
see script header  

Objects
-------




Licensing
========
