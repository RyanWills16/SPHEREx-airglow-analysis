function t_array = aux_make_time_bins(t1, t2, nbins)
% make_time_bins  Create evenly spaced datetime bins
%
% t_array = make_time_bins(t1, t2, nbins)
%
% Inputs
%   t1, t2 : datetime (with TimeZone)
%   nbins  : number of bins
%
% Output
%   t_array : datetime array of length nbins+1 (bin edges)

t1 = datetime(t1,'TimeZone','UTC');
t2 = datetime(t2,'TimeZone','UTC');

if t2 < t1
    [t1, t2] = deal(t2, t1);
end

t_array = t1 + (0:nbins) .* (t2 - t1) / nbins;
end
