# Monkey Path
class String
  def remove_html_tag!
    self.gsub(/<[^>]*>/, '').gsub(/#[^>]*#/, '').gsub(/\[[^>]*\]/, '').gsub('@', '').gsub("\n", '')
  end
end

class Hash
  def to_url_params
    elements = []
    keys.size.times do |i|
      elements << "#{keys[i]}=#{URI.encode values[i].to_s.gsub('&', '%26')}"
    end
    elements.join('&')
  end

  def self.from_url_params(url_params)
    result = {}.with_indifferent_access
    url_params.split('&').each do |element|
      element = element.split('=')
      result[element[0]] = element[1]
    end
    result
  end
end

class Array
  def sum
    @sum = 0
    self.each do |i|
      @sum += i.to_i
    end
    @sum
  end
end