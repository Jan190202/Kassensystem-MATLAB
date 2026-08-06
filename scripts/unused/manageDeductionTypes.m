function deduction = manageDeductionTypes(deduction)
    % desired:
    names = ["ID", "Datum", "Offen", "Bezahlt", "Rundungsfehler", "Kommentar"];
    types= ["double", "datetime", "double", "double", "double", "string"];

    deduction = manageTypes(deduction, names, types);
end