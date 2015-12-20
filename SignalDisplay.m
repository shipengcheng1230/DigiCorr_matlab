classdef SignalDisplay < handle
    %SIGNALDISPLAY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hSignalData
        hParent
        
        hSignalTab
        hDataPanel
        hDataDisp_ch1
        hDataDisp_ch2
        hSpectrumPanel
        hSpectrumDisp
    end
    
    methods
        function obj = SignalDisplay(parentFig)
            obj.hParent = parentFig;
            obj.hSignalData = Context.getInstance.getData('SignalData');
            obj.hSignalData.addlistener(...
                'dataimport', @obj.updateView);
            obj.hSignalData.addlistener(...
                'filterSignal', @obj.updateFilterView);
            obj.buildUI();
            obj.updateView();
        end
        
        function buildUI(obj)
            obj.hSignalTab = uitabgroup(...
                'Parent', obj.hParent, ...
                'Visible', 'off');
            
            obj.hDataPanel = uitab(...
                'Parent', obj.hSignalTab, ...
                'Title', 'Signal');
            obj.hDataDisp_ch1 = subplot(2, 1, 1, ...
                'Parent', obj.hDataPanel, ...
                'NextPlot', 'replace');
            obj.hDataDisp_ch2 = subplot(2, 1, 2, ...
                'Parent', obj.hDataPanel, ...
                'NextPlot', 'replace');
            
            obj.hSpectrumPanel = uitab(...
                'Parent', obj.hSignalTab, ...
                'Title', 'Spectrum');
            obj.hSpectrumDisp = axes(...
                'Parent', obj.hSpectrumPanel, ...
                'NextPlot', 'replace');
            set(obj.hSignalTab, 'Visible', 'on');
        end
        
        function updateView(obj, ~, ~, isfilter)
            if nargin < 4
                isfilter = 0;
            end
            switch isfilter
                case 0
                    signal = obj.hSignalData.waveData;
                    powerSpectrum = obj.hSignalData.powerSpectrum;
                case 1
                    signal = obj.hSignalData.filteredWaveData;
                    powerSpectrum = obj.hSignalData.filteredPowerSpectrum;
                otherwise
                    msgbox('isfilter invalid')
                    return
            end
            plot(obj.hDataDisp_ch1, ...
                obj.hSignalData.timeSerial, ...
                signal(:, 1));
            
            plot(obj.hDataDisp_ch2, ...
                obj.hSignalData.timeSerial, ...
                signal(:, 2), ...
                'color', [0.85 0.33 0.1]);
            
            htext = text('String', 'Time');
            set(obj.hDataDisp_ch1, 'Xlabel', htext);
            set(obj.hDataDisp_ch2, 'Xlabel', htext);
            
            htext = text('String', 'Amplitude');
            set(obj.hDataDisp_ch1, 'Ylabel', htext);
            set(obj.hDataDisp_ch2, 'Ylabel', htext);
            
            freq = obj.hSignalData.freq;            
            hplot = plot(obj.hSpectrumDisp, ...
                freq, 10 * log10(powerSpectrum(:, 1)), ...
                freq, 10 * log10(powerSpectrum(:, 2)));
            htext = text('String', 'Frequency (Hz)');
            set(obj.hSpectrumDisp, 'Xlabel', htext);
            htext = text('String', 'Magnitude (dB)');
            set(obj.hSpectrumDisp, 'Ylabel', htext);
            grid(obj.hSpectrumDisp, 'on')
            legend(hplot, 'Rec_1', 'Rec_2')
        end
        
        function updateFilterView(obj, src, eventdata)
            obj.updateView(src, eventdata, 1);
        end
    end
    
end

