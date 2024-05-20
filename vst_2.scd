s.boot;

(
SynthDef(\drums, {
	arg out = 0;
	var snare, bdrum, hihat, tempo = 4;

	tempo = Impulse.ar(tempo);
	snare = WhiteNoise.ar(Decay2.ar(PulseDivider.ar(tempo, 4, 2), 0.005, 0.5));
	bdrum = SinOsc.ar(Line.ar(120,60, 1), 0, Decay2.ar(PulseDivider.ar(tempo, 4, 0), 0.005, 0.5));
	hihat = HPF.ar(WhiteNoise.ar(1), 10000) * Decay2.ar(tempo, 0.005, 0.5);

	Out.ar(out, (snare + bdrum + hihat) * 0.4 ! 2);
}).add;
)

a = Synth(\drums);
//-------------------------------------------
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

~vst = VSTPluginController(Synth(\plugin, [\in, b, \out, 0]), id:\plugin);
~vst.open("Delay.vst3", editor:true, verbose:true);
~vst.editor;
)
~vst.close;

//----------------------------------------------------------
// Synth and Pbind Section
//----------------------------------------------------------
// Pbind
(
~arp = Pbindef(\cARPs,
	\instrument, \wtp,
	\dur, 0.20,
	\degree, Prand([0, 1, 2, 4, 5], inf),
	\sustain, 0.5
);
)

~arp.stop;
~arp.play;
Pdefn(\dur, 0.24);

// Blended wavetables with Vosc
~buf.free;
(
~buf = Buffer.allocConsecutive(4, s, 16384);
~wt = [
	Signal.sineFill(8192, 1 ! 4, 0 ! 4),
	Signal.sineFill(8192, 1 / (1..50), 0 ! 50),
	Signal.sineFill(
		8192,
		[1 / (1, 3..50), 0 ! 25].lace(50),
		0 ! 50
	),
	Signal.sineFill(
		8192,
		Array.exprand(50, 0.001, 1).sort.reverse,
		{rrand(0, 2pi)} ! 50
	),
];

~buf.do({ |buf, i| buf.loadCollection(~wt[i].asWavetable) });
)


(
SynthDef(\wtp, {
	arg kfreq = 10, freq = 200, out = 0, sustain = 0.5;
	var sig, bufmod;
	//bufmod = SinOsc.kr(0.05, 3pi/2).unipolar(2.999);
	bufmod = ExpRand(0.01, 2.999);
	sig = VOsc.ar(~buf[0].bufnum + bufmod, freq);
	//sig = sig * LFPulse.kr(kfreq);   // Amplitude modulation evitabile
	sig = sig * EnvGen.kr(Env.perc, doneAction:2);
	sig = sig * EnvGen.kr(Env.adsr(sustainLevel:sustain), doneAction:2);
	sig = sig * 0.3 ! 2;
	sig = LeakDC.ar(sig);
	Out.ar(out, sig);
}).add;
)

x = Synth(\wtp);
//---------------------------------------------------------------------------------------
// GUI section
GUI.current;
(
var button, slider, effectBtn, editorBtn, durSlider, susSlider;
w = Window.new("CARPS", Rect(200, 200, 300, 500));
w.front;
w.alwaysOnTop_(true);

button = Button.new(w, Rect(125,20,50,50));
button.states = [
	["OFF", Color.black], ["ON", Color.red]];
button.action = ({arg t;
	var val = t.value.postln;
	if(val == 1)
	{~arp.play} {~arp.stop} }
);

// effetto ON OFF
effectBtn = Button.new(w, Rect(75, 90, 150, 50));
effectBtn.states = [
	["EffectOFF", Color.black], ["EffectON", Color.red]];
effectBtn.action = ({arg x;
	var val = x.value.postln;
	if(val == 1)
	{~vst.open("Delay.vst3", editor:true, verbose:true)} {~vst.close}}
);

// Open close the editor
editorBtn = Button.new(w, Rect(75, 170, 150, 50));
editorBtn.states = [
	["OpenEditor", Color.black], ["OpenEditor", Color.black]];
editorBtn.action = ({arg x;
	var val = x.value.postln;
	if(val == 1)
	{~vst.editor} {~vst.editor}}
);

durSlider = Slider.new(w, Rect(10, 250, 280, 50));
durSlider.valueAction_(0.15);
durSlider.action_({arg n; Pbindef(\cARPs,\dur, n.value.linlin(0,1, 0.05, 0.75))});

susSlider = Slider.new(w, Rect(10, 350, 280, 50));
susSlider.valueAction_(0.15);
susSlider.action_({arg n; Pbindef(\cARPs, \sustain, n.value.linlin(0,1, 0.05, 3))});
)