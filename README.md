git-search.rb
====================================

利用方法
-----------------------------------

# 取得と実行
```
git clone https://github.com/cyousemi/git_search.git
cd git_search.git
ruby git-search.rb
```
# 興味のある検索ワードの指定方法
以下を編集します。yml型で登録していきます。
```
vim wordlist.yml 
```
# gitで検索したくないwordリスト
以下を編集します。yml型で登録していきます。
```
vim ignor_wordlist.yml 
```
# キャッシュの扱いについて
* GITの認証なしの検索は１分に５回までなので、一度取得したものは、cacheに貯める仕組みになっています。
* cacheを削除したい場合は、削除したいcacheを削除してください。
```
rm cache/検索した際の文字.yml
```
※findコマンド等利用すれば、何日前は削除する等簡単にできます。(すみません・・今のところ手動でよろしくお願いいたします。
