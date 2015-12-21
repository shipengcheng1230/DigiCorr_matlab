classdef ProcessData < handle
    %PROCESSDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        currentDataHandle
        pipInfoHandle
        equipInfoHandle
        signalDataHandle
    end
    
    methods
        function obj = ProcessData(currentdata, signaldata, pipinfo)
            disp('Initiate Process Data Structure.')
            obj.currentDataHandle = currentdata;
            obj.signalDataHandle = signaldata;
            obj.pipInfoHandle = pipinfo;
        end
    end
    
end

