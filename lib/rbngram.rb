require "rbngram/version"
require 'ffi'
require 'ffi-compiler/loader'

module Rbngram
  extend FFI::Library
  ffi_lib File.expand_path("../../ext/ngram.bundle", __FILE__) #FFI::Compiler::Loader.find('ngram')

  # example function which takes no parameters and returns long
  attach_function :Ngram_init_from_bin, [:pointer], :pointer
  attach_function :Ngram_prob2, [:pointer, :pointer, :uint], :uint
  attach_function :Ngram_bow2, [:pointer, :pointer, :uint], :uint
  attach_function :Ngram_free, [:pointer], :void

  attach_function :NgramBuilder_init, [:pointer, :uint], :pointer
  attach_function :NgramBuilder_free, [:pointer], :void
  attach_function :NgramBuilder_add_word, [:pointer, :string, :uint, :uint], :uint
  attach_function :NgramBuilder_add_ngram2, [:pointer, :pointer, :uint, :uint, :uint], :uint
  attach_function :NgramBuilder_save, [:pointer, :string], :int
end

module Ngram
  class NgramBuilder
    def initialize gram_nums
      STDERR.puts "========================="
      STDERR.puts gram_nums
      STDERR.puts "========================="
      arr = FFI::MemoryPointer.new(:uint64, gram_nums.length)
      arr.put_array_of_int64(0, gram_nums)
      @builder = Rbngram::NgramBuilder_init(arr, gram_nums.length)
      ObjectSpace.define_finalizer(self,
                                   proc do
                                        arr = FFI::MemoryPointer.new(:pointer, 1)
                                        arr.put_pointer(0, @builder)
                                        Rbngram::NgramBuilder_free(arr)
                                   end
      )
    end

    def add_word word, prob, bow
      return Rbngram::NgramBuilder_add_word(@builder, word, prob, bow)
    end
    def add_ngram words, prob, bow
      arr = FFI::MemoryPointer.new(:pointer, words.length)
      arr.put_array_of_pointer(0, words.map{|x|  FFI::MemoryPointer.from_string(x)})
      return Rbngram::NgramBuilder_add_ngram2(@builder, arr, words.length, prob, bow)
    end

    def save path
      return Rbngram::NgramBuilder_save(@builder, path)
    end
  end

  class Ngram
    def initialize path
      content = File.open(path,"rb").read
      @content = FFI::MemoryPointer.from_string(content)
      #@content.put_bytes(0, content)
      @model = Rbngram::Ngram_init_from_bin(@content)
      ObjectSpace.define_finalizer(self,
                                   proc do
                                     arr = FFI::MemoryPointer.new(:pointer, 1)
                                     arr.put_pointer(0, @model)
                                     Rbngram::Ngram_free(arr)
                                   end
      )
    end

    def prob words
      arr = FFI::MemoryPointer.new(:pointer, words.length)
      arr.put_array_of_pointer(0, words.map{|x|  FFI::MemoryPointer.from_string(x)})
      return Rbngram::Ngram_prob2 @model, arr, words.length
    end

    def bow words
      arr = FFI::MemoryPointer.new(:pointer, words.length)
      arr.put_array_of_pointer(0, words.map{|x|  FFI::MemoryPointer.from_string(x)})
      return Rbngram::Ngram_bow2 @model, arr, words.length
    end
  end
end

