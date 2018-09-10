class Forms::Paraphrase
  include ActiveModel::Model

  attr_accessor :scode, :paraphrase

  # validates :scode, presence: true
  # validates :paraphrase, presence: true

  def initialize(sentence)
    @s_code = SCode::generate(sentence)
    puts @s_code
    @paraphrase = ::Paraphrase.new(@s_code)
  end

end
