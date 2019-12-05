module ActionController
  class Parameters
    def compact
      self.reject{|k,v| !v}
    end

    def compact!
      self.reject!{|k,v| !v}
    end
    
    def first; self[self.keys.first]; end
    def last; self[self.keys.last]; end
  end
end