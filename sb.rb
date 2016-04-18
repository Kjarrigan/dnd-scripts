require_relative 'core_ext'

# [Work in Progress] Has to be renamed soon. Define your Character in some sort of DSL as class to use in other scripts.
module Sb
  VERSION = '0.1.0'

  # Steckbrief
  %w{full_name age parents place_of_birth height weight alignment race languages klasses speed feats}

  # Combat
  %w{hp ac ac_touch ac_flat initiative fort_save ref_save will_save attack_hand attack_missle grapple base_attack_bonus}

  # Skills & Feats
  %w{appraise balance bluff climb concentration diplomacy disguise escape_artist forgery gater_information heal hide intimidate jump knowledge_local listen move_silently profession_trader ride search sense_motive spellcraft spot survival swim use_rope}

  # Magic
  %w{spells_known spells_per_day}

  # Inventory
  %w{coins equipment}

  # History
  %w{bio}

  # Logbuch
  %w{levelup_history}

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
  end

  module Race
    module Human
      def speed; 30; end
      def race; 'Human'; end
    end
  end

  module Klass
    module Sorcerer
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

      def skill_points_per_level
        # Basevalue: Original 2, Houserules 4
        4 + int_mod
      end

      def spells_known(lvl=0)
        4 + ((self.level - 1) / 2).ceil - (lvl*2)
      end

      def hit_die; 4; end
    end
  end

  class Gwyn < Character
    include Race::Human
    include Klass::Sorcerer

    level 3
    desc :name, 'Gwyneth Llywleyn'
    desc :age, 18
    desc :gender, 'Female'
    desc :parents, 'Dillion & Guinevere'
    desc :place_of_birth, 'Otternburg'
    desc :size, 'Medium'
    desc :height, '165 cm'
    desc :weight, '52 kg'
    desc :alignment, 'Neutral Good'
    desc :player, 'Holger'
    desc :hair, 'Black'
    desc :skin, 'Pale'
    desc :eyes, 'Blue'
    desc :deity, ''

    ability :str, 8
    ability :dex, 14
    ability :con, 12
    ability :int, 14
    ability :wis, 10
    ability :cha, 16

    hp_add 3 # Level 2
    hp_add 3 # Level 3

    feat :Eschew_Materials
    feat :Combat_Casting
    feat :Point_Blank_shot # Level 3

  #   spell 0, :Detect_Magic
  #   spell 0, :Light
  #   spell 0, :Mage_Hand # Level 2
  #   spell 0, :Message
  #   spell 0, :Prestidigitation
  #
  #   spell 1, :Charm_Person
  #   spell 1, :Magic_Missle
  #   spell 1, :Ray_of_Enfeeblement # Level 3

    earn 8.gp, 'as start money'
    pay 1.gp, 'for bolts'
    earn 10.gp, 'for Quest#Bengar'
    pay 4.sp, 'for commodities'
  end
end

if __FILE__ == $0
  require 'pp'
  pp CharacterSheet.new(Gwyn.new).ability_table
  pp CharacterSheet.new(Gwyn.new).description
  pp CharacterSheet.new(Gwyn.new).spells_known_table
  pp CharacterSheet.new(Gwyn.new).coin_purse
end
