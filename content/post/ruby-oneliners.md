---
title: 'Новые встречи.  Ruby oneliners'
author: ctrlok
layout: post
date: 2014-01-07
dsq_thread_id:
  - 2098802456
categories:
  - Uncategorized

---
Всем привет. Возможно я немного изменю формат моего блога, потому что текущий настолько скучный, что я ощущаю невозможным его писать. Поэтому не удивляйтесь если увидите какие-то личные вещи. Но это все еще остается блог о системном администрировании и я считаю его полезным.

Итак, сегодня я буду себя позорить &#8212; _ruby oneliners_. Это такие штуки, которые я непростительно для себя упускал долгие годы своего системного администрирования.
  
Я даже выучил жуткий и ужасный **awk** только потому что в _той книге по Ruby_ не бьыло главы про однострочники. ~~Или я очень невнимательный читатель.~~

Итак, для того чтобы запустить код надо вызвать `ruby -e`. Давайте для примера вообразим что нам надо подключиться на 10 серверов `nginx{1..10}.example.com` и выполнить там `service nginx reload`.

<pre class="brush: bash; gutter: false; first-line: 1; highlight: []; html-script: false"># Сначала сделаем читаемо для других:
ruby -e &#039;for i in 1..10 do `ssh nginx#{i}.example.com service nginx reload`; end&#039;
# Или запишем это в ruby стиле:
ruby -e &#039;(1..10).select{|i| `ssh nginx#{i}.example.com service nginx reload`&#039;</pre>

`ruby -e` автоматически не парсит stdin и это немного не прикольно. Создать список можно было и тупым `echo {1..10}` в баше. Меня **дико бесит** перловский синтаксис у регекспов и приверженность ему у большинства unix комманд. Ну что за урод придумал эти `[:digit:]`?
  
<!--more-->


  
Для того чтобы читать stdin удобно в однострочном ruby есть специальный ключ `-n` который помещает каждую строку входного потока в переменную `$_`

Давайте представим что нам _очень важно_ в выводе apache _что-то_ найти и у нас нет какого-то анализатора логов и все надо _прямо сейчас_. Примеры логов апача я взял [тут][1]. Пример:

<pre class="brush: bash; gutter: false; first-line: 1; highlight: []; html-script: false">~ tail access_log

10.0.0.153 - - [12/Mar/2004:12:23:41 -0800] "GET /dccstats/stats-hashes.1week.png HTTP/1.1" 200 1670
10.0.0.153 - - [12/Mar/2004:12:23:41 -0800] "GET /dccstats/stats-spam.1month.png HTTP/1.1" 200 2651
10.0.0.153 - - [12/Mar/2004:12:23:41 -0800] "GET /dccstats/stats-spam-ratio.1month.png HTTP/1.1" 200 2023
10.0.0.153 - - [12/Mar/2004:12:23:41 -0800] "GET /dccstats/stats-hashes.1month.png HTTP/1.1" 200 1636
10.0.0.153 - - [12/Mar/2004:12:23:41 -0800] "GET /dccstats/stats-spam.1year.png HTTP/1.1" 200 2262
10.0.0.153 - - [12/Mar/2004:12:23:41 -0800] "GET /dccstats/stats-spam-ratio.1year.png HTTP/1.1" 200 1906
10.0.0.153 - - [12/Mar/2004:12:23:41 -0800] "GET /dccstats/stats-hashes.1year.png HTTP/1.1" 200 1582
216.139.185.45 - - [12/Mar/2004:13:04:01 -0800] "GET /mailman/listinfo/webber HTTP/1.1" 200 6051
pd95f99f2.dip.t-dialin.net - - [12/Mar/2004:13:18:57 -0800] "GET /razor.html HTTP/1.1" 200 2869
d97082.upc-d.chello.nl - - [12/Mar/2004:13:25:45 -0800] "GET /SpamAssassin.html HTTP/1.1" 200 7368</pre>

Теперь распарсим. Давайте не будем перегибать палку и думать о чем-то сложном.

<pre class="brush: bash; gutter: false; first-line: 1; highlight: []; html-script: false">~ tail access_log | ruby -ne &#039;m = $_.match(/(S+)s-s-s[([^]]+)]s"([A-Z]+)s(S+)s([^"]+)"s(d+)s(d+)/); puts "addr: #{m[1]}, date: #{m[2]}, type: #{m[3]}, link: #{m[4]}, response: #{m[6]}"&#039;

addr: 10.0.0.153, date: 12/Mar/2004:12:23:41 -0800, type: GET, link: /dccstats/stats-hashes.1week.png, response: 200
addr: 10.0.0.153, date: 12/Mar/2004:12:23:41 -0800, type: GET, link: /dccstats/stats-spam.1month.png, response: 200
addr: 10.0.0.153, date: 12/Mar/2004:12:23:41 -0800, type: GET, link: /dccstats/stats-spam-ratio.1month.png, response: 200
addr: 10.0.0.153, date: 12/Mar/2004:12:23:41 -0800, type: GET, link: /dccstats/stats-hashes.1month.png, response: 200
addr: 10.0.0.153, date: 12/Mar/2004:12:23:41 -0800, type: GET, link: /dccstats/stats-spam.1year.png, response: 200
addr: 10.0.0.153, date: 12/Mar/2004:12:23:41 -0800, type: GET, link: /dccstats/stats-spam-ratio.1year.png, response: 200
addr: 10.0.0.153, date: 12/Mar/2004:12:23:41 -0800, type: GET, link: /dccstats/stats-hashes.1year.png, response: 200
addr: 216.139.185.45, date: 12/Mar/2004:13:04:01 -0800, type: GET, link: /mailman/listinfo/webber, response: 200
addr: pd95f99f2.dip.t-dialin.net, date: 12/Mar/2004:13:18:57 -0800, type: GET, link: /razor.html, response: 200
addr: d97082.upc-d.chello.nl, date: 12/Mar/2004:13:25:45 -0800, type: GET, link: /SpamAssassin.html, response: 200</pre>

Я затейлил лог и через пайп передал все на вход в ruby. Там я использовал переменную `$_`, которая означает каждую строку stdin и сматчил ее на регулярное выражение, которое _очень примерно_ подходит к нашему случаю и вывел все на экран. На самом деле это больше демонстрация, реальные задачи будут выглядеть немного проще и зависить от контекста. Лучше всего парсить и группировать только то, что надо на самом деле. Это **выгоднее**. Пример вывода всех ip, которые делали `GET /dccstats/stats-hashes.1year.png` за 12 марта.

<pre class="brush: bash; gutter: false; first-line: 1; highlight: []; html-script: false">~ tail access_log | ruby -ne &#039;m = $_.match(/(S+)s-s-s[([^]]+)]s"([A-Z]+)s(S+)s/); puts m[1] if m[2].match(/12/Mar/) && m[3].match("GET") && m[4].match("/dccstats/stats-hashes.1year.png")&#039;

10.0.0.153</pre>

То есть, чтобы достичь успеха и не тратить время попусту мы забиваем большой винт на именовынные группы и все остальное и матчим только то, что нам действительно надо. И в конкретном случае уместнее был бы обычный греп. Или ключ `-p`, ведь если ruby запущен с этим ключем он выводит строку или комманду, если все ок :)

<pre class="brush: bash; gutter: false; first-line: 1; highlight: []; html-script: false">~tail  access_log| ruby -pe &#039;gsub(/^.*$/, "buzz") unless $_ =~ /(S+)s-s-s[12/Mar[^]]+]s"GETs/dccstats/stats-hashes.1year.pngs/&#039;
buzz
buzz
buzz
buzz
buzz
buzz
10.0.0.153 - - [12/Mar/2004:12:23:41 -0800] "GET /dccstats/stats-hashes.1year.png HTTP/1.1" 200 1582
buzz
buzz
buzz
</pre>

Ну или можно использовать ruby как замену грепу:

<pre class="brush: bash; gutter: false; first-line: 1; highlight: []; html-script: false">~ ls -al | ruby -pe &#039;next unless $_.match(/drwxr/)&#039;


drwxr-xr-x   24 root       wheel        816 Oct 23 09:30 .
drwxr-xr-x@   6 root       wheel        204 Oct 23 09:30 ..
drwxr-xr-x    8 daemon     wheel        272 Oct 23 09:18 at
drwxr-xr-x   64 root       wheel       2176 Jan  7 23:47 db
drwxr-xr-x    2 root       sys           68 Aug 25 03:16 empty
drwxr-xr-x    4 root       wheel        136 Oct 23 09:45 folders
drwxr-x---    2 _jabber    _jabber       68 Aug 25 03:16 jabberd
drwxr-xr-x    3 root       wheel        102 Aug 25 08:30 lib
drwxr-xr-x   66 root       wheel       2244 Jan  8 00:01 log
drwxrwxr-x    2 root       mail          68 Aug 25 03:16 mail
drwxr-xr-x    3 root       wheel        102 Oct 23 09:18 msgs
drwxr-xr-x    2 root       wheel         68 Aug 25 03:16 netboot
drwxr-xr-x    2 _networkd  _networkd     68 Aug 25 03:16 networkd
drwxr-x---    6 root       wheel        204 Oct 23 09:36 root
drwxr-xr-x    4 root       wheel        136 Aug 25 06:08 rpc
drwxrwxr-x   29 root       daemon       986 Jan  7 23:12 run
drwxr-xr-x    2 daemon     wheel         68 Aug 25 03:16 rwho
drwxr-xr-x    7 root       wheel        238 Oct 23 09:27 spool
drwxrwxrwt    5 root       wheel        170 Jan  8 00:03 tmp
drwxr-xr-x    6 root       wheel        204 Jan  7 17:34 vm
drwxr-xr-x    4 root       wheel        136 Oct 23 09:40 yp</pre>

Ну или еще что-то. На самом деле все примеры выдуманные и больше придуманы для того чтобы как-то илюстрировать однострочники и конкретно эти задачи намного проще решаются использованием стандартных grep, awk, sed, uniq и такого прочего. Надеюсь было понятно. Ну и я немного порылся в гугле _вместо вас_ и рекомендую глянуть на [reference.jumpingmonkey.org/programming_languages/ruby/ruby-one-liners.html)][2]
  
Надеюсь было весело.

 [1]: http://www.monitorware.com/en/logsamples/apache.php
 [2]: http://reference.jumpingmonkey.org/programming_languages/ruby/ruby-one-liners.html
