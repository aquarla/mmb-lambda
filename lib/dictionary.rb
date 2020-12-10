# coding: utf-8
require 'aws-sdk-s3'

class Dictionary
  def initialize(order=2)
    @order = order
    @dict = {}
    @start_words = []
    @s3 = Aws::S3::Resource.new(region: ENV['AWS_S3_REGION'] || 'ap-northeast-1')
    @s3_bucket = ENV['AWS_S3_BUCKET_NAME']
  end

  def save_model
    ['dict', 'start_words'].each do |key|
      filename = "#{key}"
      File.open("/tmp/#{filename}", 'w') do |f|
        f.write(Marshal.dump(instance_variable_get("@#{key}")))
      end
      obj = @s3.bucket(@s3_bucket).object(filename)
      obj.upload_file("/tmp/#{filename}")
    end
  end

  def load_model
    ['dict', 'start_words'].each do |key|
      filename = "#{key}"
      obj = @s3.bucket(@s3_bucket).object(filename)
      if obj.exists?
        instance_variable_set("@#{key}", Marshal.load(obj.get.body.read))
        @order = @start_words.first.count if key == 'start_words'
      end
    end
  end

  def add(sentence)
    natto = Natto::MeCab.new
    words = natto.enum_parse(sentence)
              .reject {|n| n.is_eos? }
              .map { |n| n.surface }
    start_word = words[0, @order]
    unless start_word.count < @order || @start_words.include?(start_word)
      @start_words << start_word
    end
   
    (words.count - @order).times do |n|
      (@dict[words[n, @order]] ||= []) << words[n+@order]
    end
  end

  def generate(max_size=100)
    current = @start_words.sample.dup
    sentence = current.join("")
    max_size.times do |n|
      break unless @dict[current]
      next_word = @dict[current].sample
      sentence += next_word
      current.shift
      current.append(next_word)
    end
    sentence
  end
end
