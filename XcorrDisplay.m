classdef XcorrDisplay < handle
    %XCORRDISPLAY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hSignalData
        hParent
        
        hXcorrPanel
        hXcorrDisp
    end
    
    methods
        function obj = XcorrDisplay(parentFig)
            obj.hParent = parentFig;
            obj.hSignalData = Context.getInstance.getData('SignalData');
            obj.hSignalData.addlistener(...
                'dataimport', @obj.updateView);
            obj.hSignalData.addlistener(...
                'filterXcorr', @obj.updateFilterView);
            
            obj.buildUI();
            obj.updateView();
        end
        
        function buildUI(obj)
            obj.hXcorrPanel = uipanel(...
                'Parent', obj.hParent, ...
                'Title', 'Time Correlation', ...
                'Visible', 'off');
            obj.hXcorrDisp = axes(...
                'Parent', obj.hXcorrPanel, ...
                'NextPlot', 'replace');
            set(obj.hXcorrPanel, 'Visible', 'on');
        end
        
        function updateView(obj, ~, ~, isfilter)
            if nargin < 4
                isfilter = 0;
            end
            switch isfilter
                case 0
                    corrResult = obj.hSignalData.corrResult;
                case 1
                    corrResult = obj.hSignalData.filteredcorrResult;
                otherwise
                    msgbox('isfilter invalid')
                    return
            end
            corrResult = corrResult / max(abs(corrResult));
            
            timeserial = obj.hSignalData.timeSerial;
            refertime = horzcat(-fliplr(timeserial), 0, timeserial);
            refertime = refertime(2: end - 1);
            
            plot(obj.hXcorrDisp, ...
                refertime, corrResult);
            
            htext = text('String', 'Shift Time');
            set(obj.hXcorrDisp, 'Xlabel', htext);
            htext = text('String', 'Amplitude');
            set(obj.hXcorrDisp, 'Ylabel', htext);
        end
        
        function updateFilterView(obj, src, eventdata)
            updateView(obj, src, eventdata, 1)
        end
    end
    
end

