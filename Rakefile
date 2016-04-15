task :recreate_readme do
  File.open('README.md', 'w+') do |md|
    md.puts "# dnd-scripts"
    md.puts "We're playing D&amp;D 3.5 through Roll20.net and we need some little helpers to manage all the stuff."
    md.puts

    Dir['*.rb'].sort.each do |script|
      version, desc = read_script_header(script)
      md.puts "== #{script} (v#{version})"
      desc.each do |line|
        md.puts line
      end
      md.puts
    end
  end
end

private
def read_script_header(file)
  version = '0.0.0'
  desc = []
  File.open(file, 'r') do |rb|
    until rb.eof?
      case rb.gets.chomp
      when /VERSION\s?=\s?['"](.*)['"]/
        version = $1
        break
      when /^\s*#(.*)/ then desc << $1
      end
    end
  end
  [version, desc]
end
