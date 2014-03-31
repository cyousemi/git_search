#!/usr/bin/env ruby
#
#This source is MIT License 
#
require "xmlrpc/client"
require 'net/http'
require "yaml"
require "json"


#GIT hubから指定した文字列に対する人気リポジトリを洗い出す。
#@param  word 検索する文字列
#@param  ignor_wordlista 無視するワードリスト
#@param  count 何番目か 
#return int APIへリクエストした数
def search_in_git(word, ignor_wordlist, count)
    api_request =0
    # 無視するべきwordかどうか
    is_ignor = ignor_wordlist.include?(word)

    if is_ignor
        #無視するべきwordなら、次へ
        return api_request;
    end
    if count % 5 == 0 && count !=0
        sleep(60); #1分に５回までなので 5回目の区切りで、待ちを入れる
    end
    print "Check Word: "+word+"\n"   

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
            api_request = 1
        end
       if data["total_count"]==0
           #0件の場合次へ
           return api_request
       end
       #それぞれのItemを取得する
       data["items"].each{|item|
            puts item["html_url"]+"\n" 
       }

    rescue Exception => ex
        #エラーが発生した場合
       puts ex
    end
    return api_request
end

############MAIN LOGIC###############################################

# wordlist.ymlから検索したい文字列一覧を取得
s = File.read("wordlist.yml")
wordlist = YAML::load(s);

#無視すべきword一覧
s = File.read("ignor_wordlist.yml")
ignor_wordlist = YAML::load(s);

count = 0

#指定したワード自体で、Githubリポジトリを検索
wordlist["wordlist"].each{|word|
    count = count + search_in_git(word,ignor_wordlist["wordlist"], count)
}

# はてなから関連するワードを取得
server = XMLRPC::Client.new("d.hatena.ne.jp", "/xmlrpc")
server.http_header_extra = {'accept-encoding' => 'identity'} 
result = server.call("hatena.getSimilarWord", 
    wordlist
)

# 関連するワードについて、Githubからリポジトリを検索
result["wordlist"].each{|word|
    word = word["word"];
    count = count + search_in_git(word,ignor_wordlist["wordlist"], count)
}

