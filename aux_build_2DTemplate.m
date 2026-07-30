function template = aux_build_2DTemplate(lam, resp, lam_map, varargin)
% aux_build_template_from_lammap
% Build a 2D template by interpolating a 1D response curve (lam, resp)
% onto a 2D wavelength map lam_map (e.g., 2040x2040).
%
% Inputs
%   lam     : Nx1 or 1xN wavelength array (monotonic recommended)
%   resp    : Nx1 or 1xN response array (same size as lam)
%   lam_map : MxK wavelength map, values within (or near) lam range
%
% Name-value options
%   'Method'    : interpolation method for interp1 (default 'linear')
%   'FillValue' : value for out-of-range lam_map entries (default NaN)
%
% Output
%   template : MxK array, resp interpolated at each lam_map entry

  p = inputParser;
  p.addParameter('Method','linear', @(s)ischar(s) || isstring(s));
  p.addParameter('FillValue', NaN, @(x)isscalar(x) && isnumeric(x));
  p.parse(varargin{:});
  method = char(p.Results.Method);
  fillv  = p.Results.FillValue;

  lam  = lam(:);
  resp = resp(:);

  % Ensure lam is increasing for interp1
  [lam, sortIdx] = sort(lam, 'ascend');
  resp = resp(sortIdx);

  % Interpolate: interp1 accepts an array for query points, so this is fast
  template = interp1(lam, resp, lam_map, method, fillv);
end
