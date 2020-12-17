# coding: utf-8
require 'json'
require 'net/https'
require 'sanitize'
require 'uri'

ENV['MECAB_PATH'] = '/var/task/mecab/lib/libmecab.so'
require 'natto'

require './lib/dictionary'
require './lib/mastodon_api'

def handler(event:, context:)
  mastodon = MastodonAPI.new({
                             domain: ENV['DOMAIN'],
                             read_access_token: ENV['READ_ACCESS_TOKEN'],
                             write_access_token: ENV['WRITE_ACCESS_TOKEN'],
                             })
  # Lambdaの起動間隔(秒)
  interval = ENV['INTERVAL'].to_i || 600

  # トゥート一覧取得
  account_info = mastodon.verify_credentials
  statuses = mastodon.account_statuses(account_info['id'])
  statuses.reject! {|s| Time.now.to_i - Time.parse(s['created_at']).to_i > interval }
  sentences = statuses.map do |s|
    s['content']
      .gsub(/<[^>]*?>/, '') # Remove HTML tag
      .gsub(/\n/, ' ') # Remove newlines
      .gsub(%r|https?://[\w_.%!*\?\=\/')(-]+|, '') # Remove URL
      .gsub(/@[\w\d_]+/, '') # Remove mentions
      .gsub(/(:[\w\d_]+:)/, '') # Remove custom emojis
      .gsub(/[#＃][Ａ-Ｚａ-ｚA-Za-z一-鿆0-9０-９ぁ-ヶｦ-ﾟー]+/, '') # Remove hashtag
  end
  
  # モデル生成
  dict = Dictionary.new
  dict.load_model
  sentences.each do |sentence|
    dict.add(sentence)
  end
  toot = dict.generate
  if sentences.count > 0
    dict.save_model
  end
  
  # 投稿
  mastodon.post_status(toot)

  { event: JSON.generate(event), context: JSON.generate(context.inspect) }
end
