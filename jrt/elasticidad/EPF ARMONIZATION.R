library(readr)
library(tidyverse)
library(haven)
library(rio)
pacman::p_load(readr, tidyverse, haven, rio)
rm(list = ls());gc()

# EPF 2022
cantidades_2022 <- import("quantities_2022.rds") %>% 
  dplyr::select(-ccif, -d,-g,-c,-sc,-p,-glosa_establecimiento, -cod_establecimiento,
         -cantidad_inicial, -unidad_medida_inicial, - macrozona, - folio) %>% 
  rename(glosa = glosa_ccif) %>% 
  mutate(glosa = case_when(glosa %in% c("CERVEZAS CON ALCOHOL",
                                        "CERVEZAS CON BAJO CONTENIDO DE ALCOHOL O SIN ALCOHOL" ,
                                        "OTRAS BEBIDAS ALCOHÓLICAS CON ALCOHOL, CON BAJO CONTENIDO DE ALCOHOL O SIN ALCOHOL N.C.P."
  ) ~ "Beer",
  glosa %in% c("PISCO","WHISKY" ,"RON", "CÓCTELES Y CREMAS DE LICOR CON ALCOHOL",
               "VODKA" ,  "OTROS DESTILADOS Y LICORES N.C.P.","CÓCTELES Y CREMAS DE LICOR",
               "OTROS DESTILADOS Y LICORES N.C.P.",  
               "CÓCTELES Y CREMAS DE LICOR CON BAJO CONTENIDO DE ALCOHOL O SIN ALCOHOL"                   
  ) ~ "Spirits",
  glosa %in% c("VINO DE UVAS",                                                                             
               "VINO ESPUMOSO DE UVAS" ,                                                                   
               "VINO DE UVAS Y VINO ESPUMOSO DE UVAS CON BAJO CONTENIDO DE ALCOHOL O SIN ALCOHOL",         
               "OTROS VINOS DE UVAS N.C.P." ,                                                              
               "VINO DE OTRAS FRUTAS O CEREALES CON BAJO CONTENIDO DE ALCOHOL O SIN ALCOHOL",              
               "VINO DE OTRAS FRUTAS Y CEREALES") ~ "Wines",
  TRUE ~ NA),
  apv = case_when(glosa == "Beer" ~ 5,
                  glosa == "Wines" ~ 13.5,
                  glosa == "Spirits" ~ 37.5),
  var_unit = paste0(var_unit, "_22"),
  folio_v = as.character(folio_v))

# 1) Variables a nivel hogar (incluye var_unit y unidad_medida porque “deberían estar” para todos)
hogares <- cantidades_2022 %>%
  group_by(folio_v) %>%
  summarise(
    estrato_muestreo = first(estrato_muestreo), # toma el valor del hogar
    fe               = first(fe),
    var_unit          = first(var_unit),
    unidad_medida     = first(unidad_medida),
    .groups = "drop",
    gasto_tot = sum(gasto)
  )

# 2) Suma compras por hogar y tipo (solo alcohol clasificado)
alcohol_sum <- cantidades_2022 %>%
  filter(glosa %in% c("Beer", "Wines", "Spirits")) %>%
  group_by(folio_v, glosa) %>%
  summarise(
    cantidad_oh = sum(cantidad, na.rm = TRUE),
    gasto_oh    = sum(gasto,    na.rm = TRUE),
    .groups = "drop"
  )

# 3) Panel 3x hogar + ceros donde no hay compra
cantidades_2022 <- hogares %>%
  crossing(glosa = c("Beer", "Wines", "Spirits")) %>%
  left_join(alcohol_sum, by = c("folio_v", "glosa")) %>%
  mutate(
    cantidad_oh = replace_na(cantidad_oh, 0),
    gasto_oh    = replace_na(gasto_oh, 0),
    apv = case_when(
      glosa == "Beer"    ~ 5,
      glosa == "Wines"   ~ 13.5,
      glosa == "Spirits" ~ 37.5
    ),
    unidad_medida = "ML"
  )

# 3 rows per hh
cantidades_2022 %>% count(folio_v) %>% summarise(max_n = max(n))

write_rds(cantidades_2022, "quant.rds", compress = "gz") # compress data

personas_22 <- rio::import("people_2022.rds") %>% 
  dplyr::select(folio_v, fe, estrato_muestreo,var_unit,edad, ecivil, sexo, npersonas, 
         parentesco, sprincipal, edunivel, n_linea, 
         ing_disp_hog_hd_pc,gastot_hd_pc, edutermina
         ) %>% 
  group_by(folio_v) %>% 
  mutate(educ_hhh = edunivel[sprincipal == 1][1],
         educ_t_hhh = edutermina[sprincipal == 1][1],
         n_15 = sum(edad>15),
         prop_15yo = n_15/npersonas,
         age_hhh = sum(edad[sprincipal == 1][1]),
         prop_wm = sum(sexo==2)/npersonas,
         sex_hhh = sum(sexo[sprincipal == 1][1])) %>%
  ungroup() %>% 
  mutate(id_ind= paste(folio_v, n_linea, sep = "_"),
         var_unit = paste0(var_unit, "_22"),
         educ_hhh = case_when(between(educ_hhh,1,6) ~ 1,
                              educ_hhh == 7 & educ_t_hhh == 2 ~ 1,
                              educ_hhh == 8 & educ_t_hhh == 2 ~ 1,
                              educ_hhh == 7 & educ_t_hhh == 1 ~ 2,
                              educ_hhh == 8 & educ_t_hhh == 1 ~ 2,
                              educ_hhh == 9 & educ_t_hhh == 2 ~ 3,
                              educ_hhh == 10 & educ_t_hhh == 2 ~ 3,
                              educ_hhh == 11 & educ_t_hhh == 2 ~ 3,
                              educ_hhh == 12 & educ_t_hhh == 2 ~ 3,
                              educ_hhh == 9 & educ_t_hhh == 1 ~ 4,
                              educ_hhh == 10 & educ_t_hhh == 1 ~ 4,
                              educ_hhh == 11 & educ_t_hhh == 1 ~ 4,
                              educ_hhh == 12 & educ_t_hhh == 1 ~ 4,
                              TRUE ~ 5)) %>% 
  dplyr::select(-edutermina)

personas_22 <- personas_22 %>%
  group_by(folio_v) %>%
  summarise(
    # Identificadores / diseño muestral (deberían ser constantes dentro de hogar)
    fe               = first(fe),
    estrato_muestreo = first(estrato_muestreo),
    var_unit         = first(var_unit),
    
    # Tamaño hogar
    npersonas = max(npersonas, na.rm = TRUE),
    
    # Variables de ingreso/gasto 
    ing_disp_hog_hd_pc = first(ing_disp_hog_hd_pc),
    gastot_hd_pc       = first(gastot_hd_pc),
    
    educ_hhh    = first(educ_hhh),
    educ_t_hhh  = first(educ_t_hhh),
    prop_15yo   = first(prop_15yo),
    prop_wm     = first(prop_wm),
    age_hhh     = first(age_hhh),
    sex_hhh     = first(sex_hhh),
    .groups = "drop"
  )


personas_22 %>% count(folio_v) %>% summarise(max_n = max(n))

# QUINTILIZATION
# Paso 1: Crear variable de orden y marcador de ingresos faltantes
quin_base <- personas_22 %>%
  mutate(
    id_missing = if_else(ing_disp_hog_hd_pc <= 0, 1, 0),
    vector_orden = case_when(
      id_missing == 1 ~ gastot_hd_pc,
      TRUE ~ ing_disp_hog_hd_pc
    )
  ) 
quin_base %>% count(folio_v) %>% summarise(max_n = max(n))

# Paso 2: Ordenar según vector de orden y crear acumulados
quin_hog <- quin_base %>%
  arrange(vector_orden, ing_disp_hog_hd_pc, gastot_hd_pc, folio_v) %>%
  mutate(
    fe_acum = cumsum(fe),
    part_acum = fe_acum / max(fe_acum)
  )

# Paso 3: Identificar hogares que marcan corte de quintil y calcular distancias
quin_hog <- quin_hog %>%
  mutate(
    etiqueta_hogar = case_when(
      part_acum >= 0.2 & lag(part_acum, default = 0) < 0.2 ~ 1,
      part_acum >= 0.4 & lag(part_acum, default = 0) < 0.4 ~ 1,
      part_acum >= 0.6 & lag(part_acum, default = 0) < 0.6 ~ 1,
      part_acum >= 0.8 & lag(part_acum, default = 0) < 0.8 ~ 1,
      TRUE ~ 0
    ),
    distancia = case_when(
      part_acum >= 0.2 & lag(part_acum, default = 0) < 0.2 ~ fe_acum - (0.2 * max(fe_acum)),
      part_acum >= 0.4 & lag(part_acum, default = 0) < 0.4 ~ fe_acum - (0.4 * max(fe_acum)),
      part_acum >= 0.6 & lag(part_acum, default = 0) < 0.6 ~ fe_acum - (0.6 * max(fe_acum)),
      part_acum >= 0.8 & lag(part_acum, default = 0) < 0.8 ~ fe_acum - (0.8 * max(fe_acum)),
      TRUE ~ NA_real_
    )
  ) %>%
  mutate(
    distancia_2 = fe - distancia,
    id = row_number()
  )
quin_hog %>% count(folio_v) %>% summarise(max_n = max(n))

# Paso 4: Duplicar observaciones divisorias
hogares_limite <- quin_hog %>%
  filter(etiqueta_hogar == 1) %>%
  pull(id)

quin_hog <- quin_hog %>%
  bind_rows(quin_hog %>% filter(id %in% hogares_limite)) %>%
  arrange(id)

# Paso 5: Reasignar factor de expansión para hogares divisores
quin_hog <- quin_hog %>%
  group_by(id) %>%
  mutate(fe_quintil = case_when(
    row_number() == 1 & !is.na(distancia_2) ~ distancia_2,
    row_number() == 2 ~ distancia,
    TRUE ~ fe
  )) %>%
  ungroup()

# Paso 6: Calcular suma acumulada y porcentaje acumulado nuevo
quin_hog <- quin_hog %>%
  mutate(
    suma = cumsum(fe_quintil),
    pct_acum = suma / max(suma)
  )

# Paso 7: Asignar quintiles
quin_hog <- quin_hog %>%
  mutate(
    quintil = case_when(
      pct_acum <= 0.2000000001 ~ 1,
      pct_acum <= 0.4000000001 ~ 2,
      pct_acum <= 0.6000000001 ~ 3,
      pct_acum <= 0.8000000001 ~ 4,
      pct_acum <= 1.000000001 ~ 5
    )
  )
# Paso 8: Seleccionar variables finales
quin_hog <- quin_hog %>%
  dplyr::select(folio_v, quintil, fe, fe_quintil, vector_orden,
         ing_disp_hog_hd_pc, gastot_hd_pc, id_missing) %>%
  group_by(folio_v) %>%
  mutate(aux = row_number() - 1) %>%
  ungroup()

quin_hog_uniq <- quin_hog %>%
  arrange(folio_v, desc(aux)) %>%  
  distinct(folio_v, .keep_all = TRUE) %>%
  dplyr::select(folio_v, quintil)
personas_22 %>% count(folio_v) %>% summarise(max_n = max(n))

# unir quintiles a personas_22
personas_22 <- personas_22 %>%
  left_join(quin_hog_uniq %>% dplyr::select(folio_v, quintil), by = "folio_v") %>% 
  mutate(folio_v = as.character(folio_v))

write_rds(personas_22, "people_2022_red.rds", compress = "gz")
rm(list = ls());gc()


# JOIN PEOPLE AND QUANTITIES
data_22 <- import("people_2022_red.rds") %>% 
  inner_join(import("quant.rds"), by = c("folio_v", "fe",
                                   "var_unit", 
                                  "estrato_muestreo"), relationship = "many-to-many") %>% 
  mutate(across(where(is.numeric), ~na_if(.x, -99)),
         across(where(is.numeric), ~na_if(.x, -88)),
         across(where(is.numeric), ~na_if(.x, -77)),
         across(where(is.numeric), ~na_if(.x, -66))) %>% 
  dplyr::select(
         -educ_t_hhh)

export(data_22, "epf_2022.rds")

#----------#
# EPF 2017 #
#----------#
rm(list=ls());gc()

personas_17 <- import("people_2017.rds") %>% 
  dplyr::select(folio_v = FOLIO_V, folio = FOLIO, fe = FE, estrato_muestreo = VARSTRAT, 
         var_unit = VARUNIT, edad = EDAD, ecivil = ECIVIL, sexo = SEXO, 
         npersonas = NPERSONAS, parentesco = PARENTESCO, sprincipal = SPRINCIPAL, 
         edunivel = EDUNIVEL, edutermina = EDUTERMINA,ing_disp_hog_hd_pc = ING_DISP_HOG_HD_PC, 
         gastot_hd_pc = GASTOT_HD_PC,
         n_linea = N_LINEA) %>% 
  mutate(folio_v = as.numeric(folio_v)) %>%
  group_by(folio_v) %>%
  mutate(educ_hhh = edunivel[sprincipal == 1][1],
         educ_t_hhh = edutermina[sprincipal == 1][1],
         n_15 = sum(edad > 15),
         prop_15yo = n_15 / npersonas,
         age_hhh = edad[sprincipal == 1][1],
         prop_wm = sum(sexo == 2) / npersonas,
         sex_hhh = sexo[sprincipal == 1][1]) %>%
  ungroup() %>%
  mutate(folio_v = paste0(folio_v, "_17"),
         var_unit = paste0(var_unit, "_17"),
         id_ind= paste(folio_v, n_linea, sep = "_"),
         educ_hhh = case_when(between(educ_hhh,1,6) ~ 1,
                              educ_hhh == 7 & educ_t_hhh == 2 ~ 1,
                              educ_hhh == 8 & educ_t_hhh == 2 ~ 1,
                              educ_hhh == 7 & educ_t_hhh == 1 ~ 2,
                              educ_hhh == 8 & educ_t_hhh == 1 ~ 2,
                              educ_hhh == 9 & educ_t_hhh == 2 ~ 3,
                              educ_hhh == 10 & educ_t_hhh == 2 ~ 3,
                              educ_hhh == 11 & educ_t_hhh == 2 ~ 3,
                              educ_hhh == 12 & educ_t_hhh == 2 ~ 3,
                              educ_hhh == 9 & educ_t_hhh == 1 ~ 4,
                              educ_hhh == 10 & educ_t_hhh == 1 ~ 4,
                              educ_hhh == 11 & educ_t_hhh == 1 ~ 4,
                              educ_hhh == 12 & educ_t_hhh == 1 ~ 4,
                              TRUE ~ 5))
personas_17 <- personas_17 %>%
  group_by(folio_v) %>%
  summarise(
    # Variables del hogar (deben ser constantes dentro del hogar)
    fe               = first(fe),
    estrato_muestreo = first(estrato_muestreo),
    var_unit         = first(var_unit),
    folio            = first(folio),
    
    # Tamaño hogar
    npersonas = max(npersonas, na.rm = TRUE),
    
    # Ingreso/gasto pc (si vienen repetidos por individuo, first)
    ing_disp_hog_hd_pc = first(ing_disp_hog_hd_pc),
    gastot_hd_pc       = first(gastot_hd_pc),
    
    # Resúmenes del hogar 
    educ_hhh   = first(educ_hhh),
    educ_t_hhh = first(educ_t_hhh),
    prop_15yo  = first(prop_15yo),
    prop_wm    = first(prop_wm),
    age_hhh    = first(age_hhh),
    sex_hhh    = first(sex_hhh),

    
    .groups = "drop"
  )

# QUINTILIZATION
# 1. Filtramos hogares (parentesco 1) y creamos la variable de orden
hogares_17 <- personas_17 %>%
  mutate(
    id_missing = if_else(ing_disp_hog_hd_pc <= 0, 1, 0),
    vector_orden = case_when(
      id_missing == 1 ~ gastot_hd_pc,
      TRUE ~ ing_disp_hog_hd_pc
    )
  ) %>%
  arrange(vector_orden, ing_disp_hog_hd_pc, gastot_hd_pc, folio_v) %>%
  mutate(
    fe_acum = cumsum(fe),
    fe_total = sum(fe),
    part_acum = fe_acum / fe_total,
    etiqueta = case_when(
      part_acum >= 0.2 & lag(part_acum, default = 0) < 0.2 ~ "q2",
      part_acum >= 0.4 & lag(part_acum, default = 0) < 0.4 ~ "q3",
      part_acum >= 0.6 & lag(part_acum, default = 0) < 0.6 ~ "q4",
      part_acum >= 0.8 & lag(part_acum, default = 0) < 0.8 ~ "q5",
      TRUE ~ NA_character_
    ),
    corte = case_when(
      etiqueta == "q2" ~ 0.2,
      etiqueta == "q3" ~ 0.4,
      etiqueta == "q4" ~ 0.6,
      etiqueta == "q5" ~ 0.8
    ),
    distancia = fe_acum - (corte * fe_total),
    distancia_2 = fe - distancia,
    id = row_number(),
    fe_q = fe  # peso original
  )

# 2. Creamos duplicados para los hogares que cruzan cortes
duplicados <- hogares_17 %>%
  filter(!is.na(etiqueta)) %>%
  dplyr::select(folio_v, id, distancia, distancia_2, fe, vector_orden, ing_disp_hog_hd_pc, gastot_hd_pc, fe_total)

duplicados_1 <- duplicados %>%
  mutate(fe_q = distancia, tipo = "a")

duplicados_2 <- duplicados %>%
  mutate(fe_q = distancia_2, tipo = "b")

# 3. Reunimos base original con duplicados
hogares_expandido <- hogares_17 %>%
  mutate(tipo = "original") %>%
  bind_rows(duplicados_1, duplicados_2) %>%
  arrange(vector_orden, ing_disp_hog_hd_pc, gastot_hd_pc, folio_v)

# 4. Acumulamos nuevo peso y asignamos quintil
hogares_expandido <- hogares_expandido %>%
  mutate(
    suma = cumsum(fe_q),
    pct_acum = suma / sum(fe_q),
    quintil = case_when(
      pct_acum <= 0.2 ~ 1,
      pct_acum <= 0.4 ~ 2,
      pct_acum <= 0.6 ~ 3,
      pct_acum <= 0.8 ~ 4,
      TRUE ~ 5
    )
  )

# 5. Asignamos quintil final a cada hogar único
quintiles_finales <- hogares_expandido %>%
  filter(tipo == "original") %>%
  dplyr::select(folio_v, quintil)

# 6. Lo unimos a la base original de personas
personas_17 <- personas_17 %>%
  left_join(quintiles_finales, by = "folio_v") %>% 
  dplyr::select(-folio)
  
write_rds(personas_17, "people_2017_red.rds", compress = "gz")

# QUANTITIES DATA BASE 2017
cantidades_17 <- import("quantities_2017.rds") %>% 
  dplyr::select(folio_v, fe ,n_linea,estrato_muestreo = varstrat, var_unit = varunit, glosa, gasto,
         unidad_medida, cantidad) %>% 
  mutate(glosa = case_when(glosa == c("CERVEZA") ~ "Beer",
                           glosa %in% c("PISCO","WHISKY" ,"RON", "CÓCTELES Y CREMAS DE LICOR",
                                        "VODKA" ,  "DESTILADOS Y LICORES (ND)") ~ "Spirits",
                           glosa %in% c("VINO",                                                                             
                                        "CHICHA, SIDRA Y OTROS VINOS N.C.P.",                                                                   
                                        "VINOS ESPUMOSOS") ~ "Wines"),
         apv = case_when(glosa == "Beer" ~ 5,
                         glosa == "Wines" ~ 13.5,
                         glosa == "Spirits" ~ 37.5),
         var_unit = paste0(var_unit, "_17"),
         cantidad = ifelse(unidad_medida == "LT", cantidad*1000, cantidad),
         unidad_medida = ifelse(unidad_medida == "LT", "ML", unidad_medida),
         folio_v = paste0(folio_v, "_17"),
         id_ind= paste(folio_v, n_linea, sep = "_")) %>% 
  dplyr::select(-n_linea)

cantidades_17_limpia <- import("quantities_2017.rds") %>%
  dplyr::select(
    folio_v, fe, n_linea,
    estrato_muestreo = varstrat,
    var_unit = varunit,
    glosa, gasto, unidad_medida, cantidad
  ) %>%
  mutate(
    # Estandariza glosa a 3 categorías
    glosa = case_when(
      glosa == "CERVEZA" ~ "Beer",
      glosa %in% c("PISCO","WHISKY","RON","CÓCTELES Y CREMAS DE LICOR",
                   "VODKA","DESTILADOS Y LICORES (ND)") ~ "Spirits",
      glosa %in% c("VINO","CHICHA, SIDRA Y OTROS VINOS N.C.P.","VINOS ESPUMOSOS") ~ "Wines",
      TRUE ~ NA_character_   # Todo lo demás no es alcohol relevante
    ),
    apv = case_when(
      glosa == "Beer"    ~ 5,
      glosa == "Wines"   ~ 13.5,
      glosa == "Spirits" ~ 37.5,
      TRUE ~ NA_real_
    ),
    # Unifica unidades: LT -> ML
    cantidad = if_else(unidad_medida == "LT", cantidad * 1000, cantidad),
    unidad_medida = if_else(unidad_medida == "LT", "ML", unidad_medida),
    
    # Llaves 2017
    var_unit = paste0(var_unit, "_17"),
    folio_v  = paste0(folio_v,  "_17"),
    id_ind   = paste(folio_v, n_linea, sep = "_")
  ) %>%
  dplyr::select(-n_linea)

# 1) Universo de hogares con sus vars "de hogar"
hogares_17 <- cantidades_17_limpia %>%
  group_by(folio_v) %>%
  summarise(
    fe               = first(fe),
    estrato_muestreo = first(estrato_muestreo),
    var_unit         = first(var_unit),
    unidad_medida    = first(unidad_medida),   
    gasto_tot = sum(gasto),
    .groups = "drop"
  )

# 2) Suma por hogar y tipo de bebida (solo Beer/Wines/Spirits)
alcohol_sum_17 <- cantidades_17_limpia %>%
  filter(glosa %in% c("Beer", "Wines", "Spirits")) %>%
  group_by(folio_v, glosa) %>%
  summarise(
    cantidad = sum(cantidad, na.rm = TRUE),
    gasto    = sum(gasto,    na.rm = TRUE),
    .groups = "drop"
  )

# 3) Panel 3x hogar + ceros
cantidades_17 <- hogares_17 %>%
  crossing(glosa = c("Beer", "Wines", "Spirits")) %>%
  left_join(alcohol_sum_17, by = c("folio_v", "glosa")) %>%
  mutate(
    cantidad_oh = replace_na(cantidad, 0),
    gasto_oh    = replace_na(gasto, 0),
    apv = case_when(
      glosa == "Beer"    ~ 5,
      glosa == "Wines"   ~ 13.5,
      glosa == "Spirits" ~ 37.5
    ),
    unidad_medida = "ML"
  ) %>%
  dplyr::select(folio_v, fe, estrato_muestreo, var_unit, unidad_medida, glosa, apv, cantidad_oh, gasto_oh, gasto_tot)

data_17 <- personas_17 %>% 
  inner_join(cantidades_17, by = c("folio_v", "fe", 
                                   "estrato_muestreo","var_unit"))%>% 
  mutate(across(where(is.numeric), ~na_if(.x, -88)),
         across(where(is.numeric), ~na_if(.x, -99))) %>% 
  mutate(year = 2017) %>% 
  dplyr::select(-educ_t_hhh)

export(data_17, "epf_2017.rds")

#--------#
# MERGE #
#-------#
rm(list = ls());gc()

data_22 <- import("epf_2022.rds") %>%
  zap_labels() %>%
  mutate(year = 2022,
         folio_v = as.character(folio_v)) 
colnames(data_22)
data_17 <- import("epf_2017.rds") %>%
  zap_labels() 
colnames(data_17)
data_epf <- bind_rows(data_22, data_17) %>% 
  mutate(gasto_oh_uf = gasto_oh/39733.94,
         gastot_uf = gasto_tot/39733.94) %>% 
  dplyr::select(-gasto_oh, gasto_tot)

# should have 3 rows
data_epf %>%
  count(folio_v) %>%
  summarise(
    min_n = min(n),
    max_n = max(n)
  )

# ------------------------------------------------------------
# A) Tabla HOGAR (1 fila por hogar) con covariables + OH_cat
# ------------------------------------------------------------
hh_household <- data_epf %>%
  distinct(
    folio_v, fe, estrato_muestreo, var_unit, year,
    npersonas, prop_15yo, ing_disp_hog_hd_pc, gastot_uf,
    educ_hhh, age_hhh, sex_hhh, prop_wm, quintil
  ) %>% 
  mutate(ing_uf = ing_disp_hog_hd_pc/39733.94) %>% 
  dplyr::select(-ing_disp_hog_hd_pc)

# Check: 1 fila por hogar
chk <- hh_household %>% count(folio_v) %>% summarise(max_n = max(n)) %>% pull(max_n)
if(chk > 1) stop("hh_household tiene más de 1 fila por folio_v. Revisa duplicados en variables hogar.")

# Etanol y OH_cat (1 fila por hogar)
hh_ethanol <- data_epf %>%
  mutate(ethanol_g = cantidad_oh * (apv / 100) * 0.789) %>%
  group_by(folio_v) %>%
  summarise(total_ethanol = sum(ethanol_g, na.rm = TRUE), .groups = "drop") %>%
  left_join(hh_household %>% dplyr::select(folio_v, npersonas, prop_15yo, sex_hhh), by="folio_v") %>%
  mutate(
    n_15 = npersonas * prop_15yo,
    ethanol_pc_15 = if_else(n_15 > 0, total_ethanol / n_15, NA_real_),
    hh_apc = ethanol_pc_15 / 30,
    oh_cat = case_when(
      sex_hhh == 2 & between(hh_apc, 0.001, 20) ~ "Category 1",
      sex_hhh == 1 & between(hh_apc, 0.001, 40) ~ "Category 1",
      sex_hhh == 2 & hh_apc > 20 & hh_apc <= 40 ~ "Category 2",
      sex_hhh == 1 & hh_apc > 40 & hh_apc <= 60 ~ "Category 2",
      sex_hhh == 2 & hh_apc > 40 ~ "Category 3",
      sex_hhh == 1 & hh_apc > 60 ~ "Category 3",
      TRUE ~ "ND"
    )
  ) %>%
  dplyr::select(folio_v, total_ethanol, n_15, ethanol_pc_15, hh_apc, oh_cat)

hh_household <- hh_household %>%
  left_join(hh_ethanol, by="folio_v")

# ------------------------------------------------------------
# B) Tabla HOGAR×BEBIDA con shares y unit values
# ------------------------------------------------------------
hh_summary <- data_epf %>%
  group_by(folio_v, glosa) %>%
  summarise(
    hh_quant = sum(cantidad_oh, na.rm = TRUE),
    hh_spend = sum(gasto_oh_uf,  na.rm = TRUE),
    .groups = "drop"
  ) %>%
  group_by(folio_v) %>%
  mutate(
    hh_tot_spend = sum(hh_spend, na.rm = TRUE),
    hh_share     = if_else(hh_tot_spend > 0, hh_spend / hh_tot_spend, 0),
    unit_value = if_else(hh_quant > 0 & hh_spend > 0, hh_spend / hh_quant, NA_real_)
  ) %>%
  ungroup() 

hh_data <-hh_household %>% 
  left_join(hh_summary, by = c("folio_v"))

export(hh_data, "DATA_EPS_2217_LONG.rds")
# ------------------------------------------------------------
# D) Pasar a WIDE (1 fila por hogar)
# ------------------------------------------------------------

hh_wide <- hh_summary %>%
  pivot_wider(
    names_from  = glosa,
    values_from = c(hh_share, unit_value, hh_quant, hh_spend),
    names_sep   = "_"
  ) %>%
  left_join(hh_bev %>% dplyr::select(folio_v) %>% distinct(), by="folio_v") %>%
  left_join(hh_household, by="folio_v")
export(hh_wide, "DATA_EPS_2217_WIDE.rds")

# ------------------------------------------------------------
# E) Checks rápidos
# ------------------------------------------------------------
# Shares suman 1 entre compradores
hh_wide %>%
  mutate(sum_share = hh_share_Beer + hh_share_Wines + hh_share_Spirits) %>%
  summarise(
    mean_sum_buyers = mean(sum_share[hh_tot_spend > 0], na.rm=TRUE),
    mean_sum_zeros  = mean(sum_share[hh_tot_spend == 0], na.rm=TRUE)
  ) %>% print()
