module SCode::Reflex
  def self.reflect sentence
    self.data[sentence]
  end

  def self.data
    {
      'What about Taro' => {sentence: "Q", verb: "be", arg1: "Taro", arg2: "what_about", arg3: nil, tense: "P", voice: "Act", aspect: nil, adverb: nil}
    }
  end
end
