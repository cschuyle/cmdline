require 'rubygems'
require 'id3lib'

COMMIT = false
if ARGV[0] == '--commit'
  ARGV.shift
  COMMIT = true 
end

TAGS = %w(album title track artist genre year composer publisher band interpreted_by grouping part_of_set conductor encoded_by).map {|a| a.to_sym}
RAW_TAGS = %w(TIT2 TPE1 TALB TYER TCON TRCK TCOM TPUB PRIV MCDI APIC TPE2 TPE4 TPE3 TPOS COMM GEOB USLT UFID TLEN).map {|a| a.to_sym}
 puts RAW_TAGS.inspect 

class Id3Copier

  def initialize(file, other_file = nil)
    @file = file
    @other_file = other_file
  end
    
  def process
    tag = ID3Lib::Tag.new(@file)
    other_tag = nil
    if(@other_file.nil?)
      output "SOURCE", tag
    else
      other_tag = ID3Lib::Tag.new(@other_file) 
      TAGS.each do |method|
        reset_if_necessary tag, other_tag, method
      end
      tag.each do |frame|
        add_other_frame_if_necessary frame, other_tag
      end
    end
    detail_output "SOURCE", tag
    return other_tag
  end

  def output(name, tag)
    TAGS.each do |method|
      puts "#{name} #{method}: #{tag.send method}"
    end
  end

  def detail_output(name, tag)
    tag.each do |tag_item|
      puts "#{name} tag item: #{tag_item.inspect}" if ! RAW_TAGS.include? tag_item[:id]
    end
  end

  def add_other_frame_if_necessary source_frame, other_tag
    if( source_frame.has_value?(:TLEN) && ! has_frame_for(other_tag, :TLEN)) 
      puts "Put TLEN frame #{source_frame.inspect} on target tag"
      other_tag << source_frame
    end
  end

  def has_frame_for(tag, id) 
    tag.each do |frame|
      return true if frame.has_value? id
    end  
    return false
  end

  def reset_if_necessary(source, target, method)
    source_val = source.send method
    target_val = target.send method

    if(target_val.to_s == '' && source_val.to_s != '')
      puts "  RESET: #{@clean_file}: #{method} resetting '#{target_val}' to '#{source_val}'"
      target.send "#{method}=", source_val
      @changed = true
    elsif(source_val.to_s != target_val.to_s)
      puts "  NOT RESETTING but not equal: #{@clean_file}: #{method} source='#{source_val}' target='#{target_val}'"
    else
      puts "  NO ACTION for #{@clean_file}.#{method}: source='#{target_val}' target='#{target_val}'" if target_val.to_s != source_val.to_s && (target_val.to_s != '' || source_val.to_s != '')
    end
  
    def changed?
      @changed ? true : false
    end
  end

end

source_dir = ARGV[0]
target_dir = ARGV[1]
Dir.glob(source_dir+"/**/*.{mp3,wma,m4a}") do |f|
  puts "SOURCE FILE  #{f}"
  @clean_file = f.sub(source_dir+"/",'')
  if(target_dir.nil?)
    copier = Id3Copier.new(f)
    copier.process
    next
  end
  other_file = "#{target_dir}/#{@clean_file}"
  other_file.sub! /\.(wma|mp3|m4a)$/, ".mp3" # All targets are assumed mp3
  puts "TARGET FILE #{other_file}"
  if(! File.exists?(other_file)) 
    puts "(no such TARGET FILE, but tag info follows)"
    copier = Id3Copier.new(f)
    copier.process
  else
    copier = Id3Copier.new(f, other_file)
    other_tag = copier.process
    if COMMIT && copier.changed?
      other_tag.update! 
      puts "UPDATED"
    end
  end
end