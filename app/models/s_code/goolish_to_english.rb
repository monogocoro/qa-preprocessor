module SCode::GoolishToEnglish

  def self.translate goolish
    english = SCode::GoolishToEnglish.data[goolish]
    return english if english.present?
    goolish
  end

  def self.data
    {
      'Who did you beat Taro' => 'Who hit Taro',
      'Taro would happened to' => 'What about Taro',
      'After that it was what made' => 'What happened',
    }
  end
end
