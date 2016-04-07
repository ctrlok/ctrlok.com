---
title: Бенчмарк carbon-cache.py с pypy
author: ctrlok
layout: post
date: 2016-04-04
categories:
  - Всякое

---
Недавно делал несколько докладов на тему метрик: просто взял несколько популярных решений для их хранения и погонял бенчмарки. Подробнее доклад можно посмотреть тут: <http://www.slideshare.net/VsevolodPolyakov/metrics-where-and-how>

По советам коллеги решил покрыть недостающий кейс carbon-cache.py с pypy, так как в докладе был обычный питон.

 <img class="alignleft size-full wp-image-222" src="/images/Grafana_-_carbon-cache.jpg" alt="Grafana_-_carbon-cache" width="2842" height="1052" />
 
 <img class="alignleft size-full wp-image-223" src="/images/Grafana_-_carbon-cache2.jpg" alt="Grafana_-_carbon-cache2" width="2846" height="1046" />

Если коротко, то результаты немного разочаровали, хоть оказались и лучше чем при использовании обычного питона (150 000 уникальных метрик в секунду против 120 000 используя обычный питон), но всё равно намного хуже чем у go-carbon (300 000 уникальных метрик в секунду)
