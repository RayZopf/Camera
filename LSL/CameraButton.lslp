default
{
	touch_start(integer num_detected)
	{
		llMessageLinked(LINK_ROOT, 0, "cam", llDetectedKey(0));
	}
}