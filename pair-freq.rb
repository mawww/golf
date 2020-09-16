require 'pp'
freqs = {}

Dir["*/cmd"].each do |d|
    keys = File.open(d, "r") {|f| f.read}
    keys.gsub!(/[\r\n]+/, "")
    keys.gsub!(/,q$/, "")
    last = nil
    keys.scan(/(?:<(?:[ca]-|)(?:ret|space|tab|lt|gt|backspace|esc|up|down|left|right|pageup|pagedown|home|end|backtab|del|.)>|.)/) do |key|
        if last
            freqs[last + key] ||= 0
            freqs[last + key] += 1
        end
        last = key
    end
end

pairs = []

freqs.each do |k, v|
    pairs += [[v, k]]
end
pairs.sort!
pairs.reverse!
pairs = pairs.reject do |n, k|
    n == 1
end

max_width = pairs.map{|n, k| k.size}.max

puts "       Keys       Freq "
puts "----------------- ---- "
pairs.each do |n, k|
    puts("%16s   %2d" % [k + (" " * ((max_width - k.size) / 2)), n])
end
