﻿Перем мПараметры; // заполняется только в ОбработатьНовыеВерсии  

Процедура ОбработатьНовыеВерсии() Экспорт 
	
	ОбщиеНастройки = Справочники.ОбщиеНастройки.Настройки;
	
	мПараметры = Новый Структура();
	мПараметры.Вставить("РабочийКаталог", ОписаниеХранилища.РабочийКаталог);
	мПараметры.Вставить("КаталогВременныхФайлов", ОписаниеХранилища.РабочийКаталог + "Temp\");
	мПараметры.Вставить("КаталогИсторииКомандГит", ОписаниеХранилища.РабочийКаталог + "Temp\GitHistory\");
	мПараметры.Вставить("КаталогИБ", ОписаниеХранилища.РабочийКаталог + "Base\");
	мПараметры.Вставить("КаталогХранилищаГит", ОписаниеХранилища.РабочийКаталог + "GitStorage\");
	мПараметры.Вставить("КаталогФайловКонфигурации", ОписаниеХранилища.РабочийКаталог + "GitStorage\Config");
	мПараметры.Вставить("КаталогИсполняемогоФайла1С", ОбщиеНастройки.КаталогИсполняемогоФайла1С);
	мПараметры.Вставить("АдресИсполняемогоФайлаБаш", ОбщиеНастройки.АдресИсполняемогоФайлаБаш);
	мПараметры.Вставить("АдресХранилища", ОписаниеХранилища.АдресХранилища);
	мПараметры.Вставить("ЛогинХранилища", ОписаниеХранилища.ЛогинХранилища);
	мПараметры.Вставить("ПарольХранилища", ОписаниеХранилища.ПарольХранилища);
	мПараметры.Вставить("НачальнаяВерсия", Макс(ОписаниеХранилища.НачальнаяВерсия, ОписаниеХранилища.ЗагруженнаяВерсия + 1));
	мПараметры.Вставить("АдресУдаленногоРепозитория", ОписаниеХранилища.АдресУдаленногоРепозитория);
	
	мПараметры.Вставить("НазваниеПроектаSonarqube", ОписаниеХранилища.НазваниеПроектаSonarqube);
	мПараметры.Вставить("АдресКомандыSonarScanner", ОбщиеНастройки.АдресКомандыSonarScanner);
	мПараметры.Вставить("ТокенSonarqube", ОбщиеНастройки.ТокенSonarqube);
	мПараметры.Вставить("GerritSshKey", ОбщиеНастройки.GerritSshKey);
	
	Если НЕ ЗначениеЗаполнено(ОбщиеНастройки.КаталогИсполняемогоФайла1С) Тогда
		ДобавитьЗаписьВЛог("Не заполнен справочник общих настроек", Истина);
		Возврат;
	КонецЕсли;
	
	СоздатьКаталог(мПараметры.РабочийКаталог);
	СоздатьКаталог(мПараметры.КаталогВременныхФайлов);
	СоздатьКаталог(мПараметры.КаталогИсторииКомандГит);
	СоздатьКаталог(мПараметры.КаталогИБ);
	СоздатьКаталог(мПараметры.КаталогИсполняемогоФайла1С);
	СоздатьКаталог(мПараметры.КаталогХранилищаГит);
	СоздатьКаталог(мПараметры.КаталогФайловКонфигурации);
	
	ОчиститьЛог();
	
	Попытка
		ОбработкаНовыхВерсий();
	Исключение
		ДобавитьЗаписьВЛог("Ошибка " + ОписаниеОшибки(), Истина);		
	КонецПопытки;    
	
КонецПроцедуры

Процедура ОбработкаНовыхВерсий()
	
	РезультатСозданияРепозитория = СоздатьРепозиторийGit();		
	Если РезультатСозданияРепозитория.Ошибка Тогда
		ДобавитьЗаписьВЛог(РезультатСозданияРепозитория.ТекстОшибки, Истина);
		Возврат;
	КонецЕсли;
	
	РезультатСозданияБазы = СоздатьВспомогательнуюБазу();		
	Если РезультатСозданияБазы.Ошибка Тогда
		ДобавитьЗаписьВЛог(РезультатСозданияБазы.ТекстОшибки, Истина);
		Возврат;
	КонецЕсли; 
	
	РезультатПолученияОтчета = ПолучитьОтчетПоВерсиямХранилища();
	Если РезультатПолученияОтчета.Ошибка Тогда
		ДобавитьЗаписьВЛог(РезультатПолученияОтчета.ТекстОшибки, Истина);
		Возврат;
	КонецЕсли;	 
	
	ОтчетПоВерсиям = РезультатПолученияОтчета.Отчет;
	Для Каждого ОписаниеВерсии Из ОтчетПоВерсиям Цикл     
		
		РезультатПолученияВерсии = ПолучитьВерсиюИзХранилища(ОписаниеВерсии);
		Если РезультатПолученияВерсии.Ошибка Тогда
			ДобавитьЗаписьВЛог(РезультатПолученияВерсии.ТекстОшибки, Истина);
			Возврат;
		КонецЕсли; 
		
		РезультатВыгрузкиВФайлы = ВыгрузитьКонфигурациюВФайлы();
		Если РезультатВыгрузкиВФайлы.Ошибка Тогда
			ДобавитьЗаписьВЛог(РезультатВыгрузкиВФайлы.ТекстОшибки, Истина);
			Возврат;
		КонецЕсли;

		ВыгрузитьТекстыМодулейИзОбычныхФорм(ОписаниеВерсии);   
		
		РезультатВыполненияКоммита = ВыполнитьКоммит(ОписаниеВерсии); 
		Если РезультатВыполненияКоммита.Ошибка Тогда
			ДобавитьЗаписьВЛог(РезультатВыполненияКоммита.ТекстОшибки, Истина);
			Возврат;
		КонецЕсли;
		
		Справочники.ОписаниеХранилищ.УстановитьЗагруженнуюВерсию(ОписаниеХранилища, ОписаниеВерсии.Версия);
		
	КонецЦикла;
	
	Если ОтчетПоВерсиям.Количество() = 0 Тогда
		ДобавитьЗаписьВЛог("Нет новых версий конфигурации");
		Возврат;
	КонецЕсли;

	РезультатВыполненияОтправкиНаАнализ = ОтправитьВSonarqube(); 
	Если РезультатВыполненияОтправкиНаАнализ.Ошибка Тогда
		ДобавитьЗаписьВЛог(РезультатВыполненияОтправкиНаАнализ.ТекстОшибки, Истина);
		Возврат;
	КонецЕсли;  
	
	РезультатВыполненияПуша = ВыполнитьПушВGerrit();  
	Если РезультатВыполненияПуша.Ошибка Тогда
		ДобавитьЗаписьВЛог(РезультатВыполненияПуша.ТекстОшибки, Истина);
		Возврат;
	КонецЕсли;	
	
КонецПроцедуры 

//////////////////////////////////// СОЗДАНИЕ РЕПОЗИТОРИЯ ГИТ ////////////////////////////////

Функция СоздатьРепозиторийGit()   
	ДобавитьЗаписьВЛог("НАЧАЛО СОЗДАНИЯ РЕПОЗИТОРИЯ"); 
	ДобавитьЗаписьВЛог();	  
	
	Результат = Новый Структура("Ошибка, ТекстОшибки", Ложь, "");
	
	АдресФайлБаш = мПараметры.АдресИсполняемогоФайлаБаш;
	Файл = Новый Файл(АдресФайлБаш);
	Если НЕ Файл.Существует() Тогда
		Результат.Ошибка = Истина;				
		Результат.ТекстОшибки = "Не найден исполняемый файл баш";
		Возврат Результат;
	КонецЕсли;
	
	ИмяФайлаИсключений = мПараметры.КаталогХранилищаГит + ".gitignore";
	ИмяФайлаАтрибутов = мПараметры.КаталогХранилищаГит + ".gitattributes";
	
	Файл = Новый Файл(ИмяФайлаАтрибутов);
	Если Файл.Существует() Тогда  
		ДобавитьЗаписьВЛог("репозиторий уже существует");
		Возврат Результат;
	КонецЕсли;     	
			
	ТекстКоманды = "#!/bin/bash
	|LOGFILE=""%ФайлЛога%""
	|cd '%КаталогХранилищаГит%' >> $LOGFILE 2>&1 
	|git init >> $LOGFILE 2>&1
	|git config --local gui.encoding utf-8 >> $LOGFILE 2>&1 
	|git config --local i18n.commitEncoding utf-8 >> $LOGFILE 2>&1
	|git config --local core.autocrlf false >> $LOGFILE 2>&1
	|git config --global --add safe.directory %КаталогХранилищаГит%
	|git status >> $LOGFILE 2>&1
	|";
	
	ПараметрыКоманды = Новый Структура();
	ПараметрыКоманды.Вставить("КаталогХранилищаГит", СтрЗаменить(мПараметры.КаталогХранилищаГит, "\", "/")); 	
	
	РезультатВыполненияКоманды = ВыполнитьКомандуГит(ТекстКоманды, ПараметрыКоманды);
	Если РезультатВыполненияКоманды.Ошибка Тогда
		ЗаполнитьЗначенияСвойств(Результат, РезультатВыполненияКоманды);
		Возврат Результат;
	КонецЕсли;            
	
	ФайлИсключений = Новый ТекстовыйДокумент;
    ФайлИсключений.ДобавитьСтроку("DumpFilesIndex.txt");
	ФайлИсключений.ДобавитьСтроку("ConfigDumpInfo.xml");
	ФайлИсключений.ДобавитьСтроку("Config\.scannerwork\report-task.txt");   
	ФайлИсключений.Записать(ИмяФайлаИсключений, "CESU-8"); 
	 
	ФайлАтрибутов = Новый ТекстовыйДокумент();
	ФайлАтрибутов.ДобавитьСтроку("# Binary file extensions that should not be modified.");
	ФайлАтрибутов.ДобавитьСтроку("*.bin binary");
	ФайлАтрибутов.ДобавитьСтроку("*.axdt binary");
	ФайлАтрибутов.ДобавитьСтроку("*.addin binary");
	ФайлАтрибутов.Записать(ИмяФайлаАтрибутов, "CESU-8");		
	
	ДобавитьЗаписьВЛог("РЕПОЗИТОРИЙ СОЗДАН"); 
	ДобавитьЗаписьВЛог();
	
	Возврат Результат;
КонецФункции

//////////////////////////////////// СОЗДАНИЕ ВСПОМОГАТЕЛЬНОЙ БАЗЫ /////////////////////////////////////

Функция СоздатьВспомогательнуюБазу()  
	ДобавитьЗаписьВЛог("НАЧАЛО СОЗДАНИЯ ВСПОМОГАТЕЛЬНОЙ БАЗЫ");	
	ДобавитьЗаписьВЛог();
	
	Результат = Новый Структура("Ошибка, ТекстОшибки", Ложь, "");
	
	Если БазаСуществует() Тогда  
		ДобавитьЗаписьВЛог("база уже существует");
		Возврат Результат;
	КонецЕсли; 		

	СтрокаПакетнойКоманды = "CREATEINFOBASE File=""%КаталогИБ%"" /DisableStartupDialogs /L ru /VL ru
			| /DumpResult ""%ИмяФайлаРезультатаКоманды%""
			| /Out ""%ИмяФайлаЛогаКоманды%""";
	
	ПараметрыКоманды = Новый Структура();
	ПараметрыКоманды.Вставить("КаталогИБ", мПараметры.КаталогИБ);   
	
	РезультатВыполненияПакетнойКоманды = ВыполнитьПакетнуюКоманду(СтрокаПакетнойКоманды, ПараметрыКоманды);
	Если РезультатВыполненияПакетнойКоманды.Ошибка Тогда
		ЗаполнитьЗначенияСвойств(Результат, РезультатВыполненияПакетнойКоманды);
		Возврат Результат;
	КонецЕсли;	                                          
	
	ДобавитьЗаписьВЛог("ВСПОМОГАТЕЛЬНАЯ БАЗА СОЗДАНА");  
	ДобавитьЗаписьВЛог();
	Возврат Результат;
КонецФункции    

Функция БазаСуществует()
	
	ИмяФайла = мПараметры.КаталогИБ + "1Cv8.1CD";
	Файл = Новый Файл(ИмяФайла);
	Возврат Файл.Существует();
	
КонецФункции  

//////////////////////////////////// ПОЛУЧЕНИЕ ОТЧЕТА ПО ВЕРСИЯМ /////////////////////////////////////

Функция ПолучитьОтчетПоВерсиямХранилища()
	ДобавитьЗаписьВЛог("НАЧАЛО ПОЛУЧЕНИЯ ОТЧЕТА ПО ВЕРСИЯМ");
	ДобавитьЗаписьВЛог();
	
	Результат = Новый Структура("Ошибка, ТекстОшибки, Отчет", Ложь, "", Новый Массив);
	
	СтрокаПакетнойКоманды = "DESIGNER /WA- /DisableStartupDialogs /L ru /VL ru
			| /F""%КаталогИБ%""         
			| /ConfigurationRepositoryF ""%АдресХранилища%""
			| /ConfigurationRepositoryN ""%ЛогинХранилища%""
			| /ConfigurationRepositoryP ""%ПарольХранилища%""
			| /ConfigurationRepositoryReport ""%ИмяФайлаОтчета%"" -NBegin %НачальнаяВерсия% -NEnd %КонечнаяВерсия%
			| /DumpResult ""%ИмяФайлаРезультатаКоманды%""    
			| /Out ""%ИмяФайлаЛогаКоманды%""";
	
	ИмяФайлаОтчета = мПараметры.КаталогВременныхФайлов + "report.mxl";
	
	ПараметрыКоманды = Новый Структура();
	ПараметрыКоманды.Вставить("КаталогИБ", мПараметры.КаталогИБ);   
	ПараметрыКоманды.Вставить("АдресХранилища", мПараметры.АдресХранилища);   
	ПараметрыКоманды.Вставить("ЛогинХранилища", мПараметры.ЛогинХранилища);   
	ПараметрыКоманды.Вставить("ПарольХранилища", мПараметры.ПарольХранилища);
	ПараметрыКоманды.Вставить("ИмяФайлаОтчета", ИмяФайлаОтчета);
	ПараметрыКоманды.Вставить("НачальнаяВерсия", Формат(мПараметры.НачальнаяВерсия, "ЧДЦ=; ЧГ=0"));
	ПараметрыКоманды.Вставить("КонечнаяВерсия", Формат(мПараметры.НачальнаяВерсия + 10, "ЧДЦ=; ЧГ=0"));
	
	РезультатВыполненияПакетнойКоманды = ВыполнитьПакетнуюКоманду(СтрокаПакетнойКоманды, ПараметрыКоманды);
	Если РезультатВыполненияПакетнойКоманды.Ошибка Тогда
		ЗаполнитьЗначенияСвойств(Результат, РезультатВыполненияПакетнойКоманды);
		Возврат Результат;
	КонецЕсли;	 
	
	Результат.Отчет = ПрочитатьФайлОтчета(ИмяФайлаОтчета);
	
	ДобавитьЗаписьВЛог("ОТЧЕТ ПО ВЕРСИЯМ ПОЛУЧЕН");
	ДобавитьЗаписьВЛог();  
	Возврат Результат;
КонецФункции      

Функция ПрочитатьФайлОтчета(ИмяФайла)
	Результат = Новый Массив;
	
	Файл = Новый Файл(ИмяФайла);
	Если НЕ Файл.Существует() Тогда
		Возврат Результат;
	КонецЕсли;           
	
	ТабДок = Новый ТабличныйДокумент;
	ТабДок.Прочитать(ИмяФайла);
	
	НачальнаяСтрокаПоиска = 1; 
	ОбластьПоиска = ТабДок.Область(НачальнаяСтрокаПоиска, 1, ТабДок.ВысотаТаблицы , 1); 
	Пока Истина Цикл         
		
		НайденнаяОбласть = ТабДок.НайтиТекст("Версия:", , ОбластьПоиска);
		Если НайденнаяОбласть = Неопределено Тогда
			Прервать;			
		КонецЕсли;    
		
		ОбластьВерсия = ТабДок.Область(НайденнаяОбласть.Верх, НайденнаяОбласть.Лево + 1);
		Версия = Число(СтрЗаменить(ОбластьВерсия.Текст, " ", ""));
		
		ОбластьПользователь = ТабДок.Область(НайденнаяОбласть.Верх + 1, НайденнаяОбласть.Лево + 1);
		Пользователь = ОбластьПользователь.Текст; 
		
		ОбластьДата = ТабДок.Область(НайденнаяОбласть.Верх + 2, НайденнаяОбласть.Лево + 1);
		Дата = ОбластьДата.Текст;
		
		ОбластьВремя = ТабДок.Область(НайденнаяОбласть.Верх + 3, НайденнаяОбласть.Лево + 1);
		Время = ОбластьВремя.Текст;
		
		ОбластьКомментарий = ТабДок.Область(НайденнаяОбласть.Верх + 5, НайденнаяОбласть.Лево + 1);
		Комментарий = ОбластьКомментарий.Текст;
		
		СтруктураВерсии = ПолучитьСтруктуруВерсии(Версия, Пользователь, Дата, Время, Комментарий);
		Результат.Добавить(СтруктураВерсии);    
		
		ОбластьПоиска = ТабДок.Область(ОбластьВерсия.Верх + 1, 1, ТабДок.ВысотаТаблицы , 1);
		
	КонецЦикла;                             
	
	Возврат Результат;
КонецФункции

Функция ПолучитьСтруктуруВерсии(Версия, Пользователь, Дата, Время, Комментарий)
	Результат = Новый Структура("Версия, Пользователь, ПредставлениеПользователя, ЭлектронныйАдресПользователя, Дата, Комментарий");
	
	Результат.Версия = Версия;
	Результат.Пользователь = Справочники.ПользователиХранилища.ПолучитьПользователя(ОписаниеХранилища, Пользователь);
	Если НЕ ЗначениеЗаполнено(Результат.Пользователь) Тогда
		ВызватьИсключение("Не найден пользователь " + Пользователь + " хранилища " + Строка(ОписаниеХранилища));		
	КонецЕсли;                                                                                                       
	Результат.ПредставлениеПользователя = Результат.Пользователь.Код;
	
	Результат.ЭлектронныйАдресПользователя = Результат.Пользователь.ЭлектронныйАдрес;	
	Результат.Комментарий = Строка(Версия) + " : " + Комментарий;
	
	Результат.Дата = ПолучитьДатуИзСтроки(Дата, Время);
	
	Возврат Результат;
КонецФункции

//////////////////////////////////// ПОЛУЧЕНИЕ ВЕРСИИ ИЗ ХРАНИЛИЩА /////////////////////////////////////

Функция ПолучитьВерсиюИзХранилища(ОписаниеВерсии)
	ДобавитьЗаписьВЛог("НАЧАЛО ПОЛУЧЕНИЯ ВЕРСИИ ИЗ ХРАНИЛИЩА");
	ДобавитьЗаписьВЛог();
	
	Результат = Новый Структура("Ошибка, ТекстОшибки", Ложь, "");
	
	СтрокаПакетнойКоманды = "DESIGNER /WA- /DisableStartupDialogs /L ru /VL ru
			| /F""%КаталогИБ%""         
			| /ConfigurationRepositoryF ""%АдресХранилища%""
			| /ConfigurationRepositoryN ""%ЛогинХранилища%""
			| /ConfigurationRepositoryP ""%ПарольХранилища%""
			| /ConfigurationRepositoryUpdateCfg -force -v ""%Версия%""
			| /DumpResult ""%ИмяФайлаРезультатаКоманды%""    
			| /Out ""%ИмяФайлаЛогаКоманды%""";
	
	ИмяФайлаОтчета = мПараметры.КаталогВременныхФайлов + "report.mxl";
	
	ПараметрыКоманды = Новый Структура();
	ПараметрыКоманды.Вставить("КаталогИБ", мПараметры.КаталогИБ);   
	ПараметрыКоманды.Вставить("АдресХранилища", мПараметры.АдресХранилища);   
	ПараметрыКоманды.Вставить("ЛогинХранилища", мПараметры.ЛогинХранилища);   
	ПараметрыКоманды.Вставить("ПарольХранилища", мПараметры.ПарольХранилища);
	ПараметрыКоманды.Вставить("Версия", Формат(ОписаниеВерсии.Версия, "ЧДЦ=; ЧГ=0"));
	
	РезультатВыполненияПакетнойКоманды = ВыполнитьПакетнуюКоманду(СтрокаПакетнойКоманды, ПараметрыКоманды);
	Если РезультатВыполненияПакетнойКоманды.Ошибка Тогда
		ЗаполнитьЗначенияСвойств(Результат, РезультатВыполненияПакетнойКоманды);
		Возврат Результат;
	КонецЕсли;	 
		
	ДобавитьЗаписьВЛог("ВЕРСИЯ ИЗ ХРАНИЛИЩА ПОЛУЧЕНА");
	ДобавитьЗаписьВЛог();  
	Возврат Результат;		
КонецФункции

//////////////////////////////////// ВЫГРУЗКА КОНФИГУРАЦИИ В ФАЙЛЫ /////////////////////////////////////

Функция ВыгрузитьКонфигурациюВФайлы()
	ДобавитьЗаписьВЛог("НАЧАЛО ВЫГРУЗКИ КОНФИГУРАЦИИ В ФАЙЛЫ");
	ДобавитьЗаписьВЛог();
	
	Результат = Новый Структура("Ошибка, ТекстОшибки", Ложь, "");
	  
	УдалитьФайлы(мПараметры.КаталогФайловКонфигурации);
	СоздатьКаталог(мПараметры.КаталогФайловКонфигурации);
	
	ИмяФайлаИнформацииОВыгрузке = мПараметры.КаталогФайловКонфигурации + "ConfigDumpInfo.xml";
	Файл = Новый Файл(ИмяФайлаИнформацииОВыгрузке);
	ФайлИнформацииОВыгрузкеСуществует = Файл.Существует(); 
	
	ПараметрыВыгрузки = "";
	Если ФайлИнформацииОВыгрузкеСуществует Тогда
		ПараметрыВыгрузки = "-update -force";
	КонецЕсли;
	
	СтрокаПакетнойКоманды = "DESIGNER /WA- /DisableStartupDialogs /L ru /VL ru
			| /F""%КаталогИБ%""         
			| /DumpConfigToFiles ""%КаталогФайловКонфигурации%"" ""%ПараметрыВыгрузки%""
			| /DumpResult ""%ИмяФайлаРезультатаКоманды%""    
			| /Out ""%ИмяФайлаЛогаКоманды%""";
	
	ПараметрыКоманды = Новый Структура();
	ПараметрыКоманды.Вставить("КаталогИБ", мПараметры.КаталогИБ);   
	ПараметрыКоманды.Вставить("КаталогФайловКонфигурации", мПараметры.КаталогФайловКонфигурации);   	
	ПараметрыКоманды.Вставить("ПараметрыВыгрузки", ПараметрыВыгрузки);   
	
	РезультатВыполненияПакетнойКоманды = ВыполнитьПакетнуюКоманду(СтрокаПакетнойКоманды, ПараметрыКоманды);
	Если РезультатВыполненияПакетнойКоманды.Ошибка Тогда
		ЗаполнитьЗначенияСвойств(Результат, РезультатВыполненияПакетнойКоманды);
		Возврат Результат;
	КонецЕсли;	 
		
	ДобавитьЗаписьВЛог("ВЫГРУЗКА КОНФИГУРАЦИИ В ФАЙЛЫ ВЫПОЛНЕНА");
	ДобавитьЗаписьВЛог();  
	Возврат Результат;		
КонецФункции

//////////////////////////////////// ПОЛУЧЕНИЕ ТЕКСТОВ МОДУЛЕЙ /////////////////////////////////////

Процедура ВыгрузитьТекстыМодулейИзОбычныхФорм(ОписаниеВерсии)   
	
	ДобавитьЗаписьВЛог("НАЧАЛО ВЫГРУЗКИ ТЕКСТОВ МОДУЛЕЙ ИЗ ОБЫЧНЫХ ФОРМ");
	ДобавитьЗаписьВЛог();
	
	МассивФайловФорм = НайтиФайлы(мПараметры.КаталогФайловКонфигурации, "*.bin", Истина);
	
	Для Каждого Файл Из МассивФайловФорм Цикл
		ВыгрузитьМодульФормы(Файл);			
	КонецЦикла; 
	
	//ЗаписатьФайлВерсии(ОписаниеВерсии);
	
	ДобавитьЗаписьВЛог("ТЕКСТЫ МОДУЛЕЙ ФОРМ ПОЛУЧЕНЫ");
	ДобавитьЗаписьВЛог();

КонецПроцедуры  

Процедура ВыгрузитьМодульФормы(Файл)
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.Прочитать(Файл.ПолноеИмя, "UTF-8");
	
	Текст = ТекстовыйДокумент.ПолучитьТекст();
	
	Если СтрЧислоВхождений(Текст, "00000024 00000024 7fffffff") > 1 Тогда
		//Считаем что такая строка в форме встречается только 1 раз перед модулем.		
		ВызватьИсключение("Неожиданный формат файла формы");			
	КонецЕсли;
	
	Позиция = СтрНайти(Текст, "00000024 00000024 7fffffff");
	Если Позиция = 0 Тогда
		Возврат;
	КонецЕсли;
	
	НачалоКода = СтрНайти(Текст, Символы.ПС, , Позиция, 3); //код начинается после 3го переноса
	
	Позиция = СтрНайти(Текст, " 7fffffff", , НачалоКода);	 
	ОкончаниеКода = СтрНайти(Текст, Символы.ПС, НаправлениеПоиска.СКонца , Позиция, 1); //код заканчивается до 1го переноса
	
	ТекстМодуля = Сред(Текст, НачалоКода, ОкончаниеКода - НачалоКода);
	ТекстМодуля = СокрЛП(ТекстМодуля);       
	
	Если ПустаяСтрока(ТекстМодуля) Тогда
		Возврат;
	КонецЕсли;
	
	ИмяФайлаМодуля = Файл.Путь + Файл.ИмяБезРасширения + ".binmodule";
	ТекстовыйДокумент.УстановитьТекст(ТекстМодуля); 
	ТекстовыйДокумент.Записать(ИмяФайлаМодуля);	
	
КонецПроцедуры

Процедура ЗаписатьФайлВерсии(ОписаниеВерсии)    
	ФайлВерсии = мПараметры.КаталогХранилищаГит + "version.txt";
	
	ТекстКоманды = Новый ТекстовыйДокумент;
	ТекстКоманды.УстановитьТекст(Строка(ОписаниеВерсии.Версия));  	
	ТекстКоманды.Записать(ФайлВерсии, "CESU-8");		
КонецПроцедуры
//////////////////////////////////// ВЫПОЛНЕНИЕ КОММИТА /////////////////////////////////////

Функция ВыполнитьКоммит(ОписаниеВерсии)
	
	ДобавитьЗаписьВЛог("НАЧАЛО ВЫПОЛНЕНИЯ КОММИТА");
	ДобавитьЗаписьВЛог();
	
	Результат = Новый Структура("Ошибка, ТекстОшибки", Ложь, "");	 
	
	СтрокаКоманды = "#!/bin/bash
	|LOGFILE=""%ФайлЛога%""
	|cd '%КаталогХранилищаГит%' > $LOGFILE 2>&1
	|git config --local user.name ""%Пользователь%""
	|git config --local user.email ""%АдресЭлектроннойПочты%""
	|git add --all ./ >> $LOGFILE 2>&1		
	|GIT_COMMITTER_DATE=""%Дата%"" git commit --date=""%Дата%"" -m ""%Комментарий%"" --cleanup=verbatim >> $LOGFILE 2>&1
	|git gc --auto >> $LOGFILE 2>&1
	|git status >> $LOGFILE 2>&1";   
	
	ПараметрыКоманды = Новый Структура;  
	ПараметрыКоманды.Вставить("КаталогХранилищаГит", мПараметры.КаталогХранилищаГит); 	
	ПараметрыКоманды.Вставить("Дата", Формат(ОписаниеВерсии.Дата,"ДФ=yyyy-MM-ddTHH:mm:ss"));
	ПараметрыКоманды.Вставить("Пользователь", ОписаниеВерсии.ПредставлениеПользователя);
	ПараметрыКоманды.Вставить("АдресЭлектроннойПочты", ОписаниеВерсии.ЭлектронныйАдресПользователя);
	ПараметрыКоманды.Вставить("Комментарий", ОписаниеВерсии.Комментарий);
	
	РезультатВыполненияКоманды = ВыполнитьКомандуГит(СтрокаКоманды, ПараметрыКоманды);    
	
	ФайлИсторииЛогаГит = Формат(ОписаниеВерсии.Дата,"ДФ=yyyy-MM-ddTHH-mm-ss") + "#" + Формат(ОписаниеВерсии.Версия, "ЧГ=") + ".log";
	СохранитьЛогГит(ФайлИсторииЛогаГит);                  
	
	Если РезультатВыполненияКоманды.Ошибка Тогда
		ЗаполнитьЗначенияСвойств(Результат, РезультатВыполненияКоманды);
		Возврат Результат;
	КонецЕсли;	
	
	ДобавитьЗаписьВЛог("КОММИТ ВЫПОЛНЕН");
	ДобавитьЗаписьВЛог();

	Возврат Результат;
	
КонецФункции      

Процедура СохранитьЛогГит(ИмяФайла)
	
	КоличествоХранимыхФайлов = 200;
	
	ФайлЛога = мПараметры.КаталогВременныхФайлов + "git_log.txt";
	ФайлСохраненияЛога = мПараметры.КаталогИсторииКомандГит + ИмяФайла;
	
	КопироватьФайл(ФайлЛога, ФайлСохраненияЛога);
	
	ТаблицаФайлов = Новый ТаблицаЗначений;
	ТаблицаФайлов.Колонки.Добавить("Файл");
	ТаблицаФайлов.Колонки.Добавить("ВремяИзменения", Новый ОписаниеТипов("Дата"));
	
	Файлы = НайтиФайлы(мПараметры.КаталогИсторииКомандГит, "*", Ложь);
	
	Для Каждого Файл Из Файлы Цикл
		НоваяСтрока = ТаблицаФайлов.Добавить();		
		НоваяСтрока.Файл = Файл;
		НоваяСтрока.ВремяИзменения = Файл.ПолучитьВремяИзменения();
	КонецЦикла;         
	
	Если ТаблицаФайлов.Количество() <= КоличествоХранимыхФайлов Тогда
		Возврат;		
	КонецЕсли;                        
	
	КоличествоФайловНаУдаление = ТаблицаФайлов.Количество() - КоличествоХранимыхФайлов;
	
	ДобавитьЗаписьВЛог("Количество файлов лога на удаление = " + Строка(КоличествоФайловНаУдаление));
	
	ТаблицаФайлов.Сортировать("ВремяИзменения Возр");	
	Для Сч = 1 По КоличествоФайловНаУдаление Цикл
		Строка = ТаблицаФайлов[Сч - 1];	
		УдалитьФайлы(Строка.Файл);
	КонецЦикла;                   		
	
КонецПроцедуры

//////////////////////////////////// SONARQUBE /////////////////////////////////////

Функция ОтправитьВSonarqube()       
	
	ДобавитьЗаписьВЛог("НАЧАЛО ОТПРАВКИ ДАННЫХ В СОНАРКУБ");
	ДобавитьЗаписьВЛог();
	
	Результат = Новый Структура("Ошибка, ТекстОшибки", Ложь, "");
	
	Если НЕ ЗначениеЗаполнено(мПараметры.НазваниеПроектаSonarqube) Тогда 
		Возврат Результат;
	КонецЕсли;
	
	СоздатьФайлПроекта(); 
	
	ПараметрыКоманды = Новый Структура();
	ПараметрыКоманды.Вставить("АдресКомандыSonarScanner", мПараметры.АдресКомандыSonarScanner);
	ПараметрыКоманды.Вставить("ТокенSonarqube", мПараметры.ТокенSonarqube); 
	ПараметрыКоманды.Вставить("КаталогХранилищаГит", мПараметры.КаталогХранилищаГит); 	
	
	//Команда = "cmd /c cd %КаталогХранилищаГит% && %АдресКомандыSonarScanner% -Dsonar.login=%ТокенSonarqube% > %ИмяФайлаЛогаКоманды%";
	Команда = "cd %КаталогХранилищаГит% 
	|""%АдресКомандыSonarScanner%"" -Dsonar.login=%ТокенSonarqube% > %ИмяФайлаЛогаКоманды%";
	
	РезультатВыполнения = ВыполнитьПакетнуюКомандуСистемы(Команда, ПараметрыКоманды, мПараметры.КаталогХранилищаГит);
	Если РезультатВыполнения.Ошибка Тогда
		ЗаполнитьЗначенияСвойств(Результат, РезультатВыполнения);		
	КонецЕсли;        
	
	ДобавитьЗаписьВЛог("ДАННЫЕ ОТПРАВЛЕНЫ В СОНАРКУБ");
	ДобавитьЗаписьВЛог();
	
	Возврат Результат;
	
КонецФункции           

Процедура СоздатьФайлПроекта()
	ИмяФайла = мПараметры.КаталогХранилищаГит + "sonar-project.properties";
	Файл = Новый Файл(ИмяФайла);
	Если Файл.Существует() Тогда
		Возврат;
	КонецЕсли;
	
	Текст = "
	|sonar.projectKey=%НазваниеПроектаSonarqube%
	|sonar.projectName=%НазваниеПроектаSonarqube%  
	|sonar.projectVersion=1.0
  	|sonar.projectBaseDir=Config
	|sonar.scm.enabled=true
	|sonar.scm.provider=git
	|sonar.sources=./ 
  	|sonar.sourceEncoding=UTF-8
	|sonar.inclusions=**/*.bsl, **/*.os, **/*.binmodule 
	|";    
	
	Текст = СтрЗаменить(Текст, "%НазваниеПроектаSonarqube%", мПараметры.НазваниеПроектаSonarqube);
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.УстановитьТекст(Текст);
	ТекстовыйДокумент.Записать(ИмяФайла, "CESU-8");
КонецПроцедуры


/////////////////////////////////// GERRIT //////////////////////////////////////

Функция ВыполнитьПушВGerrit()
	
	ДобавитьЗаписьВЛог("НАЧАЛО ВЫПОЛНЕНИЯ ПУША В ГЕРРИТ");
	ДобавитьЗаписьВЛог();
	
	Результат = Новый Структура("Ошибка, ТекстОшибки", Ложь, "");  
	
	Если НЕ ЗначениеЗаполнено(мПараметры.АдресУдаленногоРепозитория) Тогда
		ДобавитьЗаписьВЛог("Не указан адрес удаленного репозитория");
		Возврат Результат;		
	КонецЕсли; 
	
	Если НЕ ЗначениеЗаполнено(мПараметры.GerritSshKey) Тогда
		ДобавитьЗаписьВЛог("Не указан GerritSshKey");
		Возврат Результат;		
	КонецЕсли;
	
	РезультаВыполнения = УстановитьУдаленныйРепозиторий();
	Если РезультаВыполнения.Ошибка Тогда
		ЗаполнитьЗначенияСвойств(РезультаВыполнения, Результат);
		Возврат Результат;
	КонецЕсли;	
	
	РезультаВыполнения = ВыполнитьПушВУдаленныйРепозиторий();
	Если РезультаВыполнения.Ошибка Тогда
		ЗаполнитьЗначенияСвойств(РезультаВыполнения, Результат);
		Возврат Результат;
	КонецЕсли;
	
	ДобавитьЗаписьВЛог("ПУШ ВЫПОЛНЕН");
	ДобавитьЗаписьВЛог();
	
	Возврат Результат;
КонецФункции     

Функция УстановитьУдаленныйРепозиторий()             
	Результат = Новый Структура("Ошибка, ТекстОшибки", Ложь, "");
	
	ФайлСпискаУдаленныхРепозиториев = мПараметры.КаталогВременныхФайлов + "git.remote";

	СтрокаКоманды = "#!/bin/bash   
	|LOGFILE=""%ФайлЛога%""
	|REMOTEREPOFILE=""%ФайлСпискаУдаленныхРепозиториев%""
	|cd '%КаталогХранилищаГит%' >> $LOGFILE 2>&1
	|git remote -v > $REMOTEREPOFILE";   
	
	ПараметрыКоманды = Новый Структура;  
	ПараметрыКоманды.Вставить("КаталогХранилищаГит", мПараметры.КаталогХранилищаГит); 	
	ПараметрыКоманды.Вставить("ФайлСпискаУдаленныхРепозиториев",  ФайлСпискаУдаленныхРепозиториев);	
	
	РезультатВыполненияКоманды = ВыполнитьКомандуГит(СтрокаКоманды, ПараметрыКоманды);
	
	Если РезультатВыполненияКоманды.Ошибка Тогда
		ЗаполнитьЗначенияСвойств(Результат, РезультатВыполненияКоманды);
		Возврат Результат;
	КонецЕсли;
	
	Текст = ПолучитьТекстФайла(ФайлСпискаУдаленныхРепозиториев);
	Если СтрНайти(Текст, мПараметры.АдресУдаленногоРепозитория) > 0 Тогда
		Возврат Результат;
	КонецЕсли;
	
	СтрокаКоманды = "#!/bin/bash  
	|LOGFILE=""%ФайлЛога%""
	|cd '%КаталогХранилищаГит%' >> $LOGFILE 2>&1
	|git remote add gerrit %АдресУдаленногоРепозитория% >> $LOGFILE 2>&1"; 
	
	ПараметрыКоманды = Новый Структура;  
	ПараметрыКоманды.Вставить("КаталогХранилищаГит", мПараметры.КаталогХранилищаГит);
	ПараметрыКоманды.Вставить("АдресУдаленногоРепозитория", мПараметры.АдресУдаленногоРепозитория);
	
	РезультатВыполненияКоманды = ВыполнитьКомандуГит(СтрокаКоманды, ПараметрыКоманды);
	
	Если РезультатВыполненияКоманды.Ошибка Тогда
		ЗаполнитьЗначенияСвойств(Результат, РезультатВыполненияКоманды);
		Возврат Результат;
	КонецЕсли;	
	
	Возврат Результат;
	
КонецФункции 

Функция ВыполнитьПушВУдаленныйРепозиторий()
	Результат = Новый Структура("Ошибка, ТекстОшибки", Ложь, "");
			
	СтрокаКоманды = "#!/bin/bash 
	|LOGFILE=""%ФайлЛога%""
	|cd '%КаталогХранилищаГит%' >> $LOGFILE 2>&1
	|GIT_SSH_COMMAND=""ssh -i %GerritSshKey% -o StrictHostKeyChecking=no"" git push gerrit HEAD:refs/for/master >> $LOGFILE 2>&1"; 
	
	ПараметрыКоманды = Новый Структура;  
	ПараметрыКоманды.Вставить("КаталогХранилищаГит", мПараметры.КаталогХранилищаГит);
	ПараметрыКоманды.Вставить("GerritSshKey", мПараметры.GerritSshKey);
	
	РезультатВыполненияКоманды = ВыполнитьКомандуГит(СтрокаКоманды, ПараметрыКоманды);
	
	Если РезультатВыполненияКоманды.Ошибка Тогда
		ЗаполнитьЗначенияСвойств(Результат, РезультатВыполненияКоманды);
		Возврат Результат;
	КонецЕсли;	
	
	Возврат Результат;
КонецФункции
///////////////////////////////////// ВСПОМОГАТЕЛЬНЫЕ АЛГОРИТМЫ /////////////////////////////////////

Функция ПолучитьДатуИзСтроки(Дата, Время)
	МассивДаты = СтрРазделить(Дата, ".");
	МассивВремени = СтрРазделить(Время, ":");
	
	Возврат Дата(МассивДаты[2], МассивДаты[1], МассивДаты[0], МассивВремени[0], МассивВремени[1], МассивВремени[2]);
КонецФункции

Функция ВыполнитьКомандуСистемы(СтрокаКоманды, ПараметрыКоманды, КаталогКоманды = "") 
	
	Результат = Новый Структура("Ошибка, ТекстОшибки", Ложь, "");

	ИмяФайлаЛогаКоманды = мПараметры.КаталогВременныхФайлов + "command_log.txt";
	
	Для Каждого Элемент ИЗ ПараметрыКоманды Цикл
		СтрокаКоманды = СтрЗаменить(СтрокаКоманды, "%" + Элемент.Ключ + "%", Элемент.Значение);		
	КонецЦикла; 
	СтрокаКоманды = СтрЗаменить(СтрокаКоманды, "%ИмяФайлаЛогаКоманды%", ИмяФайлаЛогаКоманды);
	
	ДобавитьЗаписьВЛог("ВыполнениеКоманды : " + Символы.ПС + СтрокаКоманды);
	ДобавитьЗаписьВЛог("Лог : " + Символы.ПС + ИмяФайлаЛогаКоманды);
		
	КодВозврата = Неопределено;
	ЗапуститьПриложение(СтрокаКоманды, мПараметры.КаталогВременныхФайлов, Истина, КодВозврата);
	
	ТекстФайла = ПолучитьТекстФайла(ИмяФайлаЛогаКоманды);
	Если КодВозврата <> 0 Тогда
		Результат.Ошибка = Истина;
		Результат.ТекстОшибки = "Код возврата = " + Строка(КодВозврата) + "
		|" + ТекстФайла;
		Возврат Результат;			
	КонецЕсли;    
		
	Возврат Результат;
	
КонецФункции    

Функция ВыполнитьПакетнуюКомандуСистемы(СтрокаКоманды, ПараметрыКоманды, КаталогКоманды = "") 
	
	Результат = Новый Структура("Ошибка, ТекстОшибки", Ложь, "");
	
	ИмяФайлаПакетнойОперации = мПараметры.КаталогВременныхФайлов + "command.bat";
	ИмяФайлаЛогаКоманды = мПараметры.КаталогВременныхФайлов + "command_log.txt";
	
	Для Каждого Элемент ИЗ ПараметрыКоманды Цикл
		СтрокаКоманды = СтрЗаменить(СтрокаКоманды, "%" + Элемент.Ключ + "%", Элемент.Значение);		
	КонецЦикла; 
	СтрокаКоманды = СтрЗаменить(СтрокаКоманды, "%ИмяФайлаЛогаКоманды%", ИмяФайлаЛогаКоманды);   
	
	ФайлПакетнойОперации = Новый ТекстовыйДокумент;
	ФайлПакетнойОперации.УстановитьТекст(СтрокаКоманды);
	ФайлПакетнойОперации.Записать(ИмяФайлаПакетнойОперации, "CESU-8");
	
	ДобавитьЗаписьВЛог("ВыполнениеКоманды : " + Символы.ПС + СтрокаКоманды);
	ДобавитьЗаписьВЛог("ФайлПакетнойОперации : " + Символы.ПС + ИмяФайлаПакетнойОперации);
	ДобавитьЗаписьВЛог("Лог : " + Символы.ПС + ИмяФайлаЛогаКоманды);
		
	КодВозврата = Неопределено;
	ЗапуститьПриложение(ИмяФайлаПакетнойОперации, мПараметры.КаталогВременныхФайлов, Истина, КодВозврата);
	
	ТекстФайла = ПолучитьТекстФайла(ИмяФайлаЛогаКоманды);
	Если КодВозврата <> 0 Тогда
		Результат.Ошибка = Истина;
		Результат.ТекстОшибки = "Код возврата = " + Строка(КодВозврата) + "
		|" + ТекстФайла;
		Возврат Результат;			
	КонецЕсли;    
		
	Возврат Результат;
	
КонецФункции


Функция ВыполнитьПакетнуюКоманду(СтрокаПакетнойКоманды, ПараметрыКоманды)   
	Результат = Новый Структура("Ошибка, ТекстОшибки", Ложь, "");

	ИмяФайлаПакетнойОперации = мПараметры.КаталогВременныхФайлов + "command.txt";
	ИмяФайлаЛогаКоманды = мПараметры.КаталогВременныхФайлов + "command_log.txt";
	ИмяФайлаРезультатаКоманды = мПараметры.КаталогВременныхФайлов + "command_result.txt";
	
	Для Каждого Элемент ИЗ ПараметрыКоманды Цикл
		СтрокаПакетнойКоманды = СтрЗаменить(СтрокаПакетнойКоманды, "%" + Элемент.Ключ + "%", Элемент.Значение);		
	КонецЦикла; 
	СтрокаПакетнойКоманды = СтрЗаменить(СтрокаПакетнойКоманды, "%ИмяФайлаЛогаКоманды%", ИмяФайлаЛогаКоманды);
	СтрокаПакетнойКоманды = СтрЗаменить(СтрокаПакетнойКоманды, "%ИмяФайлаРезультатаКоманды%", ИмяФайлаРезультатаКоманды);
	
	ФайлПакетнойОперации = Новый ТекстовыйДокумент;
	ФайлПакетнойОперации.УстановитьТекст(СтрокаПакетнойКоманды);
	ФайлПакетнойОперации.Записать(ИмяФайлаПакетнойОперации, "CESU-8");
	
	СтрокаКоманды = """%КаталогИсполняемогоФайла%1cv8"" /@ ""%ИмяФайлаПакетнойОперации%""";
	СтрокаКоманды = СтрЗаменить(СтрокаКоманды, "%КаталогИсполняемогоФайла%", мПараметры.КаталогИсполняемогоФайла1С);
	СтрокаКоманды = СтрЗаменить(СтрокаКоманды, "%ИмяФайлаПакетнойОперации%", ИмяФайлаПакетнойОперации);
	
	ДобавитьЗаписьВЛог("ВыполнениеКоманды : " + Символы.ПС + СтрокаПакетнойКоманды);
	ДобавитьЗаписьВЛог("Команда : " + Символы.ПС + СтрокаКоманды);
		
	КодВозврата = Неопределено;
	ЗапуститьПриложение(СтрокаКоманды, мПараметры.КаталогВременныхФайлов, Истина, КодВозврата);
	РезультатВыполнения = ПолучитьТекстФайла(ИмяФайлаРезультатаКоманды); 
	
	Если КодВозврата = Неопределено Тогда
		Результат.Ошибка = Истина;
		Результат.ТекстОшибки = "Код возврата = НЕОПРЕДЕЛЕНО";
		Возврат Результат;			
	КонецЕсли;
	
	Если НЕ РезультатВыполнения = "0" Тогда
		Результат.Ошибка = Истина;
		Результат.ТекстОшибки = "Результат выполнения = " + РезультатВыполнения + "
		|" + ПолучитьТекстФайла(ИмяФайлаЛогаКоманды);
		Возврат Результат;	
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

Функция ВыполнитьКомандуГит(СтрокаКомандыГит, ПараметрыКоманды)      
	Результат = Новый Структура("Ошибка, ТекстОшибки", Ложь, "");
	
	ФайлКомандыGit = мПараметры.КаталогВременныхФайлов + "git_command.sh";
	ФайлЛога = мПараметры.КаталогВременныхФайлов + "git_log.txt";
	
	Для Каждого Элемент ИЗ ПараметрыКоманды Цикл
		СтрокаКомандыГит = СтрЗаменить(СтрокаКомандыГит, "%" + Элемент.Ключ + "%", Элемент.Значение);		
	КонецЦикла;  
	СтрокаКомандыГит = СтрЗаменить(СтрокаКомандыГит, "%ФайлЛога%", ФайлЛога);		
	
	ТекстКоманды = Новый ТекстовыйДокумент;
	ТекстКоманды.УстановитьТекст(СтрокаКомандыГит);  	
	ТекстКоманды.Записать(ФайлКомандыGit, "CESU-8"); 
	
	СтрокаВыполняемойКоманды = мПараметры.АдресИсполняемогоФайлаБаш + " " + ФайлКомандыGit;
	
	ДобавитьЗаписьВЛог("ВыполнениеКоманды : " + Символы.ПС + СтрокаКомандыГит);
	ДобавитьЗаписьВЛог("Команда : " + СтрокаВыполняемойКоманды);
	
	КодВозврата = Неопределено;
	ЗапуститьПриложение(СтрокаВыполняемойКоманды, мПараметры.КаталогХранилищаГит, Истина);
	
	Если КодВозврата <> Неопределено И КодВозврата <> 0 Тогда
		Результат.Ошибка = Истина;
		Результат.ТекстОшибки = ПолучитьТекстФайла(ФайлЛога);
		Возврат Результат;			
	КонецЕсли;  
	
	ДобавитьЗаписьВЛог("Команда Гит выполнена");
		
	Возврат Результат;
КонецФункции	
	
Функция ПолучитьТекстФайла(ИмяФайла)
	
	Текст = Новый ТекстовыйДокумент;
	Текст.Прочитать(ИмяФайла);
	
	Строка = Текст.ПолучитьТекст();
	Возврат СокрЛП(Строка);	
	
КонецФункции   

Процедура ДобавитьЗаписьВЛог(Текст = "", Ошибка = Ложь) 
	ТекстОшибки = " ";
	Если Ошибка Тогда
		ТекстОшибки = " !ОШИБКА! ";
	КонецЕсли;    
	СтрокаЛога = Строка(ТекущаяДата()) + ТекстОшибки + Текст;
	Лог.ДобавитьСтроку(СтрокаЛога);
	
	ЗаписатьЛогВФайл(СтрокаЛога);
КонецПроцедуры  

Процедура ЗаписатьЛогВФайл(СтрокаЛога)
	ПутьКФайлуЛога = мПараметры.КаталогВременныхФайлов + "log.txt"; 
	
	ТекстДляЗаписи = Новый ЗаписьТекста; 
	ТекстДляЗаписи.Открыть(ПутьКФайлуЛога, "CESU-8", , Истина);
	ТекстДляЗаписи.ЗаписатьСтроку(СтрокаЛога); 
	ТекстДляЗаписи.Закрыть();
КонецПроцедуры  

Процедура ОчиститьЛог() 
	Лог.Очистить();
	
	ПутьКФайлуЛога = мПараметры.КаталогВременныхФайлов + "log.txt";
	Файл = Новый Файл(ПутьКФайлуЛога);
	
	Если Файл.Существует() Тогда      
		ПутьКФайлуПрошлогоЛога = мПараметры.КаталогВременныхФайлов + "prev_log.txt";
		КопироватьФайл(ПутьКФайлуЛога, ПутьКФайлуПрошлогоЛога);			
	КонецЕсли;
	
	НовыйЛог = Новый ТекстовыйДокумент;
	НовыйЛог.Записать(ПутьКФайлуЛога, "CESU-8");
КонецПроцедуры