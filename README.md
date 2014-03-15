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
***|Phototools camera -- Advanced phototools camera controls|CameraControl HUD
:-----------------:|------------------------|-------------------
_Speed_|fast|slow, depending on server load and lag even slower
_Script count_|none, Firestrom function, works everywhere - same as FS AO|1 (one), currently around 32kB - needs to use workaround for noscript areas
_Saved positions_|1 (one) as of Firestorm 4.6.1, persisting relog|4 (four) reseting on region change (e.g. teleport)
_Setting up perspectives_|some are there - if 'rear view' is not good enough you need to use debug settings, as described in [Penny Patton's blog entry](http://pennycow.blogspot.de/2011/07/matter-of-perspective.html), [more detailed by Ciaran Laval](http://sl.governormarley.com/?p=483) or [modified  by Mona Eberhardt](https://monaeberhardt.wordpress.com/2014/02/10/revisiting-the-issue-of-camera-placement/)|useful presets (right/left shoulder) - for further changes edit those in script
_Camera perspectives_|only static ones|also some dynamic presets (spin, spaz)
_Interface_|big popup (way to big to keep open all the time), many preferences (Firestorm settings)|small HUD


Components
==========
Script-base
-------
see script header  

Objects
-------




Licensing
========
