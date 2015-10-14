require 'http'
require 'optparse'
require "thread"
require "wbrute/options"
require "wbrute/paths"
require "wbrute/engine"

class Wbrute
  class << self
    def options
      @@options ||= Options.new
    end

    def mutex
      @@mutex ||= Mutex.new
    end

    def report(target, path, code)
      if code <= 300 || code == 401
        puts "#{code}: #{target}#{path}"
      else
         debug "+#{code}: #{target}#{path}"
      end
    end

    def puts(msg)
      mutex.synchronize do
        $stdout.puts msg
        outfile && outfile.puts(msg)
      end
    end

    def info(msg)
      mutex.synchronize { $stderr.puts "--| #{msg}" }
    end

    def info_print(msg)
      mutex.synchronize { $stderr.print "--| #{msg}" }
    end

    def debug(msg)
      mutex.synchronize { $stderr.puts "--| #{msg}" } if options.verbose
    end

    def outfile
      return nil unless options.out
      @@outfile ||= File.open(options.out, "a").tap{|f| f.sync = true }
    end
  end
end
