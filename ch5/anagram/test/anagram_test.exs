defmodule AnagramTest do
  use ExUnit.Case
  doctest Anagram

  test "known anagrams" do
    assert Anagram.anagram? "Clint Eastwood", "Old West Action"
    assert Anagram.anagram? "parliament", "partial men"
    assert Anagram.anagram? "note", "tone"
    assert Anagram.anagram? "Resistance", "Ancestries"
    assert Anagram.anagram? "Gainly", "Laying"
    assert Anagram.anagram? "Admirer", "Married"
    assert Anagram.anagram? "Sadder", "Dreads"
    assert Anagram.anagram? "protectional", "Lactoprotein"
    assert Anagram.anagram? "Orchestra", "Carthorse"
    assert Anagram.anagram? "Creative", "Reactive"
    assert Anagram.anagram? "Deductions", "Discounted"
    assert Anagram.anagram? "Listen", "Silent"
    assert Anagram.anagram? "Replays", "Parsley"
    assert Anagram.anagram? "Crudities", "Diuretics"
    assert Anagram.anagram? "Paternal", "Parental"
    assert Anagram.anagram? "Angered", "Enraged"
    assert Anagram.anagram? "discriminator", "Doctrinairism"
    assert Anagram.anagram? "Serbia", "Rabies"

    refute Anagram.anagram? "note", "stone"
    refute Anagram.anagram? "elixir", "Erlang"
    
    # Numbers count
    refute Anagram.anagram? "note", "tone1"
    assert Anagram.anagram? "1note", "tone1"

    # Symbols don't count
    assert Anagram.anagram? "note$$!*#", "tone"

    
    # Longer ones
    assert Anagram.anagram? \
      "To be or not to be: that is the question; whether 'tis nobler in the mind to suffer the slings and arrows of outrageous fortune...",
      "In one of the Bard's best-thought-of tragedies our insistent hero, Hamlet, queries on two fronts about how life turns rotten."
    
  end
end
