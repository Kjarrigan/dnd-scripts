require_relative 'core_ext'

# [Work in Progress] Every core mechanic / (house)rule to define characters for usage in the other scripts.
module Backend
  VERSION = '0.2.0'

  # Steckbrief
  # %w{full_name age parents place_of_birth height weight alignment race languages klasses speed feats}

  # Combat
  # %w{hp ac ac_touch ac_flat initiative fort_save ref_save will_save attack_hand attack_missle grapple base_attack_bonus}

  # Skills & Feats
  # %w{appraise balance bluff climb concentration diplomacy disguise escape_artist forgery gater_information heal hide intimidate jump knowledge_local listen move_silently profession_trader ride search sense_motive spellcraft spot survival swim use_rope}

  # Magic
  # %w{spells_known spells_per_day}

  # Inventory
  # %w{coins equipment}

  # History
  # %w{bio}

  # Logbuch
  # %w{levelup_history}

  class Character
    @@hp_mod = 0
    @@feats = []
    @@coins = 0
    @@transaction_log = []

    class << self
      def ability(name, val, tmp=0)
        define_method name do val end
        define_method name.to_s+'_mod' do (val-10)/2 end
        define_method name.to_s+'_temp' do tmp end
        define_method name.to_s+'_temp_mod' do tmp > 0 ? (send(name)+send("#{name}_temp")-10)/2 : 0 end
      end

      def hp_add(val)
        @@hp_mod += val
      end

      def level(val)
        define_method :level do val end
      end

      def desc(name, val)
        define_method name do val end
      end

      def feat(name)
        @@feats << name
      end

      def earn(value, msg)
        @@transaction_log << [value, msg]
        @@coins += value
      end
      def pay(value, msg)
        earn(-1*value, msg)
      end
    end

    def base_hp
      hit_die + (level * con_mod) + hp_mod
    end

    def feats; @@feats; end
    def hp_mod; @@hp_mod; end
    def coins; @@coins; end
      
    def fortitude_save_stats
      list = []
      list << fortitude_save
      list << con_mod
      list << fortitude_magic
      list << fortitude_misc
      list << fortitude_temp
      list.unshift(list.map(&:to_i).inject(:+))
    end
    
    def reflex_save_stats
      list = []
      list << reflex_save
      list << dex_mod
      list << reflex_magic
      list << reflex_misc
      list << reflex_temp
      list.unshift(list.map(&:to_i).inject(:+))
    end
    
    def will_save_stats
      list = []
      list << will_save
      list << wis_mod
      list << will_magic
      list << will_misc
      list << will_temp
      list.unshift(list.map(&:to_i).inject(:+))
    end
    
    [:fortitude, :reflex, :will].each do |st|
      attr_accessor "#{st}_magic"
      attr_accessor "#{st}_misc"
      attr_accessor "#{st}_temp"
    end      

    def skill_points
      (self.level + 3) * (klass_skill_base_value + int_mod + race_skill_bonus)
    end
  end

  module Race
  end
  require_relative 'races/base'
  require_relative 'races/human'

  module Klass
  end
  require_relative 'klasses/sorcerer'

  require_relative 'houserules/skill_points'
end
