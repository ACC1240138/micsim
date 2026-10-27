# CASEN inputs for ENPG composition and health-contact exploration

These encrypted bundles preserve the source files used by
`__andres_control/enpg_casen_aps.ipynb`. Read them only through
`_tools/acc_data.R::acc_data()`. Each bundle has a plain MD5 sidecar.
Original local files were preserved; each new bundle was restored and its MD5
compared with its source before analysis.

Education uses CASEN 2013, 2015, 2017, 2020, 2022 and 2024. The 2013/2015
`expr_c2017_nm` files replace the old expansion factors through a checked
one-to-one join on `folio + o`. The education rule is reused from
`__andres_control/casen_educ3_insumo.R`; its old local-path configuration is
not executed. The source bundles came from the user's existing CASEN folder.
Their original download dates/versions were not independently established;
sidecar hashes identify the exact files used.

Health exploration processes all six rounds, 2013–2024. Official geography
files were downloaded on 2026-10-26; [geography_sources.csv](geography_sources.csv)
records the 2013–2022 URLs, hashes and row counts. The 2024 source is linked below.
Joins use `folio + o` through 2017 and `folio + id_persona` from 2020 onward,
with duplicate and unmatched-row checks. Region rates use the revised 2013/2015
`expr` weights and later `expr`; commune estimates use official `expc`.
Old Ñuble codes are harmonized to the INE commune grid through official labels.
PSU `varunit` and stratum `varstrat` stay unchanged; no geography-derived design
variables are invented.

2020 lacks the comparable general-care/provider items. Its separate illness/
accident consultation indicator includes every sector. Only 2013/2015/2017 can
identify consultorio/posta for general care or control; 2022/2024 distinguish
public/private sectors, not APS. Reference periods are preserved in outcome names.

Sources:

- [CASEN 2024 and documentation](https://observatorio.ministeriodesarrollosocial.gob.cl/encuesta-casen-2024)
- [Official geography file](https://bid-ckan.ministeriodesarrollosocial.gob.cl/dataset/105286d9-10a8-410a-b060-a335f3168a46/resource/8a8136a7-a842-47fc-8c2f-50806131645a/download/casen_2024_provincia_comuna.dta)
- [2024 linkage and data-use note](https://observatorio.ministeriodesarrollosocial.gob.cl/storage/docs/casen/2024/Nota_uso_bases_de_datos_Casen_2024.pdf)
- [2024 sampling design and commune expansion factor](https://observatorio.ministeriodesarrollosocial.gob.cl/storage/docs/casen/2024/Diseno_Muestral_Casen_2024.pdf)
- [2017 investigator manual: health reference periods](https://observatorio.ministeriodesarrollosocial.gob.cl/storage/docs/casen/2017/Manual_del_Investigador_Casen_2017.pdf)

No direct commune estimate is automatically approved for the microsimulator.
The 2024 health questions distinguish public/private care, not APS/hospital.
The 2013/2015/2017 APS indicators concern the last recorded establishment for general
consultation and health controls, not all possible contacts with APS.

The official 2015 geography file has `expc` only for 139 communes (52,770
sample records lack this weight). Other communes receive no direct commune
estimate; they remain represented in the national/regional analysis. For commune
variance estimation the full-sample PSU/stratum structure is retained, and
records without an official commune weight are excluded as a domain before
estimation. A computational placeholder outside that domain never contributes
to any estimate or denominator. Historic commune weights retain their original
census base; they are not relabelled as updated Censo-2017 regional weights.
See the [official 2015 sampling report](https://observatorio.ministeriodesarrollosocial.gob.cl/storage/docs/casen/2015/Metodologia_de_Diseno_Muestral_Casen_2015.pdf).
