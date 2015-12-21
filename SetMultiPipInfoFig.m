classdef SetMultiPipInfoFig < handle
    %SETMULTIPIPINFOFIG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hFig
        
        pipInfoHandle
        setPipInfoPanelHandle
        controlObj
        
        saveButton
        
        listNumText
        pipLengthText
        diameterText
        materialText
        velocityText
        
        pipLengthEdit
        diameterEdit
        materialEdit
        velocityEdit
    end
    
    properties(Dependent)
        pipLength
        diameter
        material
        velocity
    end
    
    methods
        function obj = SetMultiPipInfoFig(...
                pipInfoHandle, setPipInfoPanelHandle)
            obj.pipInfoHandle = pipInfoHandle;
            obj.setPipInfoPanelHandle = setPipInfoPanelHandle;
            obj.buildUI()
            obj.updateView();
            obj.controlObj = obj.makeController();
            obj.attachToControl(obj.controlObj);
        end
        
        function buildUI(obj)
            obj.hFig = figure(...
                'Visible', 'off', ...
                'Units', 'normalized', ...
                'OuterPosition', [0.1 0.1 0.4 0.5]);
            movegui(obj.hFig, 'center');
            
            mainLayout = uiextras.Grid(...
                'Parent', obj.hFig, ...
                'Padding', 10);
            
            segments = str2double(...
                obj.setPipInfoPanelHandle.pipSegmentsEdit.String);
            
            uiextras.Empty('Parent', mainLayout);
            for ii = 1: segments
                obj.listNumText{ii} = uicontrol(...
                    'Parent', mainLayout, ...
                    'Style', 'text', ...
                    'String', num2str(ii), ...
                    'FontSize', 9);
            end
            uiextras.Empty('Parent', mainLayout);
            
            obj.pipLengthText = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', 'Pip Length', ...
                'FontSize', 9);
            for ii = 1: segments
                obj.pipLengthEdit{ii} = uicontrol(...
                    'Parent', mainLayout, ...
                    'Style', 'edit');
            end
            uiextras.Empty('Parent', mainLayout);
            
            obj.diameterText = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', 'Diameter', ...
                'FontSize', 9);
            for ii = 1: segments
                obj.diameterEdit{ii} = uicontrol(...
                    'Parent', mainLayout, ...
                    'Style', 'edit');
            end
            
            obj.saveButton = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Save');
            
            obj.velocityText = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', 'Wave Velocity', ...
                'FontSize', 9);
            for ii = 1: segments
                obj.velocityEdit{ii} = uicontrol(...
                    'Parent', mainLayout, ...
                    'Style', 'edit');
            end
            uiextras.Empty('Parent', mainLayout);
            
            obj.materialText = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', 'Material', ...
                'FontSize', 9);
            for ii = 1: segments
                obj.materialEdit{ii} = uicontrol(...
                    'Parent', mainLayout, ...
                    'Style', 'edit');
            end
            uiextras.Empty('Parent', mainLayout);
            
            set(mainLayout, ...
                'RowSizes', 25 * ones(1, segments + 2), ...
                'ColumnSizes', [50 150 150 150 150], ...
                'Spacing', 5);
            obj.hFig.Visible = 'on';
        end
        
        function updateView(obj)
            segments = min(...
                obj.pipInfoHandle.pipSegments, ...
                str2double(...
                obj.setPipInfoPanelHandle.pipSegmentsEdit.String));
            for ii = 1: segments
                obj.pipLengthEdit{ii}.String = num2str(...
                    obj.pipInfoHandle.pipLength(ii));
                obj.diameterEdit{ii}.String = num2str(...
                    obj.pipInfoHandle.diameter(ii));
                obj.velocityEdit{ii}.String = num2str(...
                    obj.pipInfoHandle.velocity(ii));
                obj.materialEdit{ii}.String = ...
                    obj.pipInfoHandle.material{ii};
            end
        end
        
        function result = get.pipLength(obj)
            segments = length(obj.listNumText);
            result = zeros(1, segments);
            for ii = 1: segments
                result(ii) = str2double(obj.pipLengthEdit{ii}.String);
            end
        end
        function result = get.diameter(obj)
            segments = length(obj.listNumText);
            result = zeros(1, segments);
            for ii = 1: segments
                result(ii) = str2double(obj.diameterEdit{ii}.String);
            end
        end
        function result = get.velocity(obj)
            segments = length(obj.listNumText);
            result = zeros(1, segments);
            for ii = 1: segments
                result(ii) = str2double(obj.velocityEdit{ii}.String);
            end
        end
        function result = get.material(obj)
            segments = length(obj.listNumText);
            result = cell(1, segments);
            for ii = 1: segments
                result{ii} = obj.materialEdit{ii}.String;
            end
        end
        
        function controlObj = makeController(obj)
            controlObj = SetMultiPipInfoControl(...
                obj, obj.pipInfoHandle);
        end
        
        function attachToControl(obj, controlObj)
            funcH = @controlObj.save_button_callback;
            set(obj.saveButton, 'callback', funcH)
        end
    end
    
end

