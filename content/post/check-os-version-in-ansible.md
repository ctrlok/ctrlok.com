---
title: Проверяем версию ОС в Ansible
author: ctrlok
layout: post
date: 2013-08-05
dsq_thread_id:
  - 1792455641
categories:
  - ansible
tags:
  - ansible
  - маленькие трюки

---
Определить версию ОС в ansible достаточно просто. Это есть в общем мане. Но такой информации чаще всего недостаточно. Например у нас есть две разные версии дебиана &#8212; 6 и 7. Сейчас это стандартная ситуация для многих компаний.

Конечно, многие скажут что есть фактер и будут правы. Но для того чтобы верно скопировать список сорцов на этапе первого конфигурирования системы он не подходит. Да и зачем он нужен, если можно обойтись стандартными средствами ansible?

Заходим в наш темплейтик под jinja2 и добавляем в начало или куда угодно.

{{< highlight go "style=friendly" >}}
{% if ansible_distribution_version|truncate(1, True, "")|int== 6%}
  {% set release = "squeeze"%}
{% elif ansible_distribution_version|truncate(1, True, "")|int== 7%}
  {% set release = "wheezy"%}
{% endif %}
{{< /highlight >}}

В данном скрипте я беру переменную ansible\_distribution\_version, обрезаю ее до 1 знака(это и будет мажорная версия релиза), после чего насильственным путем меняю ее на  integer и результат сравниваю с числом. Если нам нужна более детальная информация можно использовать резанье до трех символов и преобразование в float.

Теперь у нас есть переменная release, в которую сохранено имя релиза. Так что теперь можно использовать подобные конструкции:

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">deb http://ftp.nl.debian.org/debian/ {{ release }} main
deb-src http://ftp.nl.debian.org/debian/ {{ release }} main</pre>
