//PoA IL autosplitter
//by Cambid

//REMEMBER should have 8 splits
	
state("MCC-Win64-Shipping") 
{
    uint tickcounter1: 0x03B80E98, 0x8, 0x2B5FCE8; //pauses on pause menu, resets on reverts
	byte bspstate: 0x03B80E98, 0x8, 0x19F748C; //tracks which bsp is loaded
	string3 levelname: 0x03B80E98, 0x8, 0x2AF8288; //tracks which level is loaded
	float xpos: 0x03B80E98, 0x8, 0x2A5EFF4; //chief camera x position
	float ypos: 0x03B80E98, 0x8, 0x2A5EFF8; //chief camera y position
	float zpos: 0x03B80E98, 0x8, 0x2A5EFFC; //chief camera z position
    byte playerfrozen: 0x03B80E98, 0x8, 0x2AF37C0; //1 for true, 0 for false
    byte cutsceneskip: 0x03B80E98, 0x8, 0x2af89b8, 0x0B; //true when cutscene is skippable
    byte cinematic: 0x03B80E98, 0x8, 0x2af89b8, 0x0A; //true when cutscene is playing
}

startup //settings for which splits you want to use 
{
    settings.Add("Load1", true, "split on hitting first bsp swap");
    settings.Add("Bridge", true, "split on keyes fade end");
    settings.Add("Load", true, "split on passing load trigger");
    settings.Add("Flank", true, "split on approaching flank encounter (barricade jump)");
    settings.Add("Shield", true, "split on shield pop");
    settings.Add("Tele", true, "split on bsp load after tele");
    settings.Add("Last BSP", true, "split on leaving 2nd to last door");

} 

init
{
    vars.indexoffset = 0;
} 


start
{
    vars.indexoffset = 0;
    return (current.levelname == "a10" && current.tickcounter1 > 280 && current.playerfrozen == 0 && old.playerfrozen == 1);
}

split
{

    int checkindex = timer.CurrentSplitIndex + vars.indexoffset;

	switch (checkindex)
	{
 
		case 0: 
		if (!(settings["Load1"]))
		    {
		        vars.indexoffset++;
		        break;
		    }
		return (current.bspstate == 1 && !(old.bspstate == 1));
		break;


		case 1:
		if (!(settings["Bridge"]))
		{
		    vars.indexoffset++;
		    break;
		}
		return (old.cutsceneskip == 1 && current.cutsceneskip == 0 && current.bspstate == 1);
		break;


		case 2:
		if (!(settings["Flank"]))
		{
	    	vars.indexoffset++;
		    break;
		}
		return (current.bspstate == 2 && current.xpos < -44 && current.ypos > 20);
		break;


		case 3:
		if (!(settings["Load"]))
		{
	    	vars.indexoffset++;
		    break;
		}
		return (current.bspstate == 3 && !(old.bspstate == 3));
		break;


        case 4:
        if (!(settings["Shield"]))
		{
	    	vars.indexoffset++;
		    break;
		}
        return (current.zpos > 1.72 && current.ypos > 32 && current.bspstate == 3);
        break;


        case 5:
        if (!(settings["Tele"]))
		{
	    	vars.indexoffset++;
		    break;
		}
        return (current.bspstate == 5 && !(old.bspstate == 5));
        break;


		case 6:
		if (!(settings["Last BSP"]))
		{
		    vars.indexoffset++;
		    break;
		}
		return (!(old.bspstate == 6) && current.bspstate == 6);
		break;		

		default:
		    return (current.cutsceneskip == 1 && old.cutsceneskip == 0 && current.bspstate == 6);
		break;
	}
}

reset
{
    return (current.tickcounter1 < 10 && current.bspstate == 0);
}