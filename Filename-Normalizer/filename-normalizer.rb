require 'rubygems'
require 'thread'
require 'active_support'
require 'find'

class String
  def normalize(normalization_form=ActiveSupport::Multibyte.default_normalization_form)
    ActiveSupport::Multibyte::Chars.new(self).normalize(normalization_form)
  end

  def deaccent
    self.normalize(:kd).gsub(/[^,.!+='"\sa-zA-Z0-9_\-\(\){}\[\];\&\#$%\^\*@]/,'')
  end
end

def recurse_tree(root_dir)
  Find.find root_dir do |path|
    dir = File.dirname path
    old_path = File.basename path
    new_path = old_path.to_s.deaccent
    if old_path != new_path
      begin
        puts "#{dir}/#{new_path}"
        File.rename path, "#{dir}/#{new_path}"
      rescue => err
        puts "Caught #{err.to_s} for #{path.to_s}"
      end
    end
  end
end

recurse_tree ARGV[0]
