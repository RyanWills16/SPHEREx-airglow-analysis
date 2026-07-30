function [A1, A2, A3, A4] = aux_fit_templates(dat, temp1, temp2, temp3, temp4)

    % Force column vectors
    dat   = dat(:);
    temp1 = temp1(:);
    temp2 = temp2(:);
    temp3 = temp3(:);
    temp4 = temp4(:);

    % Valid samples: no NaNs in data or templates
    good = ~isnan(dat) & ~isnan(temp1) & ~isnan(temp2) &...
        ~isnan(temp3) & ~isnan(temp4);

    % Apply mask
    dat_g   = dat(good);
    t1_g    = temp1(good);
    t2_g    = temp2(good);
    t3_g    = temp3(good);
    t4_g    = temp4(good);

    % Design matrix
    M = [t1_g, t2_g, t3_g, t4_g];

    % Linear least squares
    A = M \ dat_g;

    % Outputs
    A1 = A(1);
    A2 = A(2);
    A3 = A(3);
    A4 = A(4);
end
