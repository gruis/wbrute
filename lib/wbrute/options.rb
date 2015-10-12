require 'ostruct'
class Wbrute
  class Options < ::OpenStruct

    def initialize
      super
      defoptions!

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: wbrute [options] URL [URL ...]"

        opts.on("-s", "--size S", String, "dictionary size: small, medium, big") do |s|
          self.size = s
        end

        opts.on("-t", "--threads T", Integer, "number of simultaneous connections to use") do |t|
          self.threads = t
        end

        opts.on("-o", "--out File", String, "Write results to file") do |f|
          self.outfile = f
        end

        opts.on("-p", "--[no-]persistence", "Persist HTTP connections") do |v|
          self.persist = v
        end

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          self.verbose = v
        end

      end

      parser.parse!
      self.targets = ARGV.select {|a| a[0..3] == "http" }
        .map{|t| t[-1] == "/" ? t[0...-1] : t}
    end

    def defoptions!
      self.threads = 1
      self.targets = []
      self.size    = "small"
      self.verbose = false
      self.persist = false
      self.outfile = nil
    end
  end
end
