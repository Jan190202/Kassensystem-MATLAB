function data = applyChanges(data, changes)
    fields = string(fieldnames(changes));
    for field = reshape(fields, 1, [])
        if isfield(changes.(field), "deleted")
            IDsToDelete = changes.(field).deleted.ID;
            data.(field)(ismember(data.(field).ID, IDsToDelete),:) = [];
        end
        if isfield(changes.(field), "added")
            data.(field) = [data.(field); changes.(field).added];
        end
    end

    %% log creation
    data = addLogEntries(data, changes);
end