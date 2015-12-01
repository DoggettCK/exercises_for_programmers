defmodule AnagramTest do
  use ExUnit.Case
  doctest Anagram

  tests = [
    ["1note", "tone1", true],
    ["Admirer", "Married", true],
    ["Angered", "Enraged", true],
    ["Clint Eastwood", "Old West Action", true],
    ["Creative", "Reactive", true],
    ["Crudities", "Diuretics", true],
    ["Deductions", "Discounted", true],
    ["discriminator", "Doctrinairism", true],
    ["elixir", "Erlang", false],
    ["Gainly", "Laying", true],
    ["Listen", "Silent", true],
    ["note", "stone", false],
    ["note", "tone", true],
    ["note", "tone1", false],
    ["note$$!*#", "tone", true],
    ["note_1", "_note1", true],
    ["note_1", "note1", false],
    ["Orchestra", "Carthorse", true],
    ["Paternal", "Parental", true],
    ["protectional", "Lactoprotein", true],
    ["Replays", "Parsley", true],
    ["Resistance", "Ancestries", true],
    ["Sadder", "Dreads", true],
    ["Serbia", "Rabies", true],
    ["To be or not to be: that is the question; whether 'tis nobler in the mind to suffer the slings and arrows of outrageous fortune...", "In one of the Bard's best-thought-of tragedies our insistent hero, Hamlet, queries on two fronts about how life turns rotten.", true]
  ]

  for {line, index} <- (tests |> Enum.with_index) do
    [one, two, match] = line

    test "test_#{index}" do
      case unquote(match) do
        true -> assert Anagram.anagram? unquote(one), unquote(two)
        _ -> refute Anagram.anagram? unquote(one), unquote(two)
      end
    end
  end
end
