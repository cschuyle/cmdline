require 'rubygems'
require 'id3lib'

@albums = {}

def album_for dir, album
  return if album.nil?
  return if album.to_s == ''
  @albums[dir][album] = 1
end

source_dir=ARGV[0]
Dir.glob(source_dir+"/**/*.{mp3,wma,m4a}") do |file|
  dir = File.dirname file
#  puts "dir name for #{file} is #{dir}"
  @albums[dir] ||= {}
  tag = ID3Lib::Tag.new(file)
  album_for(dir, tag.album)
end
@albums.each_pair do |dir, album_names|
  num_albums = album_names.keys.size()
#  puts "dir #{dir} has #{num_albums} album names"
  if(num_albums != 1)
    puts "#{dir} has these album names:"
    album_names.keys.each do |album_name|
      puts "    #{album_name}"
    end
  end
end
