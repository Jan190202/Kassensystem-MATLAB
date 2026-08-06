function ID = getID(IDsInUse)
    nDigits = 6;

    if length(IDsInUse) >= 10^nDigits - 10^(nDigits-1)
        warning("Possible IDs soon to be all in use. Possible amount: " + 10^nDigits - 10^(nDigits-1) + "; in use: " + length(IDsInUse) + ". The less IDs are free, the longer the random creation of new ones will take!");
    end

    ID = getRandom();
    while(any(IDsInUse == ID))
        ID = getRandom();
    end

        function x = getRandom()
            maxRandVal = 10^nDigits - 10^(nDigits-1);   % for 6 digits: 900,000
            xTemp = randi(maxRandVal);                  % creates value in interval (1, maxRandVal)
            x = xTemp + 10^(nDigits-1)-1;               % adjusts interval, for 6 digits: 100,000 - 999,999
        end
    end


