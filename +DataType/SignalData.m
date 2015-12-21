classdef SignalData < handle
    %SIGNALDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        waveData = rand(1000, 2)
        timeSerial = (1: 1000)
        sampleRate = 1
        
        filteredWaveData
        filteredPowerSpectrum
        filteredcorrResult
    end
    
    properties(Dependent)
        corrResult
        powerSpectrum       
        freq
    end
    
    properties(Constant)
        channel = 2
    end
    
    events
        dataimport
        correlation
        spectrum
        filterSignal
        filterXcorr
    end
    
    methods
        function obj = SignalData()
            disp('Signal Data Structure')
        end
        
        function result = get.corrResult(obj)
            result = xcorr(obj.waveData(:, 1), obj.waveData(:, 2));
        end
        
        function result = get.powerSpectrum(obj)
            result =...
                pwelch(obj.waveData, [], [], [], obj.sampleRate);            
        end
        
        function result = get.freq(obj)
            [~, result] = ...
                pwelch(obj.waveData(:, 1), [], [], [], obj.sampleRate);
        end
        
        function set.waveData(obj, wavedata)
            obj.waveData = wavedata;
            obj.notify('dataimport')
            obj.notify('correlation')
            obj.notify('spectrum')
        end
        
        function set.filteredWaveData(obj, filteredWaveData)
            obj.filteredWaveData = filteredWaveData;
        end
        
        function set.filteredPowerSpectrum(obj, filteredPowerSpectrum)
            obj.filteredPowerSpectrum = filteredPowerSpectrum;
            obj.notify('filterSignal')
        end
        
        function set.filteredcorrResult(obj, filteredcorrResult)
            obj.filteredcorrResult = filteredcorrResult;
            obj.notify('filterXcorr')
        end
        
        function reloadData(obj)
            obj.notify('dataimport')
            obj.notify('correlation')
            obj.notify('spectrum')
        end
    end
    
end

