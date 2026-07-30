function quicklook_20261117_paperplot()
keyboard
% quicklook_20260117_paperplot
% HH

% plot_fig_1: example exposure
% plot_fig_2: 1 D spectral templates

function plot_fig_1
    % load band 1 and band 2
    FITS_b1 =...
        fitsread('files/Data/level2_2025W42_2A_0367_3D1_spx_l2b-v20-2025-293.fits','image',1);
    FITS_b2 =...
        fitsread('files/Data/level2_2025W42_2A_0367_3D2_spx_l2b-v20-2025-293.fits','image',1);

    fig = figure (1);
    clf
    set(gcf, 'position', [100,100,1000,500])
    t = tiledlayout(1,2,...
        'TileSpacing','tight', ...
        'Padding','tight');

    h(1) = nexttile(t);
    imagesc(log10(abs(FITS_b1)), [-1 0.5]); axis square
    %colorbar
    colormap hot
    ylabel('\leftarrow Increase Wavelength, \lambda = 0.74 - 1.12\mum')
    %yticks([500 1000 1500 2000])
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    axis xy;
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    title('Band 1', 'FontWeight', 'Normal');

    h(2) = nexttile(t);
    imagesc(log10(abs(FITS_b2)), [-1 0.5]); axis square
    colormap hot
    ylabel('\leftarrow Increase Wavelength, \lambda = 1.09 - 1.67\mum')
    %yticks([500 1000 1500 2000])
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    axis xy;
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    cb = colorbar;
    cb.Label.String = 'log(MJy/sr)';
    cb.Label.FontSize = 20;
    title('Band 2', 'FontWeight', 'Normal');

    exportgraphics(gcf,...
        'img/paper/spherex_exposures.pdf',...
        'ContentType', 'vector');
end

function plot_fig_2
    % load band 1 and band 2
    B1_0845 = readtable('files/Templates/Band1_template_0844nm.csv');
    B1_1083 = readtable('files/Templates/Band1_template_1083nm.csv');
    B1_1129 = readtable('files/Templates/Band1_template_1129nm.csv');
    B2_1083 = readtable('files/Templates/Band2_template_1083nm.csv');
    B2_1129 = readtable('files/Templates/Band2_template_1129nm.csv');

    fig = figure (2);
    clf
    set(gcf, 'position', [100,100,1000,500])
    t = tiledlayout(1,2,...
        'TileSpacing','compact', ...
        'Padding','tight');

    h(1) = nexttile(t);
    plot(B1_0845.Wavelength_um, B1_0845.Band1_0844nm,'b-','LineWidth',2);
    hold on
    plot(B1_1083.Wavelength_um, B1_1083.Band1_1083nm,'g-','LineWidth',2);
    plot(B1_1129.Wavelength_um, abs(B1_1129.Band1_1129nm),'r-','LineWidth',2);
    ylabel('Normalized Spectral Template (-)')
    xlim([0.73 1.14])
    ylim([1e-3 1])
    title('Band 1', 'FontWeight', 'Normal');
    grid on
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    legend('0.845\mum','1.083\mum','1.129\mum','Location','north')
    set(gca,'YScale','log')
    xlabel('wavelength \lambda (\mum)')

    h(2) = nexttile(t);
    plot(B2_1083.Wavelength_um, B2_1083.Band2_1083nm,'g-','LineWidth',2);
    hold on
    plot(B2_1129.Wavelength_um, B2_1129.Band2_1129nm,'r-','LineWidth',2);
    %set(gca, 'YTick', []);
    %ylabel('Normalized Spectral Template (-)')
    xlim([1.07 1.7])
    ylim([1e-3 1])
    title('Band 2', 'FontWeight', 'Normal');
    grid on
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    legend('1.083\mum','1.129\mum','Location','northeast')
    set(gca,'YScale','log')
    xlabel('wavelength \lambda (\mum)')

    exportgraphics(gcf,...
        'img/paper/spectral_templates.pdf',...
        'ContentType', 'vector');
end

end