---
title: Ansible 1.3
author: ctrlok
layout: post
date: 2013-09-20
dsq_thread_id:
  - 1789049219
categories:
  - ansible
tags:
  - ansible
  - updates

---
Совсем недавно ребята из ansibleworks обновили ansible до версии 1.3
  
В этом посте я постараюсь описать обновления и разобраться зачем они нужны.
  
Список нововведений:

  * Accelerated Mode
  * role dependencies
  * role defaults
  * Local Facts (Facts.d)
  * changed_when
  * always_run
  * экстра переменные из файлов

<!--more-->

## Accelerated Mode

[Accelerated Mode][1] &#8212; если говорить коротко, то при выборе такого типа подключения ansible на хостах стартует демон поверх ssh, который слушает мир 30 минут. Типа старого фаербола, но быстрее.

## role dependencies

[Совсем недавно ребята из ansibleworks обновили ansible до версии 1.3
  
В этом посте я постараюсь описать обновления и разобраться зачем они нужны.
  
Список нововведений:

  * Accelerated Mode
  * role dependencies
  * role defaults
  * Local Facts (Facts.d)
  * changed_when
  * always_run
  * экстра переменные из файлов

<!--more-->

## Accelerated Mode

[Accelerated Mode][1] &#8212; если говорить коротко, то при выборе такого типа подключения ansible на хостах стартует демон поверх ssh, который слушает мир 30 минут. Типа старого фаербола, но быстрее.

## role dependencies

][2] &#8212; очень мощная фигня, включение ролей в роли с передаваемыми переменными.
  
Теперь внутри роли можно использовать конструкции типа:

<pre class="brush: bash; gutter: false; first-line: 1; highlight: []; html-script: false">dependencies:
  - { role: hand, echotext: "hand1" }
  - { role: hand, echotext: "hand2" }</pre>

Таким образом применяя какую-либо роль мы можем сразу назначить другие роли на выполнение.
  
Например нам надо на группу серверов GROUP2 всегда устанавливать сислог-нг, nginx, php-fpm и collectd + выполнить какие-то действия. Весь этот софт связан между собой. Если раньше нам надо было либо назначать эти роли в основном плейбуке и в темплейтах рулить группами, либо в инвентори файлах включать хосты группы GROUP2 в группы nginx, collectd, syslog и т.п., а в самих связанных ролях уже обрабатывать `{% if inventory_hostname in groups['nginx'] %}`, то сейчас все стало намноооого проще:

  1. Создаем роль GROUP2
  2. Создаем файл ./roles/GROUP2/meta/main.yml
  3. Пишем в него: <pre class="brush: bash; gutter: false; first-line: 1; highlight: []; html-script: false">dependencies:
  - { role: syslog-ng, include_nginx: true } 
  - { role: nginx, istheresyslog: true, phpfpm: true }
  - { role: collectd, nginx: true, phpfpm: true }</pre>
    
    Тут мы сделали:
    
      1. запускаем роль syslog, которая проверяет include_nginx &#8212; если он true, то создает пайпы для nginx
      2. запускам роль nginx, которая устанавливает nginx и если установлен syslog &#8212; вместо файлов для логов использует пайпы, также ставит phpfpm если есть такая переменная.
      3. ставим collectd, кроме обычных проверок добавляем чек для nginx и phpfpm
  4. После этого можем со спокойной душей запускать плейбук и наблюдать :) Очередь выполнения будет такой: 
      1. роль сислога &#8212; его таски
      2. роль nginx &#8212; его таски
      3. роль collectd &#8212; его таски
      4. таски роли GROUP2

Это очень удобно не только для деплоя серверов, но и для всяких разворачиваний продукта. Мы можем разбить любой деплой на куски и выполнять их много-много раз с разными параметрами в зависимости от контекста.

## role defaults

[role defaults][3] &#8212; еще одна долгожданная фича. Если раньше мы должны были пользоваться group_vars или назначать переменные прямо в плейбуке, то сейчас достаточно создать файл `roles/rolename/defaults/main.yml` и дело в шляпе. Намного удобнее и читаемее. К тому же такие переменные будут иметь самый низкий приоритет из всех доступных.

## Остальное

[Local Facts (Facts.d)][4] &#8212; создание локальных фактов, которые будут показываться в ansible -m setup. Я пока особого применения не вижу даже в команде кроме как создания факта ansible_local.user.signature и вшитие его в все конфиги для того чтобы более наглядно показывать кто последний деплоил конфиг.
  
[changed_when][5] &#8212; удобная штука для модуля shell с помощью которой можно сделать выполнение шела зеленым, в зависимости от exit статуса команды. Но у меня почему-то не получилось заставить его работать, если программа завершается с ошибкой и пишет в stderr.
  
[always_run][6] &#8212; позволяет запускать команды даже если мы запустили плейбук только для чека ( ansible-playbook -C&#187; ) Может быть удобно для выполнения каких-то подготовок.

Также начиная с версии 1.3 внешние переменные во время выполнения плейбука можно подгружать из файла в YAML или JSON формате. Это круто, если вы используете внешние файлы переменных. Вот так: `--extra-vars "@some_file.json"`

 [1]: http://ansibleworks.com/docs/playbooks2.html#accelerated-mode
 [2]: http://ansibleworks.com/docs/playbooks.html#role-dependencies
 [3]: http://ansibleworks.com/docs/playbooks.html#id11
 [4]: http://www.ansibleworks.com/docs/playbooks2.html#local-facts-facts-d
 [5]: http://www.ansibleworks.com/docs/playbooks2.html#overriding-changed-result
 [6]: http://www.ansibleworks.com/docs/playbooks2.html#running-a-task-in-check-mode
