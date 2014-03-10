default
{
    touch_start(integer total_number)
    {
        llMessageLinked(LINK_ROOT, 0, "cam", llDetectedKey(0));
    }
}

