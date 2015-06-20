class Spellchecker
  @@aspell_path = "aspell"
  @@aspell_cmdargs = ""

  def self.aspell_path=(path)
    @@aspell_path = path
  end

  def self.aspell_path
    @@aspell_path
  end

  def self.cmdargs=(args)
    @@aspell_cmdargs = args
  end

  def self.cmdargs
    @@aspell_cmdargs
  end

  def self.query(text, lang)
    args = "-a -l #{lang}"
    if @@aspell_cmdargs != ""
      args = @@aspell_cmdargs
    end
    result = `echo "#{text}" | #{@@aspell_path} #{@@aspell_cmdargs}`
    raise 'Aspell command not found' unless result
    new_result = result.split("\n")
    new_result[1..-1] || []
  end

  def self.correct?(result_string)
    result_string == "*"
  end

  def self.check(text, lang)
    # join then re-split the word list to get a consistent word count,
    # because sometimes there's a "" (blank) word in the array that gets lost,
    # which makes the maps not equal, leading to an off by one type issue, where
    # the reported mispelled word is actually a correct word.
    # see: https://github.com/minivan/middleman-spellcheck/issues/7
    words   = text.split(/[^A-Za-z’']+/).join(" ")
    results = query(words, lang).map do |query_result|
      correct?(query_result)
    end

    words.split(" ").zip(results).map {|word, correctness| { word: word, correct: correctness } }
  end
end
