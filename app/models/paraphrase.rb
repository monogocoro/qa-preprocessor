class Paraphrase
  include ActiveModel::Model

  attr_accessor :verb, :arg1, :arg2, :to_s

  def initialize(s_code)

    # begin
      @verb = s_code[:verb]
      @arg1 = self.class.parse_arg(s_code[:arg1])
      @arg2 = self.class.parse_arg(s_code[:arg2])
    # rescue => e
    #   errors[:base] << e.message
    # end

  end

  def self.parse_arg(arg)
    # debugger
    #名詞だけの場合
    if arg.class == String
      ret = arg
    elsif arg.class == Hash

      # argが名詞節の場合
      if arg.keys == [:dp, :nx, :plu, :np, :adjp]
        np = []
        np << arg[:np]
        np.flatten!
        np << arg[:nx]
        ret = np.join(' ')
      # argが形容詞節の場合
      elsif arg.keys == [:base, :degree]
        ret = arg[:base]
      end
    end
    ret
  end

  def to_s
    unless @to_s
      # if @arg2.present? && @verb.present?
        @verb = @verb.verb.conjugate(tense: :past, aspect: :progressive)
        @to_s = [@verb, @arg2].join(' ')
      # end
    end
    @to_s
  end

  def to_ja
    en_text = to_s
    puts en_text
    EasyTranslate.translate(en_text, from: :en, to: :ja, model: :nmt)
  end

end
