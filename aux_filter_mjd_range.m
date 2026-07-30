function [mask, idx] = aux_filter_mjd_range(t_mjd, t1, t2)
% aux_filter_mjd_datetime  Filter MJD array using datetime bounds
%
% [mask, idx, t1_mjd, t2_mjd] = aux_filter_mjd_datetime(t_mjd, t1, t2)
%
% Inputs
%   t_mjd : array of Modified Julian Dates
%   t1    : datetime (start, inclusive)
%   t2    : datetime (end, inclusive)
%
% Outputs
%   mask   : logical mask for t_mjd within [t1, t2]
%   idx    : indices of selected elements
%   t1_mjd : converted start time in MJD
%   t2_mjd : converted end time in MJD
%
% Notes
%   - Order of t1 and t2 does not matter
%   - NaNs in t_mjd are excluded

% ---- validate ----
if ~isdatetime(t1) || ~isdatetime(t2)
    error('t1 and t2 must be datetime inputs');
end

if isempty(t1.TimeZone) || isempty(t2.TimeZone)
    error('t1 and t2 must have TimeZone set (e.g. UTC)');
end

% ---- enforce UTC ----
t1 = datetime(t1,'TimeZone','UTC');
t2 = datetime(t2,'TimeZone','UTC');

% ---- convert datetime to MJD ----
% datenum is days since 0000-01-00
% MJD = JD - 2400000.5
% JD = datenum + 1721058.5
% => MJD = datenum - 678942
t1_mjd = datenum(t1) - 678942;
t2_mjd = datenum(t2) - 678942;

% ensure order
tmin = min(t1_mjd, t2_mjd);
tmax = max(t1_mjd, t2_mjd);

% ---- filter ----
mask = false(size(t_mjd));
m = isfinite(t_mjd);

mask(m) = (t_mjd(m) > tmin) & (t_mjd(m) < tmax);

idx = find(mask);

end
