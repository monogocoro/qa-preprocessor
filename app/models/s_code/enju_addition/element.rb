module SCode::EnjuAddition::Element
  extend ActiveSupport::Concern

  def word?
    @word ||= !sentence? && np_cat? && single_word_noun_phrase?
  end

  def naun_phrase?
    @naun_phrase ||= !sentence? && np_cat? && !single_word_noun_phrase?
  end

  def element?
    @element ||= (vp_cat? && !vp_cat_parent?) || s_cat?
  end

  def sentence?
    name == 'sentence'
  end

  def np_cat?
    attribute('cat').try(:value) == 'NP'
  end

  def s_cat?
    attribute('cat').try(:value) == 'S'
  end

  def vp_cat?
    attribute('cat').try(:value) == 'VP'
  end

  def dp_cat?
    attribute('cat').try(:value) == 'DP'
  end

  def vp_cat_parent?
    parent.attribute('cat').try(:value) == 'VP'
  end

  def single_word_noun_phrase?
    @single_word_noun_phrase ||= children.first.attribute('cat').try(:value) == 'NX' &&
    children.first.children.first.attribute('cat').try(:value) == 'N'
  end

end
