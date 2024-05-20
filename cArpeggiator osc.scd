(
Server.default.options.numInputBusChannels=0;
s.boot;
)
n=NetAddr.new("127.0.0.1", 57120);







//----------instrument------------


//cArp

(
SynthDef(\smooth, { |freq = 440, sustain = 1, amp = 0.5|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: 2);
    Out.ar(0, sig ! 2)
}).add;
)





//------Arpeggiator-----------


(
k=[0,2,4,7];
Pdefn(\degree,Pseq(k,inf));
Pdefn(\instrument, \smooth);
p = Pbind(
	\instrument, Pdefn(\instrument),  /* synth che produrrà il suono*/
	\scale,Pdefn(\scale),             /* scala di riferimento*/
    \degree, Pdefn(\degree),          /* gradi della scala che verranno riprodotti*/
    \dur, Pdefn(\dur),                /* ogni quanto viene prodotta una nuova nota*/
	\sustain, Pdefn(\sustain),        /* quanto durano le note prodotte*/
	\root, Pdefn(\root),           /* tonica della scala*/
	\amp, Pdefn(\amp)
);
)
p.reset;
Scale.directory;



//----------GUI----------------

GUI.current;
(

var dur, sus, maj, min, dim, whol, btnPlay, inv, mirr, i, ii, iii, iv, v, vi, vii, viii;

Window.closeAll;
w = Window( "window" , Rect(500,350,610,300));

w.alwaysOnTop_(true);
//------Arpeggiator-----------



//play button

btnPlay = Button(parent:w, bounds: Rect(145,260,210,30));
btnPlay.string = "play";
btnPlay.states = [
	["play", Color.green],["stop", Color.red]];
btnPlay.action_({
	arg butt;
	var val = butt.value;
	butt.value.asBoolean.not.postln;
	if (val.value ==1)
	{p.play} {CmdPeriod.run}
});




//scale buttons

//scala maggiore

maj = Button(parent:w, bounds: Rect(160,70,70,70));
maj.string = "Major";
maj.states = [
	["Major", Color.black],["Major", Color.green]];
maj.action_({
	arg butt;
	var val = butt.value;
	butt.value.asBoolean.not.postln;
	if (val.value ==1)
	{
		Pdefn(\scale, Scale.major);
		min.states = [
	["Minor", Color.black],["Minor", Color.green]];
		whol.states = [
	["Whole", Color.black],["Whole", Color.green]];
	}

	{
		CmdPeriod.run;
		btnPlay.states = [
	["play", Color.green],["stop", Color.red]];
	}
});


//scala tonale

whol = Button(parent:w, bounds: Rect(360,70,70,70));
whol.string = "Whole";
whol.states = [
	["Whole", Color.black],["Whole", Color.green]];
whol.action_({
	arg butt;
	var val = butt.value;
	butt.value.asBoolean.not.postln;
	if (val.value ==1)
	{
		Pdefn(\scale, Scale.whole);
		maj.states = [
	["Major", Color.black],["Major", Color.green]];
		min.states = [
	["Minor", Color.black],["Minor", Color.green]];
	}

	{
		CmdPeriod.run;
		btnPlay.states = [
	["play", Color.green],["stop", Color.red]];
	}
});

//scala minore

min = Button(parent:w, bounds: Rect(260,70,70,70));
min.string = "Minor";
min.states = [
	["Minor", Color.black],["Minor", Color.green]];
min.action_({
	arg butt;
	var val = butt.value;
	butt.value.asBoolean.not.postln;
	if (val.value ==1)
	{
		Pdefn(\scale, Scale.minor);
		maj.states = [
	["Major", Color.black],["Major", Color.green]];
		whol.states = [
	["Whole", Color.black],["Whole", Color.green]];
	}

	{
		CmdPeriod.run;
		btnPlay.states = [
	["play", Color.green],["stop", Color.red]];
	}
});



//duration knob

g= ControlSpec.new(0.05,3,\exp);
dur = EZKnob( parent:w, bounds: Rect(25,150,100,100), label:"Duration",controlSpec:g,initVal:1);
	dur.action_({
	Pdefn(\dur, dur.value);

});




//sustain knob

t= ControlSpec.new(0.05,3,\exp);
sus = EZKnob( parent:w, bounds: Rect(25,20,100,100), label:"Sustain",controlSpec:t,initVal:1);
	sus.action_({
	Pdefn(\sustain, sus.value);

});



// Key note selector

/*o = PopUpMenu(parent:w, bounds: Rect(350,15,40,40));

o.items=["A","B","C","D","E","F","G"];
o.action = {arg o;Pdefn(\root, o.value-1); o.value.postln};
n = StaticText.new ( w , Rect(235,20,100,30)) ;
n.align = \center;
n.string = "Key NOte" ;
n.font = Font("Monaco", 20);

*/
// invert and mirror
j=0;

inv = Button(parent:w, bounds: Rect(490,200,40,40));
inv.string = ">/<";
inv.states = [
	["<", Color.black],[">", Color.black]];
inv.action_({
	arg butt;
	var val = butt.value;
	j=val.value;
	butt.value.asBoolean.not.postln;
	if (val.value ==1)
	{Pdefn(\degree,Pseq(k.reverse,inf))}
	{Pdefn(\degree,Pseq(k,inf))}
});

mirr = Button(parent:w, bounds: Rect(540,200,40,40));
mirr.string = ">/<";
mirr.states = [
	["o|o", Color.black],["o|o", Color.green]];
mirr.action_({
	arg butt;
	var val = butt.value;
	val=j;
	butt.value.asBoolean.not.postln;
	if (val.value == 1)
	{if (j == 1)
		{Pdefn(\degree,Pseq(k.reverse.mirror,inf))}
		{Pdefn(\degree,Pseq(k.mirror,inf))}}
	{if (j == 1)
		{Pdefn(\degree,Pseq(k.reverse,inf))}
		{Pdefn(\degree,Pseq(k,inf))}}
});


i = PopUpMenu(parent:w, bounds: Rect(150,200,40,40));

i.items=["I","II","III","IV","V","VI","VII","VIII"];
i.action = {arg i; k[0] = i.value; i.value.postln;Pdefn(\degree,Pseq(k,inf))};


ii = PopUpMenu(parent:w, bounds: Rect(190,200,40,40));

ii.items=["I","II","III","IV","V","VI","VII","VIII", "-"];
ii.action = {arg i;
	if (i.value == 8)
	{k=k.lace(1)}
	{if (k.size<2)
		{k=k.add(i.value)}
		{k[1] = i.value; i.value.postln}
	};
	Pdefn(\degree,Pseq(k,inf))
};

iii = PopUpMenu(parent:w, bounds: Rect(230,200,40,40));
iii.items=["I","II","III","IV","V","VI","VII","VIII", "-"];
iii.action = {arg i;
	if (i.value == 8)
	{k=k.lace(2)}
	{if (k.size<3)
		{k=k.add(i.value)}
		{k[2] = i.value; i.value.postln}
};
	Pdefn(\degree,Pseq(k,inf))
};

iv = PopUpMenu(parent:w, bounds: Rect(270,200,40,40));
iv.items=["I","II","III","IV","V","VI","VII","VIII", "-"];
iv.action = {arg i;
	if (i.value == 8)
	{k=k.lace(3)}
	{if (k.size<4)
		{k=k.add(i.value)}
		{k[4] = i.value; i.value.postln}
	};
	Pdefn(\degree,Pseq(k,inf))
};

v = PopUpMenu(parent:w, bounds: Rect(310,200,40,40));
v.items=["I","II","III","IV","V","VI","VII","VIII", "-"];
v.action = {arg i;
	if (i.value == 8)
	{k=k.lace(4)}
	{if (k.size<5)
		{k=k.add(i.value)}
		{k[4] = i.value; i.value.postln}
		};
	Pdefn(\degree,Pseq(k,inf))
};

vi = PopUpMenu(parent:w, bounds: Rect(350,200,40,40));
vi.items=["I","II","III","IV","V","VI","VII","VIII", "-"];
vi.action = {arg i;
	if (i.value == 8)
	{k=k.lace(5)}
	{if (k.size<6)
		{k=k.add(i.value)}
		{k[5] = i.value; i.value.postln}
			};
	Pdefn(\degree,Pseq(k,inf))
};

vii = PopUpMenu(parent:w, bounds: Rect(390,200,40,40));
vii.items=["I","II","III","IV","V","VI","VII","VIII", "-"];
vii.action = {arg i;
	if (i.value == 8)
	{k=k.lace(6)}
	{if (k.size<7)
		{k=k.add(i.value)}
		{k[6] = i.value; i.value.postln}
				};
	Pdefn(\degree,Pseq(k,inf))
};

vii = PopUpMenu(parent:w, bounds: Rect(430,200,40,40));
vii.items=["I","II","III","IV","V","VI","VII","VIII", "-"];
vii.action = {arg i;
	if (i.value == 8)
	{k=k.lace(7)}
	{if (k.size<8)
		{k=k.add(i.value)}
		{k[7] = i.value; i.value.postln}
				};
	Pdefn(\degree,Pseq(k,inf))
};

w.front;
w.onClose_({CmdPeriod.run},{p.reset});
k.postln;
)
(
var cu;
cu = OSCFunc(
	{
	arg msg, time, addr, recvPort;

	Pdefn(\dur, msg[2]/50);
	Pdefn(\root, msg[1]-60);
	Pdefn(\sustain, LinLin.kr(msg[3], 0.07, 0.98, 0.05, 3);

	if (msg[4]==1 && msg[5]==1)
		    {Pdefn(\scale, Scale.major)};

	if (msg[4]==0 && msg[5]==1)
			{Pdefn(\scale, Scale.minor)};

	if (msg[4]==0 && msg[5]==0)
			{Pdefn(\scale, Scale.whole)};
	Pdefn(\amp, msg[6]);
	},
'/params');

)



