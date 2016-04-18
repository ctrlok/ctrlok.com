---
title: 'Трюки: Как сделать таск зависимым от хеша который присвоен переменной?'
author: ctrlok
layout: post
date: 2013-08-09
dsq_thread_id:
  - 1788809739
categories:
  - ansible
tags:
  - ansible
  - маленькие трюки

---
Например у нас есть роль nginx, которая копирует конфиги серверов в зависимости от значения переменной. Типа так:

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">nginx_config_list:
  - {ip: &#039;127.0.0.1&#039;, domain: &#039;exemple.com&#039;}
  - {ip: &#039;127.0.0.2&#039;, domain: &#039;exemple2.com&#039;}</pre>

Как видно выше &#8212; это конфиг для двух сайтов &#8212; есть переменная nginx, внутри которой находятся два хеша &#8212; собственно конфиги сайтов. Тогда мы можем запустить копирование конфига стандартными методами:

<!--more-->

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">- name: Coping nginx config for sites
  template: src=nginx.j2 dest=/etc/nginx/conf.d/{{ item.domain }}.conf
  with_items:
    - $nginx_config_list
  notify:
    - restart nginx</pre>

Теперь сделаем задачу более повседневной &#8212; на одном из сайтов нам надо развернуть ssl, а второй оставить как есть. И это достаточно нетривиальная задача, так как стандартная проверка _when_set _хочет странного и проверяет внутри хеша только **(!)** при синтаксисе **${}**. То есть стандартные {{}} и $ &#8212; не работают. Это было для меня удивительным открытием и я великолепно потратил пол часа пытаюсь понять почему оно не заводится.

В любом случае итоговый синтаксис на проверку будет выглядеть подобным образом:

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">- name: Coping ssl-nginx config for sites
  template: src=nginx.j2 dest=/etc/nginx/conf.d/ssl-{{ item.domain }}.conf
  with_items:
    - $nginx_config_list
  when_set: ${item.ssl}
  notify:
    - restart nginx</pre>

А в хеш можно смело добавлять переменную ssl:

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">nginx_config_list:
- {ip: &#039;127.0.0.1&#039;, domain: &#039;exemple.com&#039;, ssl: &#039;yes&#039;}
- {ip: &#039;127.0.0.2&#039;, domain: &#039;exemple2.com&#039;}</pre>

И небольшой лайфхак в завершение &#8212; чтобы не писать два отдельных конфига под обычный nginx и nginx-ssl можно воспользоваться встроенной возможностью ansible регистрировать переменные во время выполнения тасков.

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">- name: Coping nginx config for sites
  template: src=nginx.j2 dest=/etc/nginx/conf.d/{{ item.domain }}.conf
  register: ssl_check # вот тут мы регистрируем переменную
  with_items:
    - $nginx_config_list
  notify:
    - restart nginx
- name: Coping ssl-nginx config for sites
  template: src=nginx.j2 dest=/etc/nginx/conf.d/ssl-{{ item.domain }}.conf
  with_items:
    - $nginx_config_list
  when_set: ${item.ssl}
  notify:
    - restart nginx
</pre>

А в шаблоне nginx.j2 теперь можно добавить проверку ssl_check &#8212; которая будет активна только если копирование ssl конфига осуществляется после копирования обычного конфига:

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">{% if ssl_check %}
  {% set port = "443 ssl" %}
{% else %}
  {% set port = "80" %}
{% endif %}
{# config #}

server {
  listen {{ item.interface_ip }}:{{ port }};
  server_name {{ item.domain }};
{% if ssl_check %}
  ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers AES128-SHA:AES256-SHA:RC4-SHA:DES-CBC3-SHA:RC4-MD5;
  ssl_certificate /etc/nginx/cert/{{ item.domain }}.crt;
  ssl_certificate_key /etc/nginx/cert/{{ item.domain }}.key;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;
{% endif %}</pre>

В общем у нас есть один когфиг nginx, который превращается в конфиг nginx для ssl когда копируется вторым. При первом обходе переменная не активна и, естественно, строки выше опускаются.

Надеюсь кому-то эта заметка сможет сэкономить час-два времени.

P.S. WordPress почему-то сильно бьет по пробелам и табуляциям &#8212; но, думаю, все понятно и без них.

&nbsp;
