module Backend::Klass::Sorcerer
  def klass; 'Sorcerer'; end
  def base_attack_bonus
    0 + ((level-1) / 2.0).ceil
  end

  def fortitude_save
    0 + ((level-2) / 3.0).ceil
  end
  alias_method :reflex_save, :fortitude_save

  def will_save
    2 + ((level-1) / 2.0).ceil
  end

  def klass_skill_base_value
    2
  end

  def spells_known(lvl=0)
    4 + ((self.level - 1) / 2).ceil - (lvl*2)
  end

  def hit_die; 4; end

  def klass_skills
    [:diplomacy, :profession]
  end
end
