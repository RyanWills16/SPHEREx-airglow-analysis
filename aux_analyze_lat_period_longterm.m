function out = aux_analyze_lat_period_longterm(data, lon, lat, t_mjd, varargin)
% aux_analyze_lat_period_longterm
% Find dominant period (sin-ish) versus latitude bins, and long term change
% Inputs
%   data   amplitude, vector
%   lon    deg, vector
%   lat    deg, vector
%   t_mjd  time in MJD, vector
%
% Name Value
%   LatEdges         latitude bin edges in deg, default -90:10:90
%   MinPerBin        minimum samples per lat bin, default 30
%   PeriodLimitsDays [min max] search range in days, default [10 730]
%   LongTermDays     long term timescale in days, default 180
%   DetrendForPeriod logical, remove linear trend before period search, default true
%   MakePlots        logical, make summary plots, default true
%
% Output struct fields
%   lat_edges, lat_centers
%   n_per_bin
%   period_days, power
%   trend_per_year
%   mean_longterm
%   notes

p = inputParser;
p.addParameter('LatEdges', -90:10:90, @(x)isnumeric(x) && isvector(x) && numel(x) >= 3);
p.addParameter('MinPerBin', 30, @(x)isnumeric(x) && isscalar(x) && x >= 3);
p.addParameter('PeriodLimitsDays', [10 730], @(x)isnumeric(x) && numel(x)==2 && all(x>0) && x(2)>x(1));
p.addParameter('LongTermDays', 180, @(x)isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('DetrendForPeriod', true, @(x)islogical(x) && isscalar(x));
p.addParameter('MakePlots', true, @(x)islogical(x) && isscalar(x));
p.parse(varargin{:});

lat_edges = p.Results.LatEdges(:).';
minPerBin = p.Results.MinPerBin;
perLim = p.Results.PeriodLimitsDays;
longDays = p.Results.LongTermDays;
doDetrend = p.Results.DetrendForPeriod;
makePlots = p.Results.MakePlots;

data = data(:);
lon = lon(:);
lat = lat(:);
t_mjd = t_mjd(:);

m = isfinite(data) & isfinite(lon) & isfinite(lat) & isfinite(t_mjd);
data = data(m);
lon = lon(m);
lat = lat(m);
t_mjd = t_mjd(m);

t_days = t_mjd - min(t_mjd);

lat_centers = 0.5*(lat_edges(1:end-1) + lat_edges(2:end));
nlat = numel(lat_centers);

period_days = nan(nlat,1);
power = nan(nlat,1);
trend_per_year = nan(nlat,1);
mean_longterm = nan(nlat,1);
n_per_bin = zeros(nlat,1);

for i = 1:nlat
    idx = (lat >= lat_edges(i)) & (lat < lat_edges(i+1));
    n = nnz(idx);
    n_per_bin(i) = n;
    if n < minPerBin
        continue
    end

    ti = t_days(idx);
    yi = data(idx);

    ok = isfinite(ti) & isfinite(yi);
    ti = ti(ok);
    yi = yi(ok);

    if numel(ti) < minPerBin
        continue
    end

    [ti, srt] = sort(ti);
    yi = yi(srt);

    if doDetrend
        pp = polyfit(ti, yi, 1);
        yi_for_period = yi - polyval(pp, ti);
    else
        yi_for_period = yi;
    end
    yi_for_period = yi_for_period - mean(yi_for_period, 'omitnan');

    try
        [pxx, f] = plomb(yi_for_period, ti, 'PeriodLimits', perLim, 'Normalization', 'psd');
        [power(i), imax] = max(pxx);
        period_days(i) = 1 ./ f(imax);
    catch
        period_days(i) = NaN;
        power(i) = NaN;
    end

    pp = polyfit(ti, yi, 1);
    trend_per_year(i) = pp(1) * 365.25;

    med_dt = median(diff(ti), 'omitnan');
    if isfinite(med_dt) && med_dt > 0
        win = max(3, round(longDays / med_dt));
        y_smooth = smoothdata(yi, 'movmedian', win);
        mean_longterm(i) = mean(y_smooth, 'omitnan');
    else
        mean_longterm(i) = mean(yi, 'omitnan');
    end
end

out = struct();
out.lat_edges = lat_edges;
out.lat_centers = lat_centers(:);
out.n_per_bin = n_per_bin;
out.period_days = period_days;
out.power = power;
out.trend_per_year = trend_per_year;
out.mean_longterm = mean_longterm;
out.notes = sprintf(['t_mjd converted to days via t_days = t_mjd - min(t_mjd). ' ...
                     'Period via Lomb Scargle (plomb). Long term trend is linear slope per year.']);

if makePlots
    figure (100); clf
    plot(out.lat_centers, out.period_days, 'o-', 'LineWidth', 1.5);
    grid on
    xlabel('Latitude (deg)')
    ylabel('Dominant period (days)')
    title('Dominant period versus latitude')

    figure (101); clf
    plot(out.lat_centers, out.trend_per_year, 's-', 'LineWidth', 1.5);
    grid on
    xlabel('Latitude (deg)')
    ylabel('Long term trend (data per year)')
    title('Long term trend versus latitude')

    figure (102); clf
    plot(out.lat_centers, out.n_per_bin, 'd-', 'LineWidth', 1.5);
    grid on
    xlabel('Latitude (deg)')
    ylabel('Samples per bin')
    title('Sampling versus latitude')
end
end
