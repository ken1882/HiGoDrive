module DataManager
  mattr_reader :initialized
  @initialized = false
  def self.initialize
    @initialized = true
  end
end
