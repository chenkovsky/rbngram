#!/usr/bin/env ruby
require "docopt"
require "rbngram"
require "rbngram/arpa"
doc = <<DOCOPT
convert language model to binary format
Usage:
  #{File.basename(__FILE__)} <dst> <src>
DOCOPT

args = Docopt::docopt(doc)
@builder = nil
gram = ->(lm_info, section, words, prob, bow){
  prob = (prob*-1000000).to_i
  bow = (bow*-1000000).to_i
  if words.length == 1
    @builder.add_word words[0], prob, bow
  else
    @builder.add_ngram words, prob, bow
  end
}

init_builder = ->(lm_info) {
  arr = lm_info.sort_by{|k,v| k}.map{|k,v| v}
  @builder = Ngram::NgramBuilder.new (arr)
}
if args["<src>"] == "-"
  input = STDIN
else
  require 'zlib'
  input = Zlib::GzipReader.open(args["<src>"])
end
Ngram::arpa(input, gram: gram, header_end: init_builder)

if not @builder.nil?
  @builder.save args["<dst>"]
end

if args["<src>"] != "-"
  input.close
end
