+++
title = "Chatops и будущее"
date = "2016-11-15T10:33:42+02:00"

+++
# Chatops и будущее
Chatops как явление, если мне не изменяет память, зародился в недрах Github в 2012-2013 году и сразу вызвал шквал обсуждений, многие из которых не утихают и сейчас. Уже есть несколько книг по чатопсу, огромное количество ботов — всё собрано в [awesome chatops](https://github.com/exAspArk/awesome-chatops).

Тем не менее, на всех встречах, на которых я бывал, обсуждение chatops всегда сводилось к тому, что штука эта, в принципе, неплохая, но накладные расходы на поддержку высокие. Здорово, когда chatops есть, но ничего страшного, если его нет. 
В таких разговорах я всегда придерживался политики, что chatops bot по сути своей тоже самое, что и интерактивная утилита, которую можно запустить из shell: надо строить таким образом, чтобы использование было непротиворечивым и понятным, позволяло передать опыт и лучшие практики посредством автоматизации, как и любая другая утилита, и было стабильным. Если говорить простыми словами, то опсы делают подковёрную работу, автоматизируют, костылят и так далее, выставляя наружу только UI своего решения, которым уже и пользуются остальные. В каком виде будет этот UI — консольная тулза или бот в слаке — не так важно, как сами принципы построения этого UI.
Собственно, подобного подхода придерживаются многие. И хотя `deploy 0.19 version of frontend to qa` выглядит неплохо, это всё равно обычный текстовый UI, в котором надо запоминать последовательность аргументов, ключевые слова и так далее. Это накладно, особенно в случаях редкого использования. 

> Вообще это извечная проблема админов — неспособность понять, что то, что нужно не часто, может быть забыто. Отсюда и “тупые девы”, и бесконечное количество ключей в шелл приложениях, и неумение строить нормальный UI.

И так как невозможно запомнить всё, то часто такой чатопс выглядит как
  ```
	> me: @bot who is oncall ops?
	> bot: I don't understand you
	> me: @bot help
	> bot: ....blbalba на 10 строк...
	> me: @bot  who is oncall in ops team today
  ```
Или наоборот. Так или иначе, как ни старались построить человеческий UI, в котором ты можешь просто написать кусок текста, все всё равно приходили к тому, что надо запоминать какие-то команды. 

В итоге, Slack превращается в обычный терминал с плюсами и минусами чата: единое окно, но если у нас уже есть готовый терминал со всеми плюшками, зачем делать ещё один? Аутентификация пользователя — это хорошо, но относительно сложности автоматизации и внедрения этот плюс не всегда перевешивает минусы. 

А что было бы плюсом? Почему люди вообще используют чаты вместо того, чтобы общаться какими-то простыми командами? Это большой вопрос, вопрос к языку и его появлению, но если коротко, то возможность разными словами передать одну и ту же мысль здорово сглаживает проблемы в коммуникации. Единственная сложность в этом — правильно распарсить текст: у людей есть специальные участки в мозге, которые этим занимаются. Делать такую же штуку посредством грубого парсинга и регекспов не очень-то и просто, да и вообще NLP это сложно, хотя с наскока, особенно людям, которые не в теме, может показаться, что ничего такого тут нет. 

Именно поэтому я решил поискать, какие NLP парсеры уже существуют, и с удивлением осознал, что пока индустрия шла вперёд, многие из devops, в том числе и я, застряли в прошлом: быстрое гугление выдало мне несколько SaaS на эту тему: бесплатный [wit.ai](https://wit.ai) и недавно ставший бесплатным на базовом плане [ api.ai ](http://api.ai).
Изначально я тестировал штуки именно на wit.ai, участники сообщества ukrops могут помнить мои эксперименты пол года назад, но сейчас api.ai нравится мне немного больше. 
Я не буду вдаваться в UI этого решения: там всё относительно просто, да и можно отдельный пост сделать, но если коротко, то текстовые запросы в любом формате возвратят нам json с параметрами
```
	me: залей 0.19 на прод
	to bot: ...
		"parameters": {
	      "deploy": "deploy",
	      "env": "prod",
	      "number": "0.19"
	    },
	...
	me: задеплой в тест версию 0.20
	to bot: ...
		"parameters": {
	      "deploy": "deploy",
	      "env": "test",
	      "number": "0.20"
	    },
	...
  ```

И так далее. То есть этот сервис позволяет нам достаточно просто накликивать некие контексты, которые он сам разбирает, сохраняет юзерские запросы, которые не смог распарсить, и даже умеет переспрашивать в случае, если что-то непонятно или не указано, а вы, в свою очередь, в своём приложении уже работаете с json — всё просто и понятно. 
В общем, за такими штуками определённо будущее и мне было бы очень интересно построить chatops с NLP парсером. Я попробую сделать какой-то PoC в ukrops, но если у вас или вашей компании есть потребность в chatops с человеческим лицом, то мне было бы интересно :)
