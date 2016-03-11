classdef DataInputSelectView < handle
    %DATAINPUT Summary of this class goes here
    %   Detailed explanation goes here    
    
    properties
    end
    
    methods(Static)
        function choice = chooseMode()
            viewSize = [100 100 300 200];
            dlg_title = 'Select Mode';
            
            dlg = dialog(...
                'Position', viewSize, ...
                'Name', dlg_title);
            movegui(dlg, 'center');
            mainLayout = uiextras.VBox(...
                'Parent', dlg, ...
                'Padding', 10);
            
            text = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', 'Select A Mode: ');
            
            popup = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'popup', ...
                'String', {'Stored Data', 'Real Time'}, ...
                'Callback', @popup_callback);
            choice = 'Stored Data';
            
            btn = uicontrol(...
                'Parent', mainLayout, ...
                'String', 'Confirm', ...
                'Callback', 'delete(gcf)');
            
            set(mainLayout, 'Sizes', [50 50 50], 'Spacing', 10);
            uiwait(dlg)
            
            function popup_callback(popup, callbackdata)
                idx = popup.Value;
                popup_items = popup.String;
                choice = char(popup_items(idx, :));
            end
        end
    end
    
end

