s.boot;
// PLUGIN SECTION
(
SynthDef(\plugin, {
	arg in, out;
	var sig = In.ar(in, 2);
	ReplaceOut.ar(out, VSTPlugin.ar(sig, 2, id:\plugin));
}).add;
)

VSTPlugin.search(s, "C:/Users/gabri/OneDrive/Documenti/CM/Juce_/Delay/Builds/VisualStudio2022/x64/Debug/VST3/Delay.vst3/Contents/x86_64-win");

(
~vstBus = Bus.audio(s,2);

~vst = VSTPluginController(Synth(\plugin, [\in, nil, \out, 0]), id:\plugin);
~vst.open("Delay.vst3", editor:true, verbose:true);
~vst.editor;
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
~wt.plot;
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
	//sig = Splay.ar(sig);
	sig = LeakDC.ar(sig, 0.8);
	Out.ar(out, sig);
}).add;
)

x = Synth(\carps);

(
~arp = Pbindef(\cARPs,
	\instrument, \carps,
	\dur, 0.20,
	\degree, Pseq([0, 4, 6, 8], inf),
	\sustain, 0.5
);
)

~arp.stop;
~arp.play;
//--------------------------------------------------------------------------------------------
NetAddr("127.0.0.1", 57120);
// Effetti
(
OSCdef('OSCReceiver1',
	{
		arg msg;
		var param;
		param = msg[1];
		~vst.set(0, param);
	},
	"/pan");
)
(
OSCdef('OSCReceiver2',
	{
		arg msg;
		var param;
		param = msg[1];
		~vst.set(1, param);
	},
	"/dist");
)
// ON OFF
(
OSCdef('OSCReceiver3',
	{
		arg msg;
		var command;
		//msg.postln;
		command = msg[1];
		//("Received command: " + command).postln;
		if (command == 'start') {
			~arp.play;
		};
		if (command == 'stop') {
			~arp.stop;
		};
	},
	"/onoff");
)
// Duration
(
OSCdef('OSCReceiver4',
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
OSCdef('OSCReceiver5',
	{
		arg msg;
		var sus;
		sus = msg[1];
		Pbindef(\cARPs,\sustain, sus);
	},
	"/sus");
)