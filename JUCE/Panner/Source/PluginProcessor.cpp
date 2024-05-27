
#include "PluginProcessor.h"
#include "PluginEditor.h"

PannerAudioProcessor::PannerAudioProcessor()
#ifndef JucePlugin_PreferredChannelConfigurations
     : AudioProcessor (BusesProperties()
                     #if ! JucePlugin_IsMidiEffect
                      #if ! JucePlugin_IsSynth
                       .withInput  ("Input",  juce::AudioChannelSet::stereo(), true)
                      #endif
                       .withOutput ("Output", juce::AudioChannelSet::stereo(), true)
                     #endif
                       ),
    panParam(new juce::AudioParameterFloat("Pan", "Pan", -1.0f, 1.0f, 0.5f)),
    panner()  // Default constructor for panner
{
    addParameter(panParam);
    panner.setRule(juce::dsp::Panner<float>::Rule::squareRoot4p5dB);
}
#endif

PannerAudioProcessor::~PannerAudioProcessor() {}

const juce::String PannerAudioProcessor::getName() const { return JucePlugin_Name; }

bool PannerAudioProcessor::acceptsMidi() const { return JucePlugin_WantsMidiInput; }

bool PannerAudioProcessor::producesMidi() const { return JucePlugin_ProducesMidiOutput; }

bool PannerAudioProcessor::isMidiEffect() const { return JucePlugin_IsMidiEffect; }

double PannerAudioProcessor::getTailLengthSeconds() const { return 0.0; }

int PannerAudioProcessor::getNumPrograms() { return 1; }

int PannerAudioProcessor::getCurrentProgram() { return 0; }

void PannerAudioProcessor::setCurrentProgram(int index) {}

const juce::String PannerAudioProcessor::getProgramName(int index) { return {}; }

void PannerAudioProcessor::changeProgramName(int index, const juce::String& newName) {}

void PannerAudioProcessor::prepareToPlay(double sampleRate, int samplesPerBlock)
{
    // Prepare the panner with the appropriate sample rate
    juce::dsp::ProcessSpec spec;
    spec.sampleRate = sampleRate;
    spec.maximumBlockSize = samplesPerBlock;
    spec.numChannels = getTotalNumOutputChannels();
    
    panner.prepare(spec);
}

void PannerAudioProcessor::releaseResources() {}

#ifndef JucePlugin_PreferredChannelConfigurations
bool PannerAudioProcessor::isBusesLayoutSupported(const BusesLayout& layouts) const
{
    juce::ignoreUnused(layouts);
    return true;
}
#endif

void PannerAudioProcessor::processBlock(juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages)
{
    juce::ScopedNoDenormals noDenormals;

    auto totalNumInputChannels = getTotalNumInputChannels();
    auto totalNumOutputChannels = getTotalNumOutputChannels();

    for (auto i = totalNumInputChannels; i < totalNumOutputChannels; ++i)
        buffer.clear(i, 0, buffer.getNumSamples());

    juce::dsp::AudioBlock<float> block(buffer);
    
    
    float panValue = panParam->get();
    
    // Set the pan value
    panner.setPan(panValue);

    // Process the audio block with the panner
    juce::dsp::ProcessContextReplacing<float> context(block);
    panner.process(context);
}

bool PannerAudioProcessor::hasEditor() const { return true; }

juce::AudioProcessorEditor* PannerAudioProcessor::createEditor() { return new PannerAudioProcessorEditor(*this); }

void PannerAudioProcessor::getStateInformation(juce::MemoryBlock& destData) {}

void PannerAudioProcessor::setStateInformation(const void* data, int sizeInBytes) {}

juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter() { return new PannerAudioProcessor(); }

