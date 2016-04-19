---
title: rundeck, chef, ridley, jenkins и вяско-разно для деплоя.
author: ctrlok
layout: post
date: 2014-01-08
dsq_thread_id:
  - 2101067090
categories:
  - Uncategorized

---
Привет.
  
Некоторое время назад я обзывал <a title="rundeck" href="http://rundeck.org" target="_blank">rudeck</a> плохими словами и некоторые из них, в частности обвинение в _глючности_, я готов взять обратно. На днях поставил его самостоятельно, последнюю версию (1.6.2) и он зафурычил с полпинка.
  
Так вот, сегодняшняя заметка будет посвещена **rundeck**, **ridley** и совсем немного **Jenkins**.
  
<!--more-->


  
Итак, допустим мы установили rundeck ( можно скачать пакет <a href="http://rundeck.org/downloads.html" target="_blank">тут</a>), запустили и хотим как-то впилить список нод. Желательно из Chef. Желательно с параметрами. И его можно закинуть на сервер в формате YAML (Когда наконец в opscode поймут что JSON &#8212; говно?!) или XML есть несколько способов &#8212; файл, каталог с файлами, скрипт и веб-страница. И для шефа уже существует плагин chef-rundeck, который запускат локальный веб-сервер и генерирует страничку, которую мы скармливаем в rundeck. Но у этого способа есть _фатальный недостаток_, к тому же в список не кастомизируется и я считаю _очень глупым_ имея базу данных в chef не использовать ее в rundeck. Поэтому я решил немного повозиться и использовать одну прикольную либу от создателей Berkshelf.

## Ridley

<a href="https://github.com/RiotGames/ridley" target="_blank">Ridley</a> — библиотека для работы с chef-сервером. Она удобна, быстра и дьявольски коварна, но лучше чем ничего. Естественно, она написана на ruby и для ruby. README файл на гитхабе описывает почти все, а о том, что не описывает и что я заметил &#8212; напишу сегодня. Для удобства парсинга аргументов я заюзал Trollop ( <a href="http://trollop.rubyforge.org" target="_blank">wiki</a> ) и надеюсь что все будет достаточно понятно. В итоге нам надо получить файл вида:

<pre lang="YAML">hostname: "ec2-10-00-00-01.compute-1.amazonaws.com"
  type: "Node"
  description: "node1.example.com"
  tags: 
    - base_server
      redis_server
      prod
  username: "rundeck-ssh"
  env: "prod"
</pre>

Итак, создадим скрипт.

<pre>#!/usr/bin/env ruby
require "ridley"
require "trollop"
require 'uri'

opts = Trollop::options do
  version "rchef-list 0.0.1 (c) 2013 Grammarly"
  banner &lt;&lt;-EOS
Test is an awesome program that does simple list of chef nodes for rundeck server.

Usage:
       rchef-list [options]
where [options] are:
EOS
  opt :server_url, "Enter chef server url. Example: https://api.opscode.com/organizations/ridley", :short =&gt; "s", :type =&gt; :string
  opt :client_name, "Chef client name", :short =&gt; "c", :type =&gt; :string
  opt :client_key, "Client key", :short =&gt; "k", :type =&gt; :string
end

Trollop::die "server_url are required" unless opts[:server_url]
Trollop::die "client_key are required" unless opts[:client_key]
Trollop::die "client_name are required" unless opts[:client_name]
Trollop::die :server_url, "must be vaid url" unless opts[:server_url] =~ URI::regexp
Trollop::die :client_key, "must exist" unless File.exist?(opts[:client_key]) if opts[:file]</pre>

И заставим его коннектиться к серверу:

<pre class="brush: ruby; gutter: false; first-line: 1; highlight: []; html-script: false">ridley = Ridley::new(
  server_url: opts[:server_url],
  client_name: opts[:client_name],
  client_key: opts[:client_key]
)</pre>

После чего мы получим вполне себе обьект, через которым мы сможем этим сервером управлять.

По-умолчанию, создатели рекомендуют нам для получения списка нод использовать `ridley.node.all`, но то ли это моя повышенная криворукость, то ли стремление создателей к высокой скорости, но обьекты которые я получил содержали в себе из полезной информации лишь имена нод. Это плохо, но расстраиваться не надо &#8212; есть другой способ. `nodes = ridley.search(:node)` — он _немного_ дольше, но результат устраивает и, получив обьект nodes, мы продолжим чудесное плаванье:

<pre>hash = Hash.new
nodes.each do |node|
  if node.name
    hash[node.name] = {}
    hash[node.name]["hostname"] = node.automatic.ec2 ?node.automatic.ec2.public_hostname : node.name
    hash[node.name]["type"] = "Node"
    hash[node.name]["description"] = node.name
    hash[node.name]["tags"] = "#{node.automatic.roles.join(",")},#{node.chef_environment}" unless node.automatic.roles.nil?
    hash[node.name]["username"] = "rundeck-ssh"
    hash[node.name]["env"] = node.chef_environment
  end
end
puts hash.to_yaml</pre>

_Самые умные_ уже успели догадаться что я создал хеш и наполнил его датой. Сделал я это для того, чтобы на выходе переобразовать все в YAML, так как именно его ест rundeck. Хочу обратить ваше внимание на необходимые поля &#8212; имя ноды (оглавление хеша), hostname &#8212; адрес сервера и username &#8212; имя юзера под которым вы будете к серверу подключаться. Все остальное — необязательные переменные, которые, впрочем, помогут вам взаимодествовать с сервером rundeck.

Стандартно rundeck парсит только nodename, hostname, username, description, tags, osFamily, osArch, osName, osVersion, editUrl, remoteUrl. И это оставляет меня в глубоком недоумении &#8212; о чем думали создатели, когда делали такой список? Почему нельзя парсить по самосозданным полям? Непонятно&#8230; И я **очень** надеюсь, что в версии 2.0, которая была анонсирована недавно, они это исправят.

Итак, воздуха для творчества немного, поэтому я запихнул все нужные мне поля — роли ноды и окружение — в теги.

Теперь второй прикол — теги в rundeck по-умолчанию перечисляются через запятую и не уточняют друг друга, а дополняют. И мне понадобилось минут тридцать, чтобы допереть использовать &#171;+&#187;, так как в документации нигде явно это не написано. В остальном rundeck достаточно прост.

И еще, как и обещал — есть некий <a href="https://wiki.jenkins-ci.org/display/JENKINS/RunDeck+Plugin" target="_blank">плагин рандека</a> для jenkins. Хочу отметить что он крутой и позволяет вытягивать список билдов и артифактов в опции rundeck. Настоятельно рекомендую ознакомиться.

В сухом остатке у нас получится веб страничка, зайдя на которую _кто-угодно_ может выкатить любой из билдов в любое окружение.
