classdef PipInfo < handle
    %PIPINFO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pipLength = [10 20 30]
        radius_out = [4 4 4]
        radius_in = [3 3 3]
        material = {'a', 'b', 'c'}
        velocityP = [5 5 5]
        velocityS = [3 3 3]
        pipSegments = 3
        multiPip = true
    end
    
    methods
        function obj = PipInfo()
            disp('Pip Info')
        end
        
        function set.radius_out(obj, radius_out)
            try
                validateattributes(radius_out, {'double'}, {'integer'})
                if radius_out <= 0
                    msgbox('Invalid diameter')
                    return
                end
                obj.radius_out = radius_out;
            catch
                msgbox('Invalid diameter')
            end
        end
        
        function set.radius_in(obj, radius_in)
            try
                validateattributes(radius_in, {'double'}, {'integer'})
                if radius_in <= 0
                    msgbox('Invalid diameter')
                    return
                end
                obj.radius_in = radius_in;
            catch
                msgbox('Invalid diameter')
            end
        end
        
        function set.velocityP(obj, velocityP)
            try
                validateattributes(velocityP, {'double'}, {'integer'})
                if velocityP <= 0
                    msgbox('Invalid velocity')
                    return
                end
                obj.velocityP = velocityP;
            catch
                msgbox('Invalid velocity')
            end
        end
        
        function set.velocityS(obj, velocityS)
            try
                validateattributes(velocityS, {'double'}, {'integer'})
                if velocityS <= 0
                    msgbox('Invalid velocity')
                    return
                end
                obj.velocityS = velocityS;
            catch
                msgbox('Invalid velocity')
            end
        end
        
        function set.material(obj, material)
            obj.material = material;
        end
        
        function set.pipLength(obj, pipLength)
            try
                validateattributes(pipLength, {'double'}, {'integer'})
                if pipLength <= 0
                    msgbox('Invalid pip length')
                    return
                end
                obj.pipLength = pipLength;
            catch
                msgbox('Invalid pip length')
            end
        end
        
        function set.pipSegments(obj, pipSegments)
            try
                validateattributes(pipSegments, {'double'}, {'integer'})
                if pipSegments <= 0
                    msgbox('Invalid pip segments')
                    return
                end
                obj.pipSegments = pipSegments;
            catch
                msgbox('Invalid pip segments')
            end
        end
    end
    
end

