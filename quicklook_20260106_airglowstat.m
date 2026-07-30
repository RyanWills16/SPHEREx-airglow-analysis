% load the big csv

csv_all = readtable('files/combined_D1_amplitudes.csv');

obs_time = datetime(csv_all.MJD_OBS + 2400000.5,'ConvertFrom','juliandate',...
    'TimeZone','UTC');

% figure 1: total data, time stream
% figure 2: mollweide, total data, He
% figure 3: mollweide, total data, Oxygen
% figure 4: Helium vs Oxygen Band 1
% figure 5: bin by time and Latitude
% figure 6: bin by time and Latitude and sunrise/sunset
% figure 7: bin by time and Latitude and ecliptic pole

do_plot1 = 0; 
do_plot2 = 0;
do_plot3 = 0;
do_plot4 = 0;
do_plot5 = 0;
do_plot6 = 0;
do_plot7 = 0;
do_plot8 = 1;

if do_plot1
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % figure 1, total data, time stream
    figure (1);
    clf
    set(gcf, 'position', [100,100,800,400])
    yyaxis left
    plot(obs_time, csv_all.He_D1,'b.','MarkerSize',1);
    ylabel('Helium Amplitude (MJy/sr)')
    %ax.YColor = 'r';
    ylim([-0.1 10])
    hold on
    yyaxis right
    plot(obs_time,csv_all.OI844_D1,'r.','MarkerSize',1);
    ylabel('Oxygen Amplitude (MJy/sr)')
    %ax.YColor = 'b';
    ylim([-0.05 0.05])
    title('1.083\mum Helium and 0.844\mum Oxygen in 6 months');
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    xlim([datetime(2025,4,24,'TimeZone','UTC') datetime(2025,11,24,'TimeZone','UTC')])
    exportgraphics(gcf,...
        'img/fig1_AirglowTimeAll.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig1_AirglowTimeAll.pdf',...
        'ContentType', 'vector');
    
    figure (101)
    clf
    set(gcf, 'position', [100,600,800,400])
    yyaxis left
    plot(obs_time, csv_all.He_D1,'b-','LineWidth',1.1);
    ylabel('Helium Amplitude (MJy/sr)')
    %ax.YColor = 'r';
    ylim([-0.1 6])
    hold on
    yyaxis right
    plot(obs_time,csv_all.OI844_D1,'r-','LineWidth',1.1);
    ylabel('Oxygen Amplitude (MJy/sr)')
    %ax.YColor = 'b';
    ylim([-0.005 0.03])
    title('Helium and Oxygen, 2025-06-04');
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    xlim([datetime(2025,6,4,'TimeZone','UTC') datetime(2025,6,5,'TimeZone','UTC')])
    exportgraphics(gcf,...
        'img/fig1_AirglowTime_20250604.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig1_AirglowTime_20250604.pdf',...
        'ContentType', 'vector');
    
    figure (102)
    clf
    set(gcf, 'position', [1000,600,800,400])
    yyaxis left
    plot(obs_time, csv_all.He_D1,'b-','LineWidth',1.1);
    ylabel('Helium Amplitude (MJy/sr)')
    %ax.YColor = 'r';
    ylim([-0.1 6])
    hold on
    yyaxis right
    plot(obs_time,csv_all.OI844_D1,'r-','LineWidth',1.1);
    ylabel('Oxygen Amplitude (MJy/sr)')
    %ax.YColor = 'b';
    ylim([-0.005 0.03])
    title('Helium and Oxygen, 2025-11-04');
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    xlim([datetime(2025,11,4,'TimeZone','UTC') datetime(2025,11,5,'TimeZone','UTC')])
    exportgraphics(gcf,...
        'img/fig1_AirglowTime_20251105.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig1_AirglowTime_20251105.pdf',...
        'ContentType', 'vector');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
if do_plot2
    % figure 2, mollweide
    figure (2);
    clf
    set(gcf, 'position', [100,100,800,400])
    ax = axesm('MapProjection', 'mollweid', ...
               'Frame', 'on', ...
               'Grid', 'on', ...
               'GLineStyle', '-', ...
               'GLineWidth', 0.5, ...
               'GColor', [0.6 0.6 0.6], ...
               'ParallelLabel', 'on', ...
               'MLabelLocation', 60, ...       % Fewer meridian labels
               'PLabelLocation', 45, ...       % Fewer parallel labels
               'PLabelMeridian', -180, ...
               'FontSize', 16);
    set(ax, 'Position', [0.05 0.08 0.88 0.84]);   % fill figure
    tightmap                                      % tighten map frame
    axis off;
    setm(ax, 'MapLatLimit', [-90 90], 'MapLonLimit', [-180 180]);
    % Plot scatter data
    scatterm(csv_all.SGT_LAT_MIDPT, csv_all.SGT_LON_MIDPT,...
        5, csv_all.He_D1,'filled');
    colormap turbo
    caxis([0 2])
    colorbar
    cb = colorbar;
    cb.Label.String = '(MJy/sr)';
    title('SPHEREx 6 Month Helium Airglow')
    exportgraphics(gcf,...
        'img/fig2_HeMap.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig2_HeMap.pdf',...
        'ContentType', 'vector');
    
    t1 = datetime(2025,6,4,'TimeZone','UTC');
    t2 = datetime(2025,6,11,'TimeZone','UTC');
    [tempMask, tempIDX] = aux_filter_mjd_range(csv_all.MJD_OBS, t1, t2);
    figure (21);
    clf
    set(gcf, 'position', [100,100,800,400])
    ax = axesm('MapProjection', 'mollweid', ...
               'Frame', 'on', ...
               'Grid', 'on', ...
               'GLineStyle', '-', ...
               'GLineWidth', 0.5, ...
               'GColor', [0.6 0.6 0.6], ...
               'ParallelLabel', 'on', ...
               'MLabelLocation', 60, ...       % Fewer meridian labels
               'PLabelLocation', 45, ...       % Fewer parallel labels
               'PLabelMeridian', -180, ...
               'FontSize', 16);
    set(ax, 'Position', [0.05 0.08 0.88 0.84]);   % fill figure
    tightmap                                      % tighten map frame
    axis off;
    setm(ax, 'MapLatLimit', [-90 90], 'MapLonLimit', [-180 180]);
    % Plot scatter data
    scatterm(csv_all.SGT_LAT_MIDPT(tempIDX), csv_all.SGT_LON_MIDPT(tempIDX),...
        15, csv_all.He_D1(tempIDX),'filled');
    colormap turbo
    caxis([0 2])
    colorbar
    cb = colorbar;
    %cb.Position = [0.92 0.15 0.02 0.7];
    %cb.FontSize = 14;
    cb.Label.String = '(MJy/sr)';
    title('2025/06/04 to 06/11 Helium Airglow')
    exportgraphics(gcf,...
        'img/fig2_HeMap_0604.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig2_HeMap_0604.pdf',...
        'ContentType', 'vector');
    
    
    t1 = datetime(2025,11,4,'TimeZone','UTC');
    t2 = datetime(2025,11,11,'TimeZone','UTC');
    [tempMask, tempIDX] = aux_filter_mjd_range(csv_all.MJD_OBS, t1, t2);
    figure (22);
    clf
    set(gcf, 'position', [100,600,800,400])
    ax = axesm('MapProjection', 'mollweid', ...
               'Frame', 'on', ...
               'Grid', 'on', ...
               'GLineStyle', '-', ...
               'GLineWidth', 0.5, ...
               'GColor', [0.6 0.6 0.6], ...
               'ParallelLabel', 'on', ...
               'MLabelLocation', 60, ...       % Fewer meridian labels
               'PLabelLocation', 45, ...       % Fewer parallel labels
               'PLabelMeridian', -180, ...
               'FontSize', 16);
    set(ax, 'Position', [0.05 0.08 0.88 0.84]);   % fill figure
    tightmap                                      % tighten map frame
    axis off;
    setm(ax, 'MapLatLimit', [-90 90], 'MapLonLimit', [-180 180]);
    % Plot scatter data
    scatterm(csv_all.SGT_LAT_MIDPT(tempIDX), csv_all.SGT_LON_MIDPT(tempIDX),...
        15, csv_all.He_D1(tempIDX),'filled');
    colormap turbo
    caxis([0 2])
    colorbar
    cb = colorbar;
    %cb.Position = [0.92 0.15 0.02 0.7];
    %cb.FontSize = 14;
    cb.Label.String = '(MJy/sr)';
    title('2025/11/04 to 11/11 Helium Airglow')
    exportgraphics(gcf,...
        'img/fig2_HeMap_1104.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig2_HeMap_1104.pdf',...
        'ContentType', 'vector');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if do_plot3
    % figure 3, mollweide oxygen
    figure (3);
    clf
    set(gcf, 'position', [100,100,800,400])
    ax = axesm('MapProjection', 'mollweid', ...
               'Frame', 'on', ...
               'Grid', 'on', ...
               'GLineStyle', '-', ...
               'GLineWidth', 0.5, ...
               'GColor', [0.6 0.6 0.6], ...
               'ParallelLabel', 'on', ...
               'MLabelLocation', 60, ...       % Fewer meridian labels
               'PLabelLocation', 45, ...       % Fewer parallel labels
               'PLabelMeridian', -180, ...
               'FontSize', 16);
    set(ax, 'Position', [0.05 0.08 0.88 0.84]);   % fill figure
    tightmap                                      % tighten map frame
    axis off;
    setm(ax, 'MapLatLimit', [-90 90], 'MapLonLimit', [-180 180]);
    % Plot scatter data
    scatterm(csv_all.SGT_LAT_MIDPT, csv_all.SGT_LON_MIDPT,...
        5, csv_all.OI844_D1,'filled');
    colormap turbo
    caxis([0 0.03])
    colorbar
    cb = colorbar;
    %cb.Position = [0.92 0.15 0.02 0.7];
    %cb.FontSize = 14;
    cb.Label.String = '(MJy/sr)';
    title('SPHEREx 6 Month Oxygen Airglow')
    exportgraphics(gcf,...
        'img/fig3_OxygenMap.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig3_OxygenMap.pdf',...
        'ContentType', 'vector');

    t1 = datetime(2025,6,4,'TimeZone','UTC');
    t2 = datetime(2025,6,11,'TimeZone','UTC');
    [tempMask, tempIDX] = aux_filter_mjd_range(csv_all.MJD_OBS, t1, t2);
    figure (31);
    clf
    set(gcf, 'position', [100,100,800,400])
    ax = axesm('MapProjection', 'mollweid', ...
               'Frame', 'on', ...
               'Grid', 'on', ...
               'GLineStyle', '-', ...
               'GLineWidth', 0.5, ...
               'GColor', [0.6 0.6 0.6], ...
               'ParallelLabel', 'on', ...
               'MLabelLocation', 60, ...       % Fewer meridian labels
               'PLabelLocation', 45, ...       % Fewer parallel labels
               'PLabelMeridian', -180, ...
               'FontSize', 16);
    set(ax, 'Position', [0.05 0.08 0.88 0.84]);   % fill figure
    tightmap                                      % tighten map frame
    axis off;
    setm(ax, 'MapLatLimit', [-90 90], 'MapLonLimit', [-180 180]);
    % Plot scatter data
    scatterm(csv_all.SGT_LAT_MIDPT(tempIDX), csv_all.SGT_LON_MIDPT(tempIDX),...
        15, csv_all.OI844_D1(tempIDX),'filled');
    colormap turbo
    caxis([0 0.03])
    colorbar
    cb = colorbar;
    %cb.Position = [0.92 0.15 0.02 0.7];
    %cb.FontSize = 14;
    cb.Label.String = '(MJy/sr)';
    title('2025/06/04 to 06/11 Oxygen Airglow')
    exportgraphics(gcf,...
        'img/fig3_OxygenMap_0604.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig3_OxygenMap_0604.pdf',...
        'ContentType', 'vector');
    
    
    t1 = datetime(2025,11,4,'TimeZone','UTC');
    t2 = datetime(2025,11,11,'TimeZone','UTC');
    [tempMask, tempIDX] = aux_filter_mjd_range(csv_all.MJD_OBS, t1, t2);
    figure (32);
    clf
    set(gcf, 'position', [100,600,800,400])
    ax = axesm('MapProjection', 'mollweid', ...
               'Frame', 'on', ...
               'Grid', 'on', ...
               'GLineStyle', '-', ...
               'GLineWidth', 0.5, ...
               'GColor', [0.6 0.6 0.6], ...
               'ParallelLabel', 'on', ...
               'MLabelLocation', 60, ...       % Fewer meridian labels
               'PLabelLocation', 45, ...       % Fewer parallel labels
               'PLabelMeridian', -180, ...
               'FontSize', 16);
    set(ax, 'Position', [0.05 0.08 0.88 0.84]);   % fill figure
    tightmap                                      % tighten map frame
    axis off;
    setm(ax, 'MapLatLimit', [-90 90], 'MapLonLimit', [-180 180]);
    % Plot scatter data
    scatterm(csv_all.SGT_LAT_MIDPT(tempIDX), csv_all.SGT_LON_MIDPT(tempIDX),...
        15, csv_all.OI844_D1(tempIDX),'filled');
    colormap turbo
    caxis([0 0.03])
    colorbar
    cb = colorbar;
    %cb.Position = [0.92 0.15 0.02 0.7];
    %cb.FontSize = 14;
    cb.Label.String = '(MJy/sr)';
    title('2025/11/04 to 11/11 Oxygen Airglow')
    exportgraphics(gcf,...
        'img/fig3_OxygenMap_1104.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig3_OxygenMap_1104.pdf',...
        'ContentType', 'vector');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if do_plot4
    figure (4);
    clf
    set(gcf, 'position', [100,100,500,400])
    plot(csv_all.He_D1, csv_all.OI844_D1, 'k.','MarkerSize',2);
    xlim([-0.05 6])
    ylim([-0.02 0.06])
    xlabel('Helium Amplitude (MJy/sr)')
    ylabel('Oxygen Amplitude (MJy/sr)')
    title('1.083\mum Helium and 0.844\mum Oxygen');
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    exportgraphics(gcf,...
        'img/fig4_HeOCorr.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig4_HeOCorr.pdf',...
        'ContentType', 'vector');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this is the plot binning Latitude and time
if do_plot5
    % time
    t1 = datetime(2025,4,25,'TimeZone','UTC');
    t2 = datetime(2025,11,24,'TimeZone','UTC');
    t_array = aux_make_time_bins(t1, t2, 200);

    % Latitude bin
    lat_bin = -90:5:90;

    % make an array
    HeliumGrid = nan(numel(lat_bin)-1, numel(t_array)-1);
    OxygenGrid = nan(numel(lat_bin)-1, numel(t_array)-1);

    for tt = 1:numel(t_array)-1
        % time index
        [tempMask, t_idx] =...
            aux_filter_mjd_range(csv_all.MJD_OBS, t_array(tt), t_array(tt+1));
   
        for ll = 1:numel(lat_bin)-1
            total_idx = t_idx(csv_all.SGT_LAT_MIDPT(t_idx)>lat_bin(ll) &...
                csv_all.SGT_LAT_MIDPT(t_idx)<lat_bin(ll+1));

            % okay lets try this
            HeliumGrid(ll,tt) = median(csv_all.He_D1(total_idx),'all','omitmissing');
            OxygenGrid(ll,tt) = median(csv_all.OI844_D1(total_idx),'all','omitmissing');
        end
    end
    
    xticLabel = t_array(1:end-1);
    yticLabel = -87.5:5:87.5;

    figure (51);
    HeHigh = 2.5;
    clf
    set(gcf, 'position', [100,100,800,400])
    imagesc(xticLabel, yticLabel, HeliumGrid, [0 HeHigh]);
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    xlabel('Date')
    ylabel('Latitude Bin')
    title('Helium Airglow')
    cb = colorbar;
    cb.Label.String = '(MJy/sr)';
    exportgraphics(gcf,...
        'img/fig5_HeTimeLat.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig5_HeTimeLat.pdf',...
        'ContentType', 'vector');

    figure (52);
    OHigh = 0.030;
    clf
    set(gcf, 'position', [100,600,800,400])
    imagesc(xticLabel, yticLabel, OxygenGrid, [0 OHigh]);
    colorbar
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    xlabel('Date')
    ylabel('Latitude Bin')
    title('Oxygen Airglow')
    cb = colorbar;
    cb.Label.String = '(MJy/sr)';
    exportgraphics(gcf,...
        'img/fig5_OxygenTimeLat.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig5_OxygenTimeLat.pdf',...
        'ContentType', 'vector');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this is the plot binning Latitude and time and also descending and
% ascending node
if do_plot6
    % time
    t1 = datetime(2025,4,25,'TimeZone','UTC');
    t2 = datetime(2025,11,24,'TimeZone','UTC');
    t_array = aux_make_time_bins(t1, t2, 200);

    % Latitude bin
    lat_bin = -90:5:90;

    % sunrise sunset, 0 is sunset (descending), 180 is sunrise (ascending)
    Earray = [0 180];

    % make an array
    HeliumGrid = nan(numel(lat_bin)-1, numel(t_array)-1, 2);
    OxygenGrid = nan(numel(lat_bin)-1, numel(t_array)-1, 2);

    for tt = 1:numel(t_array)-1
        % time index
        [tempMask, t_idx] =...
            aux_filter_mjd_range(csv_all.MJD_OBS, t_array(tt), t_array(tt+1));
   
        for ll = 1:numel(lat_bin)-1
            for ee = 1:2
                total_idx = t_idx(csv_all.SGT_LAT_MIDPT(t_idx)>lat_bin(ll) &...
                    csv_all.SGT_LAT_MIDPT(t_idx)<lat_bin(ll+1) &...
                    csv_all.SPS_EPA(t_idx) == Earray(ee));
    
                % okay lets try this
                HeliumGrid(ll,tt,ee) = median(csv_all.He_D1(total_idx),'all','omitmissing');
                OxygenGrid(ll,tt,ee) = median(csv_all.OI844_D1(total_idx),'all','omitmissing');
            end
        end
    end
    
    xticLabel = t_array(1:end-1);
    yticLabel = -87.5:5:87.5;

    figure (61);
    HeHigh = 2.5;
    clf
    set(gcf, 'position', [100,100,800,400])
    imagesc(xticLabel, yticLabel, squeeze(HeliumGrid(:,:,1)), [0 HeHigh]);
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    xlabel('Date')
    ylabel('Latitude Bin')
    title('Helium Airglow, EPA = 0, Sunset (Descending)')
    cb = colorbar;
    cb.Label.String = '(MJy/sr)';
    exportgraphics(gcf,...
        'img/fig6_HeTimeLatEPA000.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig6_HeTimeLatEPA000.pdf',...
        'ContentType', 'vector');

    figure (62);
    HeHigh = 2.5;
    clf
    set(gcf, 'position', [1000,100,800,400])
    imagesc(xticLabel, yticLabel, squeeze(HeliumGrid(:,:,2)), [0 HeHigh]);
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    xlabel('Date')
    ylabel('Latitude Bin')
    title('Helium Airglow, EPA = 180, Sunrise (Ascending)')
    cb = colorbar;
    cb.Label.String = '(MJy/sr)';
    exportgraphics(gcf,...
        'img/fig6_HeTimeLatEPA180.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig6_HeTimeLatEPA180.pdf',...
        'ContentType', 'vector');

    figure (63);
    OHigh = 0.030;
    clf
    set(gcf, 'position', [100,600,800,400])
    imagesc(xticLabel, yticLabel, squeeze(OxygenGrid(:,:,1)), [0 OHigh]);
    colorbar
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    xlabel('Date')
    ylabel('Latitude Bin')
    title('Oxygen Airglow, EPA = 0, Sunset (Descending)')
    cb = colorbar;
    cb.Label.String = '(MJy/sr)';
    exportgraphics(gcf,...
        'img/fig6_OxygenTimeLatEPA000.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig6_OxygenTimeLatEPA000.pdf',...
        'ContentType', 'vector');

    figure (64);
    OHigh = 0.030;
    clf
    set(gcf, 'position', [1000,600,800,400])
    imagesc(xticLabel, yticLabel, squeeze(OxygenGrid(:,:,2)), [0 OHigh]);
    colorbar
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    xlabel('Date')
    ylabel('Latitude Bin')
    title('Oxygen Airglow, EPA = 180, Sunrise (Ascending)')
    cb = colorbar;
    cb.Label.String = '(MJy/sr)';
    exportgraphics(gcf,...
        'img/fig6_OxygenTimeLatEPA180.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig6_OxygenTimeLatEPA180.pdf',...
        'ContentType', 'vector');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this is the plot binning Latitude and time, and look at the ecliptic
% poles

if do_plot7
    % time
    t1 = datetime(2025,4,25,'TimeZone','UTC');
    t2 = datetime(2025,11,24,'TimeZone','UTC');
    t_array = aux_make_time_bins(t1, t2, 200);

    % Latitude bin
    lat_bin = -90:5:90;

    % make an array
    HeliumGrid = nan(numel(lat_bin)-1, numel(t_array)-1);
    OxygenGrid = nan(numel(lat_bin)-1, numel(t_array)-1);

    for tt = 1:numel(t_array)-1
        % time index
        [tempMask, t_idx] =...
            aux_filter_mjd_range(csv_all.MJD_OBS, t_array(tt), t_array(tt+1));
   
        for ll = 1:numel(lat_bin)-1
            total_idx = t_idx(csv_all.SGT_LAT_MIDPT(t_idx)>lat_bin(ll) &...
                csv_all.SGT_LAT_MIDPT(t_idx)<lat_bin(ll+1) &...
                csv_all.SPS_EPA(t_idx) ~= 0 &...
                csv_all.SPS_EPA(t_idx) ~= 180);

            % okay lets try this
            HeliumGrid(ll,tt) = median(csv_all.He_D1(total_idx),'all','omitmissing');
            OxygenGrid(ll,tt) = median(csv_all.OI844_D1(total_idx),'all','omitmissing');
        end
    end
    
    xticLabel = t_array(1:end-1);
    yticLabel = -87.5:5:87.5;

    figure (71);
    HeHigh = 2.5;
    clf
    set(gcf, 'position', [100,100,800,400])
    imagesc(xticLabel, yticLabel, HeliumGrid(:,:,1), [0 HeHigh]);
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    xlabel('Date')
    ylabel('Latitude Bin')
    title('Helium Airglow, Poles')
    cb = colorbar;
    cb.Label.String = '(MJy/sr)';
    exportgraphics(gcf,...
        'img/fig7_HeTimeLatPoles.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig7_HeTimeLatPoles.pdf',...
        'ContentType', 'vector');

    figure (72);
    OHigh = 0.030;
    clf
    set(gcf, 'position', [1000,100,800,400])
    imagesc(xticLabel, yticLabel, OxygenGrid(:,:), [0 OHigh]);
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    xlabel('Date')
    ylabel('Latitude Bin')
    title('Oxygen Airglow, Poles')
    cb = colorbar;
    cb.Label.String = '(MJy/sr)';
    exportgraphics(gcf,...
        'img/fig7_OxygenTimeLatPoles.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig7_OxygenTimeLatPoles.pdf',...
        'ContentType', 'vector');

end


% this is the plot binning Latitude and time
% find all the one that is 180 + not equal to 0 and vise vesa 
if do_plot8
    % time
    t1 = datetime(2025,4,25,'TimeZone','UTC');
    t2 = datetime(2025,11,24,'TimeZone','UTC');
    t_array = aux_make_time_bins(t1, t2, 200);

    % Latitude bin
    lat_bin = -90:5:90;

    % sunrise sunset, 0 is sunset (descending), 180 is sunrise (ascending)
    Earray = [180 0];

    % make an array
    HeliumGrid = nan(numel(lat_bin)-1, numel(t_array)-1, 2);
    OxygenGrid = nan(numel(lat_bin)-1, numel(t_array)-1, 2);

    for tt = 1:numel(t_array)-1
        % time index
        [tempMask, t_idx] =...
            aux_filter_mjd_range(csv_all.MJD_OBS, t_array(tt), t_array(tt+1));
   
        for ll = 1:numel(lat_bin)-1
            for ee = 1:2
                % this is basicall finding all the latitude bins and also
                % for everything that is NOT equal to 180 or 0, so thats
                % all the poles and 0 / 180
                total_idx = t_idx(csv_all.SGT_LAT_MIDPT(t_idx)>lat_bin(ll) &...
                    csv_all.SGT_LAT_MIDPT(t_idx)<lat_bin(ll+1) &...
                    csv_all.SPS_EPA(t_idx) ~= Earray(ee));
    
                % okay lets try this
                HeliumGrid(ll,tt,ee) = median(csv_all.He_D1(total_idx),'all','omitmissing');
                OxygenGrid(ll,tt,ee) = median(csv_all.OI844_D1(total_idx),'all','omitmissing');
            end
        end
    end
    
    xticLabel = t_array(1:end-1);
    yticLabel = -87.5:5:87.5;

    figure (81);
    HeHigh = 2.5;
    clf
    set(gcf, 'position', [100,100,800,400])
    imagesc(xticLabel, yticLabel, squeeze(HeliumGrid(:,:,1)), [0 HeHigh]);
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    xlabel('Date')
    ylabel('Latitude Bin')
    title('Helium Airglow, EPA = 0, Sunset (Descending)')
    cb = colorbar;
    cb.Label.String = '(MJy/sr)';
    exportgraphics(gcf,...
        'img/fig8_HeTimeLatEPA000wpole.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig8_HeTimeLatEPA000wpole.pdf',...
        'ContentType', 'vector');

    figure (82);
    HeHigh = 2.5;
    clf
    set(gcf, 'position', [1000,100,800,400])
    imagesc(xticLabel, yticLabel, squeeze(HeliumGrid(:,:,2)), [0 HeHigh]);
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    xlabel('Date')
    ylabel('Latitude Bin')
    title('Helium Airglow, EPA = 180, Sunrise (Ascending)')
    cb = colorbar;
    cb.Label.String = '(MJy/sr)';
    exportgraphics(gcf,...
        'img/fig8_HeTimeLatEPA180wpole.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig8_HeTimeLatEPA180wpole.pdf',...
        'ContentType', 'vector');

    figure (83);
    OHigh = 0.030;
    clf
    set(gcf, 'position', [100,600,800,400])
    imagesc(xticLabel, yticLabel, squeeze(OxygenGrid(:,:,1)), [0 OHigh]);
    colorbar
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    xlabel('Date')
    ylabel('Latitude Bin')
    title('Oxygen Airglow, EPA = 0, Sunset (Descending)')
    cb = colorbar;
    cb.Label.String = '(MJy/sr)';
    exportgraphics(gcf,...
        'img/fig8_OxygenTimeLatEPA000wpole.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig8_OxygenTimeLatEPA000wpole.pdf',...
        'ContentType', 'vector');

    figure (84);
    OHigh = 0.030;
    clf
    set(gcf, 'position', [1000,600,800,400])
    imagesc(xticLabel, yticLabel, squeeze(OxygenGrid(:,:,2)), [0 OHigh]);
    colorbar
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    xlabel('Date')
    ylabel('Latitude Bin')
    title('Oxygen Airglow, EPA = 180, Sunrise (Ascending)')
    cb = colorbar;
    cb.Label.String = '(MJy/sr)';
    exportgraphics(gcf,...
        'img/fig8_OxygenTimeLatEPA180wpole.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig8_OxygenTimeLatEPA180wpole.pdf',...
        'ContentType', 'vector');

    figure (85);
    clf
    set(gcf, 'position', [1000,100,800,400])
    plot(t_array(1:end-1), smooth(squeeze(HeliumGrid(5,:,2))),'-','LineWidth',1.5);
    hold on
    plot(t_array(1:end-1), smooth(squeeze(HeliumGrid(18,:,2))),'-','LineWidth',1.5);
    plot(t_array(1:end-1), smooth(squeeze(HeliumGrid(32,:,2))),'-','LineWidth',1.5);
    set(gca, 'LineWidth', 2);    % thick border
    legend('South','Mid','North')
    box on;
    xlabel('Date')
    ylabel('Helium Airglow (MJy/sr)')
    title('Helium Airglow at Different Latitude, Sunrise (Ascending)')
    exportgraphics(gcf,...
        'img/fig9_HeDiffLatEPA180.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig9_HeDiffLatEPA180.pdf',...
        'ContentType', 'vector');

    figure (86);
    clf
    set(gcf, 'position', [1000,600,800,400])
    plot(t_array(1:end-1), smooth(squeeze(OxygenGrid(5,:,2))),'-','LineWidth',1.5);
    hold on
    plot(t_array(1:end-1), smooth(squeeze(OxygenGrid(18,:,2))),'-','LineWidth',1.5);
    plot(t_array(1:end-1), smooth(squeeze(OxygenGrid(32,:,2))),'-','LineWidth',1.5);
    set(gca, 'LineWidth', 2);    % thick border
    legend('South','Mid','North')
    box on;
    xlabel('Date')
    ylabel('Oxygen Airglow (MJy/sr)')
    title('Oxygen Airglow at Different Latitude, Sunrise (Ascending)')
    exportgraphics(gcf,...
        'img/fig9_HeDiffLatEPA180.png','Resolution',300);
    exportgraphics(gcf,...
        'img/fig9_HeDiffLatEPA180.pdf',...
        'ContentType', 'vector');

end

