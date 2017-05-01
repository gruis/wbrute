require 'yaml'
class Wbrute
  class InputFile
    class << self
      def parse_targets(list)
        @targets = list.select {|i| i[0..3] == "http" }
          .map{|t| t[-1] == "/" ? t[0...-1] : t}
      end
    end

    attr_reader :front_matter, :targets, :path

    def initialize(path)
      @path         = path
      @targets      = []
      @front_matter = {}
      parse(path)
    end

    private

    def parse(path)
      lines = IO.read(path).each_line.map(&:chomp)
      if (fmatter_start = lines.index("---")) && (fmatter_stop = lines[fmatter_start + 1 .. -1].index("---"))
        fmatter_stop += fmatter_start + 1
        parse_fmatter(lines[fmatter_start ... fmatter_stop].join("\n") + "\n")
        targets = lines[fmatter_stop + 1 .. -1]
      else
        targets = lines
      end
      @targets = self.class.parse_targets(targets)
    end

    def parse_fmatter(txt)
      @front_matter = YAML.load(txt)
      if @front_matter[:out]
        @front_matter[:out] = File.expand_path(@front_matter[:out])
      end
    end
  end
end
