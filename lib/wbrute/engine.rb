require "fileutils"
require 'securerandom'

class Wbrute
  class Engine
    attr_reader :target, :options, :paths, :host

    def initialize(target, options, paths)
      @target  = target
      @options = options
      @paths   = paths
      @host    = URI.parse(@target).host
      resume_pos.times { self.paths.next }
    end

    def go
      return if done?
      unless verified?
        Wbrute.puts "# Cannot verify #{target} is an HTTP server"
        return nil
      end
      go!
      self
    end

    def done?
      remaining <= 0
    end

    def remaining
      paths.remaining
    end

    def done
      paths.read
    end

    def length
      paths.length
    end

    def go!
      show_startup_info
      threads = options.threads.times.map do
        Thread.new do
          while dir = paths.next
            Wbrute.report(target, "/#{dir}", code(path(dir)))
          end
        end
      end

      save_periodic
      threads.map(&:join)
    ensure
      paths && paths.close
    end

    def path(dir)
      options.persist ? "/#{dir}/" : "#{target}/#{dir}/"
    end

    def http
      @http ||= options.persist ? HTTP.persistent(target) : HTTP
    end

    def code(path)
      http.get(path).tap do |r|
        true while r.body.readpartial
      end.code
    end

    def show_startup_info
      Wbrute.info "Checking #{target} for #{paths.length} directories\n" +
                  "  Using #{paths.file_path} dictionary"
      Wbrute.info "  Resuming from #{resume_pos}" if resume_pos > 0
    end

    def save_periodic
      Thread.new do
        begin
          save_resume_data
          sleep 5
        end while paths.remaining > 0
        save_resume_data
      end
    end

    def verified?
      return @verified if instance_variable_defined?(:@verified)
      @verfied = verify!
    end

    def verify!
      @verified = (!!HTTP.get(target) rescue false) &&
        code(path(SecureRandom.hex(16))) == 404
    end

    def resume_file_dir
      File.dirname(resume_file_path)
    end

    def resume_file_path
      fs_friendly_target = (target.gsub(/[\/:?&=]+/, ".") + ".resume").gsub(/\.\.+/, ".")
      File.expand_path("~/.wbrute/#{fs_friendly_target}")
    end

    def save_resume_data
      return unless done > resume_pos
      FileUtils.mkdir_p(resume_file_dir) unless File.exists?(resume_file_dir)
      File.open(resume_file_path, "w") {|io| io.write(done) }
    end

    def resume_pos
      return @pos if @pos
      @pos = 0
      if File.exists?(resume_file_path)
        File.open(resume_file_path) {|io| @pos = io.readline.strip.to_i }
      end
      @pos
    end
  end
end
