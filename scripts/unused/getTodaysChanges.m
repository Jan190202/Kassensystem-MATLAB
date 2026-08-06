function todaysChanges = getTodaysChanges(changes)
    dateToday = datetime("today");

    dateStamps = changes{:,1};
    todaysFirstRow = find(datetime(dateStamps), dateToday);

    if isempty(todaysFirstRow)
        todaysChanges = [];
    else
        todaysChanges = changes{todaysFirstRow:end, :};
    end
end