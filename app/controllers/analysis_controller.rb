class AnalysisController < ApplicationController

  def paraphrase
    sentence = URI.unescape(params[:sentence])
    form = Forms::Paraphrase.new(sentence)
    if form.valid?
      render plain: form.paraphrase.to_ja
    else
      render plain: form.errors.full_messages
    end
  end

  def complement

    ja_text = URI.unescape(params[:sentence])
    ja_text = SCode::Formatter.ja_format(ja_text)

    # ja_text << "。" unless ja_text[-1] == "。"

    puts ja_text

    # begin
      en_text = EasyTranslate.translate(ja_text, from: :ja, to: :en, model: :nmt)

      puts en_text

      words = en_text.split(/\s? \s?/)
      subj_data = [
        'you',
        'i',
        'we',
        'he',
        'she',
        'they'
      ]
      obj_data = [
        'me',
        'you',
        'him',
        'her',
        'them'
      ]

      matrix = {
        'you' => 'あなた',
        'i' => '私',
        'we' => '私たち',
        'he' => '彼',
        'she' => '彼女',
        'they' => '彼ら',
        'me' => '私',
        'him' => '彼',
        'her' => '彼女',
        'them' => '彼ら',
      }

      subj = nil
      break_flg = false
      words.each_with_index do |word, i|
        subj_data.each do |item|
          if word.casecmp(item) == 0
            subj = word
            words.delete_at(i)
            break_flg = true
            break
          end
        end
        if break_flg
          break
        end
      end

      objs = []
      words.each do |word|
        obj_data.each do |item|
          if word.casecmp(item) == 0
            objs << word
          end
        end
      end

      subj_text = matrix[subj.try(:downcase)]
      obj_text = objs.map {|obj| matrix[obj.downcase] }.join('、')

      result = ''
      # new_text = EasyTranslate.translate(en_text, from: :en, to: :ja, model: :base)
      #
      # if new_text
      #   result += new_text
      # end

      if subj_text.present?
        result += ''
        result += '主語 ' + subj_text
      end
      if obj_text.present?
        result += ' '
        result += '補完語 ' + obj_text
      end
      if !obj_text.present? && !subj_text.present?
        result += '取得できませんでした。'
      end
      hash = {texts: [result]}
    # rescue => e
    #   hash = {error: e.message}
    # end

    render json: hash

  end

require 'net/http'
require 'uri'

  def ja2en

    ja_text = URI.unescape(params[:sentence])
    ja_text << "。" unless ja_text[-1] == "。"

    if params[:google]
      en_text = EasyTranslate.translate(ja_text, from: :ja, to: :en, model: :nmt)
    else
      params = URI.encode_www_form(
        {
          'langFrom' => 'ja',
          'langTo' => 'en',
          'profile' => 'monogocoro',
          'subscription-key' => '78fa6d846f79469d81bf1a0cb772015f'
        })

      url = URI.parse("https://apigw.mirai-api.net/trial/mt/v1.0/translate?#{params}")
      puts url
      req = Net::HTTP::Post.new(url.request_uri)
      req["Content-Type"] = "application/json; charset=UTF-8"
      req["Host"] = "apigw.mirai-api.net"
      json = "{\"source\": \"#{ja_text}\"}"
      req["Content-Length"] = json.bytesize

      puts req.each{|k, v| puts k +":"+ v}

      req.body = json
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      res = https.request(req)

      puts res.code
      puts res.body
      puts res.header.each{|k, v| puts k +":"+ v}
      response = JSON.load(res.body)
      if response['error'].present?
        en_text = response.to_json
      else
        en_text = response['response']['translation']
      end
    end
    render plain: en_text
  end

  def en2ja
    en_text = URI.unescape(params[:sentence])
    # ja_text << "." unless ja_text[-1] == "."

    puts en_text

    ja_text = EasyTranslate.translate(en_text, from: :en, to: :ja, model: :nmt)

    render plain: ja_text
  end

  def en2enju_xml
    en_text = URI.unescape(params[:sentence])
    puts en_text
    e = Enju.new(en_text)
    render xml: e.output
  end

  def enju_xml
    ja_text = URI.unescape(params[:sentence])
    ja_text << "。" unless ja_text[-1] == "。"

    puts ja_text

    en_text = EasyTranslate.translate(ja_text, from: :ja, to: :en, model: :nmt)
    # # 可能ならgoolishを英語に修正する。
    # en_text = SCode::GoolishToEnglish.translate(en_text)
    # #文の一部を置換する。
    # en_text = SCode::Formatter.en_format(en_text)

    puts en_text

    e = Enju.new(en_text)

    render xml: e.output
  end

  def result
    # begin
      ja_text = URI.unescape(params[:sentence])
      ja_text = SCode::Formatter.ja_format(ja_text)

      ja_text << "。" unless ja_text[-1] == "。"

      puts ja_text

      en_text = EasyTranslate.translate(ja_text, from: :ja, to: :en, model: :nmt)
      puts en_text
      en_texts = en_text.split(/\s?,\s?/)
      hashes = en_texts.map do |en_text|
        en_text.strip!
        analysis(en_text)
      end
    # rescue => e
    #   hash = {error: e.message}
    # end

    render json: {scode: hashes}
  end

  def analysis en_text

    if en_text[0..3] == 'What'
      en_text.sub!(/\.$/, '?')
    end
    # 可能ならgoolishを英語に修正する。
    en_text = SCode::GoolishToEnglish.translate(en_text)
    #文の一部を置換する。
    en_text = SCode::Formatter.en_format(en_text)

    #TODO 文タイプの判定はある一箇所にまとめる
    sentence_type = nil
    gsub_result = en_text.gsub!(/(P|p)lease/, 'you')
    if gsub_result
      sentence_type = 'Ask'
    end

    pass = SCode::Pass.generate(en_text)
    if pass.present?
      hash = pass
    else
      e = Enju.new(en_text)
      hash = SCode::Sentence.generate(e.output, sentence_type)
    end

    hash = hash.map do |key, val|
      new_val = val
      new_val = nil if val == []
      [key, new_val]
    end.to_h

    hash
  end
end
