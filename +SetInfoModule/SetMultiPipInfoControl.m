classdef SetMultiPipInfoControl < handle
    %SETMULTIPIPINFOCONTROL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pipInfoHandle
        SetMultiPipInfoView
    end
    
    methods
        function obj = SetMultiPipInfoControl(...
                SetMultiPipInfoView, pipInfoHandle)
            obj.pipInfoHandle = pipInfoHandle;
            obj.SetMultiPipInfoView = SetMultiPipInfoView;
        end
        
        function save_button_callback(obj, ~, ~)
            segments = length(obj.SetMultiPipInfoView.listNumText);
            obj.pipInfoHandle.pipSegments = segments;
            obj.pipInfoHandle.multiPip = true;
            
            obj.pipInfoHandle.pipLength = ...
                obj.SetMultiPipInfoView.pipLength;
            obj.pipInfoHandle.diameter = ...
                obj.SetMultiPipInfoView.diameter;
            obj.pipInfoHandle.velocity = ...
                obj.SetMultiPipInfoView.velocity;
            obj.pipInfoHandle.material = ...
                obj.SetMultiPipInfoView.material;            
        end
    end
    
end

