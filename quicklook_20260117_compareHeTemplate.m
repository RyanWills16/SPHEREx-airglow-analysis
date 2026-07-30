% what is Yujin's template

B1_fringe_avg = fitsread('fringe_level2_band1_avg.fits');
B1_smooth = fitsread('smooth_level2_band1.fits');
B1_templ = fitsread('templ_level2_band1_HeI.fits');
% mine
B1_HH = fitsread('files/Templates/Band1_template_1083nm.FITS');
% what is the 1D
lam_c = fitsread('20250901_SSDC_BC_Band1.fits', 'image',1);
start_lam = min(lam_c,[],'all');
end_lam = max(lam_c,[],'all');
step = 0.002;

[lam, B1_fringe_avg_1D, temp] =...
    aux_find1D_spec(B1_fringe_avg, lam_c, start_lam, end_lam, step);
[lam, B1_smooth_1D, temp] =...
    aux_find1D_spec(B1_smooth, lam_c, start_lam, end_lam, step);
[lam, B1_templ_1D, temp] =...
    aux_find1D_spec(B1_templ, lam_c, start_lam, end_lam, step);
[lam, B1_HH_1D, temp] =...
    aux_find1D_spec(B1_HH, lam_c, start_lam, end_lam, step);

figure (100);
clf
set(gcf, 'position', [100,100,500,400])
%plot(lam, B1_fringe_avg_1D, '-','LineWidth',2);
hold on
plot(lam, B1_smooth_1D, '-','LineWidth',2);
plot(lam, B1_templ_1D, '-','LineWidth',2);
plot(lam, B1_HH_1D, '-','LineWidth',2);
legend('smooth','templ','HH','Location','northwest');
xlabel('wavelength \lambda (\mum)')
title('Compare different template')
grid on 

figure (101);
clf
set(gcf, 'position', [100,100,500,400])
%plot(lam, B1_HH_1D - B1_fringe_avg_1D, '-','LineWidth',2);
hold on
plot(lam, B1_HH_1D - B1_smooth_1D, '-','LineWidth',2);
plot(lam, B1_HH_1D - B1_templ_1D, '-','LineWidth',2);
legend('smooth','templ','Location','northwest');
xlabel('wavelength \lambda (\mum)')
title('SpecCal - YJ')
grid on


%{
% make the plot
figure (11)
clf
set(gcf, 'position', [100,100,500,400])
imagesc(B1_fringe_avg, [0 .1]);
%colormap hot
set(gca, 'LineWidth', 2);    % thick border
box on;
axis xy
set(gca, 'XTick', []);
set(gca, 'YTick', []);
title('Band 1, fringe average')
cb = colorbar;
%cb.Label.String = 'log(MJy/sr)';

figure (12)
clf
set(gcf, 'position', [100,100,500,400])
imagesc(B1_smooth, [0 1]);
%colormap hot
set(gca, 'LineWidth', 2);    % thick border
box on;
axis xy
set(gca, 'XTick', []);
set(gca, 'YTick', []);
title('Band 1, smooth')
cb = colorbar;
%cb.Label.String = 'log(MJy/sr)';

figure (13)
clf
set(gcf, 'position', [100,100,500,400])
imagesc(B1_templ, [0 1]);
%colormap hot
set(gca, 'LineWidth', 2);    % thick border
box on;
axis xy
set(gca, 'XTick', []);
set(gca, 'YTick', []);
title('Band 1, templ')
cb = colorbar;
%cb.Label.String = 'log(MJy/sr)';

figure (22)
clf
set(gcf, 'position', [100,100,500,400])
imagesc(B1_HH - B1_smooth, [-0.05 0.05]);
%colormap hot
set(gca, 'LineWidth', 2);    % thick border
box on;
axis xy
set(gca, 'XTick', []);
set(gca, 'YTick', []);
title('Band 1, KASI4 - smooth')
cb = colorbar;
%cb.Label.String = 'log(MJy/sr)';

figure (23)
clf
set(gcf, 'position', [100,100,500,400])
imagesc(B1_HH - B1_templ, [-0.05 0.05]);
%colormap hot
set(gca, 'LineWidth', 2);    % thick border
box on;
axis xy
set(gca, 'XTick', []);
set(gca, 'YTick', []);
title('Band 1, KASI4 - templ')
cb = colorbar;
%cb.Label.String = 'log(MJy/sr)';
%}