require 'prawn'
require_relative 'backend'

# [Work in Progress] Generate an Character Sheet in PDF Format (with prawn).
module CharacterSheetPdf
  VERSION = '0.1.0'

  module Helper
    WIDTH = 598
    FONT_NORMAL = 9
    FONT_SMALL = 4
    FONT_TINY = 2

    def text_field(label, content, x, w)
      text_box content, at: [x, cursor]
      stroke_line x, cursor-10, x+w-10, cursor-10
      text_box label, at: [x, cursor-12], size: FONT_SMALL
    end

    def black_box(content, x, w, margin: 3, weight: :normal)
      self.fill_color = "000000"
      fill_and_stroke_rectangle [x, cursor+2], w-margin, FONT_NORMAL+2
      self.fill_color = "ffffff"
      text_box content, at: [x,cursor], width: w-margin, align: :center, weight: weight
      self.fill_color = "000000"
    end

    def white_box(content, x, w, margin: 3, weight: :normal)
      self.fill_color = "ffffff"
      fill_and_stroke_rectangle [x, cursor+2], w-margin, FONT_NORMAL+2
      self.fill_color = "000000"
      text_box content, at: [x,cursor], width: w-margin, align: :center, weight: weight
    end

    def label_box(content, x, w)
      text_box content, at: [x, cursor], width: w, height: FONT_NORMAL+2, size: FONT_SMALL, align: :center, valign: :bottom
    end
  end

  class Stringifier
    attr_reader :obj
    def initialize(obj)
      @obj = obj
    end

    def method_missing(name, &block)
      resp = if block
        obj.send(name, &block)
      else
        obj.send(name)
      end
      resp.to_s
    end
  end

  class CharacterSheet35 < Prawn::Document
    include Helper

    attr_accessor :character
    def initialize
      super(margin: 5)
      font_size = FONT_NORMAL
      line_width = 0.5
    end

    def basic_information
      # Description
      text_field 'CHARACTER NAME', character.name, 0, 200
      text_field 'PLAYER', character.player, 200, 200
      move_down 20

      text_field 'CLASS AND LEVEL', character.klass, 0, 200
      text_field 'RACE', character.race, 200, 67
      text_field 'Alignment', character.alignment, 267, 66
      text_field 'Deity', character.deity, 333, 67
      move_down 20

      text_field 'SIZE', character.size, 0, 50
      text_field 'AGE', character.age, 50, 50
      text_field 'GENDER', character.gender, 100, 50
      text_field 'HEIGHT', character.height, 150, 50
      text_field 'WEIGHT', character.weight, 200, 50
      text_field 'EYES', character.eyes, 250, 50
      text_field 'HAIR', character.hair, 300, 50
      text_field 'SKIN', character.skin, 350, 50
      move_down 25
    end

    def abilites
      label_box 'ABILITY NAME', 0, 40
      label_box 'ABILITY SCORE', 40, 30
      label_box 'ABILITY MODIFIER', 70, 30
      label_box 'TEMPORARY SCORE', 100, 30
      label_box 'TEMPORARY MODIFIER', 130, 30

      [:str, :dex, :con, :int, :wis, :cha].each do |ab|
        move_down 14
        black_box ab.to_s.upcase, 0, 40, weight: :bold
        white_box character.send(ab), 40, 30
        white_box character.send("#{ab}_mod"), 70, 30
        white_box none_if_blank(character.send("#{ab}_temp")), 100, 30
        white_box none_if_blank(character.send("#{ab}_temp_mod")), 130, 30
      end
    end

    def skills
      text_box @character.skill_points, at: [300, 300]
    end

    def generate_for(char)
      @character = Stringifier.new(char)
      basic_information
      abilites
      skills
    end

    def save
      render_file('sheet.pdf')
    end

    private
    def none_if_blank(str)
      (str.nil? or str.empty? or str == '0') ? '' : str
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  require_relative 'characters/gwyn'
  cs = CharacterSheetPdf::CharacterSheet35.new
  cs.generate_for Gwyn.new
  cs.save
end
