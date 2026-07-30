function quicklook_20260102_FFpaperplot()

%%%%% example %%%%%%%
%{
fig = figure (16);
clf
set(gcf, 'position', [100,100,500,400])
plot(Band1LVF.Wavelength_um, Band1LVF.FidSpecMiddlePixel, '-', 'LineWidth',2, 'Color',inc_color(1,6));
legend ('LVF Respond at 1.083\mum','Helium Airglow','Location','southeast')
grid on
set(gca, 'YScale', 'log');
set(gca, 'LineWidth', 2);    % thick border
box on;
xlabel('Wavelength [\mum]')
ylabel('Normalized Response')
print('figs/PaperPlots/fig16_HeAirglow', '-dpng')
exportgraphics(gcf, 'figs/PaperPlots/fig16_HeAirglow.pdf', 'ContentType', 'vector');
%}

keyboard

% figure 1
% FF with no correction
function plot_fig_1
    % load the no correction
    FF_noCorr =...
        load('/Volumes/T7/SPHEREx/matFiles/20251231_FFelon/20251230_FFZodiB2.mat');
    FF_Corr =...
        load('/Volumes/T7/SPHEREx/matFiles/20251231_FFelon/20251231_FFZodiCorrB2.mat');

    fig = figure (100);
    clf
    set(gcf, 'position', [100,100,500,400])
    imagesc(FF_noCorr.tempFF, [0.96 1.04]);
    colormap hot
    colorbar;

    title('Band 2, No Elongation Correction');
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    print('figs/20251231_FF/PaperPlots/fig1_Band2FF_noCorr',...
        '-dpng')
    exportgraphics(gcf,...
        'figs/20251231_FF/PaperPlots/fig1_Band2FF_noCorr.pdf',...
        'ContentType', 'vector');

    fig = figure (101);
    clf
    set(gcf, 'position', [100,600,500,400])
    histogram(FF_noCorr.tempFF, [0.96:0.001:1.04]);
    title('Band 2, No Elongation Correction');
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    xlabel('Flatfield Error [-]')
    ylabel('Pixel Count')
    print('figs/20251231_FF/PaperPlots/fig1_Band2FF_noCorr_hist',...
        '-dpng')
    exportgraphics(gcf,...
        'figs/20251231_FF/PaperPlots/fig1_Band2FF_noCorr_hist.pdf',...
        'ContentType', 'vector');

    fig = figure (102);
    clf
    set(gcf, 'position', [100,100,500,400])
    imagesc(FF_Corr.tempFF, [0.96 1.04]);
    colormap hot
    colorbar;

    title('Band 2, With Elongation Correction');
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    print('figs/20251231_FF/PaperPlots/fig1_Band2FF_Corr',...
        '-dpng')
    exportgraphics(gcf,...
        'figs/20251231_FF/PaperPlots/fig1_Band2FF_Corr.pdf',...
        'ContentType', 'vector');

    fig = figure (103);
    clf
    set(gcf, 'position', [100,600,500,400])
    histogram(FF_Corr.tempFF, [0.96:0.001:1.04]);
    title('Band 2, With Elongation Correction');
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    xlabel('Flatfield Error [-]')
    ylabel('Pixel Count')
    print('figs/20251231_FF/PaperPlots/fig1_Band2FF_Corr_hist',...
        '-dpng')
    exportgraphics(gcf,...
        'figs/20251231_FF/PaperPlots/fig1_Band2FF_Corr_hist.pdf',...
        'ContentType', 'vector');

    fprintf('No Correction = %0.4f\n',std(FF_noCorr.tempFF, [],'all','omitmissing'))
    fprintf('With Correction = %0.4f\n',std(FF_Corr.tempFF, [],'all','omitmissing'))
end


end