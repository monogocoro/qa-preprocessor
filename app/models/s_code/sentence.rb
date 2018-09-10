class SCode::Sentence
  attr_accessor :xml, :element, :np, :advp, :sentence_type, :root

  def initialize(xml, sentence_type)
    @xml = xml
    @root = @xml.xpath('/sentence/cons')

    if @root.present?
      if @root.xpath('@cat').to_s == 'S'
        if @root.size > 0
          @element = SCode::Question.generate(@root)
        else
          @element = SCode::Element.generate(@root)
        end
      elsif @root.xpath('@cat').to_s == 'NP'
        @np = SCode::NounPart.generate(root)
      elsif @root.xpath('@cat').to_s == 'NP'
        @np = SCode::NounPart.generate(root)
      elsif @root.xpath('@cat').to_s == 'ADVP'
        advp_content = @root.xpath('.//tok/@base').to_s
        @advp = {content: advp_content}
      end
    end

    sentence_type

    #TODO xmlからは取得できない？
    #   @element = SCode::Element.generate(xml)
  end

  def self.generate(xml, sentence_type=nil)

    #決め打ちで結果を表示する
    if xml.try(:sentence).present?
      sentence = SCode::Reflex.reflect(xml.sentence)
      return sentence if sentence.present?
    end

    sentence = SCode::Sentence.new(xml, sentence_type)

    #TODO sentenceの作り方を検討する
    if sentence.element.present?
      sentence.element[:sentence] = sentence_type
      sentence.element[:sentence] ||= sentence.sentence_type
      sentence.element
    elsif sentence.np.present?
      sentence.np[:sentence] = 'NP'
      sentence.np
    elsif sentence.advp.present?
      sentence.advp[:sentence] = 'ADVP'
      sentence.advp
    else
      {pass: "There is no element."}
    end

  end

  def sentence_type
    return @sentence_type if @sentence_type

    if @root.present?
      if @root.first.xpath('@xcat="IMP"')
        @sentence_type = "Order"
      elsif @root.first.xpath('@xcat="INV"') || @root.first.xpath('@xcat="WH"') || @root.first.xpath('@xcat="INV Q"') || @root.first.xpath('@xcat="INV Q WH"')
        @sentence_type = "Q"
      end
    end
    @sentence_type ||= "S"
  end
end
