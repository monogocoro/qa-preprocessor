class SCode::Pass
  def self.generate(en_text)
    if en_text[-1] == '.'
      en_text.chop!
    end
    list = [
      'Hello',
      'What is the degree',
      'So so',
      'how are you',
      'Good evening',
      'OK',
      'Yes',
      'No',
      'By the way',
    ]
    first_item = list.select{ |item| item == en_text }.first
    if first_item
      return {pass: first_item}
    else
      return nil
    end
  end
end
