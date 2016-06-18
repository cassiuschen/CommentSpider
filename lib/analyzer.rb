require 'classifier-reborn'

class TextAnalyzer
  class << self
    def count(array)
      checker = ClassifierReborn::Bayes.new('result','junk')
      result = checker.train("result", array.concat("\n"))
      return result.map {|k,v| {k.to_s.force_encoding('utf-8') => v}}
    end
  end
end