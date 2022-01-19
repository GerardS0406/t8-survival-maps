temple_main()
{
    disableTempleBarriers();

    thread temple_Chests();

    struct::get_array("perk_vapor_altar")[0] movePerk((-3051,-906,0), (0,135,0), 1);
    struct::get_array("perk_vapor_altar")[1] movePerk((-2620,-1420,-50), (0,125,0), 0);
    struct::get_array("perk_vapor_altar")[2] movePerk((-423,-1004,56), (0,50,0), 1);
    struct::get_array("perk_vapor_altar")[3] movePerk((483,-204,0), (0,-170,0), 1);

    movepap((-1592,-1031,64), (0,10,0) + (0,90,0), 1);

    thread spawn_shield((-2629,-592,0),(0,-125,0),#"hash_134c05846f7c5c98");

    thread temple_pap();
}

disableTempleBarriers()
{
    foreach(barrier in getentarray("zombie_door", "targetname"))
    {
        barrier.origin = (0,0,-10000);
    }
    foreach(barrier in getentarray("zombie_debris", "targetname"))
    {
        if(barrier.origin != (-600,-852,104) && barrier.origin != (-2278,-976,96) && barrier.origin != (-2247,-1150,96))
        {
            barrier.origin = (0,0,-10000);
        }
    }
}

temple_pap()
{
    level flag::wait_till("all_players_spawned");
    level flag::wait_till("initial_blackscreen_passed");
    level zm_power::turn_power_on_and_open_doors();
    level flag::set(#"pap_quest_completed");
}

temple_Chests()
{
    chests = struct::get_array("treasure_chest_use", "targetname");
    i = 0;
    foreach(chest in chests)
    {
        if(chest.script_noteworthy == "temple_terrace_chest")
        {
            chest moveChest((149,-266,-10),(0,190,0),1,1);
            chest.start_exclude = 0;
            continue;
        }
        else if(chest.script_noteworthy == "seer_fountain_chest")
        {
            chest moveChest((-2871,-813,-10),(0,0,0),1,1);
            chest.start_exclude = 0;
            continue;
        }
        else
        {
            chest.start_exclude = 1;
            continue;
        }
    }
    level flag::wait_till("all_players_spawned");
    level.start_chest_name = "temple_terrace_chest";
    level._zombiemode_custom_box_move_logic = &temple_box_logic;
}

temple_box_logic()
{
    old_chest = level.chests[level.chest_index].script_noteworthy;
    level.chests = array::randomize(level.chests);
    for(i = 0; i < level.chests.size; i++)
    {
        if(old_chest == level.chests[i].script_noteworthy)
            continue;
        if(level.chests[i].script_noteworthy == "temple_terrace_chest" || level.chests[i].script_noteworthy == "seer_fountain_chest")
        {
            level.chest_index = i;
            break;
        }
    }
}