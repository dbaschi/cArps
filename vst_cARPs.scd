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

~vst = VSTPluginController(Synth(\plugin, [\in, b, \out, 0]), id:\plugin);
~vst.open("Delay.vst3", editor:true, verbose:true);
~vst.editor;
)


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
Pbindef(\cARPs, \sustain, 0.5, \dur, 0.07);

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
