
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий
	
	Процедура ОбработкаПроведения(Отказ, РежимПроведения)
		
		СформироватьДвижения(); 
		
		СформироватьДвиженияУдержания();     
		
		СформироватьДвиженияВзаиморасчетыССотрудниками();
		
	КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

	Процедура СформироватьДвижения()
		
	    СформироватьДвиженияДополнительныеНачисления();  
		
		Движения.ВКМ_ДополнительныеНачисления.Записать();
		
	КонецПроцедуры 
	
	Процедура СформироватьДвиженияДополнительныеНачисления()
	
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВКМ_НачислениеФиксированнойПремииСписокСотрудников.Сотрудник КАК Сотрудник,
		|	ВКМ_НачислениеФиксированнойПремииСписокСотрудников.Сотрудник.Подразделение КАК Подразделение,
		|	СУММА(ВКМ_НачислениеФиксированнойПремииСписокСотрудников.СуммаПремии) КАК Результат,
		|	&Дата КАК ПериодРегистрации,
		|	&ВидРасчета КАК ВидРасчета
		|ИЗ
		|	Документ.ВКМ_НачислениеФиксированнойПремии.СписокСотрудников КАК ВКМ_НачислениеФиксированнойПремииСписокСотрудников
		|ГДЕ
		|	ВКМ_НачислениеФиксированнойПремииСписокСотрудников.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	ВКМ_НачислениеФиксированнойПремииСписокСотрудников.Сотрудник,
		|	ВКМ_НачислениеФиксированнойПремииСписокСотрудников.НомерСтроки,
		|	ВКМ_НачислениеФиксированнойПремииСписокСотрудников.Сотрудник.Подразделение"; 
		Запрос.УстановитьПараметр("Ссылка", Ссылка);      
		Запрос.УстановитьПараметр("Дата", Дата);   
		Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.ВКМ_ДополнительныеНачисления.Премия);   
		
		Движения.ВКМ_ДополнительныеНачисления.Загрузить(Запрос.Выполнить().Выгрузить());
		
	КонецПроцедуры
	
	Процедура СформироватьДвиженияУдержания()
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВКМ_ДополнительныеНачисления.Сотрудник КАК Сотрудник,
		|	ВКМ_ДополнительныеНачисления.Подразделение КАК Подразделение,
		|	ВКМ_ДополнительныеНачисления.Результат * 0.13 КАК Результат,  
		|	ВКМ_ДополнительныеНачисления.Результат КАК Показатель,  
		|	&Дата КАК ПериодРегистрации,
		|	&НДФЛ КАК ВидРасчета
		|ИЗ
		|	РегистрРасчета.ВКМ_ДополнительныеНачисления КАК ВКМ_ДополнительныеНачисления
		|ГДЕ
		|	ВКМ_ДополнительныеНачисления.ПериодРегистрации = &Дата";
		Запрос.УстановитьПараметр("Дата", НачалоМесяца(Дата));   
		Запрос.УстановитьПараметр("НДФЛ", ПланыВидовРасчета.ВКМ_Удержания.НДФЛ);   
		
		Движения.ВКМ_Удержания.Загрузить(Запрос.Выполнить().Выгрузить());   
		Движения.ВКМ_Удержания.Записать();
		
	КонецПроцедуры
	
	Процедура СформироватьДвиженияВзаиморасчетыССотрудниками()
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВКМ_ДополнительныеНачисления.Сотрудник КАК Сотрудник,
		|	ЕСТЬNULL(СУММА(ВКМ_ДополнительныеНачисления.Результат), 0) КАК Результат
		|ПОМЕСТИТЬ ВТ_ДополнительныеНачисления
		|ИЗ
		|	РегистрРасчета.ВКМ_ДополнительныеНачисления КАК ВКМ_ДополнительныеНачисления
		|ГДЕ
		|	ВКМ_ДополнительныеНачисления.ПериодРегистрации = &Дата
		|	И ВКМ_ДополнительныеНачисления.Регистратор.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	ВКМ_ДополнительныеНачисления.Сотрудник
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВКМ_Удержания.Сотрудник КАК Сотрудник,
		|	ЕСТЬNULL(СУММА(ВКМ_Удержания.Результат), 0) КАК Результат
		|ПОМЕСТИТЬ ВТ_Удержания
		|ИЗ
		|	РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
		|ГДЕ
		|	ВКМ_Удержания.ПериодРегистрации = &Дата
		|	И ВКМ_Удержания.Регистратор.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	ВКМ_Удержания.Сотрудник
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	&Дата КАК Период,
		|	ВТ_ДополнительныеНачисления.Сотрудник КАК Сотрудник,
		|	ЕСТЬNULL(ВТ_ДополнительныеНачисления.Результат, 0) - ЕСТЬNULL(ВТ_Удержания.Результат, 0) КАК Сумма
		|ИЗ
		|	ВТ_ДополнительныеНачисления КАК ВТ_ДополнительныеНачисления
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Удержания КАК ВТ_Удержания
		|		ПО ВТ_ДополнительныеНачисления.Сотрудник = ВТ_Удержания.Сотрудник";
		Запрос.УстановитьПараметр("Дата", НачалоМесяца(Дата));   
		Запрос.УстановитьПараметр("Ссылка", Ссылка);       
		
		Движения.ВКМ_ВзаиморасчетыССотрудниками.Загрузить(Запрос.Выполнить().Выгрузить());   
		Движения.ВКМ_ВзаиморасчетыССотрудниками.Записать();
		
	КонецПроцедуры
	
#КонецОбласти

#КонецЕсли