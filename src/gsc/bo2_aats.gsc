#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\gametypes_zm\_spawnlogic;
#include maps\mp\animscripts\traverse\shared;
#include maps\mp\animscripts\utility;
#include maps\mp\zombies\_load;
#include maps\mp\_createfx;
#include maps\mp\_music;
#include maps\mp\_busing;
#include maps\mp\_script_gen;
#include maps\mp\gametypes_zm\_globallogic_audio;
#include maps\mp\gametypes_zm\_tweakables;
#include maps\mp\_challenges;
#include maps\mp\gametypes_zm\_weapons;
#include maps\mp\_demo;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\gametypes_zm\_spawning;
#include maps\mp\gametypes_zm\_globallogic_utils;
#include maps\mp\gametypes_zm\_spectating;
#include maps\mp\gametypes_zm\_globallogic_spawn;
#include maps\mp\gametypes_zm\_globallogic_ui;
#include maps\mp\gametypes_zm\_hostmigration;
#include maps\mp\gametypes_zm\_globallogic_score;
#include maps\mp\gametypes_zm\_globallogic;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_ai_faller;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\zombies\_zm_pers_upgrades;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\animscripts\zm_run;
#include maps\mp\animscripts\zm_death;
#include maps\mp\zombies\_zm_blockers;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\_visionset_mgr;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_server_throttle;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_melee_weapon;
#include maps\mp\zombies\_zm_audio_announcer;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_ai_dogs;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_buildables;
#include codescripts\character;

#include maps\mp\zombies\_zm_weap_riotshield;
#include maps\mp\zombies\_zm_weap_riotshield_tomb;
#include maps\mp\zombies\_zm_weap_riotshield_prison;

#include maps\mp\zm_transit_bus;
#include maps\mp\zm_transit_utility;
#include maps\mp\zombies\_zm_equip_turret;
#include maps\mp\zombies\_zm_mgturret;
#include maps\mp\zombies\_zm_weap_jetgun;

#include maps\mp\zombies\_zm_ai_sloth;
#include maps\mp\zombies\_zm_ai_sloth_ffotd;
#include maps\mp\zombies\_zm_ai_sloth_utility;
#include maps\mp\zombies\_zm_ai_sloth_magicbox;
#include maps\mp\zombies\_zm_ai_sloth_crawler;
#include maps\mp\zombies\_zm_ai_sloth_buildables;

#include maps\mp\zombies\_zm_tombstone;
#include maps\mp\zombies\_zm_chugabud;

#include maps\mp\zm_nuked_perks;
main()
{	
	if(getdvar("mapname") != "zm_prison") //[ Hotfix ] disabled in motd because afterlife doesnt work with it 
		register_player_damage_callback( ::player_aat_damage_respond ); //moved to main from init because of it not loading in origins

	maps\mp\zombies\_zm_spawner::register_zombie_damage_callback( ::aat_zombie_damage_response );
}

init()
{
    onplayerconnect_callback( ::watch_weapon_changes ); 
	
    thread new_pap_trigger();
	level._poi_override = ::turned_zombie;
}

player_aat_damage_respond( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	players = get_players();
	for(i=0;i<players.size;i++)
	{
		if( isdefined(players[i].gluster_grenade) && eattacker == players[i].gluster_grenade )
			return 0;
		
		if( isdefined(players[i].firework_weapon) && eattacker == players[i].firework_weapon )
			return 0;
	}
	return idamage;
}

vector_scal( vec, scale )
{
	vec = ( vec[ 0] * scale, vec[ 1] * scale, vec[ 2] * scale );
	return vec;
}

vending_weapon_upgrade_cost()
{
	level endon("end_game");
	for( ;; )
	{
		level waittill( "powerup bonfire sale" );
		level._bonfire_sale = 1;
		level waittill( "bonfire_sale_off" );
		level._bonfire_sale = 0;
	}
}

pap_off()
{
	level endon("end_game");
	wait 5;
	for(;;)
	{
		level waittill("Pack_A_Punch_on");
		wait 1;
		level notify("Pack_A_Punch_off");
	}
}

new_pap_trigger()
{
	level endon("end_game");
	thread vending_weapon_upgrade_cost();
    level waittill("Pack_A_Punch_on");
    wait 2;
	
	if(getdvar( "mapname" ) != "zm_transit" && getdvar ( "g_gametype") != "zstandard")
	{
		level notify("Pack_A_Punch_off");
		level thread pap_off();
	}

    if( getdvar( "mapname" ) == "zm_nuked" )
        level waittill( "Pack_A_Punch_on" );
    
	perk_machine = getent( "vending_packapunch", "targetname" );
    pap_triggers = getentarray( "specialty_weapupgrade", "script_noteworthy" );
    pap_triggers[0] delete();
	if( getdvar( "mapname" ) == "zm_transit" && getdvar ( "g_gametype")  == "zclassic" )
	{
		if(!level.buildables_built[ "pap" ])
			level waittill("pap_built");
	}
	wait 1;
	self.perk_machine = perk_machine;
	perk_machine_sound = getentarray( "perksacola", "targetname" );
	packa_rollers = spawn( "script_origin", perk_machine.origin );
	packa_timer = spawn( "script_origin", perk_machine.origin );
	packa_rollers linkto( perk_machine );
	packa_timer linkto( perk_machine );
	if( getdvar( "mapname" ) == "zm_highrise" )
	{
		Trigger = spawn( "trigger_radius", perk_machine.origin, 1, 60, 80 );
		Trigger enableLinkTo();
		Trigger linkto(self.perk_machine);
	}
	else
		Trigger = spawn( "trigger_radius", perk_machine.origin, 1, 35, 80 );
	
    
	Trigger SetCursorHint( "HINT_NOICON" );
    Trigger sethintstring( "			Hold ^3&&1^7 for Pack-a-Punch [Cost: 5000] \n Weapons can be pack a punched multiple times" );
	
    cost = 5000;

	Trigger usetriggerrequirelookat();
	for(;;)
	{
		Trigger waittill("trigger", player);
		current_weapon = player getcurrentweapon();
        if(current_weapon == "saritch_upgraded_zm+dualoptic" || current_weapon == "dualoptic_saritch_upgraded_zm+dualoptic" || current_weapon == "slowgun_upgraded_zm" || current_weapon == "staff_air_zm" || current_weapon == "staff_lightning_zm" || current_weapon == "staff_fire_zm" || current_weapon == "staff_water_zm" )
        {
            Trigger sethintstring( "^1This weapon can not be upgraded." );
			wait .05;
            continue;
        }
		
		if(player UseButtonPressed() && player.score >= cost && current_weapon != "riotshield_zm" && player can_buy_weapon() && !player.is_drinking && !is_placeable_mine( current_weapon ) && !is_equipment( current_weapon ) && level.revive_tool != current_weapon && current_weapon != "none" )
        {
			player.score -= cost;
            player thread maps\mp\zombies\_zm_audio::play_jingle_or_stinger( "mus_perks_packa_sting" );
			trigger setinvisibletoall();
			upgrade_as_attachment = will_upgrade_weapon_as_attachment( current_weapon );
            
            player.restore_ammo = undefined;
            player.restore_clip = undefined;
            player.restore_stock = undefined;
            player.restore_clip_size = undefined;
            player.restore_max = undefined;
            
            player.restore_clip = player getweaponammoclip( current_weapon );
            player.restore_clip_size = weaponclipsize( current_weapon );
            player.restore_stock = player getweaponammostock( current_weapon );
            player.restore_max = weaponmaxammo( current_weapon );
            

			player thread maps\mp\zombies\_zm_perks::do_knuckle_crack();
			wait .1;
			player takeWeapon(current_weapon);
			current_weapon = player maps\mp\zombies\_zm_weapons::switch_from_alt_weapon( current_weapon );
			self.current_weapon = current_weapon;
			upgrade_name = maps\mp\zombies\_zm_weapons::get_upgrade_weapon( current_weapon, upgrade_as_attachment );
			player third_person_weapon_upgrade( current_weapon, upgrade_name, packa_rollers, perk_machine, self );
			trigger sethintstring( &"ZOMBIE_GET_UPGRADED" );
			trigger thread wait_for_pick(player, current_weapon, self.upgrade_name);

			if ( isDefined( player ) )
			{
				Trigger setinvisibletoall();
				Trigger setvisibletoplayer( player );
			}
			self thread wait_for_timeout( current_weapon, packa_timer, player );
			self waittill_any( "pap_timeout", "pap_taken", "pap_player_disconnected" );
			self.current_weapon = "";

			if ( isDefined( self.worldgun ) && isDefined( self.worldgun.worldgundw ) )
				self.worldgun.worldgundw delete();
			
			if ( isDefined( self.worldgun ) )
				self.worldgun delete();
			
			Trigger setinvisibletoplayer( player );
			wait 1.5;
			Trigger setvisibletoall();
				
			self.current_weapon = "";
			self.pack_player = undefined;
			flag_clear( "pack_machine_in_use" );
		}
		weapon = player getcurrentweapon();
		if(isdefined(level._bonfire_sale) && level._bonfire_sale)
		{
			Trigger sethintstring( "			Hold ^3&&1^7 for Pack-a-Punch [Cost: 1000] \n Weapons can be pack a punched multiple times" );
			cost = 1000;
		}
		else if(is_weapon_upgraded(weapon))
		{
			Trigger sethintstring( "			Hold ^3&&1^7 for Pack-a-Punch [Cost: 2500] \n Weapons can be pack a punched multiple times" );
			cost = 2500;
		}
		else
		{
			Trigger sethintstring( "			Hold ^3&&1^7 for Pack-a-Punch [Cost: 5000] \n Weapons can be pack a punched multiple times" );
			cost = 5000;
		}
		wait .1;
	}
}

wait_for_pick(player, weapon, upgrade_weapon)
{
	level endon( "pap_timeout" );
	level endon("end_game");
	for (;;)
	{
		self playloopsound( "zmb_perks_packa_ticktock" );
		self waittill( "trigger", user );
		if(user UseButtonPressed() && player == user)
		{	
			self stoploopsound( 0.05 );
			player thread do_player_general_vox( "general", "pap_arm2", 15, 100 );

            base = get_base_name(weapon);
            if( base == "galil_upgraded_zm" || base == "fnfal_upgraded_zm" || base == "ak74u_upgraded_zm" )
			{
                player.restore_ammo = 1;
                player thread give_aat(weapon); //Alternative ammo type for ak74u, galil and fnfal upgraded
				player giveweapon( weapon, 0, player maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( weapon ));
				player switchToWeapon( weapon );
                x = weapon;
            }
			else 
            {
                if(is_weapon_upgraded( weapon ))
                {
                    player.restore_ammo = 1;
                    player thread give_aat(upgrade_weapon); //Alternative ammo type for all other weapons
                }
                weapon_limit = get_player_weapon_limit( player );
                player maps\mp\zombies\_zm_weapons::take_fallback_weapon();
                primaries = player getweaponslistprimaries();
                
                if ( isDefined( primaries ) && primaries.size >= weapon_limit )
                    player maps\mp\zombies\_zm_weapons::weapon_give( upgrade_weapon );
                else
                    player giveweapon( upgrade_weapon, 0, player maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( upgrade_weapon ));

                player switchToWeapon( upgrade_weapon );
                x = upgrade_weapon;
            }

			if ( isDefined( player.restore_ammo ) && player.restore_ammo )
			{
				new_clip = player.restore_clip + ( weaponclipsize( x ) - player.restore_clip_size );
				new_stock = player.restore_stock + ( weaponmaxammo( x ) - player.restore_max );
				player setweaponammostock( x, new_stock );
				player setweaponammoclip( x, new_clip );
			}
			level notify( "pap_taken" );
			player notify( "pap_taken" );
			break;
		}
		wait .1;
	}
}

aat_zombie_damage_response( mod, hit_location, hit_origin, attacker, amount )
{
    if(!can_aat_damage(self))
		return 0;

    if(!isDefined(attacker.aat_cooldown))
        attacker.aat_cooldown = 0;
    
	if(isdefined( self.damageweapon ))
	{
		if(isdefined( attacker ) && isplayer( attacker ) && isdefined(attacker.aat_cooldown) && !attacker.aat_cooldown)
		{
            zombies = getaiarray( level.zombie_team );

            if(randomint(100) >= 75 && self turned_zombie_validation() && !attacker.active_turned && isdefined(attacker.aat[self.damageweapon]) && attacker.aat[self.damageweapon] == "Turned")
            {
                attacker thread Cooldown("Turned");
                self thread turned( attacker );
                return 1;
            }
            if(randomint(100) >= 80 && isdefined(attacker.aat[self.damageweapon]) && attacker.aat[self.damageweapon] == "Cluster")
            {
                attacker thread Cooldown("Cluster");
                self thread cluster( attacker );
                return 1;
            }
            if(randomint(100) >= 70 && isdefined(attacker.aat[self.damageweapon]) && attacker.aat[self.damageweapon] == "Headcutter")
            {
                attacker thread Cooldown("Headcutter");
                for( i=0; i < zombies.size; i++ )
                {
                    if(distance(self.origin, zombies[i].origin) <= 200)
                    {
                        if(!zombies[i].done && can_aat_damage(zombies[i]))
                        {
                            zombies[i].done = 1;
                            zombies[i] thread Headcutter(attacker);
                        }
                    }
                }
                return 1;
            }
            if(randomint(100) >= 80 && isdefined(attacker.aat[self.damageweapon]) && attacker.aat[self.damageweapon] == "Thunder Wall")
            {
                attacker setclientdvar( "ragdoll_enable", 1);
                self thread thunderwall(attacker);
                attacker thread Cooldown("Thunder Wall");
                return 1;                
            }
            if(randomint(100) >= 75 && isdefined(attacker.aat[self.damageweapon]) && attacker.aat[self.damageweapon] == "Blast Furnace")
            {
                attacker thread Cooldown("Blast Furnace");
                PlayFXOnTag(level._effect[ "character_fire_death_torso" ], self, "j_spinelower");
                PlayFXOnTag(level._effect[ "character_fire_death_sm" ], self, "j_spineupper");
                for( i = 0; i < zombies.size; i++ )
                {
                    if(distance(self.origin, zombies[i].origin) <= 220 && can_aat_damage(zombies[i]))
                        zombies[i] thread flames_fx(attacker);
                }
                return 1;
            }
            if(randomint(100) >= 80 && isdefined(attacker.aat[self.damageweapon]) && attacker.aat[self.damageweapon] == "Fireworks")
            {
                attacker thread Cooldown("Fireworks");
                self thread spawn_weapon( attacker );
                self thread fireworks();
                return 1;
            }
		}
	}
	return 0;
}

Cooldown(aat)
{
	cooldown_time = 0;

	self.aat_cooldown = 1;

	if( aat == "Thunder Wall" )
		cooldown_time = randomintrange(13, 21);
	else if( aat == "Fireworks" )
		cooldown_time = randomintrange(13, 18);
    else if( aat == "Turned" )
		cooldown_time = randomintrange(13, 21);
	else if( aat == "Cluster" )
		cooldown_time = randomintrange(13, 26);
    else if( aat == "Headcutter" )
		cooldown_time = randomintrange(13, 21);
	else if( aat == "Explosive" )
		cooldown_time = randomintrange(5, 16);
    else if( aat == "Blast Furnace" )
		cooldown_time = randomintrange(13, 21);
    
	wait cooldown_time;

	self.aat_cooldown = 0;
}

explosive_bullet()
{
    level endon("end_game");
    self endon("disconnect");
	for( ;; )
	{
		self waittill( "weapon_fired", weapon );

        if(getdvar("mapname") == "zm_tomb" || getdvar("mapname") == "zm_buried")
			fx = level._effect[ "divetonuke_groundhit" ];
        else
            fx = level._effect[ "def_explosion" ];

		if(!self.aat_cooldown && isdefined(self.aat[weapon]) && self.aat[weapon] == "Explosive")
		{
			self thread Cooldown("Explosive");
			forward = self gettagorigin( "tag_weapon_right" );
			end = self thread vector_scal( anglestoforward( self getplayerangles() ), 1000000 );
			crosshair_entity = bullettrace(self gettagorigin("tag_weapon_right"),self gettagorigin("tag_weapon_right")+anglestoforward(self getplayerangles())*1000000,true,self)["entity"];
			crosshair = bullettrace( forward, end, 0, self )[ "position"];
			magicbullet( self getcurrentweapon(), self gettagorigin( "j_shouldertwist_le" ), crosshair, self );
			self enableInvulnerability();
			if(isdefined(crosshair_entity))
			{
				crosshair_entity playsound( "zmb_phdflop_explo" );
				playfx(fx, crosshair_entity.origin, anglestoforward( ( 0, 45, 55  ) ) );
				radiusdamage( crosshair_entity.origin, 300, 5000, 1000, self );
			}
			else
			{
				crosshair playsound( "zmb_phdflop_explo" );
				playfx(fx, crosshair, anglestoforward( ( 0, 45, 55  ) ) );
				radiusdamage( crosshair, 300, 5000, 1000, self );
			}
            wait .5;
			self disableInvulnerability();
		}
		wait .1;
	}
}

flames_fx(attacker)
{
	for(i = 0; i < 5; i++)
	{
		PlayFXOnTag(level._effect[ "character_fire_death_sm" ], self, "j_spineupper");

		if(i < 3)
		{
			self dodamage(self.health / 2, (0,0,0));
			attacker.score += 10;
		}
		else
		{
			self dodamage(self.maxhealth * 2, (0,0,0));
			attacker.score += 50;
		}
		wait 1;
	}
}

fireworks()
{
	level endon("end_game");
	origin = self.origin;

	if(getdvar("mapname") == "zm_buried")
    {
		for(i=0;i<10;i++)
        {
			x = randomintrange(-40, 40);
			y = randomintrange(-40, 40);

            up_in_air = origin + (0,0,65);
			up_in_air2 = origin + (x,y,randomintrange(45, 66));
			up_in_air3 = origin + (x,y,randomintrange(45, 66));

            firework = Spawn( "script_model", origin );
            firework SetModel( "tag_origin" );

			firework2 = Spawn( "script_model", origin );
            firework2 SetModel( "tag_origin" );

			firework3 = Spawn( "script_model", origin );
            firework3 SetModel( "tag_origin" );
	
            fx = PlayFxOnTag( level._effect[ "fx_wisp_m" ], firework, "tag_origin");
			fx2 = PlayFxOnTag( level._effect[ "fx_wisp_m" ], firework2, "tag_origin");
			fx3 = PlayFxOnTag( level._effect[ "fx_wisp_m" ], firework3, "tag_origin");
            
			firework moveto(up_in_air, 1);
			firework2 moveto(up_in_air2, randomfloatrange(0.4, 1.1));
            firework3 moveto(up_in_air3, randomfloatrange(0.4, 1.1));

			wait .5;
            firework delete();
			firework2 delete();
			firework3 delete();
            fx delete();
			fx2 delete();
			fx3 delete();
        }
    }

	if(getdvar("mapname") == "zm_highrise")
    {
        for(i=0;i<22;i++)
        {
            firework = Spawn( "script_model", origin );
            firework SetModel( "tag_origin" );
            firework.angles = (0,0,0);
            fx = PlayFxOnTag( level._effect[ "sidequest_dragon_spark_max" ], firework, "tag_origin");
            wait .25;
            firework delete();
            fx delete();
        }
    }

    if(getdvar("mapname") == "zm_tomb")
    {
        for(i=0;i<20;i++)
        {
            firework = Spawn( "script_model", origin );
            firework SetModel( "tag_origin" );
            firework.angles = (-90,0,0);
            fx = PlayFxOnTag( level._effect[ "fire_muzzle" ], firework, "tag_origin");
            wait .25;
            firework delete();
            fx delete();
        }
    }
    else if(getdvar("mapname") == "zm_transit" && getdvar ( "g_gametype")  == "zclassic" )
    {
        for(i=0;i<5;i++)
        {
            up_in_air = origin + (0,0,65);
            firework = Spawn( "script_model", origin );
            firework SetModel( "tag_origin" );
            fx = PlayFxOnTag( level._effect[ "richtofen_sparks" ], firework, "tag_origin");
            firework moveto(up_in_air, 1);
            wait 1;
            firework delete();
            fx delete();
        }
    }
}

spawn_weapon(attacker)
{
    origin = self.origin;
    weapon = attacker getCurrentWeapon();

    attacker.firework_weapon = spawn( "script_model", origin );
	attacker.firework_weapon.angles = (0,0,0);
	attacker.firework_weapon setmodel( GetWeaponModel( weapon ) );
    attacker.firework_weapon useweaponhidetags( weapon );

	attacker.firework_weapon MoveTo( origin + (0, 0, 45), 0.5, 0.25, 0.25 );
	attacker.firework_weapon waittill( "movedone" );
    for(i=0;i<100;i++)
    {
        zombies = get_array_of_closest( attacker.firework_weapon.origin, getaiarray( level.zombie_team ), undefined, undefined, 300  );
        forward = attacker.firework_weapon.origin;
        
        if( can_aat_damage( zombies[ 0 ] ) )
        {
            end = zombies[ 0 ] gettagorigin( "j_spineupper" );
            crosshair = bullettrace( forward, end, 0, self )[ "position" ];
            attacker.firework_weapon.angles = VectorToAngles( end - attacker.firework_weapon.origin );

            if( distance(zombies[ 0 ].origin, attacker.firework_weapon.origin) <= 300)
                magicbullet( weapon, attacker.firework_weapon.origin, crosshair, attacker.firework_weapon );
        }
        wait .05;
    }
    attacker.firework_weapon MoveTo( origin, 0.5, 0.25, 0.25 );
	attacker.firework_weapon waittill( "movedone" );
    attacker.firework_weapon delete();
}

thunderwall( attacker ) 
{
	thunder_wall_blast_pos = self.origin; 
	ai_zombies = get_array_of_closest( thunder_wall_blast_pos, getaiarray( level.zombie_team ), undefined, undefined, 250  );

    if ( !isDefined( ai_zombies ) )
		return;
	
	flung_zombies = 0;
    max_zombies = undefined;
    max_zombies = randomIntRange(5,25);
	for ( i = 0; i < ai_zombies.size; i++ )
	{
		if( can_aat_damage(ai_zombies[i]) )
        {
			n_random_x = RandomFloatRange( -3, 3 );
			n_random_y = RandomFloatRange( -3, 3 );
			ai_zombies[i] StartRagdoll();
			ai_zombies[i] LaunchRagdoll( (n_random_x, n_random_y, 150) );

			if(getdvar("mapname") == "zm_transit")
	            playfxontag( level._effect[ "jetgun_smoke_cloud"], ai_zombies[i], "J_SpineUpper" );
            else if(getdvar("mapname") == "zm_tomb")
				playfxontag( level._effect[ "air_puzzle_smoke" ], ai_zombies[i], "J_SpineUpper" );
			else if(getdvar("mapname") == "zm_buried")
				playfxontag( level._effect[ "rise_billow_foliage" ], ai_zombies[i], "J_SpineUpper" );
        	
			ai_zombies[i] DoDamage( ai_zombies[i].health * 2, ai_zombies[i].origin, attacker, attacker, "none", "MOD_IMPACT" );
			flung_zombies++;
			attacker.score += 25;
			if ( flung_zombies >= max_zombies )
				break;
		}
    }
}

Headcutter(attacker)
{
    self endon("death");
    self maps\mp\zombies\_zm_spawner::zombie_head_gib();
    for(;;)
    {  	
		wait 1;
		damage = 100 * level.round_number;
        self dodamage( damage, self.origin, attacker, attacker, "none", "MOD_IMPACT" );
    }
}

cluster( attacker )
{
	if(level.round_number < 10)
		amount = randomIntRange(1, (level.round_number * 2));
	else
		amount = randomIntRange(5, level.round_number);
	
	random_x = RandomFloatRange( -5, 5 );
	random_y = RandomFloatRange( -5, 5 );
	attacker.gluster_grenade = attacker;
	for(i = 0; i < amount; i++)
	{
		attacker.gluster_grenade MagicGrenadeType( "frag_grenade_zm", self.origin + (random_x, random_y, 10), (random_x, random_y, 0), 2 );
		wait .1;
	}
}

turned( attacker )
{
	self.is_turned = 1;
    self.actor_damage_func = ::turned_damage_respond; 
    self.health = 999999;

	attacker.active_turned = 1;
	self.turned_zombie_kills = 0;
	self.max_kills = randomIntRange(15,21);

	self thread set_zombie_run_cycle( "sprint" );
	self.custom_goalradius_override = 1000000;

    if(getdvar("mapname") == "zm_tomb")
        turned_fx = playfxontag(level._effect[ "staff_soul" ], self, "j_head");
    else
        turned_fx = playfxontag(level._effect["powerup_on_solo"], self, "j_head");

	enemyoverride = [];
	self.team = level.players; 
	self.ignore_enemy_count = 1;

	if(getdvar("mapname") == "zm_tomb")
		attackanim = "zm_generator_melee";
	else
		attackanim = "zm_riotshield_melee";
	
	if ( !self.has_legs )
		attackanim += "_crawl";
	
	while(isAlive(self))
	{
		ai_zombies = get_array_of_closest( self.origin, getaiarray( level.zombie_team ), undefined, undefined, undefined  );
		if(isdefined(ai_zombies[1]) && can_aat_damage(ai_zombies[1]))
		{
			enemyoverride[0] = ai_zombies[1].origin;
			enemyoverride[1] = ai_zombies[1];
		}
		else
		{
			enemyoverride[0] = ai_zombies[0].origin;
			enemyoverride[1] = ai_zombies[0];
		}
		self.enemyoverride = enemyoverride;	
		if(distance(self.origin, ai_zombies[1].origin) < 40 && isalive(ai_zombies[1]) )
		{
			angles = VectorToAngles( ai_zombies[1].origin - self.origin );
			self animscripted( self.origin, angles, attackanim );
			ai_zombies[1] dodamage(ai_zombies[1].maxhealth * 2, ai_zombies[1].origin);
			self.turned_zombie_kills++;
			
			attacker.score += 50;
			attacker.pers["score"] = attacker.score;

			if(self.turned_zombie_kills > self.max_kills)
			{
                turned_fx delete();
				self.is_turned = 0;
				wait .1;
				self dodamage(self.health + 666, self.origin);
			}

			wait 1;
		}
		else
			self stopanimscripted();

		wait .05; 
	}
	attacker.active_turned = 0;
	self.is_turned = 0;

    if(isdefined(turned_fx))
        turned_fx delete();
}

turned_damage_respond( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
    if(self.is_turned)
        return 0;
}

turned_zombie()
{
	if(self.turned)
	{
		//attack zombies
	}
	else
		zombie_poi = self get_zombie_point_of_interest( self.origin );
	
	return zombie_poi;
}

turned_zombie_validation()
{	
	if( IS_TRUE( self.barricade_enter ) )
		return false;
	
	if ( IS_TRUE( self.is_traversing ) )
		return false;
	
	if ( !IS_TRUE( self.completed_emerging_into_playable_area ) )
		return false;
	
	if ( IS_TRUE( self.is_leaping ) )
		return false;
	
	if ( IS_TRUE( self.is_inert ) )
		return false;
	
	return true;
}

is_true(check)
{
	return(IsDefined(check) && check);
}

give_aat(weapon)
{		
	if(!isDefined(self.aat))
		self.aat = [];

    if(isdefined(self.old_aat))
    {
        if(self.old_aat == "Thunder Wall")
            self.old_aat = 0;
        else if(self.old_aat == "Fireworks")
            self.old_aat = 1;
        else if(self.old_aat == "Turned")
            self.old_aat = 2;
        else if(self.old_aat == "Cluster")
            self.old_aat = 3;
        else if(self.old_aat == "Headcutter")
            self.old_aat = 4;
        else if(self.old_aat == "Explosive")
            self.old_aat = 5;
        else if(self.old_aat == "Blast Furnace")
            self.old_aat = 6;
    }

	name = undefined;

	number = randomint(7);

	while(isdefined(self.old_aat) && number == self.old_aat)
	{
		number = randomint(7);
		wait .05;
	}
	
	if(number == 0)
		name = "Thunder Wall";
	else if(number == 1)
		name = "Fireworks";
    else if(number == 2)
        name = "Turned";
    else if(number == 3)
        name = "Cluster";
    else if(number == 4)
        name = "Headcutter";
    else if(number == 5)
        name = "Explosive";
    else if(number == 6)
        name = "Blast Furnace";

	self.aat[weapon] = name;

	self.old_aat = name;

}

tombstone_timeout()
{
	level endon("end_game");
	self endon("dance_on_my_grave");
	self endon("disconnect");
	self endon("revived_player");

	self waittill("spawned_player");
	wait 60;
	self notify("tombstone_timedout");
	wait 1;
	weapon = self getCurrentWeapon();
	self notify("weapon_change", weapon);
}

watch_weapon_changes()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self waittill("spawned_player");
	flag_wait("initial_blackscreen_passed");

    if(getdvar("mapname") == "zm_prison") //prevent triggering weapon change when spawning in motd
        level waittill("start_of_round");

    self thread explosive_bullet(); //start explosive bullet background

	while( isdefined( self ) )
	{
		result = self waittill_any_return( "weapon_change", "fake_death", "player_downed" );
		weapon = self getCurrentWeapon();

		if(result == "player_downed" || result == "fake_death")
		{
			if(self hasperk("specialty_scavenger") || self hasperk("specialty_finalstand"))
			{
				if(self hasperk("specialty_scavenger"))
					self thread tombstone_timeout();

				self waittill_any("player_revived", "dance_on_my_grave", "tombstone_timedout", "chugabud_bleedout", "chugabud_effects_cleanup");
			}
		}

        if(isdefined(self.afterlife) && self.afterlife)
			self waittill("spawned_player");

		name = undefined;

		if( IsDefined( self.aat[weapon] ) )
			name = self.aat[weapon];

		self aat_hud(name);

		if( IsDefined( self.aat ) )
		{
			keys = GetArrayKeys( self.aat );
			foreach( aat in keys )
			{
				if(IsDefined( self.aat[aat] ) && isdefined( aat ) && !self hasweapon( aat ))
					self.aat[aat] = undefined;
			}
		}
	}
}

aat_hud(name)
{
	self endon("disconnect");

    if(isdefined(self.aat_hud))
		self.aat_hud destroy();

	if(isDefined(name))
	{
		if(name == "Thunder Wall")
        {
			label = &"Thunder Wall";
            color = (0,1,1);
        }
		else if(name == "Fireworks")
		{
        	label = &"Fireworks";
            color = (0,1,0);
		}
        else if(name == "Turned")
		{
        	label = &"Turned";
            color = (1,0.5,0.5);
		}
        else if(name == "Cluster")
		{
        	label = &"Cluster";
            color = (0.4,0.4,0.2);
		}
        else if(name == "Headcutter")
		{
        	label = &"Headcutter";
            color = (1,0,1);
		}
        else if(name == "Explosive")
		{
        	label = &"Explosive";
            color = (0,0,1);
		}
        else if(name == "Blast Furnace")
		{
        	label = &"Blast Furnace";
            color = (1,0,0);
        }
        self.aat_hud = newClientHudElem(self);
        self.aat_hud.alignx = "right";
        self.aat_hud.aligny = "bottom";
        self.aat_hud.horzalign = "user_right";
        self.aat_hud.vertalign = "user_bottom";
        if( getdvar( "mapname" ) == "zm_transit" || getdvar( "mapname" ) == "zm_highrise" || getdvar( "mapname" ) == "zm_nuked")
        {
            self.aat_hud.x = -85;
            self.aat_hud.y = -22;
        }
		else if( getdvar( "mapname" ) == "zm_tomb" )
        {
            self.aat_hud.x = -110;
            self.aat_hud.y = -80;
        }
        else
        {
            self.aat_hud.x = -95;
            self.aat_hud.y = -80;
        }
        self.aat_hud.archived = 1;
        self.aat_hud.fontscale = 1;
        self.aat_hud.alpha = 1;
        self.aat_hud.color = color;
        self.aat_hud.hidewheninmenu = 1;
        self.aat_hud.label = label;
    }
}

can_aat_damage(ai_zombies)
{
    if(isdefined(ai_zombies.is_turned) && ai_zombies.is_turned)
        return 0;

    if(isdefined(level.sloth) && ai_zombies == level.sloth)
        return 0;

    if(isDefined(ai_zombies.is_avogadro) && ai_zombies.is_avogadro || isDefined(ai_zombies.is_brutus) && ai_zombies.is_brutus || isDefined(ai_zombies.is_mechz) && ai_zombies.is_mechz )
        return 0;

    return 1;
}
