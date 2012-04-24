/**
 * When this class is used as the player input class, default player binds will be loaded from the given config file instead of the UDK default input files.
 * 
 * Important: ALL the active configuration files (UDKGame/Config/UDK*.ini) need to be deleted to reload the default config.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPlayerInput extends UDKPlayerInput within FSPlayerController
	config(InputFS);
