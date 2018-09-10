class SCode::Part
  attr_accessor :xml, :modifier, :element, :type

  def initialize(xml)
    @xml = xml
    modifier
    element
    type
  end

  def self.generate(xml)
    part = SCode::Part.new(xml)
    {
      modifier: part.modifier,
      element: part.element
    }
  end

  def modifier
    @modifier if @modifier

    # TODO 適切なmodifierの判定基準を用意する
    # リストから取得して来る
    list = %w{in with of about if to into}
    @modifier = list.select do |item|
      @xml.xpath('.//tok/text()').try(:first).try(:to_s) == item
    end.try(:first)
  end

  def element
    @element if @element
    # element側の情報を取って来る
    if @modifier
      # TODO 動詞の場合も用意しないとならない。
      item = @xml.xpath('cons[@cat="NP"]').first
    else
      item = @xml
    end

    if item.element?
      SCode::Element.generate(item)
    else
      SCode::NounPart.generate(item)
    end

  end

  def type
    @type if @type
  end
end
