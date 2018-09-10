require 'nokogiri'

class Nokogiri::XML::Document
  include SCode::EnjuAddition::Document
end

class Nokogiri::XML::Element
  include SCode::EnjuAddition::Element
end

class Enju
  include ActiveModel::Validations

  attr_accessor :sentence, :output

  validates_presence_of(:sentence)

  def initialize(sentence)
    @sentence = sentence
    if self.valid?
      self.fetch(sentence)
    end
  end

  def fetch(sentence)
    end_point = ENV['ENJU_END_POINT']
    unless end_point
      @errors.add(:ENJU_END_POINT, "（環境変数）を設定してください。")
    end

    uri = URI.parse("http://#{end_point}/cgi-lilfes/enju")

    params = {sentence: sentence}
    uri.query = URI.encode_www_form(params)

    begin
      xml = Net::HTTP::get(uri)
    rescue => e
      @errors.add(:base, e)
      return
    end

    if xml.blank?
      @errors.add(:xml, 'を取得できませんでした。')
      return
    end

    doc = Nokogiri::XML(xml)
    doc.sentence = @sentence

    # ある文に一致した場合、自動的に命令文として、動かす。

    @output = doc
  end
end
