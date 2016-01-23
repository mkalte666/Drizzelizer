/**
    Main entry point for a game. Here a game should define its "scripting".
    This includes game logic, ui handlers, ...
    
*/
module game;

import derelict.openal.al;

//import d2d.engine;
import d2d.engine;
import d2d.core.base;
import d2d.core.dbg.eventdebug;
import d2d.core.resource;
import d2d.core.resources.font;
import d2d.game.simple.camera;
import d2d.game.simple.sprite;
import d2d.game.ui.cursor;
import d2d.game.entity;
import d2d.game.ui.text;
import d2d.game.dbg.grid;
import gl3n.linalg;

import party;

int main(char[][] args)
{
    auto engine = new Engine(args, &onStartup);
    engine.run();
    return 0;
}

bool onStartup(Base base)
{
    DerelictAL.load();

    //ALCdevice* audioDevice = alcOpenDevice(null); // Request default audio device
    //LCcontext* audioContext = alcCreateContext(audioDevice,null); // Create the audio context
    //alcMakeContextCurrent(audioContext);

	import std.stdio;
    auto camera = new Camera(1.0f); 
    camera.addChild(new Party());
    base.addChild(camera);
    
	return true;
}