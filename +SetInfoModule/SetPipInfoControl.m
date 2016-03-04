classdef SetPipInfoControl < handle
    %SETPIPINFOCONTROL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pipInfoHandle
        SetPipInfoView
    end
    
    methods
        function obj = SetPipInfoControl(viewObj, modelObj)
            obj.SetPipInfoView = viewObj;
            obj.pipInfoHandle = modelObj;
        end
        
        function multipip_set_callback(obj, ~, ~)
            segments = obj.SetPipInfoView.pipSegments;
            if round(segments) ~= segments
                msgbox('Invalid pip segments')
                return
            end
            import SetInfoModule.SetMultiPipInfoFig
            SetMultiPipInfoFig(obj.pipInfoHandle, obj.SetPipInfoView);
        end
        
        function save_input(obj)
            if strcmp(obj.SetPipInfoView.modeSelected, ...
                    obj.SetPipInfoView.singlePipRadio.String)
                obj.pipInfoHandle.multiPip = false;
                obj.pipInfoHandle.pipSegments = 1;
                
                obj.pipInfoHandle.pipLength = str2double(...
                    obj.SetPipInfoView.pipLengthEdit.String);
                obj.pipInfoHandle.radius_out = str2double(...
                    obj.SetPipInfoView.radius_outEdit.String);
                obj.pipInfoHandle.radius_in = str2double(...
                    obj.SetPipInfoView.radius_inEdit.String);
                obj.pipInfoHandle.velocityP = str2double(...
                    obj.SetPipInfoView.velocityEdit.StringP);
                obj.pipInfoHandle.velocityS = str2double(...
                    obj.SetPipInfoView.velocityEdit.StringS);
                obj.pipInfoHandle.material = ...
                    {obj.SetPipInfoView.materialEdit.String};
            else
                return
            end
        end
    end
    
end

