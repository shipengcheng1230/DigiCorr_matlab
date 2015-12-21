classdef FilterModel < handle
    %FILTERMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hSignalData
        
        order = 4
        lowfreq = 0
        highfreq = 0
    end
    
    methods
        function obj = FilterModel()
            disp('Filter Model')
            obj.hSignalData = Context.getInstance.getData('SignalData');
        end
        
        function set.order(obj, order)
            try
                validateattributes(order, {'double'}, {'integer'})
                if order < 0 || mod(order, 2)
                    msgbox('Invalid order')
                    return
                end
                obj.order = order;
            catch
                msgbox('Invalid order')
            end
        end
        
        function set.lowfreq(obj, lowfreq)
            if lowfreq <= 0
                msgbox('Invalid Lowfreq')
                ME = MException('filterSetError: invalidLowFreq', ...
                    'lowfreq %f invalid.\n', lowfreq);
                throw(ME);                
            end
            obj.lowfreq = lowfreq;
        end
        
        function set.highfreq(obj, highfreq)
            if highfreq <= 0
                msgbox('Invalid Highfreq')
                ME = MException('filterSetError: invalidHighFreq', ...
                    'highfreq %f invalid.\n', highfreq);
                throw(ME);                
            end
            obj.highfreq = highfreq;
        end
        
        function filter(obj)
            [b, a] = butter(obj.order, [obj.lowfreq obj.highfreq] / ...
                obj.hSignalData.sampleRate * 2);
            obj.hSignalData.filteredWaveData = ...
                filter(b, a, obj.hSignalData.waveData);
            obj.hSignalData.filteredPowerSpectrum = ...
                pwelch(obj.hSignalData.filteredWaveData, [], [], [], ...
                obj.hSignalData.sampleRate);
            obj.hSignalData.filteredcorrResult = xcorr(...
                obj.hSignalData.filteredWaveData(:, 1), ...
                obj.hSignalData.filteredWaveData(:, 2));
        end
    end
    
end

