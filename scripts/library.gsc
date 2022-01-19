library_main()
{
    setup_library_spawnpoints();
    thread activate_zones_library();
    
    disableLibraryBarriers();

    thread library_Chests();

    struct::get_array("perk_vapor_altar")[0] movePerk((-1634,69,-8), (0,-135,0), 1);
    struct::get_array("perk_vapor_altar")[1] movePerk((-1822,442,-216), (0,0,0), 1);
    struct::get_array("perk_vapor_altar")[2] movePerk((-1798,-190,-216), (0,45,0), 1);
    struct::get_array("perk_vapor_altar")[3] movePerk((-1638,824,-216), (0,-45,0), 1);
    struct::get_array("perk_vapor_altar")[4] movePerk((-2075,-232,-8), (0,52,0), 1);

    movePap((-1356,-363,-8),(0,0,0),1);

    thread spawn_shield((-1645,443,-216),(0,180,0),#"hash_3a1959bb039f2be3");

    thread library_pap();
}

library_Chests()
{
    chests = struct::get_array("treasure_chest_use", "targetname");
    i = 0;
    foreach(chest in chests)
    {
        if(chest.script_noteworthy == "library_zone_chest")
        {
            chest.start_exclude = 0;
            continue;
        }
        else
        {
            if(chest.script_noteworthy == "pap_zone_chest")
                chest moveChest((-1005,-528,-15),(0,90,0),1,1);
            chest.start_exclude = 1;
            continue;
        }
    }
    level flag::wait_till("all_players_spawned");
    level.start_chest_name = "library_zone_chest";
    level._zombiemode_custom_box_move_logic = &library_box_logic;
}

library_box_logic()
{
    old_chest = level.chests[level.chest_index].script_noteworthy;
    level.chests = array::randomize(level.chests);
    for(i = 0; i < level.chests.size; i++)
    {
        if(old_chest == level.chests[i].script_noteworthy)
            continue;
        if(level.chests[i].script_noteworthy == "library_zone_chest" || level.chests[i].script_noteworthy == "pap_zone_chest")
        {
            level.chest_index = i;
            break;
        }
    }
}

activate_zones_library()
{
    level flag::wait_till("all_players_spawned");
    zm_zonemgr::enable_zone("zone_library_hallway_upper");
}

setup_library_spawnpoints()
{
    foreach(spawn in struct::get_array("initial_spawn_points", "targetname"))
    {
        spawn.origin = (-1304,-665,-7);
        spawn.angles = (0,145,0);
    }
}

disableLibraryBarriers()
{
    foreach(barrier in getentarray("zombie_door", "targetname"))
    {
        if(barrier.origin != (-1652,-326,57))
        {
            barrier.origin = (0,0,-10000);
        }
    }
    foreach(barrier in getentarray("zombie_debris", "targetname"))
    {
        barrier.origin = (0,0,-10000);
    }
}

library_pap()
{
    SetGametypeSetting(#"hash_19d48a0d4490b0a2",2);
    level flag::wait_till("all_players_spawned");
    level flag::wait_till("initial_blackscreen_passed");
    level flag::set("open_pap");
    foreach(perk in struct::get_array("perk_vapor_altar"))
    {
        perk.var_73bd396b delete();
        switch(perk.script_int)
        {
            case 0:
            {
                model = #"p8_fxanim_zm_vapor_altar_danu_mod";
                perk.var_2839b015 = #"p8_fxanim_zm_vapor_altar_danu_bundle";
                break;
            }
            case 1:
            {
                model = #"p8_fxanim_zm_vapor_altar_ra_mod";
                perk.var_2839b015 = #"p8_fxanim_zm_vapor_altar_ra_bundle";
                break;
            }
            case 2:
            {
                model = #"p8_fxanim_zm_vapor_altar_zeus_mod";
                perk.var_2839b015 = #"p8_fxanim_zm_vapor_altar_zeus_bundle";
                break;
            }
            case 3:
            {
                model = #"p8_fxanim_zm_vapor_altar_odin_mod";
                perk.var_2839b015 = #"p8_fxanim_zm_vapor_altar_odin_bundle";
                break;
            }
        }
        perk.var_73bd396b = util::spawn_model(model, perk.origin, perk.angles);
        perk.var_73bd396b thread scene::play(perk.var_2839b015, "on", perk.var_73bd396b);
        perk.var_73bd396b clientfield::set("" + #"hash_cf74c35ecc5a49", 1);
    }
}