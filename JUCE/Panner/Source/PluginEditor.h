#pragma once

#include <JuceHeader.h>
#include "PluginProcessor.h"

class PannerAudioProcessorEditor : public juce::AudioProcessorEditor
{
public:
    PannerAudioProcessorEditor(PannerAudioProcessor&);
    ~PannerAudioProcessorEditor() override;

    void paint(juce::Graphics&) override;
    void resized() override;

private:
    PannerAudioProcessor& audioProcessor;

    juce::Slider panSlider;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(PannerAudioProcessorEditor)
};