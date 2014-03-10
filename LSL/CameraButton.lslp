integer verbose = FALSE;

string g_sTitle = "CameraScript-Button";     // title
string g_sVersion = "1.1";            // version
string g_sScriptName;


$import MemoryManagement2.lslm(m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_iVerbose=verbose);



default
{
	state_entry()
	{
		g_sScriptName = llGetScriptName();
		MemRestrict(8192, FALSE);
	}
	
	
	touch_start(integer num_detected)
	{
		llMessageLinked(LINK_ROOT, 0, "cam", llDetectedKey(0));
	}
}