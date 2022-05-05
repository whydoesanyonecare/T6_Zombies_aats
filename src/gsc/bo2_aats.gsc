#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/gametypes_zm/_spawnlogic;
#include maps/mp/animscripts/traverse/shared;
#include maps/mp/animscripts/utility;
#include maps/mp/zombies/_load;
#include maps/mp/_createfx;
#include maps/mp/_music;
#include maps/mp/_busing;
#include maps/mp/_script_gen;
#include maps/mp/gametypes_zm/_globallogic_audio;
#include maps/mp/gametypes_zm/_tweakables;
#include maps/mp/_challenges;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/_demo;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_spawning;
#include maps/mp/gametypes_zm/_globallogic_utils;
#include maps/mp/gametypes_zm/_spectating;
#include maps/mp/gametypes_zm/_globallogic_spawn;
#include maps/mp/gametypes_zm/_globallogic_ui;
#include maps/mp/gametypes_zm/_hostmigration;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/gametypes_zm/_globallogic;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_ai_faller;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_pers_upgrades;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/animscripts/zm_run;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_power;
#include maps/mp/zombies/_zm_server_throttle;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_ai_dogs;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_buildables;
#include codescripts/character;
#include maps/mp/zombies/_zm_weap_riotshield;
#include maps/mp/zm_transit_bus;
#include maps/mp/zm_transit_utility;
#include maps/mp/zombies/_zm_equip_turret;
#include maps/mp/zombies/_zm_mgturret;
#include maps\mp\zombies\_zm_weap_jetgun;

#include maps/mp/zombies/_zm_ai_sloth;
#include maps/mp/zombies/_zm_ai_sloth_ffotd;
#include maps/mp/zombies/_zm_ai_sloth_utility;
#include maps/mp/zombies/_zm_ai_sloth_magicbox;
#include maps/mp/zombies/_zm_ai_sloth_crawler;
#include maps/mp/zombies/_zm_ai_sloth_buildables;
init()
{
	precacheshader("damage_feedback");
	precacheshader("hud_status_dead");    
	if( getdvar( "mapname" ) == "zm_transit" )
	{
		level._effect[ "jetgun_smoke_cloud" ] = loadfx( "weapon/thunder_gun/fx_thundergun_smoke_cloud" );
	}
    level.custom_pap_validation = thread new_pap_trigger();
	level._poi_override = ::turned_zombie;
    register_player_damage_callback( ::playerdamagelastcheck );
    flag_wait( "initial_blackscreen_passed" );
	level.callbackactordamage = ::actor_damage_override_wrapper;
}

playerdamagelastcheck( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	/*if(isdefined(self.has_cluster) && self.has_cluster && isdefined(eattacker) && eattacker == self) //someone will cry about it eventually..
    {
        return 0;
    }*/ 
	players = get_players();
	for(i=0;i<players.size;i++)
	{
		if(isdefined(players[i].firework_weapon) && eattacker == players[i].firework_weapon)
		{
			return 0;
		}
	}
	return idamage;
}

vector_scal( vec, scale )
{
	vec = ( vec[ 0] * scale, vec[ 1] * scale, vec[ 2] * scale );
	return vec;
}

pap_off()
{
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
    level waittill("Pack_A_Punch_on");
    wait 2;
    
	if( getdvar( "mapname" ) == "zm_transit" && getdvar ( "g_gametype")  == "zstandard" )
	{	
	}
	else
	{
		level notify("Pack_A_Punch_off");
		level thread pap_off();
	}
	perk_machine = getent( "vending_packapunch", "targetname" );
	weapon_upgrade_trigger = getentarray( "specialty_weapupgrade", "script_noteworthy" );
	weapon_upgrade_trigger[0] trigger_off();
	if( getdvar( "mapname" ) == "zm_transit" && getdvar ( "g_gametype")  == "zclassic" )
	{
		if(!level.buildables_built[ "pap" ])
		{
			level waittill("pap_built");
			wait 1;
		}
	}
	self.perk_machine = perk_machine;
	perk_machine_sound = getentarray( "perksacola", "targetname" );
	packa_rollers = spawn( "script_origin", perk_machine.origin );
	packa_timer = spawn( "script_origin", perk_machine.origin );
	packa_rollers linkto( perk_machine );
	packa_timer linkto( perk_machine );
	if( getdvar( "mapname" ) == "zm_highrise" )
	{
		trigger = spawn( "trigger_radius", perk_machine.origin, 1, 60, 80 );
		Trigger enableLinkTo();
		Trigger linkto(self.perk_machine);
	}
	else
	{
		trigger = spawn( "trigger_radius", perk_machine.origin, 1, 35, 80 );
	}
	Trigger SetCursorHint( "HINT_NOICON" );
    Trigger sethintstring( &"ZOMBIE_PERK_PACKAPUNCH", 5000 );
	Trigger usetriggerrequirelookat();
	perk_machine thread maps/mp/zombies/_zm_perks::activate_packapunch();
	for(;;)
	{
		Trigger waittill("trigger", player);
		current_weapon = player getcurrentweapon();
        if(current_weapon == "saritch_upgraded_zm+dualoptic" || current_weapon == "dualoptic_saritch_upgraded_zm+dualoptic" || current_weapon == "slowgun_upgraded_zm")
        {
            Trigger sethintstring( "^1This weapon doesn't have alternative ammo types." );
            continue;
        }
		if(player UseButtonPressed() && player.score >= 5000 && current_weapon != "riotshield_zm" && player can_buy_weapon() && !player.is_drinking && !is_placeable_mine( current_weapon ) && !is_equipment( current_weapon ) && level.revive_tool != current_weapon && current_weapon != "none" )
        {
			player.score -= 5000;
            player thread maps/mp/zombies/_zm_audio::play_jingle_or_stinger( "mus_perks_packa_sting" );
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
            
			player thread maps/mp/zombies/_zm_perks::do_knuckle_crack();
			wait .1;
			player takeWeapon(current_weapon);
			current_weapon = player maps/mp/zombies/_zm_weapons::switch_from_alt_weapon( current_weapon );
			self.current_weapon = current_weapon;
			upgrade_name = maps/mp/zombies/_zm_weapons::get_upgrade_weapon( current_weapon, upgrade_as_attachment );
			player third_person_weapon_upgrade( current_weapon, upgrade_name, packa_rollers, perk_machine, self );
			trigger sethintstring( &"ZOMBIE_GET_UPGRADED" );
			trigger thread wait_for_pick(player, current_weapon, self.upgrade_name);
			if ( isDefined( player ) )
			{
				trigger setinvisibletoall();
				trigger setvisibletoplayer( player );
			}
			self thread wait_for_timeout( current_weapon, packa_timer, player );
			self waittill_any( "pap_timeout", "pap_taken", "pap_player_disconnected" );
			self.current_weapon = "";
			if ( isDefined( self.worldgun ) && isDefined( self.worldgun.worldgundw ) )
			{
				self.worldgun.worldgundw delete();
			}
			if ( isDefined( self.worldgun ) )
			{
				self.worldgun delete();
			}
			trigger setinvisibletoplayer( player );
			wait 1.5;
			trigger setvisibletoall();
			self.pack_player = undefined;
			flag_clear( "pack_machine_in_use" );
		}
        trigger sethintstring( &"ZOMBIE_PERK_PACKAPUNCH", 5000 );
		wait .1;
	}
}

wait_for_pick(player, weapon, upgrade_weapon )
{
	level endon( "pap_timeout" );
	for (;;)
	{
		self playloopsound( "zmb_perks_packa_ticktock" );
		self waittill( "trigger", user );
		if(user UseButtonPressed() && player == user)
		{	
			self stoploopsound( 0.05 );
			player thread do_player_general_vox( "general", "pap_arm2", 15, 100 );
			gun = player maps/mp/zombies/_zm_weapons::get_upgrade_weapon( upgrade_weapon, 0 );
			if(is_weapon_upgraded( weapon ) )
			{
				player.restore_ammo = 1;
				if( weapon == "galil_upgraded_zm+reflex" || weapon  == "fnfal_upgraded_zm+reflex" )
				{
					level thread aats(weapon, player); //Alternative ammo type for galil and fnfal upgraded
				}
				else
				{
					level thread aats(upgrade_weapon, player); //Alternative ammo type for all other weapons
				}
			}
			if( weapon == "galil_upgraded_zm+reflex" || weapon  == "fnfal_upgraded_zm+reflex" )
			{
				player giveweapon( weapon, 0, player maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( weapon ));
				player switchToWeapon( weapon );
				x = weapon;
			}
            else
            {
                weapon_limit = get_player_weapon_limit( player );
                player maps/mp/zombies/_zm_weapons::take_fallback_weapon();
                primaries = player getweaponslistprimaries();
                if ( isDefined( primaries ) && primaries.size >= weapon_limit )
                {
                    player maps/mp/zombies/_zm_weapons::weapon_give( upgrade_weapon );
                }
                else
                {
                    player giveweapon( upgrade_weapon, 0, player maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( upgrade_weapon ));
                }
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

aats(name, player)
{
	self endon( "death" );
	self endon( "pap_timeout" );
	self endon( "pap_player_disconnected" );
	self endon( "Pack_A_Punch_off" );
	self waittill("pap_taken");
	self thread pick_ammo(name, player);
}

pick_ammo(name, player)
{
	player notify("new_aat");
	primaries = player getweaponslistprimaries();
	if(!isDefined(player.active_explosive_bullet))
	{
		player thread explosive_bullet();
	}
	if(!isDefined(player.weaponname))
	{
		player.active_turned = 0;
		player.has_turned = 0;
        player.has_blast_furnace = 0;
        player.has_fireworks = 0;
        player.cooldown = 0;
        player.has_explosive_bullets = 0;
        player.has_thunder_wall = 0;
		player.has_Headcutter = 0;
        player.has_cluster = 0;
		player thread aat_hitmarker();
	}
	if(!isDefined(player.weaponname))
	{
		player.weaponname = "x";
	}
	if(!isDefined(player.last_aat))
	{
		player.last_aat = 0;
	}
	if(!isDefined(player.aat_weapon))
	{
		player.aat_weapon = [];
	}
	if(!isDefined(player.weapon_aats))
	{
		player.weapon_aats = [];
	}
	aat = randomintrange(1,8); //INSANEMODE tested it abd it is working.
	if(player.weaponname == name && player.last_aat == aat)
	{
		return pick_ammo(name, player);
	}
	for(i=0; i<primaries.size; i++)
	{
		if(isdefined(primaries[i]) && name == primaries[i])
		{
			player.weapon_aats[i] = aat;
			player.aat_weapon[i] = name;
		}
	}
	player.last_aat = aat;
	player.weaponname = name;
	player.aat_hud destroy();
	if(aat == 1)
	{
		player aat_hud("Blast Furnace", (1,0,0));
		player.has_blast_furnace = 1;
		player.has_fireworks = 0;
		player.has_explosive_bullets = 0;
        player.has_thunder_wall = 0;
        player.has_Headcutter = 0;
        player.has_cluster = 0;
		player.has_turned = 0;
	}
	if(aat == 2)
	{
		player aat_hud("Fireworks", (0,1,0));
		player.has_fireworks = 1;
		player.has_blast_furnace = 0;
		player.has_explosive_bullets = 0;
        player.has_thunder_wall = 0;
        player.has_Headcutter = 0;
        player.has_cluster = 0;
		player.has_turned = 0;
	}
	if(aat == 3)
	{
		player aat_hud("Explosive", (0,0,1));
		player.has_fireworks = 0;
		player.has_blast_furnace = 0;
		player.has_explosive_bullets = 1;
        player.has_thunder_wall = 0;
        player.has_Headcutter = 0;
        player.has_cluster = 0;
		player.has_turned = 0;
	}
    if(aat == 4)
	{
		player aat_hud("Headcutter", (1,0,1));
		player.has_fireworks = 0;
		player.has_blast_furnace = 0;
		player.has_explosive_bullets = 0;
        player.has_thunder_wall = 0;
        player.has_Headcutter = 1;
        player.has_cluster = 0;
		player.has_turned = 0;
	}
    if(aat == 5)
	{
		player aat_hud("Cluster", (0.4,0.4,0.2));
		player.has_fireworks = 0;
		player.has_blast_furnace = 0;
		player.has_explosive_bullets = 0;
        player.has_thunder_wall = 0;
        player.has_Headcutter = 0;
        player.has_cluster = 1;
		player.has_turned = 0;
	}
	if(aat == 6)
	{
		player aat_hud("Turned", (1,0.5,0.5));
		player.has_fireworks = 0;
		player.has_blast_furnace = 0;
		player.has_explosive_bullets = 0;
        player.has_thunder_wall = 0;
        player.has_Headcutter = 0;
        player.has_cluster = 1;
		player.has_turned = 0;
	}
    if(aat == 7)
	{
		player aat_hud("Thunder Wall", (0,1,1));
		player.has_fireworks = 0;
		player.has_blast_furnace = 0;
		player.has_explosive_bullets = 0;
        player.has_thunder_wall = 1;
        player.has_Headcutter = 0;
        player.has_cluster = 0;
		player.has_turned = 0;
	}
	player thread monitor_aat_weapon();
}

aat_hud(name, color)
{
	self endon("disconnect");
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
	else
	{
		self.aat_hud.x = -95;
		self.aat_hud.y = -80;
	}
	self.aat_hud.fontscale = 1;
	self.aat_hud.alpha = 1;
	self.aat_hud.color = color;
	self.aat_hud.hidewheninmenu = 1;
	self.aat_hud settext(name);
}

monitor_aat_weapon()
{
	self endon("disconnect");
	self endon("new_aat");
	for(;;)
	{
		self waittill( "weapon_change" );
		wait .1;
		if(self getCurrentWeapon() == "none")
		{
			return monitor_aat_weapon();
		}
		if(isDefined(self.aat_hud))
		{
			self.aat_hud destroy();
		}
		for(i=0;i<3;i++)
		{
			if(isDefined(self.aat_weapon[i]) && !self hasweapon(self.aat_weapon[i]))
			{
				self.weapon_aats[i] = undefined;
				self.aat_weapon[i] = undefined;
			}
		}
		wait .1;
		for(i=0;i<3;i++)
		{
			if(IsDefined( self.aat_weapon[i] ) && self getCurrentWeapon() == self.aat_weapon[i])
			{
				if(self.weapon_aats[i] == 2)
				{
					self.has_fireworks = 1;
					self.has_blast_furnace = 0;
					self.has_explosive_bullets = 0;
					self.has_thunder_wall = 0;
					self.has_Headcutter = 0;
					self.has_cluster = 0;
					self.has_turned = 0;
					self aat_hud("Fireworks", (0,1,0));
				}
				if(self.weapon_aats[i] == 1)
				{
					self.has_fireworks = 0;
					self.has_blast_furnace = 1;
					self.has_explosive_bullets = 0;
					self.has_thunder_wall = 0;
					self.has_Headcutter = 0;
					self.has_cluster = 0;
					self.has_turned = 0;
					self aat_hud("Blast Furnace", (1,0,0));
				}
				if(self.weapon_aats[i] == 3)
				{
					self aat_hud("Explosive", (0,0,1));
					self.has_fireworks = 0;
					self.has_blast_furnace = 0;
					self.has_explosive_bullets = 1;
					self.has_thunder_wall = 0;
					self.has_Headcutter = 0;
					self.has_cluster = 0;
					self.has_turned = 0;
				}
				if(self.weapon_aats[i] == 4)
				{
					self aat_hud("Headcutter", (1,0,1));
					self.has_fireworks = 0;
					self.has_blast_furnace = 0;
					self.has_explosive_bullets = 0;
					self.has_thunder_wall = 0;
					self.has_Headcutter = 1;
					self.has_cluster = 0;
					self.has_turned = 0;
				}
				if(self.weapon_aats[i] == 5)
				{
					self aat_hud("Cluster", (0.4,0.4,0.2));
					self.has_fireworks = 0;
					self.has_blast_furnace = 0;
					self.has_explosive_bullets = 0;
					self.has_thunder_wall = 0;
					self.has_Headcutter = 0;
					self.has_cluster = 1;
					self.has_turned = 0;
				}
				if(self.weapon_aats[i] == 6)
				{
					self aat_hud("Turned", (1,0.5,0.5));
					self.has_fireworks = 0;
					self.has_blast_furnace = 0;
					self.has_explosive_bullets = 0;
					self.has_thunder_wall = 0;
					self.has_Headcutter = 0;
					self.has_cluster = 0;
					self.has_turned = 1;
				}
                if(self.weapon_aats[i] == 7)
				{
					self aat_hud("Thunder Wall", (0,1,1));
					self.has_fireworks = 0;
					self.has_blast_furnace = 0;
					self.has_explosive_bullets = 0;
					self.has_thunder_wall = 1;
					self.has_Headcutter = 0;
					self.has_cluster = 0;
					self.has_turned = 0;
				}
			}
		}
		if(self getCurrentWeapon() != self.aat_weapon[0] && self getCurrentWeapon() != self.aat_weapon[1] && self getCurrentWeapon() != self.aat_weapon[2])
		{
            self.has_thunder_wall = 0;
			self.has_fireworks = 0;
			self.has_blast_furnace = 0;
			self.has_explosive_bullets = 0;
            self.has_Headcutter = 0;
			self.has_cluster = 0;
			self.has_turned = 0;
		}
	}
}

actor_damage_override_wrapper( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked does not match cerberus output did not change
{
	damage_override = self actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	if ( ( self.health - damage_override ) > 0 || !is_true( self.dont_die_on_me ) )
	{
		self finishactordamage( inflictor, attacker, damage_override, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
}

actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) 
{
    if(isdefined(level.sloth) && self == level.sloth)
    {
    	if ( weapon == "equip_headchopper_zm" )
		{
			self.damageweapon_name = weapon;
			self check_zombie_damage_callbacks( meansofdeath, shitloc, vpoint, attacker, damage );
			self.damageweapon_name = undefined;
		}
		if ( isDefined( self.sloth_damage_func ) )
		{
			xdamage = self [[ self.sloth_damage_func ]]( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime );
			return xdamage;
		}
		if ( meansofdeath == level.slowgun_damage_mod && weapon == "slowgun_zm" )
		{
			return 0;
		}
		if ( meansofdeath == "MOD_MELEE" )
		{
			self sloth_leg_pain();
			return 0;
		}
		if ( self.state == "jail_idle" )
		{
			self stop_action();
			self sloth_set_state( "jail_cower" );
			maps/mp/zombies/_zm_unitrigger::register_unitrigger( self.gift_trigger, ::buildable_place_think );
			return 0;
		}
		if ( meansofdeath != "MOD_EXPLOSIVE" && meansofdeath != "MOD_EXPLOSIVE_SPLASH" && meansofdeath != "MOD_GRENADE" && meansofdeath != "MOD_GRENADE_SPLASH" || meansofdeath == "MOD_PROJECTILE" && meansofdeath == "MOD_PROJECTILE_SPLASH" )
		{
			do_pain = self sloth_pain_react();
			self sloth_set_state( "jail_run", do_pain );
			return 0;
		}
		if ( !is_true( self.damage_accumulating ) )
		{
			self thread sloth_accumulate_damage( damage );
		}
		else
		{
			self.damage_taken += damage;
			self.num_hits++;
		}
		return 0;
    }
	if(isdefined( attacker.weaponname ))
	{
        //attacker cannot damage active turned zombie
        if(!isDefined(self.is_turned))
        {
            self.is_turned = 0;
        }
		if(attacker.active_turned && self.is_turned)
		{
			return 0;
		}
		if(isdefined( attacker ) && isplayer( attacker ) && !attacker.cooldown && MeansOfDeath != "MOD_MELEE" && MeansOfDeath != "MOD_IMPACT" && weapon != "knife_zm")
		{
            aat_cooldown_time = randomintrange(10, 16); //cooldown 10 - 15 seconds
	        aat_activation = randomintrange(1,11); //bullet that actives aat 1 - 10 

			if(isDefined(self.is_avogadro) && self.is_avogadro || isDefined(self.is_brutus) && self.is_brutus || isDefined(self.is_mechz) && self.is_mechz )
			{
				//boss zombie check
                return int( damage );
			}
			else
			{
				zombies = getaiarray( level.zombie_team );
				if(meansofdeath == "MOD_GRENADE" || meansofdeath == "MOD_GRENADE_SPLASH" || meansofdeath == "MOD_EXPLOSIVE" || meansofdeath == "MOD_PROJECTILE")
				{
					if(is_weapon_upgraded( weapon ))
					{
					}
					else
					{
						return damage;
					}
				}
				if(self turned_zombie_validation() && attacker.has_turned && !attacker.active_turned)
				{
					turned = aat_activation;
					if(turned == 1)
					{
						attacker.aat_actived = 1;
						attacker thread cool_down(aat_cooldown_time);
						self thread turned( attacker );
						idamage = 1;
						return idamage;
					}
				}
				if(attacker.has_cluster)
				{
					cluster = aat_activation;
					if(cluster == 1)
					{
						attacker.aat_actived = 1;
						attacker thread cool_down(aat_cooldown_time);
						self thread cluster();
						self dodamage( self.health * 2, self.origin, attacker, attacker, "none", "MOD_IMPACT" );
					}

				}
				if(attacker.has_Headcutter)
				{
					Headcutter = aat_activation;
					if(Headcutter == 1)
					{
						attacker.aat_actived = 1;
						attacker thread cool_down(aat_cooldown_time);
						for( i=0; i < zombies.size; i++ )
						{
							if(distance(self.origin, zombies[i].origin) <= 200)
							{
								if(!zombies[i].done)
								{
									zombies[i].done = 1;
									zombies[i] thread Headcutter(attacker);
								}
							}
						}
						self dodamage( self.health * 2, self.origin, attacker, attacker, "none", "MOD_IMPACT" );
					}
				}
				if(attacker.has_thunder_wall)
				{
					thunder_wall = aat_activation;
					if(thunder_wall == 1)
					{
                        attacker setclientdvar( "ragdoll_enable", 1);
						attacker.aat_actived = 1;
						self thread thunderwall(attacker);
						attacker thread cool_down(aat_cooldown_time);
						self dodamage( self.health * 2, self.origin, attacker, attacker, "none", "MOD_IMPACT" );
					}
					
				}
				if(attacker.has_blast_furnace)
				{
					blast_furnace = aat_activation;
					if(blast_furnace == 1)
					{
						attacker.aat_actived = 1;
						attacker thread cool_down(aat_cooldown_time);
						flameFX=loadfx("env/fire/fx_fire_zombie_torso");
						PlayFXOnTag(flameFX,self, "j_spinelower");
						flameFX2=loadfx("env/fire/fx_fire_zombie_md");
						PlayFXOnTag(flameFX2,self,"j_spineupper");
						for( i = 0; i < zombies.size; i++ )
						{
							if(distance(self.origin, zombies[i].origin) <= 220)
							{
								zombies[i] thread flames_fx();
							}
						}
						self dodamage( self.health * 2, self.origin, attacker, attacker, "none", "MOD_IMPACT" );
					}
				}
				if(attacker.has_fireworks)
				{
					fireworks = aat_activation;
					if(fireworks == 1)
					{
						attacker.aat_actived = 1;
						attacker thread cool_down(aat_cooldown_time);
						origin = self.origin;
						weapon = attacker getcurrentweapon();
						self thread spawn_weapon(origin, weapon, attacker);
						self thread fireworks(origin);
						return damage;
                        //self dodamage( self.health * 2, self.origin, attacker, attacker, "none", "MOD_IMPACT" );
					}
				}
			}
		}
	}
	return int( damage );
}

cool_down(time)
{
	self.cooldown = 1;
	wait time;
	self.cooldown = 0;
}

explosive_bullet()
{
	self.active_explosive_bullet = 1;
	for( ;; )
	{
		self waittill( "weapon_fired" );
		explosive = randomintrange(1,5);
		if(explosive == 1 && self.has_explosive_bullets && !self.cooldown)
		{
			self.aat_actived = 1;
			self thread cool_down(randomintrange(5,11));
			forward = self gettagorigin( "tag_weapon_right" );
			end = self thread vector_scal( anglestoforward( self getplayerangles() ), 1000000 );
			crosshair_entity = bullettrace(self gettagorigin("tag_weapon_right"),self gettagorigin("tag_weapon_right")+anglestoforward(self getplayerangles())*1000000,true,self)["entity"];
			crosshair = bullettrace( forward, end, 0, self )[ "position"];
			magicbullet( self getcurrentweapon(), self gettagorigin( "j_shouldertwist_le" ), crosshair, self );
			self enableInvulnerability();
			if(isdefined(crosshair_entity))
			{
				crosshair_entity playsound( "zmb_phdflop_explo" );
				playfx(loadfx("explosions/fx_default_explosion"), crosshair_entity.origin, anglestoforward( ( 0, 45, 55  ) ) );
				radiusdamage( crosshair_entity.origin, 300, 5000, 1000, self );
			}
			else
			{
				crosshair playsound( "zmb_phdflop_explo" );
				playfx(loadfx("explosions/fx_default_explosion"), crosshair, anglestoforward( ( 0, 45, 55  ) ) );
				radiusdamage( crosshair, 300, 5000, 1000, self );
			}
            wait .5;
			self disableInvulnerability();
		}
		wait .1;
	}
}

flames_fx()
{
	for(i = 0; i < 5; i++)
	{
		flameFX=loadfx("env/fire/fx_fire_zombie_torso");
		PlayFXOnTag(flameFX, self, "j_spineupper");
		if(i < 3)
		{
			self dodamage(self.health / 2, (0,0,0));
		}
		else
		{
			self dodamage(self.maxhealth * 2, (0,0,0));
		}
		wait 1;
	}
}

fireworks(origin)
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

spawn_weapon(origin, weapon, attacker)
{
    attacker.firework_weapon = spawnentity( "script_model", getweaponmodel( weapon ), origin + (0,0,45), (0,0,0) + ( 0, 50, 0 ));
    for(i=0;i<100;i++)
    {
        zombies = get_array_of_closest( attacker.firework_weapon.origin, getaiarray( level.zombie_team ), undefined, undefined, 300  );
        forward = attacker.firework_weapon.origin;
        end = zombies[ 0 ] gettagorigin( "j_spineupper" );
        crosshair = bullettrace( forward, end, 0, self )[ "position"];
        attacker.firework_weapon.angles = VectorToAngles( end - attacker.firework_weapon.origin );
        if( distance(zombies[ 0 ].origin, attacker.firework_weapon.origin) <= 300)
        {
            magicbullet( weapon, attacker.firework_weapon.origin, crosshair, attacker.firework_weapon );
        }
        wait .05;
    }
    attacker.firework_weapon delete();
}

spawnentity( class, model, origin, angle )
{
	entity = spawn( class, origin );
	entity.angles = angle;
	entity setmodel( model );
	return entity;
}

thunderwall( attacker ) 
{
	thunder_wall_blast_pos = self.origin; 
	ai_zombies = get_array_of_closest( thunder_wall_blast_pos, getaiarray( level.zombie_team ), undefined, undefined, 250  );
    if ( !isDefined( ai_zombies ) )
	{
		return;
	}
	flung_zombies = 0;
    max_zombies = undefined;
    max_zombies = randomIntRange(5,25);
	for ( i = 0; i < ai_zombies.size; i++ )
	{
		if(isDefined(ai_zombies[i].is_avogadro) && ai_zombies[i].is_avogadro || isDefined(ai_zombies[i].is_brutus) && ai_zombies[i].is_brutus || isDefined(ai_zombies[i].is_mechz) && ai_zombies[i].is_mechz )
		{
			//boss zombie check
		}
		else
		{
			n_random_x = RandomFloatRange( -3, 3 );
			n_random_y = RandomFloatRange( -3, 3 );
			ai_zombies[i] StartRagdoll();
			ai_zombies[i] LaunchRagdoll( (n_random_x, n_random_y, 150) );
            playfxontag( level._effect[ "jetgun_smoke_cloud"], ai_zombies[i], "J_SpineUpper" );
            ai_zombies[i] DoDamage( ai_zombies[i].health * 2, ai_zombies[i].origin, attacker, attacker, "none", "MOD_IMPACT" );
        	flung_zombies++;
			if ( flung_zombies >= max_zombies )
			{
				break;
			}
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

cluster()
{
	if(level.round_number < 10)
	{
		amount = randomIntRange(1, (level.round_number * 2));
	}
	else
	{
		amount = randomIntRange(7, level.round_number);
	}
	random_x = RandomFloatRange( -3,3 );
	random_y = RandomFloatRange( -3,3 );
	for(i = 0; i < amount; i++)
	{
		self MagicGrenadeType( "frag_grenade_zm", self.origin + (random_x, random_y, 10), (random_x, random_y, 0), 2 );
		wait .1;
	}
}

aat_hitmarker()
{
	self thread startwaiting();
	self.aat_hitmarker = newdamageindicatorhudelem( self );
	self.aat_hitmarker.horzalign = "center";
	self.aat_hitmarker.vertalign = "middle";
	self.aat_hitmarker.x = -12;
	self.aat_hitmarker.y = -12;
	self.aat_hitmarker.alpha = 0;
	self.aat_hitmarker setshader( "damage_feedback", 24, 48 );
}

startwaiting()
{
	while( 1 )
	{
		foreach( zombie in getaiarray( level.zombie_team ) )
		{
			if( !(IsDefined( zombie.waitingfordamage )) )
			{
				zombie thread aat_hitmarks();
			}
		}
		wait 0.25;
	}
}

aat_hitmarks()
{
	self.waitingfordamage = 1;
	while( 1 )
	{
		self waittill( "damage", amount, attacker, dir, point, mod );
		if(!isDefined(attacker.aat_actived))
		{
			attacker.aat_actived = 0;
		}
		attacker.aat_hitmarker.alpha = 0;
		if( isplayer( attacker ) )
		{
			if(attacker.aat_actived)
			{
				attacker.aat_hitmarker.alpha = 1;
				for(i=0;i<20;i++)
				{
					r = randomfloatrange(0.1, 0.9);
					g = randomfloatrange(0.1, 0.9);
					b = randomfloatrange(0.1, 0.9);
					attacker.aat_hitmarker.color = ( r, g, b );
					if(i > 5)
					{
						attacker.aat_hitmarker.alpha -= .075;
					}
					wait .1;
				}
				attacker.aat_hitmarker.alpha = 0;
				attacker.aat_actived = 0;
				self.waitingfordamage = 0;
				break;
			}
		}
	}
}

turned( attacker )
{
	self.is_turned = 1;
	attacker.active_turned = 1;
	turned_zombie_kills = 0;
	max_kills = randomIntRange(15,21);

	self thread set_zombie_run_cycle( "sprint" );
	self.custom_goalradius_override = 1000000;

	//set turned icon for zombie
	//todo: icon takes zombies z origin from original ground not zombies z origin
	turned_icon = newHudElem();
    turned_icon.x = self.origin[ 0 ];
    turned_icon.y = self.origin[ 1 ];
    turned_icon.z = self.origin[ 2 ] + (0,0,80);
	turned_icon.color = (0,1,0);
    turned_icon.isshown = 1;
    turned_icon.archived = 0;
    turned_icon setshader( "hud_status_dead", 4, 4 );
    turned_icon setwaypoint( 1 );

	enemyoverride = [];

	//cannot damage player
	self.team = level.players; 
	
	//allow round change while turned zombie is alive
	self.ignore_enemy_count = 1;

	attackanim = "zm_riotshield_melee";
	if ( !self.has_legs )
	{
		attackanim += "_crawl";
	}
	
	while(isAlive(self))
	{
		turned_icon.x = self.origin[ 0 ];
		turned_icon.y = self.origin[ 1 ];
		turned_icon.z = self.origin[ 2 ] + (0,0,80);

		ai_zombies = get_array_of_closest( self.origin, getaiarray( level.zombie_team ), undefined, undefined, undefined  );
		if(isdefined(ai_zombies[1]))
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
			turned_zombie_kills++;
			if(turned_zombie_kills > max_kills)
			{
				self dodamage(self.maxhealth * 2, self.origin);
			}
			wait 1;
		}
		else
		{
			self stopanimscripted();
		}
		wait .05; 
	}
	attacker.active_turned = 0;
	self.is_turned = 0;
	turned_icon destroy();
}

turned_zombie()
{
	if(self.turned)
	{
		//attack zombies
	}
	else
	{
		zombie_poi = self get_zombie_point_of_interest( self.origin );
	}
	return zombie_poi;
}

turned_zombie_validation()
{	
	if( IS_TRUE( self.barricade_enter ) )
	{
		return false;
	}
	if ( IS_TRUE( self.is_traversing ) )
	{
		return false;
	}
	if ( !IS_TRUE( self.completed_emerging_into_playable_area ) )
	{
		return false;
	}
	if ( IS_TRUE( self.is_leaping ) )
	{
		return false;
	}
	if ( IS_TRUE( self.is_inert ) )
	{
		return false;
	}
	
	return true;
}

is_true(check)
{
	return(IsDefined(check) && check);
}

//----leroy-functions----------------------------------------------------------------------------------------------------------------------------------------------------------

sloth_leg_pain()
{
	self.leg_pain_time = getTime() + 4000;
}

stop_action()
{
	self notify( "stop_action" );
	self.is_turning = 0;
	self.teleport = undefined;
	self.needs_action = 1;
	self stopanimscripted();
	self unlink();
	self orientmode( "face default" );
}

sloth_set_state( state, param2 )
{
	if ( isDefined( self.start_funcs[ state ] ) )
	{
		result = 0;
		if ( isDefined( param2 ) )
		{
			result = self [[ self.start_funcs[ state ] ]]( param2 );
		}
		else
		{
			result = self [[ self.start_funcs[ state ] ]]();
		}
		if ( result == 1 )
		{
			self.state = state;
		}
	}
}

sloth_pain_react()
{
	if ( self.state != "roam" || self.state == "follow" && self.state == "player_idle" )
	{
		if ( !self sloth_is_traversing() )
		{
			return 1;
		}
	}
	return 0;
}

sloth_accumulate_damage( amount )
{
	self endon( "death" );
	self notify( "stop_accumulation" );
	self endon( "stop_accumulation" );
	self.damage_accumulating = 1;
	self.damage_taken = amount;
	self.num_hits = 1;
	if ( self sloth_pain_react() )
	{
		self.is_pain = 1;
		prev_anim_state = self getanimstatefromasd();
		if ( self.state == "roam" || self.state == "follow" )
		{
			self animmode( "gravity" );
		}
		self setanimstatefromasd( "zm_pain" );
		self.reset_asd = "zm_pain";
		maps/mp/animscripts/zm_shared::donotetracks( "pain_anim" );
		if ( self.state == "roam" || self.state == "follow" )
		{
			self animmode( "normal" );
		}
		self.is_pain = 0;
		self.reset_asd = undefined;
		self setanimstatefromasd( prev_anim_state );
	}
	else
	{
		wait 1;
	}
	self.damage_accumulating = 0;
	if ( self.num_hits >= 3 )
	{
		self sloth_set_state( "jail_run", 0 );
	}
}

sloth_is_traversing()
{
	if ( is_true( self.is_traversing ) )
	{
		anim_state = self getanimstatefromasd();
		if ( anim_state != "zm_traverse" && anim_state != "zm_traverse_no_restart" && anim_state != "zm_traverse_barrier" && anim_state != "zm_traverse_barrier_no_restart" && anim_state != "zm_sling_equipment" && anim_state != "zm_unsling_equipment" && anim_state != "zm_sling_magicbox" && anim_state != "zm_unsling_magicbox" && anim_state != "zm_sloth_crawlerhold_sling" && anim_state != "zm_sloth_crawlerhold_unsling" || anim_state == "zm_sloth_crawlerhold_sling_hunched" && anim_state == "zm_sloth_crawlerhold_unsling_hunched" )
		{
			return 1;
		}
		else
		{
			self.is_traversing = 0;
		}
	}
	return 0;
}

//_-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
