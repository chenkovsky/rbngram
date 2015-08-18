__author__ = 'chenkovsky'
module Ngram
  def self.arpa(fp, gram: nil, header_start: nil, header_end: nil, section_start: nil, section_end: nil, file_end: nil)
      section = nil
      lm_info = {}
      max_gram = 0
      fp.each do |l|
        if l.start_with? "\\"
          if l == "\\data\\\n"
            section = 0
            STDERR.puts "loading header"
            if header_start and header_start.call() == false
                break
            end
          elsif l == "\\end\\\n"
            if file_end
              file_end.call(lm_info)
              break
            end
          else
            if l =~ /\\(\d+)-grams/
              section = $1.to_i
              STDERR.puts "loading #{section}-grams"
            end
            if section_start and section_start.call(lm_info,section) == false
                break
            end
          end
          next
        elsif l == "\n"
          if section == 0 and header_end and header_end.call(lm_info)== false
              break
          elsif section and section > 0 and section_end and section_end.call(lm_info,section) == false
              break
          end
          section = nil
          next
        elsif section == 0
          if l =~ /^ngram (\d+)=(\d+)/
            lm_info[$1.to_i] = $2.to_i
            STDERR.puts "ngram #{$1}=#{$2}"
          end
          max_gram = [max_gram, $1.to_i].max
        else
          larr = l.strip.split("\t")
          bow = nil
          if larr.length == 3
              bow = larr[-1].to_f
          elsif larr.length < 2
              next
          end
          if bow.nil?
            bow = 0
          end
          prob = larr[0].to_f
          words = larr[1].split(" ")
          if gram and gram.call(lm_info, section, words, prob, bow) == false
              break
          end
        end
      end
  end

  def self.arpa_all fp
    res = {bow: {}, prob: {}}
    arpa fp, ->(lm_info, section, words, prob, bow){res[:prob][words] = prob;if bow != 0 then res[:bow][words] = bow end}
    return res
  end
end