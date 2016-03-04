function [ output ] = get_matrix( omega, xi, n, a, b, v1, v2 )

c_up = para( omega, xi, n, a, v1, v2 );
c_down = para( omega, xi, n, b, v1, v2 );
output = vertcat(c_up, c_down);

end

function [ c ] = para( omega, xi, n, radius, v1, v2 )

vz = omega / xi;

alpha = sqrt(omega^2 / v1^2 - xi^2);
beta = sqrt(omega^2 / v2^2 - xi^2);
alpha1 = abs(alpha);
beta1 = abs(beta);

if vz > v1
    Z = @besselj;
    Za = Z;
    Zb = Z;
    W = @bessely;
    Wa = W;
    Wb = W;
    sgn1 = 1;
    sgn2 = 1;
elseif vz < v1 && vz > v2
    Za = @besseli;
    Zb = @besselj;
    Wa = @besselk;
    Wb = @bessely;
    sgn1 = -1;
    sgn2 = 1;
else
    Z = @besseli;
    Za = Z;
    Zb = Z;
    W = @besselk;
    Wa = W;
    Wb = W;
    sgn1 = -1;
    sgn2 = -1;
end

c(1, 1) = (2 * n * (n - 1) - (beta^2 - xi^2) * radius^2) * feval(Za, n, alpha1 * radius) ...
    + 2 * sgn1 * alpha1 * radius * feval(Za, n+1, alpha1 * radius);

c(1, 2) = 2 * xi * beta1 * radius^2 * feval(Zb, n, beta1 * radius) ...
    - 2 * xi * radius * (n + 1) * feval(Zb, n+1, beta1 * radius);

c(1, 3) = -2 * n * (n - 1) * feval(Zb, n, beta1 * radius) ...
    + 2 * sgn2 * n * beta1 * radius * feval(Zb, n+1, beta1 * radius);

c(1, 4) = (2 * n * (n - 1) - (beta^2 - xi^2) * radius^2) * feval(Wa, n, alpha1 * radius) ...
    + 2 * alpha1 * radius * feval(Wa, n+1, alpha1 * radius);

c(1, 5) = 2 * sgn2 * xi * beta1 * radius^2 * feval(Wb, n, beta1 * radius) ...
    - 2 * (n + 1) * xi * radius * feval(Wb, n+1, beta1 * radius);

c(1, 6) = -2 * n * (n - 1) * feval(Wb, n, beta1 * radius) ...
    + 2 * n * beta1 * radius * feval(Wb, n+1, beta1 * radius);

c(2, 1) = 2 * n * (n - 1) * feval(Za, n, alpha1 * radius) ...
    - 2 * sgn1 * n * alpha1 * radius * feval(Za, n+1, alpha1 * radius);

c(2, 2) = -xi * beta1 * radius^2 * feval(Zb, n, beta1 * radius) ...
    + 2 * xi * radius * (n + 1) * feval(Zb, n+1, beta1 * radius);

c(2, 3) = -(2 * n * (n - 1) - beta^2 * radius^2) * feval(Zb, n, beta1 * radius) ...
    - 2 * sgn2 * beta1 * radius * feval(Zb, n+1, beta1 * radius);

c(2, 4) = 2 * n * (n - 1) * feval(Wa, n, alpha1 * radius) ...
    - 2 * n * alpha1 * radius * feval(Wa, n+1, alpha1 * radius);

c(2, 5) = -sgn2 * xi * beta1 * radius^2 * feval(Wb, n, beta1 * radius) ...
    + 2 * xi * radius * (n + 1) * feval(Wb, n+1, beta1 * radius);

c(2, 6) = -(2 * n * (n - 1) - beta^2 * radius^2) * feval(Wb, n, beta1 * radius) ...
    - 2 * beta1 * radius * feval(Wb, n+1, beta1 * radius);

c(3, 1) = 2 * n * xi * radius * feval(Za, n, alpha1 * radius) ...
    - 2 * sgn1 * xi * alpha1 * radius^2 * feval(Za, n+1, alpha1 * radius);

c(3, 2) = n * beta1 * radius * feval(Zb, n, beta1 * radius) ...
    - (beta^2 - xi^2) * radius^2 * feval(Zb, n+1, beta1 * radius);

c(3, 3) = -n* xi * radius * feval(Zb, n, beta1 * radius);

c(3, 4) = 2 * n * xi * radius * feval(Wa, n, alpha1 * radius) ...
    - 2 * xi * alpha1 * radius^2 * feval(Wa, n+1, alpha1 * radius);

c(3, 5) = sgn2 * n * beta1 * radius * feval(Wb, n, beta1 * radius) ...
    - (beta^2 - xi^2) * radius^2 * feval(Wb, n+1, beta1 * radius);

c(3, 6) = -n * xi * radius * feval(Wb, n, beta1 * radius);

end
