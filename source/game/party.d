module party;

import derelict.openal.al;
import gl3n.linalg;
import std.math;
import std.complex;
import std.numeric;
import std.process;

import d2d.game.entity;
import d2d.core.render.objects.quad;
import d2d.core.render.renderer;



class Party : Entity
{
    enum : int {
        SRATE = 22050,
        SSIZE = 512,
        SETSIZE=50,
    }

    this()
	{
        import std.stdio;
        auto s = alcGetString(null, ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER);
        
        _quads.length = (SETSIZE);
        foreach(i; 0..SETSIZE) {
            _quads[i] = new ColoredQuad();
            _quads[i].pos = vec2(-1.0+i*(1.0/SETSIZE*2.0),0.0);
            _quads[i].scale = vec3(1.0/SETSIZE/2.0,1.0,1.0);
            _quads[i].ignoreView = true;
        }

        auto d = alcCaptureOpenDevice( null, SRATE, AL_FORMAT_MONO16, SSIZE);
        alcCaptureStart(d);
        _device = d;
        _buf.length = SSIZE;
        _fft = new Fft(SSIZE);
	}

    ~this()
    {
        alcCaptureStop(_device);
        alcCaptureCloseDevice(_device);
    }

	override void render()
	{
		auto renderer = getService!Renderer("d2d.renderer");
        //_quad.pos = this.absolutePos;
        foreach(ref q; _quads) {
		    renderer.pushObject(q);
        }
	}

    override void update()
    {
        
        ALint sIn;
        alcGetIntegerv(_device, ALC_CAPTURE_SAMPLES,1,&sIn);
        if(sIn >= SSIZE) {
            ushort[] absBuf;
            absBuf.length=SSIZE;

            alcCaptureSamples(_device,_buf.ptr,SSIZE);
            ushort mean = abs(_buf[0]);
            absBuf[0]=mean;
            for(int i=1; i<SSIZE; i++) {
                absBuf[i] = cast(ushort)(abs(_buf[i]));
                mean = (mean + absBuf[i]) / 2;               
            }
            import std.stdio;
            write("Mean Sound volume: ");
            writeln(mean);
            //vec4 c = vec4(0.1,cast(float)(mean)/50000.0, 1.0, 1.0);
            //_quad.color = c;

            // do the fourier
            auto raw = _fft.fft(absBuf);
            double[] absTrans;
            absTrans.length = raw.length/2;
            for(int i=0; i<absTrans.length;i++) {
                absTrans[i] = raw[i].re < 0.0 ? 0.0 : raw[i].re;
            }

            
            for(int i=(SSIZE/SETSIZE),j=1; i<absTrans.length&&j<SETSIZE; i+=(SSIZE/SETSIZE/2)) {
                int freq = i * SRATE / SSIZE; 
                _quads[j].color = vec4(mean/50000.0,1.0-mean/50000.0,1.0,absTrans[i]/1000000.0+0.01);
                auto s = _quads[j].scale;
                s.y = absTrans[i]/1000000.0+0.01;
                _quads[j].scale= s;
                j++;
            }
        }
    }

private:
	ColoredQuad[] _quads;
    short[] _buf;
    ALCdevice* _device;
    Fft     _fft;
}