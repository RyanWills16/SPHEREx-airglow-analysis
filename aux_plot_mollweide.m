function aux_plot_mollweide(lon, lat, y, varargin)
% aux_plot_mollweide  Mollweide color scatter (lon/lat colored by y)
% Requires Mapping Toolbox.
%
% ax = aux_plot_mollweide(lon, lat, y)
% ax = aux_plot_mollweide(lon, lat, y, Name, Value)
%
% lon, lat in degrees. lon can be 0..360 or -180..180.

% ---- parse ----
p = inputParser;
p.addRequired('lon', @(x)isnumeric(x) && isvector(x));
p.addRequired('lat', @(x)isnumeric(x) && isvector(x));
p.addRequired('y',   @(x)isnumeric(x) && isvector(x));
p.addParameter('Marker', 'o', @(s)ischar(s) || isstring(s));
p.addParameter('MarkerSize', 12, @(x)isnumeric(x) && isscalar(x)); % scatter size in points^2
p.addParameter('Colormap', parula, @(c)ischar(c) || isstring(c) || isa(c,'function_handle') || (isnumeric(c) && size(c,2)==3));
p.addParameter('Title', '', @(s)ischar(s) || isstring(s));
p.addParameter('CLim', [], @(x)isnumeric(x) && (isempty(x) || numel(x)==2));
p.addParameter('Filled', true, @(x)islogical(x) && isscalar(x));
p.parse(lon, lat, y, varargin{:});

mk     = char(p.Results.Marker);
sz     = p.Results.MarkerSize;
cmap   = p.Results.Colormap;
ttl    = char(p.Results.Title);
clim   = p.Results.CLim;
filled = p.Results.Filled;

% ---- clean ----
lon = lon(:); lat = lat(:); y = y(:);
m = isfinite(lon) & isfinite(lat) & isfinite(y);
lon = lon(m); lat = lat(m); y = y(m);

% wrap lon to [-180, 180]
lon = mod(lon + 180, 360) - 180;

% ---- plot ----
figure; clf

axesm('mollweid', ...
    'Frame','on','Grid','on', ...
    'MeridianLabel','on','ParallelLabel','on', ...
    'MLabelParallel','equator','PLabelMeridian',0);

ax = gca;

if filled
    h = scatterm(lat, lon, sz, y, mk, 'filled');
else
    h = scatterm(lat, lon, sz, y, mk);
end
h.HandleVisibility = 'off';

colormap(ax, cmap);
if ~isempty(clim)
    caxis(ax, clim);
end

cb = colorbar;
cb.Label.String = 'y';

title(ax, ttl);

end



