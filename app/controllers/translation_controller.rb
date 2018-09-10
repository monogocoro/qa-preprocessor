class TranslationController < ApplicationController
  def perform
    data = URI.unescape(params[:data])
    result = JSON.parse(data)

    from = result['from'].try(:to_sym)
    from ||= :en

    to = result['to'].try(:to_sym)
    to ||= :ja

    begin
      result = EasyTranslate.translate(result['texts'], from: from, to: to, model: :nmt)
      hash = {texts: result}
    rescue => e
      hash = {error: e.message}
    end

    render json: hash
  end
end
