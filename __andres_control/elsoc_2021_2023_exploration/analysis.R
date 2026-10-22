.t0 <- Sys.time()
# Read the encrypted repository copy into tempdir(); export aggregates only.
root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
while (!file.exists(file.path(root, ".acc_root")) && dirname(root) != root) root <- dirname(root)
stopifnot(file.exists(file.path(root, ".acc_root")))
source(file.path(root, "_tools", "acc_data.R"))
root <- acc_root(root)
out <- file.path(root, "__andres_control", "elsoc_2021_2023_exploration", "tables")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
save_table <- function(x, name) utils::write.csv(x, file.path(out, paste0(name, ".csv")), row.names = FALSE, na = "", fileEncoding = "UTF-8")
file <- acc_data("_elsoc/elsoc_wide_2016_2023.tar.xz.enc")
stopifnot(file.exists(file))
meta <- haven::read_sav(file, n_max = 0, user_na = TRUE)
label <- function(x) { z <- attr(x, "label"); if (is.null(z)) "" else z }
names_all <- names(meta)
save_table(data.frame(variable = names_all, label = vapply(meta, label, "")), "variable_inventory")
keep <- names_all[grepl("^(idencuesta|muestra|tipo_atricion|segmento_disenno|estrato_disenno)$|^(ola|fecha_entr|cuestion_completo)_w0[1-7]$|^(s09|s10|s15|m0_sexo|m0_edad|m01|ponderador_long_total|ponderador_long_panel|ponderador01|ponderador02)_w0[567]$", names_all)]
required <- c("idencuesta", "muestra", "segmento_disenno", "estrato_disenno", "ola_w05", "ola_w07", "s09_w05", "s09_w07", "s10_w05", "s10_w07", "fecha_entr_w05", "fecha_entr_w07", "m0_edad_w05", "m0_edad_w07", "m0_sexo_w05", "m0_sexo_w07", "m01_w05", "s15_w07")
stopifnot(all(required %in% keep))
d <- as.data.frame(haven::read_sav(file, col_select = tidyselect::all_of(keep), user_na = TRUE))
codes <- do.call(rbind, lapply(keep, function(v) {
  z <- attr(meta[[v]], "labels")
  if (!length(z)) return(NULL)
  data.frame(variable = v, code = as.numeric(z), label = names(z))
}))
save_table(codes, "value_labels")
for (v in names(d)) if (is.numeric(d[[v]])) d[[v]] <- as.numeric(d[[v]])
stopifnot(!anyNA(d$idencuesta), !anyDuplicated(d$idencuesta), all(d$muestra %in% 1:2))
stopifnot(all(unname(attr(meta$ola_w05, "labels")) %in% 1:2))
present <- function(w) d[[paste0("ola_w", w)]] %in% 1
regular <- function(x) ifelse(x %in% 1:2, x, NA_real_)
frequency <- function(s09, s10) ifelse(s09 %in% 1 & s10 %in% 1:8, s10, NA_real_)
stopifnot(identical(frequency(c(2, 1, 1, -888), c(NA, 1, -999, 4)), c(NA_real_, 1, NA_real_, NA_real_)))
for (w in c("05", "07")) stopifnot(identical(present(w), !is.na(d[[paste0("cuestion_completo_w", w)]])))
for (w in c("05", "07")) {
  stopifnot(all(is.na(d[[paste0("s09_w",w)]]) | d[[paste0("s09_w",w)]] %in% c(-999,-888,-777,-666,1,2)))
  stopifnot(all(is.na(d[[paste0("s10_w",w)]]) | d[[paste0("s10_w",w)]] %in% c(-999,-888,-777,-666,1:8)))
}
sample_label <- ifelse(d$muestra == 1, "M1", "M2")
date0 <- as.Date(d$fecha_entr_w05, format = "%Y-%m-%d")
date1 <- as.Date(d$fecha_entr_w07, format = "%Y-%m-%d")
elapsed <- as.numeric(date1 - date0) / 365.2425
age0 <- d$m0_edad_w05; age1 <- d$m0_edad_w07
sex0 <- d$m0_sexo_w05; sex1 <- d$m0_sexo_w07
baseline <- present("05") & !is.na(age0) & age0 >= 18 & age0 <= 65
linked <- baseline & present("07")
valid_dates <- !is.na(date0) & !is.na(date1) & date1 > date0 &
  date0 >= as.Date("2021-01-01") & date0 <= as.Date("2021-12-31") &
  date1 >= as.Date("2023-01-01") & date1 <= as.Date("2024-12-31")
age_residual <- age1 - age0 - elapsed
# Whole-year ages can differ from elapsed years by almost one year around birthdays.
age_ok <- !is.na(age_residual) & abs(age_residual) <= 1.05
sex_ok <- sex0 %in% 1:2 & sex1 %in% 1:2 & sex0 == sex1
# Age discrepancies are not proof of an invalid ID; retain and flag, then test strict exclusion.
quality <- linked & sex_ok & valid_dates & !is.na(age1) & age1 >= 18 & age1 <= 110
strict_quality <- quality & age_ok
r0 <- regular(d$s09_w05); r1 <- regular(d$s09_w07)
f0 <- frequency(d$s09_w05, d$s10_w05); f1 <- frequency(d$s09_w07, d$s10_w07)
rp <- quality & !is.na(r0) & !is.na(r1)
fp <- quality & !is.na(f0) & !is.na(f1)
age_group <- as.character(cut(age0, c(17, 29, 44, 59, 65), labels = c("18-29", "30-44", "45-59", "60-65")))
sex <- ifelse(sex0 == 1, "Men", ifelse(sex0 == 2, "Women", "Unknown"))
edu <- ifelse(d$m01_w05 %in% 1:4, "Basic_or_less", ifelse(d$m01_w05 %in% c(5,6,8), "Secondary", ifelse(d$m01_w05 %in% c(7,9,10), "Higher", "Unknown")))

flow_masks <- list(w05_participants = present("05"), w07_participants = present("07"),
  w05_age18_65 = baseline, reinterviewed_w07 = linked,
  sex_consistent = linked & sex_ok, dates_valid_after_sex = linked & sex_ok & valid_dates,
  primary_links = quality, strict_age_consistent_links = strict_quality, s09_classifiable_pairs = rp,
  regular_both = quality & r0 %in% 1 & r1 %in% 1, s10_classifiable_pairs = fp,
  primary_pairs_absent_w06_return_w07 = quality & !present("06"))
flow <- do.call(rbind, lapply(c("All", "M1", "M2"), function(s) do.call(rbind, lapply(names(flow_masks), function(k) {
  z <- if (s == "All") rep(TRUE, nrow(d)) else sample_label == s
  data.frame(sample = s, stage = k, n = sum(z & flow_masks[[k]], na.rm = TRUE))
}))))
save_table(flow, "sample_flow")
reason <- rep("outside_baseline_age_domain", nrow(d))
reason[baseline] <- "not_reinterviewed"
reason[linked] <- "sex_missing_or_changed"
reason[linked & sex_ok] <- "date_missing_or_invalid"
reason[linked & sex_ok & valid_dates] <- "destination_age_missing_or_impossible"
reason[quality] <- "primary_link_valid"
save_table(as.data.frame(table(sample = sample_label[baseline], reason = reason[baseline])), "exclusion_flow")
save_table(data.frame(check = c("wide_rows", "unique_ids", "eligible_sex_changed", "eligible_age_inconsistent", "eligible_date_invalid", "age18_19_at_baseline", "primary_pairs"),
  n = c(nrow(d), length(unique(d$idencuesta)), sum(linked & sex0 %in% 1:2 & sex1 %in% 1:2 & sex0 != sex1), sum(linked & valid_dates & !age_ok), sum(linked & !valid_dates), sum(baseline & age0 <= 19), sum(quality))), "integrity_checks")
save_table(as.data.frame(table(sample=sample_label[quality],age_change=age1[quality]-age0[quality],age_date_consistent=age_ok[quality])),"age_change_distribution")
save_table(data.frame(wave=c("w05","w07"),mode_status=c("CATI_documented_no_individual_mode_field","MIXED_documented_individual_mode_unidentified"),n_participants=c(sum(present("05")),sum(present("07")))),"mode_coverage_limit")
summ <- function(x) { x <- x[is.finite(x)]; if (!length(x)) return(rep(NA_real_, 7)); c(n=length(x),min=min(x),q25=unname(stats::quantile(x,.25)),median=stats::median(x),q75=unname(stats::quantile(x,.75)),max=max(x),mean=mean(x)) }
save_table(do.call(rbind, lapply(c("All","M1","M2"), function(s) {
  z <- linked & (s == "All" | sample_label == s)
  a <- summ(elapsed[z]); b <- summ(age_residual[z])
  rbind(data.frame(sample=s,quantity="elapsed_years",t(a)), data.frame(sample=s,quantity="age_change_minus_elapsed_years",t(b)))
})), "intervals_and_age_checks")
save_table(do.call(rbind, lapply(c("05","07"), function(w) {
  dates <- as.Date(d[[paste0("fecha_entr_w",w)]],format="%Y-%m-%d")
  data.frame(wave=w,n_present=sum(present(w)),n_date=sum(present(w)&!is.na(dates)),first=as.character(min(dates[present(w)],na.rm=TRUE)),last=as.character(max(dates[present(w)],na.rm=TRUE)))
})), "field_dates")

raw <- list(); routing <- list()
for (w in c("05","07")) for (s in c("M1","M2")) {
  z <- present(w) & sample_label == s
  for (v in c("s09","s10","s15")) {
    vn <- paste0(v,"_w",w); if (!vn %in% names(d)) next
    tb <- table(ifelse(is.na(d[[vn]][z]), "SYSTEM_MISSING", as.character(d[[vn]][z])))
    raw[[length(raw)+1]] <- data.frame(wave=w,sample=s,item=v,code=names(tb),n=as.vector(tb))
  }
  a <- d[[paste0("s09_w",w)]]; b <- d[[paste0("s10_w",w)]]
  tb <- table(s09=ifelse(is.na(a[z]),"SYSTEM_MISSING",a[z]),s10_status=ifelse(b[z] %in% 1:8,"VALID",ifelse(is.na(b[z]),"SYSTEM_MISSING","SPECIAL_MISSING")))
  routing[[length(routing)+1]] <- cbind(wave=w,sample=s,as.data.frame(tb))
  stopifnot(sum(z & a %in% 2 & b %in% 1:8)==0)
}
save_table(do.call(rbind,raw),"raw_code_counts")
save_table(do.call(rbind,routing),"s10_routing")

weight_audit <- list(); composition <- list()
for (w in c("05","07")) for (s in c("M1","M2")) for (v in c("ponderador02","ponderador_long_total","ponderador_long_panel")) {
  vn <- paste0(v,"_w",w); if (!vn %in% names(d)) next
  for (domain in c("all_wave_respondents","primary_s09_pairs")) {
    z <- sample_label==s & if(domain=="all_wave_respondents") present(w) else rp
    wt <- d[[vn]]; good <- z & is.finite(wt) & wt>0
    weight_audit[[length(weight_audit)+1]] <- data.frame(wave=w,sample=s,variable=vn,domain=domain,n=sum(z),positive=sum(good),missing=sum(z&is.na(wt)),nonpositive=sum(z&!is.na(wt)&wt<=0),sum_weight=sum(wt[good]),min=if(any(good))min(wt[good]) else NA,max=if(any(good))max(wt[good]) else NA,ess=if(any(good))sum(wt[good])^2/sum(wt[good]^2) else NA)
  }
}
save_table(do.call(rbind,weight_audit),"weight_coverage")
for (w in c("05","07")) for(s in c("M1","M2")) for(domain in c("wave_age18_65","balanced_panel_age18_65","s09_pairs")) {
  aw <- d[[paste0("m0_edad_w",w)]]; sw <- d[[paste0("m0_sexo_w",w)]]
  z <- present(w)&sample_label==s&!is.na(aw)&aw>=18&aw<=65
  if(domain=="balanced_panel_age18_65") z <- z & !is.na(d[[paste0("ponderador_long_panel_w",w)]]) & d[[paste0("ponderador_long_panel_w",w)]]>0
  if(domain=="s09_pairs") z <- rp & sample_label==s
  # Pair composition is assessed at each endpoint, without reapplying destination age exclusion.
  ag <- as.character(cut(aw,c(17,29,44,59,65,Inf),labels=c("18-29","30-44","45-59","60-65","66+")))
  tb<-as.data.frame(table(sex=sw[z],age_group=ag[z]));tb$proportion<-tb$Freq/sum(tb$Freq)
  composition[[length(composition)+1]]<-cbind(wave=w,sample=s,domain=domain,tb)
}
save_table(do.call(rbind,composition),"composition_for_weight_choice")

# shortcut: segment bootstrap omits city-stage dependence; replace when full design is available.
stopifnot(!anyNA(d$segmento_disenno[quality]),!anyNA(d$estrato_disenno[quality]))
seg <- as.character(d$segmento_disenno)
seg_strata <- tapply(d$estrato_disenno,seg,function(z) length(unique(z)))
stopifnot(all(seg_strata == 1))
design_people <- which(baseline)
units <- unique(data.frame(segment=seg[design_people],stratum=d$estrato_disenno[design_people]))
save_table(data.frame(stratum=sort(unique(units$stratum)),segments=as.vector(table(units$stratum))),"bootstrap_design")
save_table(data.frame(check=c("segments_all","segments_shared_M1_M2"),n=c(length(unique(seg)),sum(tapply(d$muestra,seg,function(z)length(unique(z)))>1))),"cluster_overlap")
B <- 1999L; set.seed(20231021)
boot <- matrix(0,nrow(units),B)
for (h in unique(units$stratum)) {
  ix <- which(units$stratum==h); stopifnot(length(ix)>1)
  boot[ix,] <- stats::rmultinom(B,length(ix),rep(1/length(ix),length(ix)))
}
unit_index <- match(seg,units$segment)
estimate <- function(den,num) {
  stopifnot(all(!num|den)); n <- sum(den); k<-sum(num); g<-length(unique(seg[den])); p<-if(n)k/n else NA_real_
  lo<-hi<-NA_real_; status<-if(!n)"empty_origin" else if(g<10)"fewer_than_10_segments" else if(k==0||k==n)"boundary_no_interval" else "exploratory_segment_bootstrap"
  if(n && g>=10 && k>0 && k<n) {
    cd<-tabulate(unit_index[den],nbins=nrow(units)); cn<-tabulate(unit_index[num],nbins=nrow(units))
    dd<-as.numeric(crossprod(cd,boot)); nn<-as.numeric(crossprod(cn,boot)); pp<-nn[dd>0]/dd[dd>0]
    if(length(pp)>=.95*B) { ci<-stats::quantile(pp,c(.025,.975),names=FALSE);lo<-ci[1];hi<-ci[2] } else status<-"insufficient_bootstrap_support"
  }
  data.frame(n_origin=n,n_event=k,n_segments=g,estimate=p,lower=lo,upper=hi,small_origin=n<30,rare_event=if(n)min(k,n-k)<5 else TRUE,ci_status=status)
}
groups <- list(All=rep(TRUE,nrow(d)),M1=sample_label=="M1",M2=sample_label=="M2")
for(s in c("Men","Women")) for(a in c("18-29","30-44","45-59","60-65")) groups[[paste(s,a,sep="_")]] <- sex==s & !is.na(age_group)&age_group==a
for(e in c("Basic_or_less","Secondary","Higher","Unknown")) groups[[paste0("Education_",e)]] <- edu==e
matrices<-list();changes<-list()
for(group in names(groups)) {
  gg<-groups[[group]];gg[is.na(gg)]<-FALSE
  for(item in c("s09","s10")) {
    mask<-if(item=="s09")rp else fp; a<-if(item=="s09")r0 else f0;b<-if(item=="s09")r1 else f1;cats<-if(item=="s09")1:2 else 1:8
    for(fr in cats) for(to in cats) {
      den<-mask&gg&a %in% fr;num<-den&b %in% to
      matrices[[length(matrices)+1]]<-cbind(group=group,item=item,from=fr,to=to,estimate(den,num))
    }
    den<-mask&gg
    events<-if(item=="s09") list(same=r0==r1,entry_regular=r0==2&r1==1,exit_regular=r0==1&r1==2) else list(same=f0==f1,increase=f1>f0,decrease=f1<f0)
    for(event in names(events)) {
      ee<-events[[event]];ee[is.na(ee)]<-FALSE
      changes[[length(changes)+1]]<-cbind(group=group,item=item,event=event,estimate(den,den&ee))
    }
  }
}
matrices<-do.call(rbind,matrices);changes<-do.call(rbind,changes)
save_table(matrices,"transition_matrices_unweighted")
save_table(changes,"change_summary_unweighted")
net <- do.call(rbind,lapply(names(groups),function(group) {
  z <- rp & groups[[group]]; z[is.na(z)]<-FALSE
  v <- as.numeric(r1 %in% 1)-as.numeric(r0 %in% 1)
  n <- sum(z); ci<-c(NA_real_,NA_real_)
  if(n && length(unique(seg[z]))>=10 && length(unique(v[z]))>1) {
    cd<-tabulate(unit_index[z],nbins=nrow(units))
    cn<-tabulate(unit_index[z&v==1],nbins=nrow(units))-tabulate(unit_index[z&v == -1],nbins=nrow(units))
    dd<-as.numeric(crossprod(cd,boot));nn<-as.numeric(crossprod(cn,boot));ci<-stats::quantile(nn[dd>0]/dd[dd>0],c(.025,.975),names=FALSE)
  }
  data.frame(group=group,n=n,regular_origin=sum(z&r0%in%1),regular_destination=sum(z&r1%in%1),difference=if(n)mean(v[z])else NA,lower=ci[1],upper=ci[2])
}))
save_table(net,"paired_regular_share_change")
for(item in c("s09","s10")) for(group in names(groups)) {
  z<-matrices[matrices$item==item&matrices$group==group,]
  for(fr in unique(z$from)) { a<-z[z$from==fr,];if(a$n_origin[1]>0)stopifnot(abs(sum(a$estimate)-1)<1e-12,sum(a$n_event)==a$n_origin[1]) }
}
sensitivity<-list()
for(scope in c("all_linked_no_quality_exclusion","primary_quality","strict_age_consistency","primary_complete_questionnaires")) for(item in c("s09","s10")) {
  z<-if(scope=="all_linked_no_quality_exclusion")linked else quality
  if(scope=="strict_age_consistency")z<-strict_quality
  if(scope=="primary_complete_questionnaires")z<-z&d$cuestion_completo_w05%in%1&d$cuestion_completo_w07%in%1
  a<-if(item=="s09")r0 else f0;b<-if(item=="s09")r1 else f1;z<-z&!is.na(a)&!is.na(b)
  for(event in c("same","increase","decrease")) {
    ee<-if(event=="same")a==b else if(item=="s09") {if(event=="increase")a==2&b==1 else a==1&b==2} else {if(event=="increase")b>a else b<a}
    ee[is.na(ee)]<-FALSE
    sensitivity[[length(sensitivity)+1]]<-data.frame(scope=scope,item=item,event=event,n=sum(z),n_event=sum(z&ee),proportion=if(sum(z))sum(z&ee)/sum(z) else NA)
  }
}
save_table(do.call(rbind,sensitivity),"quality_sensitivity")
retention<-list()
for(group in names(groups)) for(origin in c("All","1","2","Missing")) {
  den<-baseline&groups[[group]];den[is.na(den)]<-FALSE
  if(origin=="Missing")den<-den&is.na(r0) else if(origin!="All")den<-den&r0 %in% as.numeric(origin)
  retention[[length(retention)+1]]<-data.frame(group=group,s09_origin=origin,n_baseline=sum(den),n_reinterviewed=sum(den&present("07")),n_s09_pairs=sum(den&rp),reinterview_fraction=if(sum(den))sum(den&present("07"))/sum(den) else NA)
}
save_table(do.call(rbind,retention),"retention_by_origin_group")
s15<-list()
for(s in c("M1","M2")) for(rr in c("All","1","2","Missing")) {
  z<-present("07")&sample_label==s
  if(rr=="Missing")z<-z&is.na(r1) else if(rr!="All")z<-z&r1 %in% as.numeric(rr)
  v<-d$s15_w07; good<-z&!is.na(v)&v>=0
  s15[[length(s15)+1]]<-data.frame(sample=s,s09=rr,n_respondents=sum(z),n_valid=sum(good),n_zero=sum(good&v==0),n_positive=sum(good&v>0),n_over30=sum(good&v>30),n_system_missing=sum(z&is.na(v)),n_special_missing=sum(z&!is.na(v)&v<0),median=if(any(good))stats::median(v[good])else NA,q25=if(any(good))unname(stats::quantile(v[good],.25))else NA,q75=if(any(good))unname(stats::quantile(v[good],.75))else NA,max=if(any(good))max(v[good])else NA)
}
save_table(do.call(rbind,s15),"s15_2023_audit")
support<-do.call(rbind,lapply(c("Men","Women"),function(s)do.call(rbind,lapply(c("18-29","30-44","45-59","60-65"),function(a)do.call(rbind,lapply(c("Basic_or_less","Secondary","Higher","Unknown"),function(e){z<-sex==s&!is.na(age_group)&age_group==a&edu==e;z[is.na(z)]<-FALSE;data.frame(sex=s,age_group=a,education=e,n_s09=sum(z&rp),n_s10=sum(z&fp),small_s09=sum(z&rp)<30,small_s10=sum(z&fp)<30)}))))))
save_table(support,"education_joint_support")
# Reuse only empirical fields from existing EPS/TSM outputs, never annualized matrices.
tri<-list()
for(src in c("EPS","TSM")) {
  dir<-if(src=="EPS")"eps_markov_outputs_v2" else "tsm_markov_outputs"
  path<-file.path(root,"__andres_control",dir,"rank_matching_vs_panel.csv")
  if(file.exists(path)) {x<-utils::read.csv(path);x<-x[x$source=="Observed_panel"&x$from=="NC"&x$to=="NC",];tri[[src]]<-data.frame(survey=src,period=x$period,construct="no_declared_use",persistence=x$probability,source=paste0("../",dir,"/rank_matching_vs_panel.csv"))}
}
save_table(do.call(rbind,tri),"triangulation_existing_observed")
path<-file.path(root,"__andres_control","tsm_markov_outputs","calibration_by_origin_cell.csv")
if(file.exists(path)) {x<-utils::read.csv(path);x<-x[x$model=="A"&x$destination=="NC"&x$state0%in%c("N0","FD"),c("state0","sex","age_group","n_origin","observed","sparse")];save_table(x,"tsm_observed_group_context")}
save_table(data.frame(source="_elsoc/elsoc_wide_2016_2023.tar.xz.enc",md5=unname(tools::md5sum(file)),rows=nrow(d),bootstrap_replicates=B,seed=20231021,weights="none; w07 weights present but pair-specific applicability unverified"),"provenance")
capture.output(utils::sessionInfo(),file=file.path(out,"session_info.txt"))
# Keep report values reproducible from the same run as the aggregate CSV files.
pct <- function(x) ifelse(is.na(x),"\u2014",sprintf("%.1f%%",100*x))
interval <- function(row) {
  if(!nrow(row) || is.na(row$estimate[1])) return("\u2014")
  paste0(pct(row$estimate[1]),if(is.na(row$lower[1]))" [sin intervalo]" else paste0(" [",pct(row$lower[1]),"; ",pct(row$upper[1]),"]"),if(row$small_origin[1])" *"else "")
}
md <- function(x) c(paste0("| ",paste(names(x),collapse=" | ")," |"),paste0("|",paste(rep("---",ncol(x)),collapse="|"),"|"),apply(x,1,function(r)paste0("| ",paste(r,collapse=" | ")," |")),"")
report <- c("# ELSOC 2021\u21922023: resultados observados", "", "Generado por `analysis.R`. Resultados no ponderados, condicionados a participantes enlazados. Los intervalos del 95% son exploratorios por segmentos, no inferencia poblacional ni validaci\u00f3n del motor. V\u00e9ase [decisiones y l\u00edmites](README.md).", "", "## Flujo", "")
fl <- data.frame(Etapa=names(flow_masks))
for(s in c("All","M1","M2"))fl[[s]]<-flow$n[flow$sample==s]
report<-c(report,md(fl),"Las etapas strict_age y retorno w06 son diagn\u00f3sticos/subconjuntos, no descartes adicionales del primario. Los participantes w07 incluyen personas fuera del conjunto inicial.","", "## S09: matriz de regularidad", "", "Cada fila usa su propio N de origen. C\u00f3digo 1=regular; 2=no regular (no significa abstinencia). Celda: n; porcentaje [intervalo].", "")
tab<-data.frame(Origen=c("1 Regular","2 No regular"),N=NA_integer_,Destino_regular="",Destino_no_regular="")
for(i in 1:2) {
  for(j in 1:2) {r<-matrices[matrices$group=="All"&matrices$item=="s09"&matrices$from==i&matrices$to==j,];tab[i,j+2]<-paste0(r$n_event,"; ",interval(r));tab$N[i]<-r$n_origin}
}
report<-c(report,md(tab),"## Cambios globales", "", "S09: misma respuesta, paso a regular y paso a no regular divididos por TODOS los pares S09. Las probabilidades condicionadas al origen est\u00e1n en la matriz anterior. S10: solo regulares en ambos extremos y frecuencia v\u00e1lida en ambos.", "")
z<-changes[changes$group=="All",];report<-c(report,md(data.frame(Item=z$item,Cambio=z$event,N=z$n_origin,Eventos=z$n_event,Estimacion=vapply(seq_len(nrow(z)),function(i)interval(z[i,]),""))))
z<-net[net$group=="All",];report<-c(report,sprintf("Cambio pareado de proporci\u00f3n regular: %.2f puntos porcentuales [%.2f; %.2f]; origen %d/%d y destino %d/%d.",100*z$difference,100*z$lower,100*z$upper,z$regular_origin,z$n,z$regular_destination,z$n),"", "## Sexo \u00d7 edad inicial: S09", "")
gg<-names(groups)[grepl("^(Men|Women)_",names(groups))]
rows<-lapply(gg,function(g){a<-matrices[matrices$group==g&matrices$item=="s09"&matrices$from==1&matrices$to==1,];b<-matrices[matrices$group==g&matrices$item=="s09"&matrices$from==2&matrices$to==2,];data.frame(Grupo=g,N_regular=a$n_origin,Permanencia_regular=interval(a),N_no_regular=b$n_origin,Permanencia_no_regular=interval(b))})
report<-c(report,md(do.call(rbind,rows)),"## Sexo \u00d7 edad inicial: S10 condicionada", "")
rows<-lapply(gg,function(g){a<-changes[changes$group==g&changes$item=="s10",];data.frame(Grupo=g,N=a$n_origin[1],Igual=interval(a[a$event=="same",]),Aumento=interval(a[a$event=="increase",]),Disminucion=interval(a[a$event=="decrease",]))})
report<-c(report,md(do.call(rbind,rows)),"* N de origen <30. Las categor\u00edas 18\u201329 no incluyen personas de 18\u201319 en esta entrega. No inferir diferencias entre grupos por comparar intervalos marginales.", "", "## S10: matriz completa en categor\u00edas originales", "", "1=<1 d\u00eda/semana; 2=1; 3=2; 4=3; 5=4; 6=5; 7=6; 8=7 d\u00edas. Celda: n (porcentaje de fila). Sin frecuencia cero imputada. Intervalos y banderas de cada celda: [CSV completo](tables/transition_matrices_unweighted.csv).", "")
tab<-data.frame(Origen=1:8,N=NA_integer_)
for(j in 1:8)tab[[paste0("Destino",j)]]<-""
for(i in 1:8)for(j in 1:8){r<-matrices[matrices$group=="All"&matrices$item=="s10"&matrices$from==i&matrices$to==j,];tab$N[i]<-r$n_origin;tab[i,j+2]<-paste0(r$n_event," (",pct(r$estimate),")")}
report<-c(report,md(tab),"## Muestras y educaci\u00f3n basal (aproximaci\u00f3n)", "", "M1/M2 se muestran por separado; educaci\u00f3n se ofrece como margen adicional, no como equivalencia exacta de t\u00edtulos completados. La tabla conjunta sexo\u00d7edad\u00d7educaci\u00f3n est\u00e1 en [soporte](tables/education_joint_support.csv).", "")
gg<-names(groups)[grepl("^M[12]$|^Education_",names(groups))]
rows<-lapply(gg,function(g){a<-changes[changes$group==g&changes$item=="s09"&changes$event=="same",];b<-changes[changes$group==g&changes$item=="s10"&changes$event=="same",];data.frame(Grupo=g,N_S09=a$n_origin,Misma_regularidad=interval(a),N_S10=b$n_origin,Misma_frecuencia=interval(b))})
report<-c(report,md(do.call(rbind,rows)),"## Sensibilidad de calidad", "",md(do.call(rbind,sensitivity)),"## S15: toda la muestra de 2023, sin restricci\u00f3n 18\u201365", "",md(do.call(rbind,s15)),"## Contexto observado EPS/TSM", "", "Estos porcentajes describen no consumo declarado, NO no regularidad. Difieren intervalos, pesos y selecci\u00f3n. No comparar magnitudes con S09 como si fuera la misma medida.", "",md(do.call(rbind,tri)))
writeLines(enc2utf8(report),file.path(dirname(out),"RESULTS.md"),useBytes=TRUE)
message(sprintf("Completed with %d S09 pairs and %d conditional S10 pairs. Elapsed %.2f minutes.",sum(rp),sum(fp),as.numeric(difftime(Sys.time(),.t0,units="mins"))))
