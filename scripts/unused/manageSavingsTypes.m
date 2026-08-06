function pricing = manageSavingsTypes(pricing)
    % desired:
    names = ["ID", "Name", "Guthaben", "Aktualisierungsdatum"];
    types= ["double", "string", "double", "datetime"];

    pricing = manageTypes(pricing, names, types);
end