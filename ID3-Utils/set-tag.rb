require 'rubygems'
require 'id3lib'

should_commit = false
if ARGV[0] == '--commit'
  should_commit = true
  ARGV.shift
end
  
dir, tag, value = ARGV
tag = tag.to_sym
dir = dir.sub /\/$/, ''

puts "setting files in #{dir}, #{tag}='#{value}'"

Dir.glob("#{dir}/*.{mp3,wma,m4a}") do |f|
  this_tag = ID3Lib::Tag.new(f)
  current_value = this_tag.send tag
  puts "setting #{f}.#{tag} from '#{current_value}' to '#{value}'"
  this_tag.send "#{tag}=".to_sym, value
  if should_commit
    this_tag.update! 
    puts "UPDATED"
  else
    puts %Q(Changes not saved. "#{$0} --commit '#{ARGV.join("' '")}'" if you wanted to actually update the files on disk)
  end
end
