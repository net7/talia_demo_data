# Quick script to download exported xml files from NietzscheSource for testing

require 'rexml/document'
require 'open-uri'

puts "Usage downloader.rb <list_file> [output_path (default .)]" unless(ARGV[0])
@output_path = ARGV[1]
@output_path ||= "."


def grab_siglum(siglum)
  enc_siglum = siglum.gsub(/\[/, "%5B")
  enc_siglum = enc_siglum.gsub(/\]/, "%5D")
  begin
    open("http://localhost:3000/sources/#{enc_siglum}.rdf") do |io|
      open(File.join(@output_path, "#{siglum}.rdf"), "w") do |file|
        file << io.read
      end
    end
  rescue Exception => e
    puts "Error reading #{siglum}: #{e}"
  end
end

open(ARGV[0]) do |file|
  file.each_line do |line|
    line.strip!
    unless(line == "" || line.include?(":") || line.include?(" "))
      puts "fetching #{line}"
      grab_siglum(line)
    end
  end
end
