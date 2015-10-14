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

        if active?(ele)
          conflicting = [ele]
          while(active?(ele = @queue.pop))
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

    def active?(ele)
      return false unless ele
      @poped.any? {|e| e.host == ele.host && !e.done?  }
    end

    def sort!
      @queue.sort! do |a,b|
        active_a = active?(a)
        active_b = active?(b)
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
