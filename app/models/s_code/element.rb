class SCode::Element
  attr_accessor :xml, :verb_obj, :verb, :arg1, :arg2, :arg3, :tense, :voice, :aspect, :adverb, :sent_xml

  def initialize(xml)
    # TODO 動詞を含んだ節、句を形成しないケース
    @xml = xml
    verb
    arg1
    arg2
    arg3
    tense
    voice
    aspect
    adverb
  end

  def self.generate(xml)

    result = nil
    # if xml.xpath('./cons').size > 1
    #
    #   if xml.xpath('./cons[@cat="S"]').size > 0
    #     element = xml.xpath('./cons').map do |cons|
    #       if cons.xpath('@cat') == 'S'
    #         item = SCode::Element.new(cons)
    #       elsif cons.xpath('@cat') == 'NP'
    #         item = SCode::NounPart.new(cons)
    #       end
    #     end
    #   end
    #
    # else
      element = SCode::Element.new(xml)
    # end

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

  # TODO 本来は、arg1と省略されている語をswapしないとならない。
  def self.swap_arg1_and_arg2?(arg1, verb)
    q_marker_list = %w{what who}
    swap_arg1_arg2 = q_marker_list.map do |marker|
      marker.casecmp(arg1.to_s) == 0 && verb == 'be'
    end.select{|item| item.present?}.uniq
    swap_arg1_arg2.present?
  end

  def verb(sent_xml=nil)
    sent_xml ||= @xml

    if @verb_obj.blank?
      # 第一階層の動詞を見つける。
      # TODO イディオムや助動詞のチェックを用意する必要がある。
      # auxiliary_verb_idiom = {
      #   'be about to' => 'About'
      #   'will' => 'About'
      # }
      # センテンス直下のVPを取得する
      vp = sent_xml.xpath('cons[@cat="VP"]')
      unless vp.present?
        vp = sent_xml.xpath('cons[@cat="VX"]')
      end

      unless vp.present?
        if sent_xml.xpath('@cat').to_s == 'VP'
          vp = sent_xml
        end
      end

      unless vp.xpath('cons').size > 0
        @verb_obj = vp
      else
        search_items = %w{VP VX}
        result = search_items.map do |item|
          vp.xpath('cons[@cat="' + item + '"]').try(:first)
        end.select{|item| item.present?}.first

        @verb_obj = result
      end
    end

    unless @verb_obj.xpath('tok').present?
      @verb_obj = result.xpath('cons[@cat="VP"]')
    end

    unless @verb_obj.xpath('tok').present?
      @verb_obj = result.xpath('cons[@cat="VX"]')
    end

    @verb = @verb_obj.xpath('tok').xpath('@base').to_s
    @verb
  end

  def arg1
    @arg1 ||= search_arg(1)
  end

  def arg2
    @arg2 ||= search_arg(2)
  end

  def arg3
    @arg3 ||= search_arg(3)
  end

  def tense
    if @tense.blank?
      matrix = {
        present: 'P',
        past: 'Past',
        will: 'F',
        untensed: 'Untensed'
      }
      key = @verb_obj.xpath('tok').xpath('@tense').to_s
      unless key.present?
        key = @verb_obj.xpath('cons[@cat="VP"]/tok').xpath('@tense').to_s
      end
      result = matrix[key.try(:to_sym)]
      @tense = result
      unless @tense.present? && @tense != 'Untensed'
        if @verb_obj.parent
          key = @verb_obj.parent.xpath('cons[@cat="VX"]/tok/@base').try(:to_s)
          result = matrix[key.try(:to_sym)]
          @tense = result
        end

      end
    end

    @tense ||= 'Untensed'

    # Untensedの場合
    # TODO 未来形かを確認する
    @tense

  end

  def voice
    if @voice.blank?
      matrix = {
        active: 'Act',
        passive: 'Pass',
      }
      key = @verb_obj.xpath('tok').xpath('@voice').to_s
      unless key.present?
        key = @verb_obj.xpath('cons[@cat="VP"]/tok').xpath('@voice').to_s
      end
      result = matrix[key.try(:to_sym)]
      @voice = result
    end

    @voice
    # Untensedの場合
    # TODO Negは、能動形、受動形どちらもありえる？
  end

  def aspect
    # TODO 実装する　デモ用データには不要なため
    if @aspect.blank?
      result = nil
      matrix = {
        can: 'Pot',
        may: 'May',
        should: 'Need',
      }
      item = @xml.xpath('cons[@cat="VP"]').xpath('cons[@cat="VX"]/tok[@pos="MD"]').first
      if item.present?
        key = item.xpath('text()').to_s
        result = matrix[key.try(:to_sym)]
      end
      @aspect = result
    end

    @aspect
  end

  def adverb
    # 副詞部分を探す
    # TODO to不定詞の副詞的用法は取得が難しいか。to以下は形容詞的な扱いになることが多い。
    return @adverb if @adverb

    # 語の場合
    # 議論となるエレメントの直下の、「ADVP」
    # 議論となるエレメントの動詞直下の「ADVP」
    advp = []
    @xml.xpath('cons[@cat="VP"]/cons[@cat="ADVP"]').each do |item|
      advp << {word: item}
    end
    @xml.xpath('cons[@cat="VP"]/cons[@cat="VP"]/cons[@cat="ADVP"]').each do |item|
      advp << {word: item}
    end

    # Sの直下にあるADVP
    @xml.xpath('cons[@cat="ADVP"]').each do |item|
      advp << {word: item}
    end

    # 句の場合
    # VPの直下にあるPP
    @xml.xpath('cons[@cat="VP"]/cons[@cat="PP"]').each do |item|
      advp << {clause: item}
    end
    @xml.xpath('cons[@cat="VP"]/cons[@cat="VP"]/cons[@cat="PP"]').each do |item|
      advp << {clause: item}
    end

    @xml.xpath('cons[@cat="VP"]/cons[@cat="NP"]').each do |item|
      arg1 = item.xpath('@id').to_s == verb_obj.xpath('tok/@arg1').to_s
      arg2 = item.xpath('@id').to_s == verb_obj.xpath('tok/@arg2').to_s
      arg3 = item.xpath('@id').to_s == verb_obj.xpath('tok/@arg3').to_s
      if !arg1 && !arg2 && !arg3
        advp << {naun_clause: item}
      end
    end
    @xml.xpath('cons[@cat="VP"]/cons[@cat="VP"]/cons[@cat="NP"]').each do |item|
      arg1 = item.xpath('@id').to_s == verb_obj.xpath('tok/@arg1').to_s
      arg2 = item.xpath('@id').to_s == verb_obj.xpath('tok/@arg2').to_s
      arg3 = item.xpath('@id').to_s == verb_obj.xpath('tok/@arg3').to_s
      if !arg1 && !arg2 && !arg3
        advp << {naun_clause: item}
      end
    end

    # Sの直下にあるPP
    @xml.xpath('cons[@cat="PP"]').each do |item|
      advp << {clause: item}
    end

    # 節の場合
    # VPの直下にあるSCP
    @xml.xpath('cons[@cat="VP"]/cons[@cat="SCP"]').each do |item|
      advp << {phrase: item}
    end
    # Sの直下にあるSCP
    @xml.xpath('cons[@cat="SCP"]').each do |item|
      advp << {phrase: item}
    end

    # それぞれを適切なオブジェクトに変換する
    @adverb = advp.map do |item|
      result = nil
      if item.keys.first == :word
        # 文字列
        result = item[:word].xpath('tok/text()').to_s
      elsif item.keys.first == :clause
        result = SCode::Part.generate(item[:clause])
      elsif item.keys.first == :naun_clause
        result = SCode::NounPart.generate(item[:naun_clause])
      elsif item.keys.first == :phrase
        result = SCode::Part.generate(item[:phrase])
      end
      result
    end

  end

  def search_arg(num)
    arg_search = @verb_obj.xpath('tok').xpath('@arg'+num.to_s)
    unless arg_search.present?
      arg_search = @verb_obj.xpath('cons[@cat="VP"]/tok').xpath('@arg'+num.to_s)
    end
    result = nil
    if arg_search.present?
      arg_id = arg_search[0].value
      result = @xml.xpath("//cons[@id='#{arg_id}']")
    end
    if result.present?
      if result.first.xpath('@cat').to_s == 'S'
        SCode::Part.generate(result.first)
      elsif result.first.xpath('@cat').to_s == 'CP'
        item = result.first.xpath('./cons[@cat="S"]').first
        if item
          SCode::Part.generate(item)
        end
      elsif result.first.xpath('@cat').to_s == 'ADJP'
        # 形容詞を生成
        base = result.first.xpath('tok').xpath('@base').to_s
        degree = result.first.xpath('tok').xpath('@pos').to_s
        {base: base, degree: degree}
      elsif result.first.xpath('@cat').to_s == 'NP'

        # 冠詞がなければ、テキストを取得してしまう
        # adjp_present = result.first.xpath('./cons[@cat="NX"]/cons[@cat="ADJP"]')
        # dp_present = result.first.xpath('cons[@cat="DP"]')
        # if dp_present.size < 1 && adjp_present.size < 1
        #   cons_nx_tok = result.first.xpath('cons[@cat="NX"]/tok')
        #   if cons_nx_tok.size == 1
        #     if cons_nx_tok.xpath('@pos').to_s == 'NNP'
        #       result.first.xpath('cons[@cat="NX"]/tok/text()').to_s
        #     else
        #       result.first.xpath('cons[@cat="NX"]/tok/@base').to_s
        #     end
        #   elsif result.first.xpath('tok[@cat="N"]').size == 1
        #     if cons_nx_tok.xpath('@pos') == 'NNP'
        #       result.first.xpath('tok[@cat="N"]/text()').to_s
        #     else
        #       result.first.xpath('tok[@cat="N"]/@base').to_s
        #     end
        #   end
        # else
        #   # 名詞節を生成
          SCode::NounPart.generate(result.first)
        # end

      end
    end
  end

end
