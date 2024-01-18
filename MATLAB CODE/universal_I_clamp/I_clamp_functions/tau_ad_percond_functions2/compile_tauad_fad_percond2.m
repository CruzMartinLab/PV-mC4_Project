function[] = compile_tauad_fad_percond(final_basefilename_tauad_fad, genotype_folder, tauad_fad_finalresults)

final_basefilename_tauad_fad = char(final_basefilename_tauad_fad);
final_savefilename_tauad_fad = strcat(genotype_folder, '\', final_basefilename_tauad_fad);
xlswrite(final_savefilename_tauad_fad, tauad_fad_finalresults);

end
    