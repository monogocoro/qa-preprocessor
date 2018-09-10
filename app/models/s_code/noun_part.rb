class SCode::NounPart
  attr_accessor :xml, :nx, :nx_obj, :adjp, :np, :dp, :plu

  # NP以下のXMLを引数とする
  def initialize(xml)
    # TODO 動詞を含んだ節、句を形成しないケース
    @xml = xml
    dp
    nx
    plu
    adjp
  end

  def self.generate(xml)

    # tok = xml.xpath('//tok')
    tok = xml.xpath('.//tok')
    if tok.size == 1
      return self.fetch_noun_string(tok.first)
    end

   noun_part = SCode::NounPart.new(xml)
   result = {
     dp: noun_part.dp,
     nx: noun_part.nx,
     plu: noun_part.plu,
     np: noun_part.np,
     adjp: noun_part.adjp
   }
  end

  def self.fetch_noun_string(tok)
    # 固有名詞か一般名詞かを判定する
    pos = tok.xpath('@pos').to_s
    # 固有名詞の場合
    if pos == 'NNP'
      value = tok.xpath('./text()').to_s
    else
      value = tok.xpath('@base').to_s
      value = 'I' if value == 'i'
    end
    value
  end

  def plu
    @plu ||= @nx_obj.xpath('tok/@pos').to_s == 'NNS'
  end

  def dp
    result = @xml.xpath('cons[@cat="DP"]/tok/text()').to_s
    if result.present?
      @dp ||= result
    end
  end

  def nx
    # NPの場合
    np_text = xml.xpath('./cons[@cat="NX"]/cons[@cat="NP"]/tok/text()').to_s
    if np_text.present?
      @np = np_text
    end
    is_nx_recursively(xml)
  end

  #再帰的にnxがあるかをチェックする
  def is_nx_recursively(xml)
    if xml.xpath('cons[@cat="NX"]').present?
      xml = xml.xpath('cons[@cat="NX"]')
      is_nx_recursively(xml)
    else
      @nx_obj = xml
      @nx = xml.xpath('tok/text()').to_s
    end
  end

  def adjp
    # 形容詞部分を探す
    # TODO 副詞が形容詞を修飾しているケース
    # return @adjp if @adjp.present?

    # 語の場合
    # 議論となるエレメントの直下の、「ADJP」
    adjp = []
    @xml.xpath('cons[@cat="NX"]/cons[@cat="ADJP"]').each do |item|
      adjp << {word: item}
    end
    # 句の場合
    # to不定詞の場合：CP
    @xml.xpath('cons[@cat="NX"]/cons[@cat="CP"]').each do |item|
      adjp << {clause: item}
    end
    # 前置詞句の場合：PP
    @xml.xpath('cons[@cat="NX"]/cons[@cat="PP"]').each do |item|
      adjp << {clause: item}
    end
    # 動名詞の場合：VP
    @xml.xpath('cons[@cat="NX"]/cons[@cat="VP"]').each do |item|
      adjp << {clause: item}
    end

    # 節の場合
    # 関係代名詞
    @xml.xpath('cons[@cat="NX"]/cons[@cat="S-REL"]').each do |item|
      adjp << {phrase: item}
    end
    # 関係副詞
    @xml.xpath('cons[@cat="NX"]/cons[@cat="SCP"]').each do |item|
      adjp << {phrase: item}
    end

    # それぞれを適切なオブジェクトに変換する
    @adjp = adjp.map do |item|
      result = nil
      if item.keys.first == :word
        #形容詞は以下の構造
        # {base: "high", degree: "jjs"}
        base = item[:word].xpath('tok').xpath('@base').to_s
        degree = item[:word].xpath('tok').xpath('@pos').to_s
        result = {base: base, degree: degree}

      elsif item.keys.first == :clause
        result = SCode::Part.generate(item[:clause])
      elsif item.keys.first == :phrase
        result = SCode::Part.generate(item[:phrase])
      end
      result
    end

  end
end
