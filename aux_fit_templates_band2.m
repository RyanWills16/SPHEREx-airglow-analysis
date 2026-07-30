function [A1, A2, A3] = aux_fit_templates_band2(dat, temp1, temp2, temp3)

    % Force column vectors
    dat   = dat(:);
    temp1 = temp1(:);
    temp2 = temp2(:);
    temp3 = temp3(:);

    % Valid samples: no NaNs in data or templates
    good = ~isnan(dat) & ~isnan(temp1) & ~isnan(temp2) &...
        ~isnan(temp3);

    % Apply mask
    dat_g   = dat(good);
    t1_g    = temp1(good);
    t2_g    = temp2(good);
    t3_g    = temp3(good);

    % Design matrix
    M = [t1_g, t2_g, t3_g];

    % Linear least squares
    A = M \ dat_g;

    % Outputs
    A1 = A(1);
    A2 = A(2);
    A3 = A(3);
end
