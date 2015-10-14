class Wbrute
  class Paths
    attr_reader :read, :size
    def initialize(size = "small")
      @size = ["small", "medium", "big"].find { |s| s == size } || "small"
      @read = 0
      @mutex = Mutex.new
    end

    def next
      dir = @mutex.synchronize { next_dir }
      return nil unless dir
      @read += 1
      dir
    end

    def next_dir
      begin
        line = file.readline
      end while ["#", nil].include?(line.strip[0])
      line.chomp
    rescue EOFError
      nil
    end

    def percent
      ((@read.to_f / length) * 100).round(2)
    end

    def remaining
      length - @read
    end

    def length
      @length ||= IO.read(file_path).each_line.reject{|l| ["#", nil].include?(l.strip[0]) }.length
    end

    def file_path
      @file_path ||= File.expand_path("../../../data/directory-list-2.3-#{@size}.txt", __FILE__)
    end

    def file
      @file ||= File.open(file_path, "r")
    end

    def close
      file.close
    end
  end
end
