classdef SetPipInfoPanel < handle
    %SETPIPINFOPANEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hPanel
        hParent
        pipInfoHandle
        controlObj
        
        multiSelectBG
        singlePipRadio
        multiPipRadio
        
        pipLengthText
        diameterText
        materialText
        velocityText
        pipSegmentsText
        
        pipLengthEdit
        diameterEdit
        materialEdit
        velocityEdit
        pipSegmentsEdit
        
        multiPipSetButton
        multiPipSetFig
        
        modeSelected
    end
    
    properties(Dependent)
        pipLength
        diameter
        material
        velocity
        pipSegments
    end
    
    events
        modeChanged
    end
    
    methods
        function obj = SetPipInfoPanel(figParent, pipInfoHandle)
            obj.hParent = figParent;
            obj.pipInfoHandle = pipInfoHandle;
            obj.addlistener('modeChanged', @mode_active_callback);
            obj.buildUI();
            obj.controlObj = obj.makeController();
            obj.attachToControl(obj.controlObj);
            obj.updateView();
        end
        
        function buildUI(obj)
            obj.hPanel = uiextras.Panel(...
                'Parent', obj.hParent, ...
                'Title', 'Pip Information', ...
                'Visible', 'off');
            
            mainLayout = uiextras.HBox(...
                'Parent', obj.hPanel, ...
                'Padding', 10);
            
            obj.multiSelectBG = uibuttongroup(...
                'Visible','off',...
                'Parent', mainLayout, ...
                'SelectionChangedFcn', @buttongroup_selection);
            obj.singlePipRadio = uicontrol(...
                'Parent', obj.multiSelectBG, ...
                'Style', 'radiobutton', ...
                'String', 'Single Pip', ...
                'Position', [10 300 300 50], ...
                'Units', 'normalized');
            obj.multiPipRadio = uicontrol(...
                'Parent', obj.multiSelectBG, ...
                'Style', 'radiobutton', ...
                'String', 'Multi Pip', ...
                'Position', [10 50 300 50], ...
                'Units', 'normalized');
            obj.multiSelectBG.Visible = 'on';
            
            function buttongroup_selection(~, eventdata)
                obj.modeSelected = eventdata.NewValue.String;
            end
            
            rightLayout = uiextras.Grid(...
                'Parent', mainLayout, ...
                'Padding', 10);
            obj.pipLengthText = uicontrol(...
                'Parent', rightLayout, ...
                'Style', 'text', ...
                'String', 'Pip Length', ...
                'FontSize', 9);
            obj.diameterText = uicontrol(...
                'Parent', rightLayout, ...
                'Style', 'text', ...
                'String', 'Diameter', ...
                'FontSize', 9);
            obj.velocityText = uicontrol(...
                'Parent', rightLayout, ...
                'Style', 'text', ...
                'String', 'Wave velocity', ...
                'FontSize', 9);
            obj.materialText = uicontrol(...
                'Parent', rightLayout, ...
                'Style', 'text', ...
                'String', 'Pip Material', ...
                'FontSize', 9);
            obj.pipSegmentsText = uicontrol(...
                'Parent', rightLayout, ...
                'Style', 'text', ...
                'String', 'Pip Segments', ...
                'FontSize', 9);
            
            obj.pipLengthEdit = uicontrol(...
                'Parent', rightLayout, ...
                'Style', 'edit');
            obj.diameterEdit = uicontrol(...
                'Parent', rightLayout, ...
                'Style', 'edit');
            obj.velocityEdit = uicontrol(...
                'Parent', rightLayout, ...
                'Style', 'edit');
            obj.materialEdit = uicontrol(...
                'Parent', rightLayout, ...
                'Style', 'edit');
            obj.pipSegmentsEdit = uicontrol(...
                'Parent', rightLayout, ...
                'Style', 'edit');
            
            uiextras.Empty('Parent', rightLayout);
            uiextras.Empty('Parent', rightLayout);
            uiextras.Empty('Parent', rightLayout);
            uiextras.Empty('Parent', rightLayout);
            obj.multiPipSetButton = uicontrol(...
                'Parent', rightLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Set');
            
            set(rightLayout, ...
                'RowSizes', [25 25 25 25 25], ...
                'ColumnSizes', [120 150 120], ...
                'Spacing', 5);
            set(mainLayout, 'Sizes', [-1 -3], 'Spacing', 10);
            obj.hPanel.Visible = 'on';
            obj.modeSelected = obj.multiSelectBG.SelectedObject.String;
        end
        
        function updateView(obj)
            switch obj.pipInfoHandle.multiPip
                case false
                    set(obj.pipLengthEdit, 'String', ...
                        num2str(obj.pipInfoHandle.pipLength));
                    set(obj.diameterEdit, 'String', ...
                        num2str(obj.pipInfoHandle.diameter));
                    set(obj.velocityEdit, 'String', ...
                        num2str(obj.pipInfoHandle.velocity));
                    set(obj.materialEdit, 'String', ...
                        obj.pipInfoHandle.material);
                    set(obj.pipSegmentsEdit, 'String', ...
                        num2str(obj.pipInfoHandle.pipSegments));
                case true
                    set(obj.pipSegmentsEdit, 'String', ...
                        num2str(obj.pipInfoHandle.pipSegments));
                    obj.multiSelectBG.SelectedObject = obj.multiPipRadio;
                    obj.modeSelected = obj.multiPipRadio.String;
                otherwise
                    return
            end;
        end
        
        function result = get.pipLength(obj)
            result = get(obj.pipLengthEdit, 'String');
            result = str2double(result);
        end
        function result = get.diameter(obj)
            result = get(obj.diameterEdit, 'String');
            result = str2double(result);
        end
        function result = get.velocity(obj)
            result = get(obj.velocityEdit, 'String');
            result = str2double(result);
        end
        function result = get.material(obj)
            result = get(obj.materialEdit, 'String');
        end
        function result = get.pipSegments(obj)
            result = get(obj.pipSegmentsEdit, 'String');
            result = str2double(result);
        end
        
        function set.modeSelected(obj, modeSelected)
            obj.modeSelected = modeSelected;
            obj.notify('modeChanged')
        end
        
        function mode_active_callback(obj, ~, ~)
            switch obj.modeSelected
                case obj.singlePipRadio.String
                    set(obj.pipLengthEdit, 'Enable', 'on')
                    set(obj.diameterEdit, 'Enable', 'on')
                    set(obj.velocityEdit, 'Enable', 'on')
                    set(obj.materialEdit, 'Enable', 'on')
                    set(obj.pipSegmentsEdit, 'Enable', 'off');
                    set(obj.multiPipSetButton, 'Enable', 'off');
                case obj.multiPipRadio.String
                    set(obj.pipLengthEdit, 'Enable', 'off')
                    set(obj.diameterEdit, 'Enable', 'off')
                    set(obj.velocityEdit, 'Enable', 'off')
                    set(obj.materialEdit, 'Enable', 'off')
                    set(obj.pipSegmentsEdit, 'Enable', 'on');
                    set(obj.multiPipSetButton, 'Enable', 'on');
                otherwise
                    return
            end
        end
        
        function controlObj = makeController(obj)
            controlObj = SetPipInfoControl(obj, obj.pipInfoHandle);
        end
        
        function attachToControl(obj, controller)
            funcH = @controller.multipip_set_callback;
            set(obj.multiPipSetButton, 'callback', funcH);
        end
    end
    
end

