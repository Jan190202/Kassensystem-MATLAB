function weekDayArr = getWeekday(datetimeArr)
        % % input: dattime array of any size and dimension
        % % output: string array of corresponding german weekdays of same size and dimension
        % % does not work for NaT entries
        % weekdayTransl = ["Sonntag" "Montag" "Dienstag" "Mittwoch" "Donnerstag" "Freitag" "Samstag"];
        % 
        % weekDayArr = strings(size(datetimeArr));
        % for i = 1:numel(weekDayArr)
        %     dayNum = weekday(datetimeArr(i));
        %     weekDayArr(i) = weekdayTransl(dayNum);
        % end
        
        dayNumbers = weekday(datetimeArr);
        weekDayArr = strings(length(datetimeArr),1);

        weekDayArr(dayNumbers == 2) = "Montag";
        weekDayArr(dayNumbers == 3) = "Dienstag";
        weekDayArr(dayNumbers == 4) = "Mittwoch";
        weekDayArr(dayNumbers == 5) = "Donnerstag";
        weekDayArr(dayNumbers == 6) = "Freitag";
        weekDayArr(dayNumbers == 7) = "Samstag";
        weekDayArr(dayNumbers == 1) = "Sonntag";
    end