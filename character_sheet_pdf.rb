require 'prawn'

module Helper
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

WIDTH = 598
FONT_NORMAL = 9
FONT_SMALL = 4
FONT_TINY = 2

Prawn::Document.include Helper

cs = Prawn::Document.new(margin: 5)
cs.font_size = FONT_NORMAL
cs.line_width = 0.5

# Description
cs.text_field 'CHARACTER NAME', 'Gwyneth Llywelyn', 0, 200
cs.text_field 'PLAYER', 'Holger', 200, 200
cs.move_down 20

cs.text_field 'CLASS AND LEVEL', 'Lvl. 3 Sorceress', 0, 200
cs.text_field 'RACE', 'Human', 200, 67
cs.text_field 'Alignment', 'Neutral Good', 267, 66
cs.text_field 'Deity', '-', 333, 67
cs.move_down 20

cs.text_field 'SIZE', 'Medium', 0, 50
cs.text_field 'AGE', '18', 50, 50
cs.text_field 'GENDER', 'Female', 100, 50
cs.text_field 'HEIGHT', '165 cm', 150, 50
cs.text_field 'WEIGHT', '52 kg', 200, 50
cs.text_field 'EYES', 'blue', 250, 50
cs.text_field 'HAIR', 'black', 300, 50
cs.text_field 'SKIN', 'pale', 350, 50
cs.move_down 25

# Abilites
cs.label_box 'ABILITY NAME', 0, 40
cs.label_box 'ABILITY SCORE', 40, 30
cs.label_box 'ABILITY MODIFIER', 70, 30
cs.label_box 'TEMPORARY SCORE', 100, 30
cs.label_box 'TEMPORARY MODIFIER', 130, 30
cs.move_down 14
cs.black_box 'STR', 0, 40, weight: :bold
cs.white_box '8', 40, 30
cs.white_box '-1', 70, 30
cs.white_box '', 100, 30
cs.white_box '', 130, 30
cs.move_down 14
cs.black_box 'DEX', 0, 40, weight: :bold
cs.white_box '14', 40, 30
cs.white_box '+2', 70, 30
cs.white_box '', 100, 30
cs.white_box '', 130, 30
cs.move_down 14
cs.black_box 'CON', 0, 40, weight: :bold
cs.white_box '12', 40, 30
cs.white_box '+1', 70, 30
cs.white_box '', 100, 30
cs.white_box '', 130, 30
cs.move_down 14
cs.black_box 'INT', 0, 40, weight: :bold
cs.white_box '14', 40, 30
cs.white_box '+2', 70, 30
cs.white_box '', 100, 30
cs.white_box '', 130, 30
cs.move_down 14
cs.black_box 'WIS', 0, 40, weight: :bold
cs.white_box '10', 40, 30
cs.white_box '0', 70, 30
cs.white_box '', 100, 30
cs.white_box '', 130, 30
cs.move_down 14
cs.black_box 'CHA', 0, 40, weight: :bold
cs.white_box '16', 40, 30
cs.white_box '+3', 70, 30
cs.white_box '', 100, 30
cs.white_box '', 130, 30

cs.render_file('cs.pdf')