require 'ostruct'
require 'wbrute/input_file'
class Wbrute
  class Options < ::OpenStruct

    def initialize
      super
      @cli_options = []
      defoptions!
      parse_cli!
      self.targets = InputFile.parse_targets(ARGV)
      parse_input_file
      reconcile_targets!
      self.batch = self.targets.length unless self.batch
    end

    private

    def reconcile_targets!
      self.targets = self.targets.uniq do |t|
        uri = URI.parse(t)
        # FIXME targets with different base paths will be treated as the same target
        "#{uri.scheme}://#{uri.host}#{uri.port}"
      end
    end


    def parse_input_file
      return nil unless self.input

      input        = InputFile.new(self.input)

      self.targets = self.targets + input.targets

      # FIXME frontmatter options must use the long name of the option; support short version too
      input.front_matter.each do |name, value|
        # CLI options take precedence over input file front-matter options
        next if @cli_options.include?(name)
        self[name] = value
      end
    end

    def parse_cli!
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: wbrute [options] URL [URL ...]"

        opts.on("-i", "--input FILE", String, "File listing target URLs (one per line)") do |i|
          cli_option!(:input, i)
        end

        opts.on("-s", "--size S", String, "dictionary size: small, medium, big") do |s|
          cli_option!(:size, s)
        end

        # TODO support a user specified dictionary
        #  - need to update the Wbrute.paths
        #  - need to update the resume file format, or location

        opts.on("-t", "--threads T", Integer, "number of simultaneous connections to use") do |t|
          cli_option!(:threads, t)
        end

        opts.on("-b", "--batch B", Integer, "check maximum of B servers at once") do |b|
          cli_option!(:batch, b)
        end


        opts.on("-o", "--out File", String, "Write results to file") do |f|
          cli_option!(:out, f)
        end

        opts.on("-p", "--[no-]persist", "Persist HTTP connections") do |p|
          cli_option!(:persist, p)
        end

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          cli_option!(:verbose, v)
        end

      end

      parser.parse!
    end

    def cli_option!(name, val)
      self[name] = val
      @cli_options << name
      return self
    end

    def defoptions!
      defoptions.each { |k,v| self[k] = v }
    end

    def defoptions
      {
        threads: 1,
        targets: [],
        size: 'small',
        verbose: false,
        persist: false,
        out: nil,
        batch: nil,
        input: nil
      }
    end
  end
end
