function [ output ] = get_det( omega, xi, n, a, b, v1, v2 )
%GET_DET Summary of this function goes here
%   Detailed explanation goes here
output  = det(get_matrix( omega, xi, n, a, b, v1, v2 ));

if xi > omega / v1 && xi < omega / v2
    output = -output;
end

end

