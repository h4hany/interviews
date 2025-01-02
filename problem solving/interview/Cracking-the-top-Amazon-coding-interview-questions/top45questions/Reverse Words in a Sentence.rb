#!/user/bin/ruby
def str_rev(str, from, to)
  if !str || str.length < 2
    return
  end
  while from < to
    temp = str[from]
    str = str[0, from] + str[to] + str[from + str[to].length .. -1]
    str = str[0, to] + temp + str[to + temp.length .. -1]
    from+=1
    to-=1
  end
   str
end
def reverse_words(sentence)

  # Here sentence is a nil-terminated string ending with char '\0'.
  if !sentence || sentence.length == 0
    return
  end

  #  To reverse all words in the string, we will first reverse
  #  the string. Now all the words are in the desired location, but
  #  in reverse order: "Hello World" -> "dlroW olleH".

  str_len = sentence.length
  sentence = str_rev(sentence, 0, str_len - 1)

  # Now, s iterate the sentence and reverse each word in place.
  # "dlroW olleH" -> "World Hello"

  from = 0
  to = 0
  while true
    # find the 'from' index of a word while skipping spaces.
    while sentence[from] == ' '
      from+=1
    end
    if from >= sentence.length
      break
    end

    # find the 'to' index of the word.
    to = from + 1
    while to < sentence.length && sentence[to] != ' '
      to+=1
    end

    # let's reverse the word in-place.
    sentence = str_rev(sentence, from, to - 1)

    from = to
  end
   sentence
end
s = "Hello World!"
puts reverse_words(s)
