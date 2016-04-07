---
title: Системы роутинга нотификаций. OpsGenie vs PagerDuty vs VictorOps
author: ctrlok
layout: post
date: 2014-10-26
categories:
  - мониторинг

---
# Когда деревья были молодыми

Давным-давно, когда деревья были молодыми, мы мониторили все-подряд. Мы делали алерты на все, что приходило в наши головы и получали тонны писем, которые просматривали каждое утро и в течении дня. Мы настраивали нотификации в jabber и icq. Самые продвинутые прикручивали SMS шлюзы или вообще Asterisk. Золотое было время.

Сейчас все по-другому. Сейчас, когда все ушло в Web, когда пользователям нужен доступ 24х7, мы вынуждены подчиниться этой странной гонке. Когда серверов больше 100 уже не хочется просыпаться от каждого CPU спайка. Когда серверов больше 300, а сервисов больше 10 появляется желание как-то разрулить нотификации между разными людьми, а не исполнять ночью роль звонилки, вызванивая конкретную группу инженеров. В общем, хватит воды, оформим самые важные требования.

# Самые важные требования

Система должна звонить, отправлять смс, иметь мобильное приложение, уметь в зависимости от группы или еще чего-то отправлять сообщение нужному человеку, уметь строить расписания, уметь вебхуки как от себя, так и к себе, уметь интегрироваться с Hipchat иили Slack.

По этим нехитрым и базовым требованиям были отобраны аж целых три SaaS.

Почему SaaS? Да просто потому что в самой продвинутой opensouerce нотификалке [Flapcjack][1] нет даже минимальных правил роутинга. Это не серьезно.

Я использовал каждую из этих систем в течении месяца-двух на команде из 4-х опсов и ~20 девелоперах.

# [Pagerduty][2]

Отличное приложение, лидер рынка, все такое, хорошая мобильная апликуха. Но есть несколько но:

  * Нельзя объединять пользователей в группы, соответственно в расписаниях нельзя назначать группу. Поддержка порекомендовала мне создать отдельного (платного) пользователя, на которого уже повесить все телефоны членов команды.
  * Нет тегов, нет поиска по тегам.
  * 25 алертов (звонков и смс) в другие страны на базовом тарифе. Остальные по 35 центов за штуку.
  * Негибкий роутинг нотификаций.
  * Нельзя настроить политики личной нотификации глубже чем «сразу — почта и приложение, через _n_ минут смс, через _n_ минут звонок». Это неудобно.
  * Нельзя задавать алертам дополнительные поля.
  * Нет «тихих часов»

# [Victorops][3]

У этих ребят все очень модно и современно. Возможно, я просто не понял всех прелестей их плана. Собственно у них бесплатные нотификации по миру и серьезная интеграция с HipChat, которой они очень горядтся. Главная идея VictorOps крутится вокруг event stream, в который падают уведомления от сервисов и реакция людей на эти уведомления. То есть что-то вроде чата. Лучшее мобильное приложение. Еще мне понравилось, что в правилах эскалации можно задавать другие правила эскалации. Например, при срабатывании алерта оповестить команду Ops, если в течении 20 минут не будет никакой реакции — оповестить команду TechLeads. И в каждой команде все будет идти по-правилам, заранее написанным для каждой команды. Также как шаг исполнения можно вызвать вебхук. Кроме прочего очень прикольно, что можно дернуть следующего юзера в расписании. Или предыдущего.

Минусы:

  * Настройка расписаний немного странная и не всегда очевидна.
  * Исходящие вебхуки не передают всей информации, которая есть в алерте. Нет исходящих вебхуков на acknowledge.
  * Как и в pager duty — нет возможности настроить политики личных нотификаций в зависимости от каких-то внешних параметров.
  * Нет поиска.
  * Нет «тихих часов»

Как я уже писал выше — у victorops лучшее мобильное приложение из всех тех, что я видел. Еще их стоит похвалить за отличный саппорт, общение с которым одно удовольствие. Например, они обещали прикрутить Slack и отображение графиков в ближайших релизах (**UPD.** обещали 3 месяца назад, пока ничего не прикрутили) и прислали нам робота Ollie просто так, в качестве приветствия.

# [Opsgenie][4]

Сервис типа «мы-сделали-все-свистоперделки-какие-смогли-придмать». И это накладывает свой отпечаток на все. Например, интеграция с Slack — пример того, как надо делать интеграции: можно при помощи команд просматривать все алерты, акновледжить их, назначать на других людей. Одним словом — удобно. Также можно писать произвольные поля в алерты и использовать их в качестве фильтра. По всем этим полям можно настраивать любые политики как на глобальном уровне, так и локально у себя. Например, если я вдруг захочу чтобы все алерты, с тегом «business» будили меня в любое время дня и ночи, а все остальные просто приходили на телефон и email и при добавлении любой заметки или комментария в алерт исполнялся вебхук — я могу так настроить. Другое дело, что не всегда это все богатство надо. В отличии от VictorOps нет eventstream, только список алертов и глобальный лог файл. По каждому алерту можно посмотреть его локальный лог. И лично мне кажется, что в качестве eventstream намного удобнее использовать какой-то чат типа Slack. Еще у OpsGenie есть некий сервис автоматизации, к которому можно прикрутить действия типа «перезагрузить сервер» и которой сделает это прямо из алерта или согласно с политикой автоматизации и который также можно использовать в качестве proxy сервера для OpsGenie. Я его не использовал, поэтому не могу прокомментировать. Минусы:

  * Ужасное мобильное приложение. Древнее, как какашки мамонта и к тому же с поломанными push-нотификациями на iOS8.
  * Ужасный и медленный сайт (**UPD.** сайт обновили).
  * Нет бесплатных интернациональных звонков и смсок. Смс стоит 10 центов, а звонок — 35.
  * Много кнопок, сложно обучать других людей.

# Сравнительная таблица

<table cellspacing="0" cellpadding="0">
  <tr>
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;"><b>Фичи/Saas</b></span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;"><b>PagerDuty</b></span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;"><b>OpsGenie</b></span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;"><b>VictorOps</b></span>
    </td>
  </tr>
  
  <tr>
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;"><b>Интернациональыне звонки и смс на юзера в месяц</b></span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">25 или 100, остальные по 35 сентов</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">5 смс<span class="Apple-converted-space">  </span>и 2 звонка или 25 смс и 10 звонков, остальные по 10 и 35 центов соответственно</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Безлимит</span>
    </td>
  </tr>
  
  <tr>
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;"><b>Мобильное приложение</b></span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Неплохое</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Ужасное</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Суперское</span>
    </td>
  </tr>
  
  <tr>
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;"><b>Глобальные политики</b></span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Только роутинг</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Все что можно придумать</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Только роутинг</span>
    </td>
  </tr>
  
  <tr>
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;"><b>Локальные политики для каждого пользователя</b></span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Минимальные</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Все что можно придумать и даже больше</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Минимальные</span>
    </td>
  </tr>
  
  <tr>
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;"><b>Расписания</b></span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Неплохо, но нет групп</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Все что душе угодно</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Неплохо, но странная логика</span>
    </td>
  </tr>
  
  <tr>
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;"><b>Интеграция с внешними сервисами</b></span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Есть все</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Есть почти все</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Мало</span>
    </td>
  </tr>
  
  <tr>
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;"><b>Вебхуки</b></span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Вроде что-то есть.</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Супер</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Слабовато</span>
    </td>
  </tr>
  
  <tr>
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;"><b>Дополнительные поля у алерта</b></span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Нет</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Пиши что хочешь</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Пиши что хочешь</span>
    </td>
  </tr>
  
  <tr>
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;"><b>Вебсайт</b></span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Быстрый и красивый</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Нормальный</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Быстрый и красивый, но без поиска</span>
    </td>
  </tr>
  
  <tr>
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;"><b>Эскалации</b></span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Так себе</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Неплохо</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">Очень круто</span>
    </td>
  </tr>
  
  <tr>
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;"><b>Цена</b></span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">19$/39$</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">12$/16$</span>
    </td>
    
    <td valign="middle">
      <span style="color: #000000; font-family: Helvetica; font-size: small;">27,00 $</span>
    </td>
  </tr>
</table>

# Выводы

PagerDuty очень неплохая базовая система для тех, кто еще не вполне знает, зачем ему роутинг нотификаций. Также он должен подойти тем, у кого нет каких-то извращенных требований. Отличное мобильное приложение и приличный сайт.

VictorOps — некая смесь таксы с носорогом и чата с системой роутинга алертов. Это сто процентов будет удобно всем, кто не использует чаты типа Slack или HipChat.

OpsGenie — многорукий и многоногий монстр, которого будет не очень просто приручить, но который умеет вообще все.

 [1]: http://flapjack.io/ "flapjack"
 [2]: http://www.pagerduty.com
 [3]: https://victorops.com
 [4]: http://www.opsgenie.com
