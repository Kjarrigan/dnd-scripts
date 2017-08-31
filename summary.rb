class ChangelogParser
  def initialize
    @levels = []
    @attributes = Hash.new(0)
    @feats = []
    @spells = {}
    @skills = Hash.new(0)
  end

  def to_s
    validate
    instance_variables.each do |var|
      print var, ': '
      val = instance_variable_get(var)
      case val
      when Array
        puts val.sort.inspect
      when Hash
        puts
        val.sort{|(k1,_),(k2,_)| k1 <=> k2 }.each do |k,v|
          puts " - #{k}: #{v.is_a?(Array) ? v.sort : v}"
        end
      else
        puts val.inspect
      end
    end
  end

  def parse(fo)
    until fo.eof?
      line = fo.gets.chomp

      case line
      when /^Lv. (\d+)/
        @levels << $1
        debug "Parsing Lv. #{$1}"

      # int based attributes
      when /^- (HP|BaseAttack|FortSave|WillSave|RefSave)/
        att = "@"+underscore($1)
        debug "Parsing att: #{att}"
        instance_variable_set(att, (instance_variable_get(att) || 0) + line.scan(/\+[0-9]+/).map(&:to_i).inject(&:+))
      when /- Attribute: (\w+)\+(\d+)/
        @attributes[$1] += $2.to_i
      when /- New Spell: (\w.*) \(Lv. (\d)\)/
        lvl = "Lv. #{$2}"
        @spells[lvl] ||= []
        @spells[lvl] << $1
      when /- Change Spell: (\w.*) \(Lv. (\d)\) -> (\w.*) \(Lv. (\d)\)/
        if $2 != $4
          warn "You can't swap Spells of different levels: #{$2} <> #{$4}"
        else
          lvl = "Lv. #{$2}"
          @spells[lvl] ||= []
          @spells[lvl] << $3
          @spells['-'+lvl] ||= []
          @spells['-'+lvl] << $1
        end
      when /- Feat: (.*)/
        @feats << $1
      when /- Skills (.*):(.*)/
        points = eval($1)
        debug "Points: #{points}"

        $2.split(',').each do |subset|
          subset =~ /\+(\d)\s\((cc|cs)\)\s(.*)/
          ranks = $1.to_i
          type = $2
          debug subset, ranks, type, $3
          $3.split('/').each do |skill|
            @skills[skill.strip + " (#{type})"] += ranks
            points -= ranks * (type == 'cc' ? 2 : 1)
            warn("Too many points spent! #{points} - #{line}") if points < 0
          end
        end
        warn("Not all points spent! #{points} #{line}") if points > 0
      when /- (Spells(\/Day|Known))/
        att = "@"+underscore($1).gsub('/', '_')
        debug "Parsing att: #{att}"

        line.scan(/(0|\+\d+)/).flatten.each_with_index do |spells, lvl|
          lvl = "Lv. #{lvl}"
          instance_variable_set(att, Hash.new(0) ) if instance_variable_get(att).nil?
          instance_variable_get(att)[lvl] = instance_variable_get(att)[lvl] + spells.to_i
        end
      when /^#/
        next
      else
        warn "SKIPPED LINE: #{line}" unless line.empty?
      end
    end
  end

  def validate
    if (@levels.min..@levels.max).to_a != @levels.sort
      warn "Levels missing! You don't have to start at Lv. 1 but there should be no gaps!"
      warn "#{(@levels.min..@levels.max).to_a} <> #{@levels}"
    end

    @spells.sort.each do |lvl,list|
      next if lvl =~ /^-/
      if @spells.has_key?('-'+lvl)
        @spells['-'+lvl].each do |forgotten_spell|
          debug "Forgot: #{list.delete(forgotten_spell)}"
        end
      end
    end

    @spells_known.each do |lvl, max|
      warn "Too much lvl #{lvl} spells! (should be #{max} but is #{@spells[lvl].size})" if @spells[lvl].size < max
      warn "Too less lvl #{lvl} spells! (should be #{max} but is #{@spells[lvl].size})" if @spells[lvl].size < max
    end

    @points = 0
    @skills.each do |skill,rank|
      cap = @levels.max.to_i + 3
      cap /= 2 if skill =~ /\(cc\)/
      warn("#{skill} exceeds level cap #{cap}") if rank > cap
      @points += rank * (skill =~ /\(cc\)/ ? 2 : 1)
    end
  end

  private
  def underscore(camel_cased_word)
    word = camel_cased_word.to_s.gsub("::".freeze, "/".freeze)
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2'.freeze)
    word.gsub!(/([a-z\d])([A-Z])/, '\1_\2'.freeze)
    word.tr!("-".freeze, "_".freeze)
    word.downcase!
    word
  end

  def debug(*msg)
    puts *msg if ENV['DEBUG']
  end

  def warn(msg)
    ENV['DEBUG'] ? puts(msg) : raise(msg)
  end
end

if __FILE__ == $PROGRAM_NAME
  f = ChangelogParser.new
  f.parse(File.new('changelog.dat'))
  puts f
end