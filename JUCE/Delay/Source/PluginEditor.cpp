/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"

//==============================================================================
DelayAudioProcessorEditor::DelayAudioProcessorEditor (DelayAudioProcessor& p)
    : AudioProcessorEditor (&p), audioProcessor (p)
{
    setSize (400, 300);

    timeSlider.setRange(0.01f, 0.9f);
    addAndMakeVisible(timeSlider);
    timeSliderAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, "TIME", timeSlider);
    timeLabel.setText("TIME", juce::dontSendNotification);
    addAndMakeVisible(timeLabel);

    feedbackSlider.setRange(0.01f, 0.9f);
    addAndMakeVisible(feedbackSlider);
    feedbackSliderAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, "FEEDBACK", feedbackSlider);
    feedbackLabel.setText("FEEDBACK", juce::dontSendNotification);
    addAndMakeVisible(feedbackLabel);

    dryWetSlider.setRange(0.0f, 1.0f);
    addAndMakeVisible(dryWetSlider);
    dryWetSliderAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, "DRYWET", dryWetSlider);
    dryWetLabel.setText("MIX", juce::dontSendNotification);
    addAndMakeVisible(dryWetLabel);
}

DelayAudioProcessorEditor::~DelayAudioProcessorEditor()
{
}

void DelayAudioProcessorEditor::paint (juce::Graphics& g)
{
    g.fillAll(juce::Colours::black);
}

void DelayAudioProcessorEditor::resized()
{
    timeSlider.setBounds(10, 10, 300, 40);
    timeLabel.setBounds(320, 20, 130, 20);

    feedbackSlider.setBounds(10, 60, 300, 40);
    feedbackLabel.setBounds(320, 70, 130, 20);

    dryWetSlider.setBounds(10, 110, 300, 40);
    dryWetLabel.setBounds(320, 120, 130, 20);
}