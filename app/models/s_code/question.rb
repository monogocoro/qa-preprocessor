class SCode::Question < SCode::Element
  attr_accessor :sent_xml

  def self.generate(xml)
    result = nil
    element = SCode::Question.new(xml)

    # 疑問詞が主語の場合、arg1とarg2を置き換える
    arg1 = element.arg1
    arg2 = element.arg2
    if self.swap_arg1_and_arg2?(arg1, element.verb)
      arg1 = element.arg2
      arg2 = element.arg1
    end

   result = {
     verb: element.verb,
     arg1: arg1,
     arg2: arg2,
     arg3: element.arg3,
     tense: element.tense,
     voice: element.voice,
     aspect: element.aspect,
     adverb: element.adverb
   }
   result
  end

  def verb(sent_xml=nil)
    sent_xml = @xml.first.xpath('cons[@cat="S"]').first
    super(sent_xml)
  end
end
