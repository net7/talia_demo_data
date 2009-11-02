#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'builder'
require 'pathname'

if(ARGV.size == 0 || ARGV.size > 2)
  puts "Usage: #{$0} <input_file> [output_file.xml]"
  exit(1)
end

def write_attribute(predicate, objects, force_value = false)
  predicate = predicate.gsub('#', ':')
  objects = [ objects ] unless(objects.is_a?(Array))
  @xml.attribute do
    @xml.predicate { @xml.text!(predicate) }
    objects.each do |object|
      if(object.include?(':') && !force_value)
        @xml.object { @xml.text!(object) }
      else
        @xml.value { @xml.text!(object) }
      end
    end
  end
end

def collect_data_items
  data_collection = {}
  Dir["#{File.dirname(ARGV.first)}/*"].each do |item|
    next unless(File.directory?(item))
    Dir["#{item}/*"].each do |file|
      next unless(File.file?(file))
      name_parts = File.basename(file).split('-')
      source_name = name_parts.first.split('.').first
      data_collection[source_name] ||= []
      data_collection[source_name] << file
    end
  end
  data_collection
end


data = YAML.load_file(ARGV.first)
out = (ARGV.size == 2) ? File.open(ARGV.last, 'w') : ''
root_path = Pathname.new(File.dirname(ARGV.first))

@xml = Builder::XmlMarkup.new(:target => out)
@files = collect_data_items

@xml.instruct!

@xml.sources do
  data.each do |name, element|
    @xml.source do
      write_attribute('uri', name, true)
      write_attribute('type', 'TaliaCore::Source', true)
      element.each do |predicate, objects|
        predicate = predicate.gsub('type', 'rdf:type')
        write_attribute(predicate, objects)
      end
      @files[name].each do |f| 
        f = Pathname.new(f).relative_path_from(root_path).to_s
        @xml.file { @xml.text!(f) } 
      end if(@files[name])
    end
  end
end


if(out.is_a?(String))
  puts out
else
  out.close
end