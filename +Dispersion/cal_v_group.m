function [ v_group ] = cal_v_group(v_phase_disper)

[m, n] = size(v_phase_disper);
if m == 2
    v_phase_disper = v_phase_disper';
elseif n ~= 2 && m ~= 2
    ME = MException('InputMatrix:mismatch', ...
        'Should be 2 * n or n * 2, n >= 2.');
    throw(ME)
end
partial = diff(v_phase_disper, 1, 1);
d_vp_d_omega = partial(:, 2) ./ partial(:, 1);
one_of_vg = ...
    1 ./ v_phase_disper(1: end-1, 2)...
    - v_phase_disper(1: end-1, 1) ./ v_phase_disper(1: end-1, 2).^2 ...
    .* d_vp_d_omega;
v_group = 1 ./ one_of_vg;
v_group = horzcat(v_phase_disper(1: end-1, 1), v_group);

end
