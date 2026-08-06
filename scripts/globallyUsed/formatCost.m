function textOutput = formatCost(cost, varargin)
    if ~isempty(varargin) && isnumeric(varargin{1})
        nDigits = varargin{1};
    else
        nDigits = 2;
    end

    textOutput = sprintf(['%.' num2str(nDigits) 'f'], cost) + " €";
end