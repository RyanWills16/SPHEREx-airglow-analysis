% load the line files and make 2D template
step = 0.002;

% band 1 and 2
for array_num = 1:2
    % SpecCal
    lam_c = fitsread(sprintf('20250901_SSDC_BC_Band%d.fits',...
        array_num), 'image',1);
    start_lam = min(lam_c,[],'all');
    end_lam = max(lam_c,[],'all');

    % what is the zodi
    FITS_highOI_zodi = fitsread(...
        ['level2_2025W42_2A_0367_3',...
        sprintf('D%d_spx_l2b-v20-2025-293.fits', array_num)],...
        'image',4);
    FITS_noOI_zodi = fitsread(...
        ['level2_2025W37_2A_0483_1',...
        sprintf('D%d_spx_l2b-v20-2025-267.fits', array_num)],...
        'image',4);

    % what is the 1D line for zodi
        [lam, spec_noOI_zodi] =...
            aux_find1D_spec(FITS_noOI_zodi, lam_c, start_lam, end_lam, step);
        [lam, spec_highOI_zodi] =...
            aux_find1D_spec(FITS_highOI_zodi, lam_c, start_lam, end_lam, step);

    %%%%%%%%%%%%%% He 1.083, OI 0.845, 1.129 %%%%%%%%%%%%%%
    He_1083 = readtable(sprintf('files/Templates/Band%d_template_1083nm.csv', array_num));
    OI_1129 = readtable(sprintf('files/Templates/Band%d_template_1129nm.csv', array_num));
    
    if array_num == 1
        He_1083 = He_1083.Band1_1083nm;
        OI_0844 = readtable(sprintf('files/Templates/Band%d_template_0844nm.csv', array_num));
        OI_0844 = OI_0844.Band1_0844nm;
        OI_1129 = OI_1129.Band1_1129nm;
        OI_0844_2D = aux_build_2DTemplate(lam, OI_0844, lam_c);
    elseif array_num == 2
        He_1083 = He_1083.Band2_1083nm;
        OI_1129 = OI_1129.Band2_1129nm;
    end
    % now make that to 2D
    He_1083_2D = aux_build_2DTemplate(lam, He_1083, lam_c);
    OI_1129_2D = aux_build_2DTemplate(lam, OI_1129, lam_c);
    
    %%%%%%%%%%%% save the 2D template %%%%%%%%%%%%%%%%%%%%%
    fitswrite(He_1083_2D, sprintf('files/Templates/Band%d_template_1083nm.FITS',array_num));
    fitswrite(OI_1129_2D, sprintf('files/Templates/Band%d_template_1129nm.FITS',array_num));
    if array_num == 1
        fitswrite(OI_0844_2D, sprintf('files/Templates/Band%d_template_0844nm.FITS',array_num));
    end


    %%%%%%%%%%%%%% figure %%%%%%%%%%%%%%%%%
    % zodi, 1/2D and no/high OI
    figure (11)
    clf
    set(gcf, 'position', [100,100,500,400])
    plot(lam, spec_noOI_zodi, '-k','LineWidth',2);
    xlabel('wavelength \lambda (\mum)')
    grid on
    if array_num == 1
        xlim([0.73 1.13])
    elseif array_num ==2
        xlim([1.08 1.65])
    elseif array_num == 3
        xlim([1.6 2.4])
    end
    title(sprintf('Band %d Zodi Template, no OI', array_num))
    ylabel('MJy/sr')
    ylim([0.08 0.14])
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_ZodinoOI_1D.png',...
        array_num),'Resolution',300);
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_ZodinoOI_1D.pdf',...
        array_num),...
        'ContentType', 'vector');

    figure (12)
    clf
    set(gcf, 'position', [100,100,500,400])
    plot(lam, spec_highOI_zodi, '-k','LineWidth',2);
    xlabel('wavelength \lambda (\mum)')
    grid on
    if array_num == 1
        xlim([0.73 1.13])
    elseif array_num ==2
        xlim([1.08 1.65])
    elseif array_num == 3
        xlim([1.6 2.4])
    end
    title(sprintf('Band %d Zodi Template, high OI', array_num))
    ylabel('MJy/sr')
    ylim([0.08 0.14])
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_ZodihighOI_1D.png',...
        array_num),'Resolution',300);
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_ZodihighOI_1D.pdf',...
        array_num),...
        'ContentType', 'vector');

    figure (13)
    clf
    set(gcf, 'position', [100,100,500,400])
    imagesc(FITS_noOI_zodi, [0.08 0.14]);
    colormap hot
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    title(sprintf('Band %d Zodi Template, no OI', array_num))
    cb = colorbar;
    cb.Label.String = '(MJy/sr)';
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_ZodinoOI_2D.png',...
        array_num),'Resolution',300);
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_ZodinoOI_2D.pdf',...
        array_num),...
        'ContentType', 'vector');

    figure (14)
    clf
    set(gcf, 'position', [100,100,500,400])
    imagesc(FITS_highOI_zodi, [0.08 0.14]);
    colormap hot
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    title(sprintf('Band %d Zodi Template, high OI', array_num))
    cb = colorbar;
    cb.Label.String = '(MJy/sr)';
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_ZodihighOI_2D.png',...
        array_num),'Resolution',300);
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_ZodihighOI_2D.pdf',...
        array_num),...
        'ContentType', 'vector');


    %%%%%%%%%%%%%%%%%
    % this is helium
    figure (21)
    clf
    set(gcf, 'position', [100,100,500,400])
    plot(lam, He_1083, '-k','LineWidth',2);
    xlabel('wavelength \lambda (\mum)')
    grid on
    if array_num == 1
        xlim([0.73 1.13])
    elseif array_num ==2
        xlim([1.08 1.65])
    elseif array_num == 3
        xlim([1.6 2.4])
    end
    title(sprintf('Band %d 1.083\mum He Template', array_num))
    ylabel('Normalized (-)')
    ylim([-0.02 1])
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_He1083_1D.png',...
        array_num),'Resolution',300);
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_He1083_1D.pdf',...
        array_num),...
        'ContentType', 'vector');

    figure (22)
    clf
    set(gcf, 'position', [100,100,500,400])
    imagesc(He_1083_2D, [-0.02 1]);
    title(sprintf('Band %d 1.083\mum He Template', array_num))
    colormap hot
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    cb = colorbar;
    cb.Label.String = '(-)';
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_He1083_2D.png',...
        array_num),'Resolution',300);
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_He1083_2D.pdf',...
        array_num),...
        'ContentType', 'vector');

    % this is OI 1129
    figure (31)
    clf
    set(gcf, 'position', [100,100,500,400])
    plot(lam, OI_1129, '-k','LineWidth',2);
    xlabel('wavelength \lambda (\mum)')
    grid on
    if array_num == 1
        xlim([0.73 1.13])
    elseif array_num ==2
        xlim([1.08 1.65])
    elseif array_num == 3
        xlim([1.6 2.4])
    end
    title(sprintf('Band %d 1.129\mum OI Template', array_num))
    ylabel('Normalized (-)')
    ylim([-0.02 1])
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_OI1129_1D.png',...
        array_num),'Resolution',300);
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_OI1129_1D.pdf',...
        array_num),...
        'ContentType', 'vector');

    figure (32)
    clf
    set(gcf, 'position', [100,100,500,400])
    imagesc(OI_1129_2D, [-0.02 1]);
    title(sprintf('Band %d 1.129\mum OI Template', array_num))
    colormap hot
    set(gca, 'LineWidth', 2);    % thick border
    box on;
    axis xy
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    cb = colorbar;
    cb.Label.String = '(-)';
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_OI1129_2D.png',...
        array_num),'Resolution',300);
    exportgraphics(gcf,...
        sprintf('img/templates/band%d_OI1129_2D.pdf',...
        array_num),...
        'ContentType', 'vector');

    if array_num == 1
        % this is OI 0844
        figure (41)
        clf
        set(gcf, 'position', [100,100,500,400])
        plot(lam, OI_0844, '-k','LineWidth',2);
        xlabel('wavelength \lambda (\mum)')
        grid on
        xlim([0.73 1.13])
        title(sprintf('Band %d 0.844\mum OI Template', array_num))
        ylabel('Normalized (-)')
        ylim([-0.02 1])
        set(gca, 'LineWidth', 2);    % thick border
        box on;
        exportgraphics(gcf,...
            sprintf('img/templates/band%d_OI0844_1D.png',...
            array_num),'Resolution',300);
        exportgraphics(gcf,...
            sprintf('img/templates/band%d_OI0844_1D.pdf',...
            array_num),...
            'ContentType', 'vector');
    
        figure (42)
        clf
        set(gcf, 'position', [100,100,500,400])
        imagesc(OI_0844_2D, [-0.02 1]);
        title(sprintf('Band %d 0.844\mum OI Template', array_num))
        colormap hot
        set(gca, 'LineWidth', 2);    % thick border
        box on;
        axis xy
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
        cb = colorbar;
        cb.Label.String = '(-)';
        exportgraphics(gcf,...
            sprintf('img/templates/band%d_OI0844_2D.png',...
            array_num),'Resolution',300);
        exportgraphics(gcf,...
            sprintf('img/templates/band%d_OI0844_2D.pdf',...
            array_num),...
            'ContentType', 'vector');



    end




end