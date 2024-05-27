(
Server.default.options.numInputBusChannels=0;
s.boot;
)

// PLUGIN SECTION
VSTPlugin.clear

(
SynthDef(\plugin, {
	arg bus;
	var sig = In.ar(bus, 2);
	ReplaceOut.ar(bus, VSTPlugin.ar(sig, 2, id:\plugin));
}).add;
)

VSTPlugin.search(s, "/Users/davidebaschieri/Desktop/computer music/ProJUCE project/Distortion/Builds/MacOSX/build/Debug");

(
~vstBus = Bus.audio(s,2);

~dist = VSTPluginController(Synth(\plugin, [\in, ~vstBus, \out, 0]), id:\plugin);
~dist.open("Distortion.vst3", editor:true, verbose:true);
//~dist.editor;
)
(
~vstBus = Bus.audio(s,2);

~pan = VSTPluginController(Synth(\plugin, [\in, ~vstBus, \out, 0]), id:\plugin);
~pan.open("Panner.vst3", editor:true, verbose:true);
//~pan.editor;
)
(
~vstBus = Bus.audio(s,2);

~delay = VSTPluginController(Synth(\plugin, [\in, ~vstBus, \out, 0]), id:\plugin);
~delay.open("Delay.vst3", editor:true, verbose:true);
~delay.editor;
)


//--------------------------------------------------------------------------------------------

// WAVETABLE
~buf.free;
(
~buf = Buffer.allocConsecutive(5, s, 16384);
~wt = [
	Signal.sineFill(8192, 1 / (1..50), 0 ! 50),
	Signal.sineFill(8192, [1 / (1, 3..50), 0 ! 25].lace(50), 0 ! 50),
	Signal.sineFill(8192, [1/(1..40), 0!40].lace(40), 0!13),
	Signal.sineFill(8192, [1/(1, 3..40), 0!20].lace(50), 0!3),
	Signal.sineFill(8192, (10..40), 0!3)
];

~buf.do({ |buf, i| buf.loadCollection(~wt[i].asWavetable) });
)

// SYNTH AND PBIND
(
SynthDef(\carps, {
	arg kfreq = 10, freq = 200, out = 0, sustain = 0.5;
	var sig, bufmod;

	bufmod = ExpRand(0.01, 3.999);
	sig = VOsc.ar(~buf[0].bufnum + bufmod, freq);
	sig = sig * EnvGen.kr(Env.perc, doneAction:2);
	sig = sig * EnvGen.kr(Env.adsr(sustainLevel:sustain), doneAction:2);
	sig = sig * 0.3 ! 2;
	sig = LeakDC.ar(sig, 0.8);
	Out.ar(out, sig);
}).add;
)


(
~arp = Pbindef(\cARPs,
	\instrument, \carps,
	\dur, 0.20,
	\degree, Prand([0, 1, 2, 3, 4, 5, 6, 7], inf),
	\sustain, 0.5,
	\root, 0,
	\scale, Scale.major
);
)

//--------------------------------------------------------------------------------------------

//OSCRecivers

NetAddr("127.0.0.1", 57120);

// On Off
(
OSCdef('OSCReceiverOnOff',
	{
		arg msg;
		var command = msg[1];
		if (command == 'start') {
			~arp.play;
		};
		if (command == 'stop') {
			~arp.stop;
		};
	},
	"/onoff");
)

//Pitch and Scale
(
OSCdef('OSCReceiverPitchScale',
	{
		arg msg;
		var pitch, scale1, scale2;
		pitch = msg[1];
		Pbindef(\cARPs, \root, pitch-60);

	if (msg[2]==1 && msg[3]==1)
		    {Pbindef(\cARPs, \scale, Scale.major)};

	if (msg[2]==0 && msg[3]==1)
			{Pbindef(\cARPs, \scale, Scale.minor)};

	if (msg[2]==1 && msg[3]==0)
			{Pbindef(\cARPs, \scale, Scale.egyptian)};

	if (msg[2]==0 && msg[3]==0)
			{Pbindef(\cARPs, \scale, Scale.whole)};

	},
	"/pitch");
)

// Duration
(
OSCdef('OSCReceiverDuration',
	{
		arg msg;
		var dur;
		dur = msg[1];
		Pbindef(\cARPs,\dur, dur);
	},
	"/dur");
)

// Sustain
(
OSCdef('OSCReceiverSustain',
	{
		arg msg;
		var sus;
		sus = msg[1];
		Pbindef(\cARPs,\sustain, sus);
	},
	"/sus");
)

// Panner
(
OSCdef('OSCReceiverPanner',
	{
		arg msg;
		var param;
		param = msg[1];
		~pan.set(0, param);
	},
	"/pan");
)

// Distortion
(
OSCdef('OSCReceiverDistortion',
	{
		arg msg;
		var param;
		param = msg[1];
		~dist.set(0, param);
	},
	"/dist");
)

// Delay
(
OSCdef('OSCReceiverDelay',
	{
		arg msg;
		var time, feedback, mix;
		time = msg[1];
		feedback = msg[2];
		mix = msg[3];
		~delay.set(0, time);
		~delay.set(1, feedback);
		~delay.set(2, mix);
	},
	"/delay");
)
