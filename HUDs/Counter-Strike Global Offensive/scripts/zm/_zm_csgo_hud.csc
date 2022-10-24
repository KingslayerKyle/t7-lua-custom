#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

REGISTER_SYSTEM_EX( "zm_csgo_hud", &__init__, &__main__, undefined )

function __init__()
{
    LuiLoad( "ui.uieditor.menus.hud.CSGOHud_zm_factory" );
    LuiLoad( "ui.uieditor.widgets.HUD.CSGOPowerupsWidget.CSGOPowerups" );

    clientfield::register( "clientuimodel", "CSGO.Health",   VERSION_SHIP, GetMinBitCountForNum( 200 ), "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function __main__()
{
}
