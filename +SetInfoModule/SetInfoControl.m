classdef SetInfoControl < handle
    %SETINFOCONTROL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        modelObj
        viewObj
    end
    
    methods
        function obj = SetInfoControl(viewObj, modelObj)
            obj.viewObj = viewObj;
            obj.modelObj = modelObj;
        end
        
        function save_button_callback(obj, ~, ~)
            obj.viewObj.hSetCurrentDataPanel.controlObj.save_input();
            obj.viewObj.hSetPipInfoPanel.controlObj.save_input();
        end
    end
    
end

