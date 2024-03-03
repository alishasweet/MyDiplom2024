
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Ответственный = Пользователи.ТекущийПользователь();
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ЗаказПокупателя") Тогда
		ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения);
	КонецЕсли; 
	
	// Рагозина {
	Если ТипЗнч(ДанныеЗаполнения) = Тип("СправочникСсылка.ДоговорыКонтрагентов") Тогда  
		Структура = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ДанныеЗаполнения,"Организация,Владелец");
		Организация = Структура.Организация;
		Контрагент = Структура.Владелец;
		Договор = ДанныеЗаполнения;
		ВыполнитьАвтозаполнение();		
	КонецЕсли; 
	// } Рагозина
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	СуммаДокумента = Товары.Итог("Сумма") + Услуги.Итог("Сумма");
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	
	ВыполнитьАвтозаполнение();
	
	Движения.ОбработкаЗаказов.Записывать = Истина;
	Движения.ОстаткиТоваров.Записывать = Истина;
	
	Движение = Движения.ОбработкаЗаказов.Добавить();
	Движение.Период = Дата;
	Движение.Контрагент = Контрагент;
	Движение.Договор = Договор;
	Движение.Заказ = Основание;
	Движение.СуммаОтгрузки = СуммаДокумента;

	Для Каждого ТекСтрокаТовары Из Товары Цикл
		Движение = Движения.ОстаткиТоваров.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.Номенклатура = ТекСтрокаТовары.Номенклатура;
		Движение.Сумма = ТекСтрокаТовары.Сумма;
		Движение.Количество = ТекСтрокаТовары.Количество;
	КонецЦикла;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЗаказПокупателя.Организация КАК Организация,
	               |	ЗаказПокупателя.Контрагент КАК Контрагент,
	               |	ЗаказПокупателя.Договор КАК Договор,
	               |	ЗаказПокупателя.СуммаДокумента КАК СуммаДокумента,
	               |	ЗаказПокупателя.Товары.(
	               |		Ссылка КАК Ссылка,
	               |		НомерСтроки КАК НомерСтроки,
	               |		Номенклатура КАК Номенклатура,
	               |		Количество КАК Количество,
	               |		Цена КАК Цена,
	               |		Сумма КАК Сумма
	               |	) КАК Товары,
	               |	ЗаказПокупателя.Услуги.(
	               |		Ссылка КАК Ссылка,
	               |		НомерСтроки КАК НомерСтроки,
	               |		Номенклатура КАК Номенклатура,
	               |		Количество КАК Количество,
	               |		Цена КАК Цена,
	               |		Сумма КАК Сумма
	               |	) КАК Услуги
	               |ИЗ
	               |	Документ.ЗаказПокупателя КАК ЗаказПокупателя
	               |ГДЕ
	               |	ЗаказПокупателя.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", ДанныеЗаполнения);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Не Выборка.Следующий() Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, Выборка);
	
	ТоварыОснования = Выборка.Товары.Выбрать();
	Пока ТоварыОснования.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(Товары.Добавить(), ТоварыОснования);
	КонецЦикла;
	
	УслугиОснования = Выборка.Услуги.Выбрать();
	Пока ТоварыОснования.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(Услуги.Добавить(), УслугиОснования);
	КонецЦикла;
	
	Основание = ДанныеЗаполнения;
	
КонецПроцедуры

Процедура ВыполнитьАвтозаполнение() Экспорт  // Рагозина
	
	АбонентскаяПлата = Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить();
	РаботаСпециалиста = Константы.ВКМ_НоменклатураРаботыСпециалиста.Получить();
	ЕжемесПлата = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Договор, "ВКМ_ЕжемесячнаяПлата");
	
	Товары.Очистить();
	Услуги.Очистить(); 
	
	Если не ЕжемесПлата = 0 Тогда 
		НовСтр = Услуги.Добавить();
		НовСтр.Номенклатура = АбонентскаяПлата;
		НовСтр.Количество = 1;
		НовСтр.Цена = ЕжемесПлата;
		НовСтр.Сумма = НовСтр.Цена;
	КонецЕсли;  
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СУММА(ВКМ_ВыполненныеКлиентуРаботы.КоличествоЧасов) КАК КоличествоЧасов,
	|	СУММА(ВКМ_ВыполненныеКлиентуРаботы.СуммаКОплате) КАК СуммаКОплате,
	|	ВКМ_ВыполненныеКлиентуРаботыОстаткиИОбороты.Договор КАК Договор
	|ИЗ
	|	РегистрНакопления.ВКМ_ВыполненныеКлиентуРаботы КАК ВКМ_ВыполненныеКлиентуРаботы
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрНакопления.ВКМ_ВыполненныеКлиентуРаботы.ОстаткиИОбороты(
	|				&НачалоПериода,
	|				&КонецПериода,
	|				,
	|				,
	|				Договор В
	|					(ВЫБРАТЬ
	|						РеализацияТоваровУслуг.Договор КАК Договор
	|					ИЗ
	|						Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	|					ГДЕ
	|						РеализацияТоваровУслуг.Ссылка = &Ссылка)) КАК ВКМ_ВыполненныеКлиентуРаботыОстаткиИОбороты
	|		ПО ВКМ_ВыполненныеКлиентуРаботы.Клиент = ВКМ_ВыполненныеКлиентуРаботыОстаткиИОбороты.Клиент
	|			И ВКМ_ВыполненныеКлиентуРаботы.Договор = ВКМ_ВыполненныеКлиентуРаботыОстаткиИОбороты.Договор
	|
	|СГРУППИРОВАТЬ ПО
	|	ВКМ_ВыполненныеКлиентуРаботыОстаткиИОбороты.Договор"; 
	Запрос.УстановитьПараметр("НачалоПериода",НачалоМесяца(Дата));
	Запрос.УстановитьПараметр("КонецПериода",КонецМесяца(Дата)); 
	Запрос.УстановитьПараметр("Ссылка",Ссылка);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда 
		НовСтр = Услуги.Добавить();
		НовСтр.Номенклатура = РаботаСпециалиста;
		НовСтр.Количество = Выборка.КоличествоЧасов;
		НовСтр.Сумма = Выборка.СуммаКОплате;
	КонецЕсли;
	
	СуммаДокумента = Товары.Итог("Сумма") + Услуги.Итог("Сумма");
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
