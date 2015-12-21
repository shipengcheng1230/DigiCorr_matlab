classdef CurrentData < handle
    %CURRENTDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        userName = 'spc'
        location = 'beijing'
        actionState = 2
        leakDist = NaN
    end    
    
    methods
        function obj = CurrentData()
            disp('Current Data Initiated!')
        end
        
        function set.userName(obj, userName)
            obj.userName = userName;
        end
        
        function set.location(obj, location)
            obj.location = location;
        end
        
        function set.actionState(obj, actionState)
            obj.actionState = actionState;
        end
        
        function set.leakDist(obj, leakDist)
            obj.leakDist = leakDist;
        end
    end
    
end

