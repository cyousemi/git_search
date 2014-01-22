#!/usr/bin/env ruby

require "xmlrpc/client"
require 'net/http'
require "yaml"
require "json"

# wordlist.ymlから検索したい文字列一覧を取得
s = File.read("wordlist.yml")
wordlist = YAML::load(s);

#無視すべきword一覧
s = File.read("ignor_wordlist.yml")
ignor_wordlist = YAML::load(s);

# はてなから関連するワードを取得
server = XMLRPC::Client.new("d.hatena.ne.jp", "/xmlrpc")
server.http_header_extra = {'accept-encoding' => 'identity'} 
result = server.call("hatena.getSimilarWord", 
    wordlist
)

# 関連するワードについて、Githubからリポジトリを検索
result["wordlist"].each{|word|
    print word["word"],"\n"   
    word = word["word"];
    # 無視するべきwordかどうか
    is_ignor = ignor_wordlist["wordlist"].include?(word)

    if is_ignor
        #無視するべきwordなら、次へ
        next;
    end

    uri_word = URI.encode(word);
    url = "https://api.github.com/search/repositories?q="+uri_word+"&sort=stars&order=desc";
    begin
        #cacheファイルがあるかどうか調べる
        cache_file = "cache/"+word+".yml"
        has_cache = File.exist?(cache_file)

        if has_cache
            #cacheファイルがある場合は、cacheから取得する
            s = File.read(cache_file)
            data = YAML::load(s);
        else
            #HTTP上から取得する
            data = Net::HTTP.get_response(URI.parse(url)).body
            #Jsonを解析する
            data = JSON.parse(data) 
            # cache fileとして、一度取得したワードは保存
            File.binwrite(cache_file,data.to_yaml);
            #認証なしだと1分に5回までなのでsleep
            sleep(12)
       end
       if data["total_count"]==0
           #0件の場合次へ
           next
       end
       #それぞれのItemを取得する
       data["items"].each{|item|
            puts item["html_url"]+"\n" 
       }

    rescue Exception => ex
        #エラーが発生した場合
       puts ex
    end
}

