module Backend::Race
  module Human
    include Base
    
    def speed; 30; end
    def race; self.class.to_s; end
    def size; 'Medium'; end
    def race_skill_bonus; 1; end
  end
end
