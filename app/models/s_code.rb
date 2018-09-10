class SCode
  def self.generate(sentence)

    ja_text = URI.unescape(sentence)
    ja_text = SCode::Formatter.ja_format(ja_text)

    # 翻訳
    en_text = EasyTranslate.translate(ja_text, from: :ja, to: :en, model: :nmt)
    # 可能ならgoolishを英語に修正する。
    en_text = SCode::GoolishToEnglish.translate(en_text)
    #文の一部を置換する。
    en_text = SCode::Formatter.en_format(en_text)

    pass = SCode::Pass.generate(en_text)
    if pass.present?
      hash = pass
    else
      e = Enju.new(en_text)
      hash = SCode::Sentence.generate(e.output)
    end

    hash = hash.map do |key, val|
      new_val = val
      new_val = nil if val == []
      [key, new_val]
    end.to_h

    hash

  end
end
