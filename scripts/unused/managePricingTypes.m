function pricing = managePricingTypes(pricing)
    % desired:
    names = ["ID", "Name", "Menge", "Preis", "Erfassungsdatum"];
    types= ["double", "string", "double", "double", "datetime"];

    pricing = manageTypes(pricing, names, types);
end