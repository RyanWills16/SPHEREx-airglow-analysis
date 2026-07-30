%%%% this is just a note for Howard's todo

% first load the csv, and find some exposure that is
% low number of flags, medium He, no oxygen in band 1 and band 2
% low number of flags, medium He, high oxygen in band 1 and band 2

% Helium: 1.083um 
% Oxygen: 1.129um, (201634, dark 202936)
% 0.8446um

do_step1 = 0;
do_step2 = 1;

csv_all = readtable('combined_D1_amplitudes.csv');
step = 0.002;

if do_step1
    tempIDXnoOI = find(csv_all.mask_frac < 0.5 &... % less than 50% pixel masked
        csv_all.He_D1>0.45 & csv_all.He_D1<0.55 &... % Helium between 0.45 and 0.55
        csv_all.OI844_D1 > 0 & csv_all.OI844_D1 < 0.005);
    
    tempIDXhighOI = find(csv_all.mask_frac < 0.5 &... % less than 50% pixel masked
        csv_all.He_D1>0.45 & csv_all.He_D1<0.55 &... % Helium between 0.45 and 0.55
        csv_all.OI844_D1 > 0 & csv_all.OI844_D1 > 0.03 );
    
    % two data set one with low oxygen and one with high oxygen
    csv_noOI = csv_all(tempIDXnoOI,:);
    csv_highOI = csv_all(tempIDXhighOI,:);
    
    % HIGH OI: '2025W42_2A_0367_3', He 0.5317, Aurora 0.0050, OI: 0.0328
    % LOW OI: '2025W37_2A_0483_1'
end

%%%% going to do this filtering step myself %%%% in 1D to see whats up

if do_step2

    % template
    %{
    % now what is the 1.083 template
    HeTemplate = readtable('FiducialSpec_Band1_SubCh06_68.csv');
    % minor correction
    HeTemplate.Wavelength_um = HeTemplate.Wavelength_um+0.001;
    % 0.844 template
    OITemplate = readtable('FiducialSpec_Band1_SubCh47_68.csv');
    %}

    %%%%%%%% temp

    %%%%%%%%

    for array_num = 1%:2%[1,3]
       % SpecCal
        lam_c = fitsread(sprintf('20250901_SSDC_BC_Band%d.fits',...
            array_num), 'image',1);
        start_lam = min(lam_c,[],'all');
        end_lam = max(lam_c,[],'all');
        
        %% Templates
        if array_num == 1
            % templates in Band 1, 1.083, 0.844, 1.129
            % 1.083 He
            specCal_1083 = fitsread('refCorr_slope_SPX_ID11_21903_20231130_181428.FITS');
            specCal_1083_dark = fitsread('refCorr_slope_SPX_ID11_21903_20231130_181848_close.FITS');
            specCal_1083 = specCal_1083-specCal_1083_dark;
            specCal_Final1083 = fitsread('20231130_181428_band1_1083_1_1.FITS');
            
            % 0.844 OI
            specCal_0844 = fitsread('refCorr_slope_SPX_ID11_21903_20231130_075757.FITS');
            specCal_0844_dark = fitsread('refCorr_slope_SPX_ID11_21903_20231130_075336_close.FITS');
            specCal_0844 = specCal_0844-specCal_0844_dark;
            specCal_Final0844 = fitsread('20231130_075757_band1_0845_1_1.FITS');
            
            % 1.129 OI
            specCal_1129 = fitsread('refCorr_slope_SPX_ID11_21903_20231130_201634.FITS');
            specCal_1129_dark = fitsread('refCorr_slope_SPX_ID11_21903_20231130_202936_close.FITS');
            specCal_1129 = specCal_1129-specCal_1129_dark;
            specCal_Final1129 = fitsread('20231130_201634_band1_1129_1_1.FITS');

            load ('band1HeCorr.mat');

            % 1.05765, 1.10965, lam #162:188

            % template in 1D form
            [lam, template_0844_final, sig_template_0844] =...
                aux_find1D_spec(specCal_Final0844, lam_c, start_lam, end_lam, step);
            [lam, template_1083_final, sig_template_1083] =...
                aux_find1D_spec(specCal_Final1083, lam_c, start_lam, end_lam, step);
            [lam, template_1129_final, sig_template_1129] =...
                aux_find1D_spec(specCal_Final1129, lam_c, start_lam, end_lam, step);

            %%%%%%%%%%%%%%%%%%%

            template_1083 = template_1083_final;
            template_0844 = template_0844_final;
            template_1129 = template_1129_final;

            % normalized them
            template_0844 = template_0844/max(template_0844,[], 'all','omitmissing');
            template_1083 = template_1083/max(template_1083,[], 'all','omitmissing');
            template_1129 = template_1129/max(template_1129,[], 'all','omitmissing');

            % correction on He
            template_1083(163:193) = template_1083(163:193)+ band1HeCorr;
            template_1083 = template_1083/max(template_1083,[], 'all','omitmissing');

            % save the 1D template
            % Helium 1.083um
            T_1083 = table(lam(:), template_1083(:), 'VariableNames',...
                {'Wavelength_um','Band1_1083nm'});
            writetable(T_1083, 'files/Templates/Band1_template_1083nm.csv');
            % Oxygen 0.844um
            T_0844 = table(lam(:), template_0844(:), 'VariableNames',...
                {'Wavelength_um','Band1_0844nm'});
            writetable(T_0844, 'files/Templates/Band1_template_0844nm.csv');
            % Oxygen 1.129um
            T_1129 = table(lam(:), template_1129(:), 'VariableNames',...
                {'Wavelength_um','Band1_1129nm'});
            writetable(T_1129, 'files/Templates/Band1_template_1129nm.csv');
       
        elseif array_num == 2
            % templates in Band 2, 1.083 (1.082), 1.129 (1.13)
            % 1.083 He, 20231127_122818, 20231127_123039_Close
            specCal_1083 = fitsread('20231127_122818_band2_1082_2_1.FITS');
            % 1.129 OI
            specCal_1129 = fitsread('20231127_125138_band2_1130_2_1.FITS');
            load ('band2HeCorr.mat');
            load ('band2OICorr.mat');
            % 1.05765, 1.10965, lam #162:188

            % template in 1D form
            [lam, template_1083, sig_template_1083] =...
                aux_find1D_spec(specCal_1083, lam_c, start_lam, end_lam, step);
            [lam, template_1129, sig_template_1129] =...
                aux_find1D_spec(specCal_1129, lam_c, start_lam, end_lam, step);

            % normalized them
            template_1083 = template_1083/max(template_1083,[], 'all','omitmissing');
            template_1129 = template_1129/max(template_1129,[], 'all','omitmissing');
            % small correction on He
            template_1083(1:13) = template_1083(1:13)+ band2HeCorr;
            template_1083 = template_1083/max(template_1083,[], 'all','omitmissing');
            
            % small correction on OI
            %template_1129(13:34) = template_1129(13:34)+ band2OICorr;
            %template_1129 = template_1129/max(template_1129,[], 'all','omitmissing');
            template_1129(1:end-2) = template_1129(3:end);

            % save the 1D template
            % Helium 1.083um
            T_1083 = table(lam(:), template_1083(:), 'VariableNames',...
                {'Wavelength_um','Band2_1083nm'});
            writetable(T_1083, 'files/Templates/Band2_template_1083nm.csv');
            % Oxygen 1.129um
            T_1129 = table(lam(:), template_1129(:), 'VariableNames',...
                {'Wavelength_um','Band2_1129nm'});
            writetable(T_1129, 'files/Templates/Band2_template_1129nm.csv');

        elseif array_num == 3
            % 1.8244um is the line they care
        end

        % load the FITS
        FITS_noOIRaw = fitsread(...
            ['level2_2025W37_2A_0483_1',...
            sprintf('D%d_spx_l2b-v20-2025-267.fits', array_num)],...
            'image',1);
        FITS_noOI_flags = fitsread(...
            ['level2_2025W37_2A_0483_1',...
            sprintf('D%d_spx_l2b-v20-2025-267.fits', array_num)],...
            'image',2);
        FITS_noOI_zodi = fitsread(...
            ['level2_2025W37_2A_0483_1',...
            sprintf('D%d_spx_l2b-v20-2025-267.fits', array_num)],...
            'image',4);
        FITS_highOIRaw = fitsread(...
            ['level2_2025W42_2A_0367_3',...
            sprintf('D%d_spx_l2b-v20-2025-293.fits', array_num)],...
            'image',1);
        FITS_highOI_flags = fitsread(...
            ['level2_2025W42_2A_0367_3',...
            sprintf('D%d_spx_l2b-v20-2025-293.fits', array_num)],...
            'image',2);
        FITS_highOI_zodi = fitsread(...
            ['level2_2025W42_2A_0367_3',...
            sprintf('D%d_spx_l2b-v20-2025-293.fits', array_num)],...
            'image',4);
        
        FITS_noOI = FITS_noOIRaw;
        FITS_highOI = FITS_highOIRaw;
        % nan the flagged pixel
        tempFlagIDX = FITS_noOI_flags>0;
        FITS_noOI(tempFlagIDX) = nan;
        tempFlagIDX = FITS_highOI_flags>0;
        FITS_highOI(tempFlagIDX) = nan;
    
        % now find the 1D spectra for the data and zodi
        [lam, spec_noOI] =...
            aux_find1D_spec(FITS_noOI, lam_c, start_lam, end_lam, step);
        [lam, spec_highOI] =...
            aux_find1D_spec(FITS_highOI, lam_c, start_lam, end_lam, step);
        % now what is the zodi template
        [lam, spec_noOI_zodi] =...
            aux_find1D_spec(FITS_noOI_zodi, lam_c, start_lam, end_lam, step);
        [lam, spec_highOI_zodi] =...
            aux_find1D_spec(FITS_highOI_zodi, lam_c, start_lam, end_lam, step);

        figure (123)
        clf
        set(gcf, 'position', [100,100,500,400])
        plot(lam, spec_noOI, '-r','LineWidth',2);
        hold on
        plot(lam, spec_highOI, '-b','LineWidth',2);
        xlabel('wavelength \lambda (\mum)')
        grid on
        if array_num == 1
            xlim([0.73 1.13])
            legend('No OI','High OI', 'Location','northwest')
            ylim([0 0.8])
        elseif array_num ==2
            xlim([1.08 1.65])
            legend('No OI','High OI', 'Location','northeast')
            ylim([0 0.8])
        elseif array_num == 3
            xlim([1.6 2.4])
        end
        title(sprintf('Band %d Exposures', array_num))
        ylabel('(MJy/sr)')
        set(gca, 'LineWidth', 2);    % thick border
        box on;
        exportgraphics(gcf,...
            sprintf('img/band%d/ex_band%d_raw1Dspec.png',...
            array_num, array_num),'Resolution',300);
        exportgraphics(gcf,...
            sprintf('img/band%d/ex_band%d_raw1Dspec.pdf',...
            array_num, array_num),...
            'ContentType', 'vector');

        %%%%% do the fitting %%%%%
        if array_num == 1
            
            % doing the fit
            [highOI_HeAmp, highOI_OIAmp, highOI_OI2Amp, highOI_ZodiAmp] =...
                aux_fit_templates(spec_highOI, template_1083,...
                template_0844, template_1129, spec_highOI_zodi);        
            [noOI_HeAmp, noOI_OIAmp, noOI_OI2Amp, noOI_ZodiAmp] =...
                aux_fit_templates(spec_noOI, template_1083,...
                template_0844, template_1129, spec_noOI_zodi);

            % What are the residual
            highOI_Res = spec_highOI-(...
                highOI_HeAmp*template_1083+...
                highOI_OIAmp*template_0844+...
                highOI_OI2Amp*template_1129+...
                highOI_ZodiAmp*spec_highOI_zodi);

            noOI_Res = spec_noOI-(...
                noOI_HeAmp*template_1083+...
                noOI_OIAmp*template_0844+...
                noOI_OI2Amp*template_1129+...
                noOI_ZodiAmp*spec_noOI_zodi);
            
            % what does it looks like
            fig = figure (101);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_highOI, 'k-','LineWidth',2);
            hold on
            plot(lam, highOI_Res, 'r--','LineWidth',2);
            plot(lam, highOI_HeAmp*template_1083, 'g-','LineWidth',1.2);
            plot(lam, highOI_OIAmp*template_0844, 'b-','LineWidth',1.2);
            plot(lam, highOI_OI2Amp*template_1129, 'c-','LineWidth',1.2);
            plot(lam, highOI_ZodiAmp*spec_highOI_zodi,'m-','LineWidth',1.2);
            legend('Data','Residual of Fit',...
                sprintf('1.083\\mum Helium = %0.3f', highOI_HeAmp),...
                sprintf('0.844\\mum Oxygen = %0.3f', highOI_OIAmp),...
                sprintf('1.129\\mum Oxygen = %0.3f', highOI_OI2Amp),...
                sprintf('Zodi Fit = %0.3f', highOI_ZodiAmp),...
                'Location','northwest')
            grid on
            title('Band 1, High OI, 2025W42_2A_0367_3','Interpreter','none')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.05 0.8])
            xlim([0.73 1.13])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_fit.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_fit.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            fig = figure (102);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_noOI, 'k-','LineWidth',2);
            hold on
            plot(lam, noOI_Res, 'r--','LineWidth',2);
            plot(lam, noOI_HeAmp*template_1083, 'g-','LineWidth',1.2);
            plot(lam, noOI_OIAmp*template_0844, 'b-','LineWidth',1.2);
            plot(lam, noOI_OI2Amp*template_1129, 'c-','LineWidth',1.2);
            plot(lam, noOI_ZodiAmp*spec_noOI_zodi,'m-','LineWidth',1.2);
            legend('Data','Residual of Fit',...
                sprintf('1.083\\mum Helium = %0.3f', noOI_HeAmp),...
                sprintf('0.844\\mum Oxygen = %0.3f', noOI_OIAmp),...
                sprintf('1.129\\mum Oxygen = %0.3f', noOI_OI2Amp),...
                sprintf('Zodi Fit = %0.3f', noOI_ZodiAmp),...
                'Location','northwest')
            grid on
            title('Band 1, No OI, 2025W37_2A_0483_1','Interpreter','none')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.05 0.8])
            xlim([0.73 1.13])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_fit.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_fit.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            
            % 1) what does it looks like removing Zodi
            fig = figure (201);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_highOI, 'k-','LineWidth',2);
            hold on
            plot(lam,...
                spec_highOI-(...
                highOI_ZodiAmp*spec_highOI_zodi), 'r--','LineWidth',2);
            legend('Data','Data-Zodi',...
                'Location','northwest')
            grid on
            title('Band 1, High OI, 2025W42_2A_0367_3','Interpreter','none')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.05 0.8])
            xlim([0.73 1.13])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_removedZodi.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_removedZodi.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            fig = figure (202);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_noOI, 'k-','LineWidth',2);
            hold on
            plot(lam,...
                spec_noOI-(...
                noOI_ZodiAmp*spec_noOI_zodi), 'r--','LineWidth',2);
            legend('Data','Data-Zodi',...
                'Location','northwest')
            grid on
            title('Band 1, No OI, 2025W37_2A_0483_1','Interpreter','none')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.05 0.8])
            xlim([0.73 1.13])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_removedZodi.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_removedZodi.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            %{
            %%%%% make the exposure plots
            figure (21)
            clf
            set(gcf, 'position', [100,100,500,400])
            imagesc(log10(abs(FITS_noOIRaw)), [-1 0]);
            colormap hot
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            axis xy
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            title(sprintf('Band %d, no OI Raw Exposure',array_num))
            cb = colorbar;
            cb.Label.String = 'log(MJy/sr)';
            exportgraphics(gcf,...
                sprintf('RawExp_noOI_band%d.png', array_num),...
                'Resolution',300);
            exportgraphics(gcf,...
                sprintf('RawExp_noOI_band%d.pdf', array_num),...
                'ContentType', 'vector');

            figure (22)
            clf
            set(gcf, 'position', [100,100,500,400])
            imagesc(log10(abs(FITS_highOIRaw)), [-1 0]);
            colormap hot
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            axis xy
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            title(sprintf('Band %d, high OI Raw Exposure',array_num))
            cb = colorbar;
            cb.Label.String = 'log(MJy/sr)';
            exportgraphics(gcf,...
                sprintf('RawExp_highOI_band%d.png', array_num),...
                'Resolution',300);
            exportgraphics(gcf,...
                sprintf('RawExp_highOI_band%d.pdf', array_num),...
                'ContentType', 'vector');

            figure (31)
            clf
            set(gcf, 'position', [100,100,500,400])
            imagesc(log10(abs(FITS_noOI)), [-1 0]);
            colormap hot
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            axis xy
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            title(sprintf('Band %d, no OI Raw Exposure',array_num))
            cb = colorbar;
            cb.Label.String = 'log(MJy/sr)';
            exportgraphics(gcf,...
                sprintf('RawMaskedExp_noOI_band%d.png', array_num),...
                'Resolution',300);
            exportgraphics(gcf,...
                sprintf('RawMaskedExp_noOI_band%d.pdf', array_num),...
                'ContentType', 'vector');

            figure (32)
            clf
            set(gcf, 'position', [100,100,500,400])
            imagesc(log10(abs(FITS_highOI)), [-1 0]);
            colormap hot
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            axis xy
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            title(sprintf('Band %d, high OI Raw Exposure',array_num))
            cb = colorbar;
            cb.Label.String = 'log(MJy/sr)';
            exportgraphics(gcf,...
                sprintf('RawMaskedExp_highOI_band%d.png', array_num),...
                'Resolution',300);
            exportgraphics(gcf,...
                sprintf('RawMaskedExp_highOI_band%d.pdf', array_num),...
                'ContentType', 'vector');

            figure (41)
            clf
            set(gcf, 'position', [100,100,500,400])
            imagesc(log10(abs(FITS_noOI-noOI_ZodiAmp*FITS_noOI_zodi)),...
                [-2 0]);
            colormap hot
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            axis xy
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            title(sprintf('Band %d, no OI Raw Exposure',array_num))
            cb = colorbar;
            cb.Label.String = 'log(MJy/sr)';
            exportgraphics(gcf,...
                sprintf('ZodiSubExp_noOI_band%d.png', array_num),...
                'Resolution',300);
            exportgraphics(gcf,...
                sprintf('ZodiSubExp_noOI_band%d.pdf', array_num),...
                'ContentType', 'vector');

            figure (42)
            clf
            set(gcf, 'position', [100,100,500,400])
            imagesc(log10(abs(FITS_highOI-highOI_ZodiAmp*FITS_highOI_zodi)),...
                [-2 0]);
            colormap hot
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            axis xy
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            title(sprintf('Band %d, high OI Raw Exposure',array_num))
            cb = colorbar;
            cb.Label.String = 'log(MJy/sr)';
            exportgraphics(gcf,...
                sprintf('ZodiSubExp_highOI_band%d.png', array_num),...
                'Resolution',300);
            exportgraphics(gcf,...
                sprintf('ZodiSubExp_highOI_band%d.pdf', array_num),...
                'ContentType', 'vector');
            %}
            

            %%%%%% now step 2, fitting Helium
            fig = figure (301);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_highOI-(...
                highOI_ZodiAmp*spec_highOI_zodi),...
                'k-','LineWidth',2);
            hold on
            plot(lam,...
                highOI_HeAmp*template_1083, 'r--','LineWidth',2);
            plot(lam, highOI_Res,...
                'b-.','LineWidth',2);
            legend('Data - Zodi',...
                sprintf('1.083\\mum Helium = %0.3fMJy/sr', highOI_HeAmp),...
                'Residual',...
                'Location','northwest')
            grid on
            title('Band 1, High OI, 1.083\mum fit')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.05 0.7])
            xlim([1.05 1.12])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_1083fit.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_1083fit.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            fig = figure (302);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_noOI-(...
                noOI_ZodiAmp*spec_noOI_zodi),...
                'k-','LineWidth',2);
            hold on
            plot(lam,...
                noOI_HeAmp*template_1083, 'r--','LineWidth',2);
            plot(lam, noOI_Res,...
                'b-.','LineWidth',2);
            legend('Data - Zodi',...
                sprintf('1.083\\mum Helium = %0.3fMJy/sr', noOI_HeAmp),...
                'Residual',...
                'Location','northwest')
            grid on
            title('Band 1, No OI, 1.083\mum fit')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.05 0.7])
            xlim([1.05 1.12])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_1083fit.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_1083fit.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            
            fig = figure (401);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_highOI-(...
                highOI_ZodiAmp*spec_highOI_zodi+...
                highOI_HeAmp*template_1083),...
                'k-','LineWidth',2);
            hold on
            plot(lam,...
                highOI_OIAmp*template_0844, 'r--','LineWidth',1.2);
            plot(lam, highOI_Res,...
                'b-.','LineWidth',1.2);
            legend('Data - Zodi - 1.083\mum',...
                sprintf('0.844\\mum Oxygen = %0.3fMJy/sr', highOI_OIAmp),...
                'Residual',...
                'Location','northwest')
            grid on
            title('Band 1, High OI, 0.844\mum fit')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.02 0.05])
            xlim([0.8 0.9])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_0844fit.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_0844fit.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            fig = figure (402);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_noOI-(...
                noOI_ZodiAmp*spec_noOI_zodi+...
                noOI_HeAmp*template_1083),...
                'k-','LineWidth',2);
            hold on
            plot(lam,...
                noOI_OIAmp*template_0844, 'r--','LineWidth',1.2);
            plot(lam, noOI_Res,...
                'b-.','LineWidth',1.2);
            legend('Data - Zodi - 1.083\mum',...
                sprintf('0.844\\mum Oxygen = %0.3fMJy/sr', noOI_OIAmp),...
                'Residual',...
                'Location','northwest')
            grid on
            title('Band 1, No OI, 0.844\mum fit')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.02 0.05])
            xlim([0.8 0.9])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_0844fit.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_0844fit.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            fig = figure (501);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_highOI-(...
                highOI_ZodiAmp*spec_highOI_zodi+...
                highOI_HeAmp*template_1083+...
                highOI_OIAmp*template_0844),...
                'k-','LineWidth',2);
            hold on
            plot(lam,...
                highOI_OI2Amp*template_1129, 'r--','LineWidth',1.2);
            plot(lam, highOI_Res,...
                'b-.','LineWidth',1.2);
            legend('Data - Zodi - 1.083\mum - 0.844\mum',...
                sprintf('1.129\\mum Oxygen = %0.3fMJy/sr', highOI_OI2Amp),...
                'Residual',...
                'Location','northwest')
            grid on
            title('Band 1, High OI, 1.129\mum fit')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.02 0.06])
            xlim([1.1 1.125])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_1129fit.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_1129fit.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            fig = figure (502);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_noOI-(...
                noOI_ZodiAmp*spec_noOI_zodi+...
                noOI_HeAmp*template_1083+...
                noOI_OIAmp*template_0844),...
                'k-','LineWidth',2);
            hold on
            plot(lam,...
                noOI_OI2Amp*template_1129, 'r--','LineWidth',1.2);
            plot(lam, noOI_Res,...
                'b-.','LineWidth',1.2);
            legend('Data - Zodi - 1.083\mum - 0.844\mum',...
                sprintf('1.129\\mum Oxygen = %0.3fMJy/sr', noOI_OI2Amp),...
                'Residual',...
                'Location','northwest')
            grid on
            title('Band 1, No OI, 1.129\mum fit')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.02 0.06])
            xlim([1.1 1.125])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_1129fit.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_1129fit.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % make 4 panel plot, 1) overall fit 2) 0845, 3) 1083 4) 1129
            fig = figure (130);
            clf
            set(gcf, 'position', [100,500,1400,400])
            t = tiledlayout(1,4,...
                'TileSpacing','tight', ...
                'Padding','tight');
            
            h(1) = nexttile(t);
            plot(lam, spec_highOI, 'k-','LineWidth',2);
            hold on
            plot(lam, highOI_Res, 'k--','LineWidth',1.5);
            plot(lam, highOI_HeAmp*template_1083, 'g-','LineWidth',1.5);
            plot(lam, highOI_OIAmp*template_0844, 'b-','LineWidth',1.5);
            plot(lam, highOI_OI2Amp*template_1129, 'r-','LineWidth',1.5);
            plot(lam, highOI_ZodiAmp*spec_highOI_zodi,'m-','LineWidth',1.5);
            legend('Data','Residual',...
                '1.083\mum Helium',...
                '0.844\mum Oxygen',...
                '1.129\mum Oxygen',...
                'Zodiacal Light Template',...
                'Location','northwest')
            grid on
            %title('Band 1, High OI, 2025W42_2A_0367_3','Interpreter','none')
            %xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.05 0.8])
            xlim([0.73 1.13])
            set(gca, 'LineWidth', 2);    % thick border
            box on;

            h(2) = nexttile(t);
            plot(lam, spec_highOI-(highOI_HeAmp*template_1083 +...
                highOI_OI2Amp*template_1129 +...
                highOI_ZodiAmp*spec_highOI_zodi), 'k-','LineWidth',2);
            hold on
            plot(lam, highOI_OIAmp*template_0844, 'b-','LineWidth',1.5);
            plot(lam, highOI_Res, 'k--','LineWidth',1.5);
            legend('0.844\mum Oxygen Data',...
                'Template', 'Residual',...
                'Location','northwest')
            grid on
            %title('Band 1, High OI, 2025W42_2A_0367_3','Interpreter','none')
            %xlabel('wavelength \lambda (\mum)')
            %set(gca, 'YTick', []);
            ylim([-0.01 0.04])
            xlim([0.8 0.9])
            set(gca, 'LineWidth', 2);    % thick border
            box on;

            h(3) = nexttile(t);
            plot(lam, spec_highOI-(highOI_OIAmp*template_0844 +...
                highOI_OI2Amp*template_1129 +...
                highOI_ZodiAmp*spec_highOI_zodi), 'k-','LineWidth',2);
            hold on
            plot(lam, highOI_HeAmp*template_1083, 'g-','LineWidth',1.5);
            plot(lam, highOI_Res, 'k--','LineWidth',1.5);
            legend('1.083\mum Helium Data',...
                'Template', 'Residual',...
                'Location','northwest')
            grid on
            %title('Band 1, High OI, 2025W42_2A_0367_3','Interpreter','none')
            %xlabel('wavelength \lambda (\mum)')
            %set(gca, 'YTick', []);
            ylim([-0.05 0.7])
            xlim([1.05 1.12])
            set(gca, 'LineWidth', 2);    % thick border
            box on;

            h(4) = nexttile(t);
            plot(lam, spec_highOI-(highOI_OIAmp*template_0844 +...
                highOI_HeAmp*template_1083 + ...
                highOI_ZodiAmp*spec_highOI_zodi), 'k-','LineWidth',2);
            hold on
            plot(lam, highOI_OI2Amp*template_1129, 'r-','LineWidth',1.5);
            plot(lam, highOI_Res, 'k--','LineWidth',1.5);
            legend('1.129\mum Oxygen Data',...
                'Template', 'Residual',...
                'Location','northwest')
            grid on
            %title('Band 1, High OI, 2025W42_2A_0367_3','Interpreter','none')
            %xlabel('wavelength \lambda (\mum)')
            %set(gca, 'YTick', []);
            ylim([-0.01 0.06])
            xlim([1.1 1.125])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            xlabel(t, 'wavelength (\mum)','FontSize',18); 
            exportgraphics(gcf,...
                'img/paper/band1_fit_comp.pdf',...
                'ContentType', 'vector');




        elseif array_num == 2

            % doing the fit
            [highOI_HeAmp, highOI_OIAmp, highOI_ZodiAmp] =...
                aux_fit_templates_band2(spec_highOI, template_1083,...
                template_1129, spec_highOI_zodi);        
            [noOI_HeAmp, noOI_OIAmp, noOI_ZodiAmp] =...
                aux_fit_templates_band2(spec_noOI, template_1083,...
                template_1129, spec_noOI_zodi);
            
            % What are the residual
            highOI_Res = spec_highOI-(...
                highOI_HeAmp*template_1083+...
                highOI_OIAmp*template_1129+...
                highOI_ZodiAmp*spec_highOI_zodi);

            noOI_Res = spec_noOI-(...
                noOI_HeAmp*template_1083+...
                noOI_OIAmp*template_1129+...
                noOI_ZodiAmp*spec_noOI_zodi);


            % what does it looks like
            fig = figure (101);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_highOI, 'k-','LineWidth',2);
            hold on
            plot(lam,...
                spec_highOI-(...
                highOI_HeAmp*template_1083+...
                highOI_OIAmp*template_1129+...
                highOI_ZodiAmp*spec_highOI_zodi), 'r--','LineWidth',2);
            plot(lam, highOI_HeAmp*template_1083, 'g-','LineWidth',1.2);
            plot(lam, highOI_OIAmp*template_1129, 'b-','LineWidth',1.2);
            plot(lam, highOI_ZodiAmp*spec_highOI_zodi,'m-','LineWidth',1.2);
            legend('Data','Residual of Fit',...
                sprintf('1.083\\mum Helium = %0.3f', highOI_HeAmp),...
                sprintf('1.129\\mum Oxygen = %0.3f', highOI_OIAmp),...
                sprintf('Zodi Fit = %0.3f', highOI_ZodiAmp),...
                'Location','northeast')
            grid on
            title('Band 2, High OI, 2025W42_2A_0367_3','Interpreter','none')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.05 0.8])
            xlim([1.08 1.65])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_fit.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_fit.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            fig = figure (102);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_noOI, 'k-','LineWidth',2);
            hold on
            plot(lam,...
                spec_noOI-(...
                noOI_HeAmp*template_1083+...
                noOI_OIAmp*template_1129+...
                noOI_ZodiAmp*spec_noOI_zodi), 'r--','LineWidth',2);
            plot(lam, noOI_HeAmp*template_1083, 'g-','LineWidth',1.2);
            plot(lam, noOI_OIAmp*template_1129, 'b-','LineWidth',1.2);
            plot(lam, noOI_ZodiAmp*spec_noOI_zodi,'m-','LineWidth',1.2);
            legend('Data','Residual of Fit',...
                sprintf('1.083\\mum Helium = %0.3f', noOI_HeAmp),...
                sprintf('1.129\\mum Oxygen = %0.3f', noOI_OIAmp),...
                sprintf('Zodi Fit = %0.3f', noOI_ZodiAmp),...
                'Location','northeast')
            grid on
            title('Band 2, No OI, 2025W37_2A_0483_1','Interpreter','none')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.05 0.8])
            xlim([1.08 1.65])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_fit.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_fit.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            %%%%%%% step by step removal, removing zodi %%%%%%
            % what does it looks like
            fig = figure (201);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_highOI, 'k-','LineWidth',2);
            hold on
            plot(lam,...
                spec_highOI-(...
                highOI_ZodiAmp*spec_highOI_zodi), 'r--','LineWidth',2);
            legend('Data','Data-Zodi',...
                'Location','northeast')
            grid on
            title('Band 2, High OI, 2025W42_2A_0367_3','Interpreter','none')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.05 0.8])
            xlim([1.08 1.65])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_removedZodi.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_removedZodi.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            fig = figure (202);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_noOI, 'k-','LineWidth',2);
            hold on
            plot(lam,...
                spec_noOI-(...
                noOI_ZodiAmp*spec_noOI_zodi), 'r--','LineWidth',2);
            legend('Data','Data-Zodi',...
                'Location','northeast')
            grid on
            title('Band 2, No OI, 2025W37_2A_0483_1','Interpreter','none')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.05 0.8])
            xlim([1.08 1.65])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_removedZodi.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_removedZodi.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            %%%%%% now step 2, fitting Helium
            fig = figure (301);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_highOI-(...
                highOI_ZodiAmp*spec_highOI_zodi),...
                'k-','LineWidth',2);
            hold on
            plot(lam,...
                highOI_HeAmp*template_1083, 'r--','LineWidth',2);
            plot(lam, highOI_Res,...
                'b-.','LineWidth',2);
            legend('Data - Zodi',...
                sprintf('1.083\\mum Helium = %0.3fMJy/sr', highOI_HeAmp),...
                'Residual',...
                'Location','northwest')
            grid on
            title('Band 2, High OI, 1.083\mum fit')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.05 0.75])
            xlim([1.06 1.15])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_1083fit.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_1083fit.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            fig = figure (302);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_noOI-(...
                noOI_ZodiAmp*spec_noOI_zodi),...
                'k-','LineWidth',2);
            hold on
            plot(lam,...
                noOI_HeAmp*template_1083, 'r--','LineWidth',2);
            plot(lam, noOI_Res,...
                'b-.','LineWidth',2);
            legend('Data - Zodi',...
                sprintf('1.083\\mum Helium = %0.3fMJy/sr', noOI_HeAmp),...
                'Residual',...
                'Location','northwest')
            grid on
            title('Band 2, No OI, 1.083\mum fit')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.05 0.75])
            xlim([1.06 1.15])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_1083fit.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_1083fit.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            
            fig = figure (401);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_highOI-(...
                highOI_ZodiAmp*spec_highOI_zodi+...
                highOI_HeAmp*template_1083),...
                'k-','LineWidth',2);
            hold on
            plot(lam,...
                highOI_OIAmp*template_1129, 'r--','LineWidth',1.2);
            plot(lam, highOI_Res,...
                'b-.','LineWidth',1.2);
            legend('Data - Zodi - 1.083\mum',...
                sprintf('1.129\\mum Oxygen = %0.3fMJy/sr', highOI_OIAmp),...
                'Residual',...
                'Location','northwest')
            grid on
            title('Band 2, High OI, 1.129\mum fit')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.01 0.05])
            xlim([1.08 1.16])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_1129fit.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_highOI_band%d_1129fit.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

            fig = figure (402);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_noOI-(...
                noOI_ZodiAmp*spec_noOI_zodi+...
                noOI_HeAmp*template_1083),...
                'k-','LineWidth',2);
            hold on
            plot(lam,...
                noOI_OIAmp*template_1129, 'r--','LineWidth',1.2);
            plot(lam, noOI_Res,...
                'b-.','LineWidth',1.2);
            legend('Data - Zodi - 1.083\mum',...
                sprintf('1.129\\mum Oxygen = %0.3fMJy/sr', noOI_OIAmp),...
                'Residual',...
                'Location','northwest')
            grid on
            title('Band 2, No OI, 1.129\mum fit')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.01 0.05])
            xlim([1.08 1.16])
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_1129fit.png',...
                array_num, array_num),'Resolution',300);
            exportgraphics(gcf,...
                sprintf('img/band%d/ex_noOI_band%d_1129fit.pdf',...
                array_num, array_num),...
                'ContentType', 'vector');

        elseif array_num == 3
    
            [highOI_ZodiAmp] =...
                aux_fit_templates(spec_highOI, spec_highOI_zodi);
        
            [noOI_ZodiAmp] =...
                aux_fit_templates(spec_noOI, spec_noOI_zodi);
        
            
            fig = figure (100);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_highOI, 'k-','LineWidth',2);
            hold on
            plot(lam,...
                spec_highOI-(...
                highOI_ZodiAmp*spec_highOI_zodi), 'r--','LineWidth',2);
            plot(lam, highOI_ZodiAmp*spec_highOI_zodi,'-','LineWidth',1.2);
            legend('Data','Residual of Fit',...
                sprintf('Zodi Fit = %0.3f', highOI_ZodiAmp),...
                'Location','northwest')
            grid on
            title('Band 3, High OI, 2025W42_2A_0367_3','Interpreter','none')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.05 0.2])
            print(sprintf('ex_highOI_band%d_fit',array_num),'-dpng')
        
            fig = figure (200);
            clf
            set(gcf, 'position', [100,100,500,400])
            plot(lam, spec_noOI, 'k-','LineWidth',2);
            hold on
            plot(lam,...
                spec_noOI-(...
                noOI_ZodiAmp*spec_noOI_zodi), 'r--','LineWidth',2);
            plot(lam, noOI_ZodiAmp*spec_noOI_zodi,'-','LineWidth',1.2);
            legend('Data','Residual of Fit',...
                sprintf('Zodi Fit = %0.3f', noOI_ZodiAmp),...
                'Location','northwest')
            grid on
            title('Band 3, No OI, 2025W37_2A_0483_1','Interpreter','none')
            xlabel('wavelength \lambda (\mum)')
            ylabel('(MJy/sr)')
            ylim([-0.05 0.2])
            print(sprintf('ex_noOI_band%d_fit',array_num),'-dpng')
        end
            

        



        if array_num == 1
            fig = figure (90);
            clf
            set(gcf, 'position', [100,100,1400,450])
            t = tiledlayout(1,4,...
                'TileSpacing','none', ...
                'Padding','tight');
            
            h(1) = nexttile(t);
            imagesc(log10(abs(FITS_highOIRaw)), [-2 0]); axis square
            colormap hot
            ylabel('\leftarrow Increase \lambda, Spectral Direction')
            %yticks([500 1000 1500 2000])
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            axis xy
            title('Calibrated Exposure', 'FontWeight', 'Normal');

            h(2) = nexttile(t);
            imagesc(log10(abs(FITS_highOI)), [-2 0]); axis square
            colormap hot
            %ylabel('\leftarrow Increase Wavelength, \lambda = 0.74 - 1.12\mum')
            %yticks([500 1000 1500 2000])
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            axis xy
            title('Masked Exposure', 'FontWeight', 'Normal');
            %xlabel('\leftarrow---- 3.5^\circ ----\rightarrow')
            xlabel('\leftarrow Imaging Direction, 3.5^\circ \rightarrow')

            h(3) = nexttile(t);
            imagesc(log10(abs(FITS_highOI-highOI_ZodiAmp*FITS_highOI_zodi)),...
                [-2 0]); axis square
            colormap hot
            %ylabel('\leftarrow Increase Wavelength, \lambda = 0.74 - 1.12\mum')
            %yticks([500 1000 1500 2000])
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            axis xy
            title('Background Removal', 'FontWeight', 'Normal');
            %cb = colorbar;
            %cb.Label.String = 'log(MJy/sr)';
            %cb.Label.FontSize = 18;

            h(4) = nexttile(t);
            plot(spec_highOI,lam,'k-','LineWidth',2);
            hold on
            plot(spec_highOI-(...
                highOI_ZodiAmp*spec_highOI_zodi),lam, 'r-','LineWidth',2);
            legend('Masked Exposure','Background Removed',...
                'Location','northeast')
            grid on
            axis square
            title('1D Spectrum','Interpreter','none')
            ylabel('wavelength (\mum)', 'Rotation',270)
            xlabel('(MJy/sr)')
            xlim([-0.05 0.8])
            ylim([0.72 1.13])
            set(gca,'YAxisLocation','right')
            set(gca, 'LineWidth', 2);    % thick border
            box on;
            set(gca,'YDir','reverse')
            exportgraphics(gcf,...
                'img/paper/masked_example.pdf',...
                'ContentType', 'vector');

        end
    end
end
