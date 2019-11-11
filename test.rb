require 'benchmark'
require 'ostruct'

REP = 100000

User = Struct.new(:name, :age)

USER = "User".freeze
AGE = 21
HASH = {:name => USER, :age => AGE}.freeze


class Hash
  def to_bool; self.to_a.to_bool; end
  def to_struct
    return OpenStruct.new(self)
  end
end

Benchmark.bm 20 do |x|
  x.report 'OpenStruct slow' do
    REP.times do |index|
       OpenStruct.new(:name => "User", :age => 21)
    end
  end

  x.report 'OpenStruct fast' do
    REP.times do |index|
       OpenStruct.new(HASH)
    end
  end

  x.report 'Struct slow' do
    REP.times do |index|
       User.new("User", 21)
    end
  end

  x.report 'Struct fast' do
    REP.times do |index|
       User.new(USER, AGE)
    end
  end

  x.report 'Hash to struct' do
    REP.times do |index|
      HASH.to_struct
   end
  end
end