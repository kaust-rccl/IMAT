function val = validatedPropValue(cluster, prop, type, defaultValue)

% If we pass in a defaultValue, that means we want this property
% to be set to a specific value.
if nargin == 3
    switch type
        case 'char'
            defaultValue = '';
        case 'double'
            defaultValue = [];
        case 'bool'
            defaultValue = false;
        otherwise
            error('Not a valid data type')
    end
end

validatedPropValue = @IntegrationScripts.common.validatedPropValue;
val = validatedPropValue(cluster, prop, type, defaultValue);
