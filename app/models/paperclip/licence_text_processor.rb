require 'nokogiri'
module Paperclip
  class LicenceTextProcessor < Processor
    def make
      @file.rewind
      dest = Tempfile.new "#{File.basename(@file.path)}.converted.#{@options[:format]}"
      case @options[:format]
        when 'txt'
          dest << Nokogiri::HTML(@file.read).text
        when 'html'
          dest << Nokogiri::HTML(@file.read).serialize
        else
          dest.binmode
          dest << @file.read
      end
      dest.flush
      dest
    end
  end
end