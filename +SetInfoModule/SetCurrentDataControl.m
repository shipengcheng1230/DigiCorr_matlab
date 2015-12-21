classdef SetCurrentDataControl < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        currentDataHandle
        setCurrentDataView
    end
    
    methods
        function obj = SetCurrentDataControl(...
                setCurrentDataView, currentDataHandle)
            obj.currentDataHandle = currentDataHandle;
            obj.setCurrentDataView = setCurrentDataView;
        end
        
        function save_input(obj)
            obj.currentDataHandle.userName = ...
                obj.setCurrentDataView.userNameEdit.String;
            obj.currentDataHandle.location = ...
                obj.setCurrentDataView.locationEdit.String;
            obj.currentDataHandle.actionState = ...
                obj.setCurrentDataView.actionStatePopup.Value;
            obj.currentDataHandle.leakDist = num2str(...
                obj.setCurrentDataView.leakDistShow.String);
        end
    end
    
end

