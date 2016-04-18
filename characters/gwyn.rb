require_relative '../backend'

class Gwyn < Backend::Character
  include Backend::Race::Human
  include Backend::Klass::Sorcerer

  level 3
  desc :name, 'Gwyneth Llywleyn'
  desc :age, 18
  desc :gender, 'Female'
  desc :parents, 'Dillion & Guinevere'
  desc :place_of_birth, 'Otternburg'
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
