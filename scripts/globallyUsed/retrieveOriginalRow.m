function originalRow = retrieveOriginalRow(row, tableFilter, sortingVector)
    % assume table was first filtered (-> fTable = table(tableFilter,:)
    % then sorted (-> [sTable, sortingVector] = sortrow(fTable)
    % function returns original index of a row in sTable

    % unsort
    unsortedRow = sortingVector(row);

    % unfilter
    unfilteredRow = find(tableFilter, unsortedRow);     % returns first n true indices in tableFilter, where n = unsortedRow
    unfilteredRow = unfilteredRow(end);                 % tableData is subset of consumption using tableFilter. nth row of tableData is row of nth true value in tableFilter

    % return
    originalRow = unfilteredRow;


    % sortingVector: describes original indices, i.e. sortedTable(1,:) was originally in index sortingVector(1) of original table
    % meaning: table(sortingVector(1),:) = sortedTable(1,:), completely: table(sortingVector,:) = sortedTable
    % or: table(1,:) = sortedTable(find(sortingVector==1),:)
end