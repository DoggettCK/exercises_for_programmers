defmodule AnagramTest do
  use ExUnit.Case
  doctest Anagram

  test "known anagrams" do
    assert Anagram.anagram? "Clint Eastwood", "Old West Action"
    assert Anagram.anagram? "parliament", "partial men"
    assert Anagram.anagram? "note", "tone"

    assert Anagram.anagram? "note$$!*#", "tone"

    refute Anagram.anagram? "note", "stone"

    refute Anagram.anagram? "note", "tone1"
    assert Anagram.anagram? "1note", "tone1"

    # Longer ones
    assert Anagram.anagram? \
      "To be or not to be: that is the question; whether 'tis nobler in the mind to suffer the slings and arrows of outrageous fortune...",
      "In one of the Bard's best-thought-of tragedies our insistent hero, Hamlet, queries on two fronts about how life turns rotten."
    
  end
end
