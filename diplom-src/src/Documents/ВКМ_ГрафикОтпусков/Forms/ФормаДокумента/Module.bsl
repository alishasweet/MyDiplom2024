
#Область ОписаниеПеременных

#КонецОбласти
Перем КрасныйЦвет;

#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ПриОткрытииНаСервере();
КонецПроцедуры  

&НаСервере
Процедура ПриОткрытииНаСервере()
	
	ОбработкаСтрок();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыОтпускаСотрудников

&НаКлиенте
Процедура ОтпускаСотрудниковПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)
	
	ОбработкаСтрок();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура АнализГрафика(Команда) 
	ПараметрыФормы = Новый Структура;  
	Адрес = ПолучитьАдресОтпусков();
	ПараметрыФормы.Вставить("Адрес",Адрес);   
	ПараметрыФормы.Вставить("Год",Объект.Год);
	ОткрытьФорму("Документ.ВКМ_ГрафикОтпусков.Форма.АнализГрафика",ПараметрыФормы);
КонецПроцедуры       

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ОбработкаСтрок()
	
	ДокументОбъект = РеквизитФормыВЗначение("Объект");
	Данные = ДокументОбъект.ПолучитьДанныеДляРасчета();
	
	Для Каждого стр из Данные Цикл 
		Если стр.Дней > 28 Тогда 
			ВыделитьСтроки(стр.Сотрудник,Новый Цвет(235, 35, 42)); 
		Иначе
			ВыделитьСтроки(стр.Сотрудник,Новый Цвет(149, 232, 130)); 
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

&НаСервере
Процедура ВыделитьСтроки(Сотрудник,Цвет)
	
	МассивИменКолонок = Новый Массив;
    МассивИменКолонок.Добавить(Элементы.ОтпускаСотрудников.ПодчиненныеЭлементы.ОтпускаСотрудниковНомерСтроки.Имя); 
	МассивИменКолонок.Добавить(Элементы.ОтпускаСотрудников.ПодчиненныеЭлементы.ОтпускаСотрудниковСотрудник.Имя);
    МассивИменКолонок.Добавить(Элементы.ОтпускаСотрудников.ПодчиненныеЭлементы.ОтпускаСотрудниковДатаНачала.Имя);
    МассивИменКолонок.Добавить(Элементы.ОтпускаСотрудников.ПодчиненныеЭлементы.ОтпускаСотрудниковДатаОкончания.Имя);

	//Для Каждого строкаТЧ из Объект.ОтпускаСотрудников Цикл 
		ЭлементОформления = УсловноеОформление.Элементы.Добавить();
		ЭлементОформления.Использование = Истина;
		ЭлементОформления.Оформление.УстановитьЗначениеПараметра("ЦветФона", Цвет);
		
		ЭлементУсловия                = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ЭлементУсловия.ЛевоеЗначение  = Новый ПолеКомпоновкиДанных("Объект.ОтпускаСотрудников.Сотрудник");
		ЭлементУсловия.ПравоеЗначение = Сотрудник;
		ЭлементУсловия.ВидСравнения   = ВидСравненияКомпоновкиДанных.Равно;   
		ЭлементУсловия.Использование  = Истина;
		
		Для каждого ТекЭлемент из МассивИменКолонок Цикл
			ОформляемоеПоле      = ЭлементОформления.Поля.Элементы.Добавить();
			ОформляемоеПоле.Поле = Новый ПолеКомпоновкиДанных(ТекЭлемент);
		КонецЦикла;
	//КонецЦикла;

КонецПроцедуры

&НаСервере
Функция ПолучитьАдресОтпусков()
	Возврат ПоместитьВоВременноеХранилище(Объект.ОтпускаСотрудников.Выгрузить(),Новый УникальныйИдентификатор);	
КонецФункции

#КонецОбласти
