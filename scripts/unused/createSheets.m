function summarySheet = createSheets(userReports, uniqueNames, correspondingNameIdentifiers)
    summarySheet = cell(1000, 4);
    summarySheet(1,1:4) = {"Name", "Gesamt", "Bezahlt", "Ausstehend"};
    newEntryRowBegin = 2;
    for name = reshape(uniqueNames, 1, [])
        nameAlias = correspondingNameIdentifiers(uniqueNames == name);
    
        summarySheet(newEntryRowBegin, 1:4) = {name, userReports.(nameAlias).total, userReports.(nameAlias).paid, userReports.(nameAlias).due};
        newEntryRowBegin = newEntryRowBegin + 1;
    end
    summarySheet(newEntryRowBegin:end, :) = [];
end