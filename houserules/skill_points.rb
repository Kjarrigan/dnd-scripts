# Sorcerer get more skill points per level above level 1 (generation)
module Backend
  class Character
    alias_method :orig_skill_points, :skill_points
    def skill_points
      orig_skill_points - (self.klass == 'Sorcerer' ? 8 : 0)
    end
  end

  module Klass::Sorcerer
    def klass_skill_base_value
      4
    end
  end
end
