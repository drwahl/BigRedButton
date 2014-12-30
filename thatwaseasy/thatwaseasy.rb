require 'rubygems'
require 'dream_cheeky'
require 'espeak'
include ESpeak

$SPEAK_EASY = Speech.new("That was easy!", :voice => "en", :pitch => 70, :speed => 130)

DreamCheeky::BigRedButton.run do
  #on open, do nothing
  open do
  end

  #on close, do nothing
  close do
  end

  #for each button press, say "That was easy!"
  push do
    $SPEAK_EASY.speak
  end
end
