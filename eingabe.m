 if ~isdeployed
    clear
    close all
    close(findall(0, 'type', 'figure'))
    clc
    
    addpath(genpath("scripts"))
    addpath("data")
end

load("data\data.mat", "data")

[mainWindow, tabGroup, tabElements, lowerButtons] = setupMainWindow();

returnState = "";
while returnState ~= "exit"
    [changes, returnState] = startNewTabOperation(tabGroup, tabElements, lowerButtons, data);

    if returnState == "apply" || returnState == "save"
        data = applyChanges(data, changes);
        if returnState == "save"
            saveData(data);
        end
    end
end

close(mainWindow)


