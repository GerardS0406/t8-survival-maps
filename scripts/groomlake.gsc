groomlake_main()
{
    setup_gl_spawnpoints();
    thread activate_zone();
    chests = struct::get_array("treasure_chest_use", "targetname");
    i = 0;
    foreach(chest in chests)
    {
        if(i==0)
        {
            chest moveChest((8376,1128,-424),(0,270,0));
            chest.start_exclude = 0;
            chest.no_fly_away = 1;
        }
        else
        {
            chest.start_exclude = 1;
        }
        i++;
    }
    struct::get_array("perk_vapor_altar")[0] movePerk((8787,212,-366),(0,-125,0),1);
    struct::get_array("perk_vapor_altar")[1] movePerk((8303,212,-366),(0,-35,0),1);
    struct::get_array("perk_vapor_altar")[2] movePerk((7991,588,-424),(0,0,0),1);
    struct::get_array("perk_vapor_altar")[3] movePerk((9104,710,-424),(0,180,0),1);

    removegroomdebris();

    thread groomlake_pap();

    thread speedupzambs();
}

setup_gl_spawnpoints()
{
    struct::get_array("initial_spawn", "script_noteworthy")[0].origin = (8592,-180,-349);
    struct::get_array("initial_spawn", "script_noteworthy")[0].angles = (0,90,0);
    struct::get_array("initial_spawn", "script_noteworthy")[1].origin = (8592,-42,-349);
    struct::get_array("initial_spawn", "script_noteworthy")[1].angles = (0,90,0);
    struct::get_array("initial_spawn", "script_noteworthy")[2].origin = (8493,-42,-349);
    struct::get_array("initial_spawn", "script_noteworthy")[2].angles = (0,90,0);
    struct::get_array("initial_spawn", "script_noteworthy")[3].origin = (8493,-180,-349);
    struct::get_array("initial_spawn", "script_noteworthy")[3].angles = (0,90,0);
}

activate_zone()
{
    level flag::wait_till("all_players_spawned");
    zm_zonemgr::enable_zone("cage");
    zm_zonemgr::enable_zone("cage_upper");
}

groomlake_pap()
{
    level flag::wait_till("all_players_spawned");
    foreach(weapon in level.zombie_weapons)
    {
        if(isdefined(weapon.weapon.isriotshield) && weapon.weapon.isriotshield)
        {
            weapon.is_in_box = 1;
        }
    }
    level.round_wait_func = &round_wait_override;
    level flag::wait_till("initial_blackscreen_passed");
    level zm_power::turn_power_on_and_open_doors();
    level flag::set(#"hash_537cc10c9deca9da");
    getent("bunker_gate", "targetname") linkto(getent("cage_portal_blocker", "targetname"));
	getent("bunker_gate_2", "targetname") linkto(getent("cage_portal_blocker", "targetname"));
	getent("bunker_gate_3", "targetname") linkto(getent("cage_portal_blocker", "targetname"));
    getent("cage_portal_blocker", "targetname") movez(150, 1);
}

removegroomdebris()
{
    foreach(debris in struct::get_array("cage_debris", "targetname"))
    {
        debris.parts = [];
        debris.clips = [];
        foreach(part in GetEntArray(debris.target, "targetname"))
        {
            if(part iszbarrier())
            {
                debris.parts[debris.parts.size] = part;
                continue;
            }
            debris.clips[debris.clips.size] = part;
        }
        array::run_all(debris.clips, &delete);
        array::run_all(debris.parts, &delete);
    }
}