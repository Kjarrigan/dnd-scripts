module Backend::Race
  module Base
    def race; self.class.to_s; end
    def race_skill_bonus; 0; end
    def self.interface(name)
      define_method name do raise "Not implemented for #{self.class}!" end
    end

    interface :speed
    interface :size
  end
end
