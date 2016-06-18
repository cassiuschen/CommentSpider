require 'classifier-reborn'

class TextAnalyzer
  class << self
    def count(array)
      checker = ClassifierReborn::Bayes.new('result','drop')
      result = checker.train("result", array.join("\n"))
      return result.map {|k,v| {k.to_s.force_encoding('utf-8') => v}}
    end
  end
end

class JunkAnalyzer
  attr_reader :classifier
  def initialize
    @classifier = ClassifierReborn::Bayes.new 'Good', 'Junk'
    @classifier.train_good(IO.read('./training/good').gsub("\n", ''))
    @classifier.train_junk(IO.read('./training/junk').gsub("\n", ''))
    return @classifier
  end
end