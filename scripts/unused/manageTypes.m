function table = manageTypes(table, names, types)
    for columnNum = 1:length(names)
        nameDesired = names(columnNum);
        nameActual = string(table.Properties.VariableNames{columnNum});
        typeDesired = types(columnNum);
        typeActual = string(class(table.(nameActual)));
        
        % set variable names
        if ~(nameActual == nameDesired)
            table.Properties.VariableNames(columnNum) = nameDesired;
        end

        % double to string
        if typeActual == "double" && typeDesired == "string"
            table.(nameDesired) = string(table.(nameDesired)); 
        end


        % cell to string
        if typeActual == "cell" && typeDesired == "string"
            table.(nameDesired) = string(table.(nameDesired)); 
        end

        % double to datetime
        if typeActual == "double" && typeDesired == "datetime"
            if ~isempty(table.(nameDesired)) && ~any(isnan(table.(nameDesired)))
                table.(nameDesired) = datetime(table.(nameDesired)); 
            else
                table.(nameDesired) = NaT(height(table.(nameDesired)),1);
            end
        end

        % string/cell to double
        if (typeActual == "string" || typeActual == "cell") && typeDesired == "double"
            table.(nameDesired) = str2double(string(table.(nameDesired))); 
        end

        % cell to datetime
        if typeActual == "cell" && typeDesired == "datetime"
            table.(nameDesired) = datetime(table.(nameDesired), "Locale", "de_DE");
        end
    end
end