#include "PluginProcessor.h"
#include "PluginEditor.h"

PannerAudioProcessorEditor::PannerAudioProcessorEditor(PannerAudioProcessor& p)
    : AudioProcessorEditor(&p), audioProcessor(p)
{
    panSlider.setSliderStyle(juce::Slider::Rotary);
    panSlider.setTextBoxStyle(juce::Slider::NoTextBox, false, 0, 0);  // Disable the text box
    panSlider.setRange(0.0, 1.0, 0.001);
    panSlider.setValue(audioProcessor.panParam->get());
    panSlider.onValueChange = [this] { audioProcessor.panParam->setValueNotifyingHost((float)panSlider.getValue()); };
    addAndMakeVisible(&panSlider);

    setSize(400, 300);
}

PannerAudioProcessorEditor::~PannerAudioProcessorEditor() {}

void PannerAudioProcessorEditor::paint(juce::Graphics& g)
{
    g.fillAll(getLookAndFeel().findColour(juce::ResizableWindow::backgroundColourId));

    g.setColour(juce::Colours::white);
    g.setFont(15.0f);
    g.drawText("Panner", getLocalBounds().removeFromTop(40), juce::Justification::centred, true);
}

void PannerAudioProcessorEditor::resized()
{
    panSlider.setBounds((getWidth() / 2) - 60, (getHeight() / 2) - 20, 120, 120);
}