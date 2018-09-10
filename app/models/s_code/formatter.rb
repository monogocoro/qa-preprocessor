module SCode::Formatter
  def self.en_format en_text
    self.en_data_for_sub.each do |key, value|
      en_text.gsub!(Regexp.new(key), value)
    end
    en_text
  end

  def self.en_data_for_sub
    {
      '(P|p)lease' => 'You'
    }
  end

  def self.ja_format ja_text
    self.ja_data_for_sub.each do |key, value|
      ja_text.gsub!(Regexp.new(key), value)
    end
    ja_text
  end

  def self.ja_data_for_sub
    {
      # ' ' => '、',
      '株式会社モノゴコロ' => 'Monogocoro',
      '株式会社コシダカフォールディングス' => 'Koshidaka Holdings',
      '真夏の夜の夢' => 'MANATSUNOYONOYUME',
      '腰高' => 'KOSHIDAKA',
      '中森明菜' => 'SNGRNAKAMORIAKINA'
    }
  end
end
