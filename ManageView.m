classdef ManageView < handle
    %MANAGEVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hFig
        
        hFilterPanel
        hSignalTab
        hXcorrPanel
        hXcorrDisp
        hButtonPanel
        
        modelObj
        controlObj
    end
    
    properties(Constant)
        viewSize = [100 100 1600 900]
    end
    
    methods
        function obj = ManageView()
            obj.modelObj = Context.getInstance.getData('ProcessData');
            obj.buildUI();
        end
        
        function buildUI(obj, hParent)
            %             choose = obj.chooseMode();
            %             switch choose
            %                 case 'Stored Data'
            %                     [filename, pathname] = obj.dataImport();
            %                 case 'Real Time'
            %                     [userName, location] = obj.loginView();
            %             end
            
            if nargin < 2
                hParent = groot;
            end
            
            filtermodel = Context.getInstance.getData('Filter');
            signaldata_handle = obj.modelObj.signalDataHandle;
            
            obj.hFig = figure(...
                'Parent', hParent, ...
                'Units', 'normalized', ...
                'OuterPosition', [0.1 0.1 0.8 0.8], ...
                'Visible', 'off');
            
            mainLayout = uiextras.HBox(...
                'Parent', obj.hFig, ...
                'Padding', 10);
            
            leftLayout = uiextras.VBox(...
                'Parent', mainLayout, ...
                'Padding', 10);
            obj.hButtonPanel = ButtonPanel(leftLayout);
            uiextras.Empty('Parent', leftLayout);
            uiextras.Empty('Parent', leftLayout);
            obj.hFilterPanel = FilterView(leftLayout, filtermodel);
            set(leftLayout, 'Sizes', [-1 -1 -1 -1], 'Spacing', 10);
            
            rightLayout = uiextras.VBox(...
                'Parent', mainLayout, ...
                'Padding', 10);
            obj.hSignalTab = SignalDisplay(rightLayout, signaldata_handle);
            obj.hXcorrPanel = XcorrDisplay(rightLayout, signaldata_handle);
            set(rightLayout, 'Sizes', [-1 -1], 'Spacing', 10);
            
            set(mainLayout, 'Sizes', [-1 -2], 'Spacing', 20);
            set(obj.hFig, 'Visible', 'on');
        end
        
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
            
            uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', 'Select A Mode: ');
            uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'popup', ...
                'String', {'Stored Data', 'Real Time'}, ...
                'Callback', @popup_callback);
            choice = 'Stored Data';
            uicontrol(...
                'Parent', mainLayout, ...
                'String', 'Confirm', ...
                'Callback', 'delete(gcf)');
            
            set(mainLayout, 'Sizes', [50 50 50], 'Spacing', 10);
            uiwait(dlg)
            
            function popup_callback(popup, ~)
                idx = popup.Value;
                popup_items = popup.String;
                choice = char(popup_items(idx, :));
            end
        end
        
        function [userName, location] = loginView()
            prompt = {'Name: ', 'Location: '};
            dlg_title = 'Login';
            num_lines = 1;
            answers = ...
                inputdlg(prompt, dlg_title, num_lines);
            userName = answers{1};
            location = answers{2};
        end
        
        function [filename, pathname] = dataImport()
            dlgTitle = 'Select Data';
            [filename, pathname] = uigetfile('DialogTitle', dlgTitle);
        end
    end
    
end

