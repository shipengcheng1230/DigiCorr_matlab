classdef Context < handle
    %CONTEXT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataDict
    end
    
    methods(Access = private)
        function obj = Context()
            obj.dataDict = containers.Map();
        end
    end
    
    methods(Static)
        function obj = getInstance()
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = Context();
            end
            obj = localObj;
        end
    end
    
    methods
        function register(obj, ID, data)
            if isnumeric(ID)
                ID = num2str(ID);
            end
            if ~ischar(ID)
                ME = MException('Context:RegisterIDinValid', ...
                    'Register ID %s invalid!\r\n', ID);
                throw(ME)                
            else
                obj.dataDict(ID) = data;
            end
        end
        
        function data = getData(obj, ID)
            if isKey(obj.dataDict, ID)
                data = obj.dataDict(ID);
            else
                ME = MException('Context:RequiredIDnotExist', ...
                    'Required ID %s not exist!\r\n', ID);
                throw(ME)
            end
        end
    end
end

