classdef SetInfoView < handle
    %SET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hParent = groot
        modelObj
        controlObj
        
        hFig
        hSetCurrentDataPanel
        hSetPipInfoPanel
        
        saveButton
    end
    
    methods
        function obj = SetInfoView(hParent, ModelObj)
            obj.hParent = hParent;
            obj.modelObj = ModelObj;
            obj.buildUI();
            obj.controlObj = obj.makeController();
            obj.attachToControl(obj.controlObj);
        end
        
        function buildUI(obj)
            obj.hFig = figure(...
                'Parent', obj.hParent, ...
                'Visible', 'off', ...
                'Name', 'Setting', ...
                'Units', 'normalized', ...
                'OuterPosition', [0.2 0.2 0.8 0.6]);
             movegui(obj.hFig, 'center');
             
             mainLayout = uiextras.VBox(...
                 'Parent', obj.hFig, ...
                 'Padding', 10);             
             upperLayout = uiextras.Grid(...
                 'Parent', mainLayout, ...
                 'Padding', 10);
             downLayout = uiextras.HBox(...
                 'Parent', mainLayout, ...
                 'Padding', 10);
             
             obj.hSetCurrentDataPanel = ...
                 SetInfoModule.SetCurrentDataPanel(...
                 upperLayout, ...
                 obj.modelObj.currentDataHandle);
             obj.hSetPipInfoPanel = ...
                 SetInfoModule.SetPipInfoPanel(...
                 upperLayout, ...
                 obj.modelObj.pipInfoHandle);
             uiextras.Empty('Parent', upperLayout);
             uiextras.Empty('Parent', upperLayout);
             
             uiextras.Empty('Parent', downLayout);
             uiextras.Empty('Parent', downLayout);
             obj.saveButton = uicontrol(...
                 'Parent', downLayout, ...
                 'Style', 'pushbutton', ...
                 'String', 'Save');
             uiextras.Empty('Parent', downLayout);
             uiextras.Empty('Parent', downLayout);
             
             set(upperLayout, ...
                 'RowSizes', [-1 -1], ...
                 'ColumnSizes', [-1 -1], ...
                 'Spacing', 20);
             set(downLayout, 'Sizes', -ones(1, 5), 'Spacing', 10);
             set(mainLayout, 'Sizes', [-5 -1], 'Spacing', 10);
             set(obj.hFig, 'Visible', 'on');
        end
        
        function controlObj = makeController(obj)
            controlObj = ...
                SetInfoModule.SetInfoControl(obj, obj.modelObj);
        end
        
        function attachToControl(obj, controller)
            funcH = @controller.save_button_callback;
            set(obj.saveButton, 'callback', funcH);
        end
        
    end
    
end

