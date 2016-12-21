
"""
log(p(x1|x2)) Straight out of Wikipedia
"""
function logpdf_conditional(x1, x2, Sigma11, Sigma22, Sigma12)
    Sigma21 = transpose(Sigma12)
    mu_cond = Sigma12 * (Sigma22 \ x2)
    Sigma_cond = Sigma11 - Sigma12 * (Sigma22 \ Sigma21)
    return logpdf_normal(x1, Sigma_cond, mu_cond)
end


