---
title: check_mk и nagios, история успеха. Часть первая, обзорная.
author: ctrlok
layout: post
date: 2013-09-22
dsq_thread_id:
  - 1788807639
categories:
  - мониторинг
tags:
  - check_mk
  - nagios
  - мониторинг

---
На моем новом месте работы вместо любимого мной  check_mk и nagios будет zabbix, так уж сложилось. Поэтому я постараюсь сделать то, что откладывал долгими зимними вечерами, а именно &#8212; напишу пост о этой чудесной штуке.

[Check_mk][1] &#8212; это надстройка над nagios. Если говорить грубо &#8212; серверная часть генерит конфиги для нагиоса, а клиентская &#8212; плагин, который висит на порту 6556 через, ну например, xinetd и отдает статистику по машине.

Установка check_mk тривиальна и описана тут. На выходе мы получим для каждой машины чек процессора, рама, свободного места и кучу других чеков. Подробнее можно прочитать тут. Самое вкусное что это пасивный чек &#8212; никто не ломится на сервер, сервер сам подключается к хостам и вытягивает инфу в текстовом виде. <!--more-->

# Конфиги.

Чек меня привлекает check\_mk, так это простотой. Самым первым читается файл /etc/check\_mk/main.mk, после него читаются все \*.mk файлы из основной директории, потом все \*.mk файлы из директории /etc/check_mk/conf.d/

Список хостов обычно ставят в самое начало файла main.mk, чтобы не запутаться:

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">all_hosts=[
...
&#039;MyWebServer|WebServers|Hypervisor9|deb|PROD&#039;,
&#039;MyWebServer2|WebServers|Hypervisor9|deb|TEST&#039;,
...
]</pre>

Итак, мы добавили в мониторинг хост MyWebServer с тегами WebServers, Hypervisor9, PROD и deb и хост MyWebServer2 с тегами WebServers, Hypervisor9, TEST и deb. При помощи тегов мы сможем творить различные непотребства (а именно: назначение проверок, хостгрупп, управление проверками и т.п.) гораздо эффективнее.
  
Теперь нужно провести инвентаризацию хоста и задеплоить конфиги на нагиос:

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">cmk -II MyWebServer #Инициализируем
cmk -O MyWebServer #Деплоим</pre>

К примеру, давайте создадим хостгруппу:

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">host_groups = [
...
("PRODUCTION WEBSERVERS", ["PROD","WebServers"], ALL_HOSTS),
("OTHER WEBSERVERS", ["!PROD","WebServers"], ALL_HOSTS),
...
]</pre>

Наше первое поле &#8212; название группы, второе &#8212; теги по которым мы собираем хосты в эту группу. Третее &#8212; выборка из всех хостов. То есть в первом поле мы взяли все хосты, проверили их на теги и если обнаружили в тегах &#171;PROD&#187; и &#171;WebServers&#187; &#8212; добавили их в хост группу &#171;PRODUCTION WEBSERVERS&#187;. Аналогично мы поступили и для хост группы &#171;OTHER WEBSERVERS&#187;, с той лиш разницей, что включили в нее все хосты, которые имеют тег &#171;WebServers&#187;, но точно не имеют тег &#171;PROD&#187;. Об явном исключении говорит нам знак восклицания перед тегом.
  
Зачем еще нужны теги? Ну&#8230; много для чего.
  
Например на основе тегов можно сделать красивую картинку в веб морде мониторинга с логотипом ОС.

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">extra_host_conf["icon_image"] = [
...
  ( "base/little_debian.png", ["deb"], ALL_HOSTS ),
...
]</pre>

А вообще на оф. сайте есть табличка:

<table>
  <tr>
    <th>
      Config variable
    </th>
    
    <th>
      Item field
    </th>
    
    <th>
      Service list
    </th>
    
    <th>
      Meaning
    </th>
  </tr>
  
  <tr>
    <td class="tt">
      host_groups
    </td>
    
    <td>
      all
    </td>
    
    <td>
      <i>missing</i>
    </td>
    
    <td>
      Mapping of hosts to Nagios host groups
    </td>
  </tr>
  
  <tr>
    <td class="tt">
      host_contactgroups
    </td>
    
    <td>
      all
    </td>
    
    <td>
      <i>missing</i>
    </td>
    
    <td>
      Mapping of hosts to Nagios contact groups
    </td>
  </tr>
  
  <tr>
    <td class="tt">
      parents
    </td>
    
    <td>
      all
    </td>
    
    <td>
    </td>
    
    <td>
      Definition of hosts&#8217; <a class="quer" href="checkmk_parents.html">parents</a> for Nagios
    </td>
  </tr>
  
  <tr>
    <td class="tt">
      service_groups
    </td>
    
    <td>
      all
    </td>
    
    <td>
    </td>
    
    <td>
      <tt>servicegroups</tt> definitions for services
    </td>
  </tr>
  
  <tr>
    <td class="tt">
      service_contactgroups
    </td>
    
    <td>
      all
    </td>
    
    <td>
    </td>
    
    <td>
      Assigning services to contact groups
    </td>
  </tr>
  
  <tr>
    <td class="tt">
      summary_host_groups
    </td>
    
    <td>
      all
    </td>
    
    <td>
      <i>missing</i>
    </td>
    
    <td>
      Host groups for <a class="quer" href="checkmk_aggregation.html">summary hosts</a>
    </td>
  </tr>
  
  <tr>
    <td class="tt">
      summary_service_groups
    </td>
    
    <td>
      all
    </td>
    
    <td>
    </td>
    
    <td>
      Service groups for aggregated services
    </td>
  </tr>
  
  <tr>
    <td class="tt">
      summary_service_contactgroups
    </td>
    
    <td>
      all
    </td>
    
    <td>
    </td>
    
    <td>
      Contact groups for aggregated services
    </td>
  </tr>
  
  <tr>
    <td class="tt">
      service_aggregations
    </td>
    
    <td>
      all
    </td>
    
    <td>
    </td>
    
    <td>
      Definition of services to be aggregated
    </td>
  </tr>
  
  <tr>
    <td class="tt">
      non_aggregated_hosts
    </td>
    
    <td>
      <i>missing</i>
    </td>
    
    <td>
      <i>missing</i>
    </td>
    
    <td>
      Hosts that are generally excluded from <a class="quer" href="checkmk_aggregation.html">service aggregation</a>
    </td>
  </tr>
  
  <tr>
    <td class="tt">
      service_dependencies
    </td>
    
    <td>
      all
    </td>
    
    <td>
    </td>
    
    <td>
      Definition of <a class="quer" href="checkmk_service_dependencies.html">Service Dependencies</a>
    </td>
  </tr>
  
  <tr>
    <td class="tt">
      datasource_programs
    </td>
    
    <td>
      first
    </td>
    
    <td>
      <i>missing</i>
    </td>
    
    <td>
      <a class="quer" href="checkmk_datasource_programs.html">Programs to call</a> instead of TCP port 6556
    </td>
  </tr>
  
  <tr>
    <td class="tt">
      snmp_hosts
    </td>
    
    <td>
      <i>missing</i>
    </td>
    
    <td>
      <i>missing</i>
    </td>
    
    <td>
      Host which can be contacted only via <a class="quer" href="checkmk_snmp.html">SNMP</a>
    </td>
  </tr>
  
  <tr>
    <td class="tt">
      bulkwalk_hosts
    </td>
    
    <td>
      <i>missing</i>
    </td>
    
    <td>
      <i>missing</i>
    </td>
    
    <td>
      Hosts that support <a class="quer" href="checkmk_snmp.html">SNMP</a> bulk walk
    </td>
  </tr>
  
  <tr>
    <td class="tt">
      clustered_services
    </td>
    
    <td>
      <i>missing</i>
    </td>
    
    <td>
    </td>
    
    <td>
      Services assumed to be only available on active <a class="quer" href="checkmk_clusters.html">cluster node</a>
    </td>
  </tr>
  
  <tr>
    <td class="tt">
      only_hosts
    </td>
    
    <td>
      <i>missing</i>
    </td>
    
    <td>
      <i>missing</i>
    </td>
    
    <td>
      Limit check_mk to certain hosts (usefull for testing)
    </td>
  </tr>
</table>

Но давайте сделаем что-то интересное, например начнем на всех вебсерверах мониторить количество процессов apache2 и nginx.

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">checks += [
...
( [&#039;WebServers&#039;], [&#039;@all&#039;], "ps.perf", "nginx", ( "~.*nginx.*", 1, 1, 80, 100 ) ), 
( [&#039;WebServers&#039;], [&#039;@all&#039;], "ps.perf", "apache", ( "~.*(apache|httpd).*", 1, 1, 80, 100 ) ), 
...
]</pre>

Тут мы добавили дополнительную проверку для всех (@all) хостов, у которых есть тег &#171;WebServers&#187;, которая заключается в вызове ps.perf (расширенный вывод команды ps) и поиске внутри ее по регулярному выражению &#171;.\*nginx.\*&#187;. Регулярные выражения в check\_mk по определению начинаются с &#8216;~&#8217;. Проверку мы назвали nginx (или apache), но полное ее имя будет proc\_nginx или proc_apache. Также мы назначили пределы срабатывания &#8212; если процессов от 1 до 80 &#8212; это ОК, если от 80 до 100 &#8212; это Warning, если больше 100 &#8212; это CRITICAL.

Если нам нужно добавить какую-то проверку на конкретный хост &#8212; вместо тега и всех хостов мы пишем имя хоста. Вот так:

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">( "WebServer", "ps.perf", "nginx", ( "~.*nginx.*", 1, 1, 80, 100 ) ),</pre>

Хочу заметить, что данный ход конем не переназначает проверку выставленную по тегу, но добавляет новую.
  
Чтобы переназначить проверку надо использовать `check_parameters`.

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">check_parameters += [
...
( ("~.*nginx.*", 4, 4, 120, 200), [&#039;WebServer2&#039;], ["ps.perf"] ),
...
]</pre>

А некоторые встроенные чеки можно переназначать напрямую:

<pre class="brush: actionscript3; gutter: true; first-line: 1; highlight: []; html-script: false">postfix_mailq_default_levels = (10000, 50000)
</pre>

А вот так можно игнорировать чеки на хостах или группах:

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">ignored_checks += [
...
        ( "mysql.innodb_io", [ "MyISAM-DB" ]), 
...
]</pre>

Теперь давайте обновим конфигурацию nagios:

<pre class="brush: bash; gutter: true; first-line: 1; highlight: []; html-script: false">cmk -II WebServers
cmk -O WebServers</pre>

Как вы могли заметить &#8212; тут мы использовали инициализацию по тегу &#8212; так намного удобнее.
  
Кстати, `cmk -II` можно выполнить и без тега, и без хоста &#8212; тогда переинициализация произойдет для всех хостов. Но это долго, нудно, а если прервать в середине &#8212; еще и вредно, так как хосты окажутся без проверок.

> Обратите внимание &#8212; я почти везде использую &#8216;+=&#8217; для того чтобы добавить, а не переопределить, как делает просто &#8216;=&#8217;. Один раз увлекательнейшим образом потратил пол часа вылавливая проблему, а оказалось &#8212; косяк напарника, который использовал &#8216;=&#8217; где-то в конце.

Про дополнительные чеки, их виды, сервис группы и контакт группы мы поговорим в следующем номере.

# К изучению:

> http://mathias-kettner.com/checkmk_hosttags.html &#8212; теги и все что с ними связано
  
> http://mathias-kettner.com/checkmk_configvars.html &#8212; переменные конфигов
  
> http://mathias-kettner.de/checkmk_checks.html &#8212; типы чеков и их значение для перенастройки.

 [1]: http://mathias-kettner.com/
