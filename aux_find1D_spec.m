function [lam, spec, spec_var] = aux_find1D_spec(m, lam_c, start_lam, end_lam, step)
% aux_find1D_spec
% Bin a 2D image into a 1D spectrum using per-pixel wavelength map lam_c.
%
% Inputs:
%   m         2040x2040 (or same size as lam_c) image values
%   lam_c     2040x2040 wavelength at each pixel (same units as start_lam)
%   start_lam scalar, start wavelength (inclusive bin edge)
%   end_lam   scalar, end wavelength (inclusive bin edge)
%   step      scalar, bin width
%
% Outputs:
%   lam   bin centers: start_lam+step/2 : step : end_lam-step/2
%   spec  binned spectrum (mean of m in each wavelength bin)

    % Basic checks
    if ~isequal(size(m), size(lam_c))
        error('m and lam_c must have the same size.');
    end
    if step <= 0
        error('step must be positive.');
    end
    if end_lam <= start_lam
        error('end_lam must be greater than start_lam.');
    end

    % Bin edges and centers
    edges = start_lam:step:end_lam;
    if numel(edges) < 2
        error('Wavelength range too small for the given step.');
    end

    lam = edges(1:end-1) + step/2;

    % Flatten and keep finite values only
    x = lam_c(:);
    y = m(:);
    good = isfinite(x) & isfinite(y);
    x = x(good);
    y = y(good);

    % Assign each pixel to a wavelength bin
    binIdx = discretize(x, edges); % NaN if outside range
    in = ~isnan(binIdx);
    binIdx = binIdx(in);
    y = y(in);

    % Compute mean in each bin (use accumarray)
    nbins = numel(lam);
    
    %{
    sumY = accumarray(binIdx, y, [nbins 1], @sum, NaN);
    nY   = accumarray(binIdx, 1, [nbins 1], @sum, 0);

    spec = sumY ./ nY;
    spec(nY == 0) = NaN; % empty bins
    %}
    spec = accumarray(binIdx, y, [nbins 1], @median, NaN);

    % Counts per bin
    N = accumarray(binIdx, 1, [nbins 1], @sum, 0);
    
    % Standard deviation
    sigma = accumarray(binIdx, y, [nbins 1], @std, NaN);
    
    % Uncertainty on the median
    spec_var = 1.253 .* sigma ./ sqrt(N);
    spec_var(N == 0) = NaN;


end
