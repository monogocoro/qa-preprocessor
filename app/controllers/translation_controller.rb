require 'json'
require 'net/https'
require 'openssl'
require 'uri'
class TranslationController < ApplicationController
  def perform
    kind = params[:kind] || 'google'
    puts kind

    if params[:from] == 'ja'
      params[:sentence].gsub!(/。?$/, '')
      params[:sentence] = params[:sentence] + '。'
    elsif params[:from] == 'en'
      params[:sentence].gsub!(/\.?$/, '')
      params[:sentence] = params[:sentence] + '.'
    elsif params[:from] == 'zh-CN'
      params[:sentence].gsub!(/。?$/, '')
      params[:sentence] = params[:sentence] + '。'
    elsif params[:from] == 'zh-TW'
      params[:sentence].gsub!(/。?$/, '')
      params[:sentence] = params[:sentence] + '。'
    elsif params[:from] == 'ko'
      params[:sentence].gsub!(/\.?$/, '')
      params[:sentence] = params[:sentence] + '.'
    end

    if kind == 'google'
      text = EasyTranslate.translate(params[:sentence], from: params[:from], to: params[:to], model: :nmt)
    elsif kind == 'mirai'
      text = mirai params[:sentence], params[:from], params[:to]
    elsif kind == 'rozetta'
      text = rozetta params[:sentence], params[:from], params[:to]
    end

    render plain: text
  end

  private
  def mirai input, from, to
    unless from == 'ja' &&  to == 'en'
      return 'Mirai need "from: ja, to:en on this version."'
    end

    mirai_params = URI.encode_www_form(
      {
        'langFrom' => from,
        'langTo' => to,
        'profile' => 'monogocoro',
        'subscription-key' => '78fa6d846f79469d81bf1a0cb772015f'
      })

    url = URI.parse("https://apigw.mirai-api.net/trial/mt/v1.0/translate?#{mirai_params}")
    puts url
    req = Net::HTTP::Post.new(url.request_uri)
    req["Content-Type"] = "application/json; charset=UTF-8"
    req["Host"] = "apigw.mirai-api.net"
    json = "{\"source\": \"#{params[:sentence].to_s}\"}"
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
      text = response.to_json
    else
      text = response['response']['translation']
    end

    text
  end

  def rozetta input, from, to

    unless from == 'ja' &&  to == 'en'
      return 'Rozetta need "from: ja, to:en on this version."'
    end

    accessKey = '97e1bae53a6a3a9ee8d357e62305db0067ce22109e9a6733b355ba216415c194'
    secretKey = '6a86c265535d246591ce2453e85464b7abfa27ff650867d1b0f241a9b205b64f11e2015cf847242e5bf970280b635fc7'
    nonce = '987'
    basePath = 'https://translate.classiii.info'
    path = '/api/v1/translate'
    fullURI = basePath + path

    signature = generateSignature(nonce, path, secretKey)

    uri = URI.parse(fullURI)

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'
    request['accessKey'] = accessKey
    request['nonce'] = nonce
    request['signature'] = generateSignature(nonce, path, secretKey)
    requestBody = {
      'fieldId' => '1',
      'text' => [input + '。'],
      'sourceLang' => from,
      'targetLang' => to
    }.to_json

    request.body = requestBody
    response = https.request(request)

    hash = JSON.parse(response.body)
    hash["data"]["translationResult"][0]["translatedText"]
  end

  def generateSignature(nonce, path, secretKey)
    hmac = OpenSSL::HMAC.new(secretKey, 'sha256')
    hmac.update(nonce)
    hmac.update(path)
    return hmac.hexdigest()
  end
end
