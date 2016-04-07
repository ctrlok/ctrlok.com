---
title: rerun и nfs (vagrant)
author: ctrlok
layout: post
date: 2015-01-04
categories:
  - ruby
  - vagrant

---
Если вы разрабатываете руби приложения под вагрант то скорее всего уже столкнулись с тем что достаточно сложно перезапускать руби код внутри контейнера по изменению.&nbsp;

В vagrant есть несколько способов синкать файлы с хостовой машины в контейнер: rsync и nfs. Если мы используем rsync, то все, в приципе, ок. Но если мы хотим использовать nfs (мне этот вариант кажется удобнее, потому что ненадо держать в фоне vagrant rsync-all), то в некоторых случаях все становится немного сложнее.

Сейчас я использую&nbsp;<a href="https://github.com/alexch/rerun" title="" target="_blank">rerun</a>, который в свою очередь использует gem&nbsp;<a href="https://rubygems.org/gems/listen" title="" target="_blank">listen</a>. Чтобы перезапуск по изменению кода&nbsp;заработал, надо форкнуть rerun и добавить один параметр, как&nbsp;<a href="https://github.com/ctrlok/rerun/commit/7dc85d964f32cd9ec18b73efdd9c9e59b25c4208" title="" target="_blank">тут</a>. Ну или воспользоваться&nbsp;<a href="https://github.com/ctrlok/rerun" title="" target="_blank">моим форком.</a>&nbsp;
