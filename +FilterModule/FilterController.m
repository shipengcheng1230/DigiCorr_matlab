classdef FilterController < handle
    %FILTERCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        modelObj
        viewObj
    end
    
    methods
        function obj = FilterController(viewObj, modelObj)
            obj.modelObj = modelObj;
            obj.viewObj = viewObj;
        end
        
        function filter_button_callback(obj, ~, ~)
            try
                obj.modelObj.order = obj.viewObj.inputOrder;
                obj.modelObj.lowfreq = obj.viewObj.inputLowfreq;
                if obj.viewObj.inputHighfreq >= ...
                        obj.modelObj.hSignalData.sampleRate / 2
                    msgbox('Exceeding Nyquist Frequency')
                    return
                end
                obj.modelObj.highfreq = obj.viewObj.inputHighfreq;
                obj.modelObj.filter();
            catch
                return
            end
        end
        
        function reset_button_callback(obj, ~, ~)
            obj.modelObj.hSignalData.reloadData();
        end
    end
    
end

