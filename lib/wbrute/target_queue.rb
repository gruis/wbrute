class Wbrute
  class TargetQueue
    def initialize(targets = [])
      @mutex = Mutex.new
      @poped = []
      @queue = []
      targets.each { |t| @queue << t }
      sort!
    end

    def size
      @mutex.synchronize { @queue.size }
    end

    def empty?
      size == 0
    end

    def pop
      @mutex.synchronize do
        sort!

        ele = @queue.pop

        if active_host?(ele)
          conflicting = [ele]
          while(active_host?(ele = @queue.pop))
            conflicting << ele
          end
          conflicting.each { |c| @queue.unshift(c) }
        end

        @poped << ele if ele
        ele # can be nil
      end
    end

    def <<(ele)
      @mutex.synchronize { @queue << ele }
    end


    private

    def active_host?(ele)
      return false unless ele
      Wbrute.options.batch_per_server <= active_for_host(ele.host)
    end

    def active_for_host(host)
      @poped.select {|e| e.host == host && !e.done?  }.length
    end

    def sort!
      @queue.sort! do |a,b|
        active_a = active_host?(a)
        active_b = active_host?(b)
        if active_a && active_b
          0
        elsif active_a
          -1
        elsif active_b
          1
        else
          b.remaining <=> a.remaining
        end
      end
    end
  end
end
