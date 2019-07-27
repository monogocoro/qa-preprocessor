require 'json'
require 'net/https'
require 'openssl'
require 'uri'
class TranslationController < ApplicationController
  def detect

    require "google/cloud/translate"

    translate   = Google::Cloud::Translate.new
    detect = translate.detect params[:q]

    render plain: detect.language

  end
  def perform
    kind = params[:kind] || 'googlev2'
    puts kind

    if params[:from] == 'ja'
      # params[:sentence].gsub!(/。?$/, '')
      # params[:sentence] = params[:sentence] + '。'
    elsif params[:from] == 'en'
      # params[:sentence].gsub!(/\.?$/, '')
      # params[:sentence] = params[:sentence] + '.'
    elsif params[:from] == 'zh-CN'
      # params[:sentence].gsub!(/。?$/, '')
      # params[:sentence] = params[:sentence] + '。'
    elsif params[:from] == 'zh-TW'
      # params[:sentence].gsub!(/。?$/, '')
      # params[:sentence] = params[:sentence] + '。'
    elsif params[:from] == 'ko'
      # params[:sentence].gsub!(/\.?$/, '')
      # params[:sentence] = params[:sentence] + '.'
    end

    if kind == 'googlev1'
      text = EasyTranslate.translate(params[:sentence], from: params[:from], to: params[:to], model: :nmt)
    elsif kind == 'googlev2'
      text = google params[:sentence], params[:from], params[:to]
    elsif kind == 'rozetta'
      text = rozetta params[:sentence], params[:from], params[:to]
    end

    render plain: text
  end

  private
  def google input, from, to

    require "google/cloud/translate"

    translate   = Google::Cloud::Translate.new
    translation = translate.translate input, from: from, to: to

    puts "Translated '#{input}' to '#{translation.text.inspect}'"
    puts "Original language: #{translation.from} translated to: #{translation.to}"
    translation.text

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
      'text' => [input],
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
