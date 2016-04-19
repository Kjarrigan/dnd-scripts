require_relative 'core_ext'
require 'yaml'

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
  class Skill < Struct.new :name, :useable_without_ranks, :key_ability
    def self.all
      list = []
      YAML.load_file('./skills.yml').each do |_,skill|
        list << Skill.new(skill['name'], skill['useable_without_ranks'], skill['key_ability'])
      end
      list
    end

    # attr_accessor :name
    # attr_accessor :useable_without_ranks
    # attr_accessor :key_ability
    attr_accessor :special
    attr_accessor :points
    attr_accessor :klass_skill

    def usable?
      self.useable_without_ranks or self.ranks > 1
    end

    def ranks
      klass_skill ? points / 2.0 : points
    end
  end

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

      def skill(name, points_spent, special: nil)
        @@skills ||= initialize_skills
        @@skills[name].points = points_spent
        @@skills[name].special = special
      end

      private
      # Load all known skills and merge them with the klass-specific values
      def initialize_skills
        list = Skill.all
        klass_skills.each do |ks|
          list[ks].klass_skill = true
        end
        list
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

    def initiative_stats
      list = []
      list << initiative_ability
      list << initiative_misc
      list.unshift(list.map(&:to_i).inject(:+))
    end
    attr_accessor :initiative_ability
    attr_accessor :initiative_misc

    def grapple_stats
      list = []
      list << base_attack_bonus
      list << str_mod
      list << grapple_size_mod
      list << grapple_misc
      list.unshift(list.map(&:to_i).inject(:+))
    end
    # TODO: Is the size_mod grapple specific or common for alle values effected by size?!
    attr_accessor :grapple_size_mod
    attr_accessor :grapple_misc

    def skill_points
      (self.level + 3) * (klass_skill_base_value + int_mod + race_skill_bonus)
    end

    def skills
      @@skills ||= initialize_skills
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
