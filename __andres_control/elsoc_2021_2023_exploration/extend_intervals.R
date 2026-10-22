.t0 <- Sys.time()
if (.Platform$OS.type == "windows") invisible(Sys.setlocale("LC_CTYPE", "English_United States.utf8"))
root <- normalizePath(getwd(), winslash="/", mustWork=TRUE)
while (!file.exists(file.path(root,".acc_root")) && dirname(root)!=root) root <- dirname(root)
stopifnot(file.exists(file.path(root,".acc_root")))
source(file.path(root,"_tools","acc_data.R")); root <- acc_root(root)
base <- file.path(root,"__andres_control","elsoc_2021_2023_exploration")
old <- file.path(base,"tables"); out <- file.path(base,"intervals")
dir.create(out,showWarnings=FALSE)
file <- acc_data("_elsoc/elsoc_wide_2016_2023.tar.xz.enc")
old_files <- list.files(old,full.names=TRUE); old_hash <- tools::md5sum(old_files)
provenance <- utils::read.csv(file.path(old,"provenance.csv"))
stopifnot(unname(tools::md5sum(file))==provenance$md5)
save_table <- function(x,name) utils::write.csv(x,file.path(out,paste0(name,".csv")),row.names=FALSE,na="",fileEncoding="UTF-8")
read_old <- function(name) utils::read.csv(file.path(old,paste0(name,".csv")),stringsAsFactors=FALSE)
meta <- haven::read_sav(file,n_max=0,user_na=TRUE)
keep <- names(meta)[grepl("^(idencuesta|muestra|segmento_disenno|estrato_disenno)$|^(ola|fecha_entr|cuestion_completo)_w0[1-7]$|^(s09|s10|m0_sexo|m0_edad|m01|ponderador01|ponderador02|ponderador_long_total|ponderador_long_panel)_w0[1357]$",names(meta))]
d <- as.data.frame(haven::read_sav(file,col_select=tidyselect::all_of(keep),user_na=TRUE))
save_table(do.call(rbind,lapply(keep,function(v){z<-attr(meta[[v]],"labels");if(length(z))data.frame(variable=v,code=as.numeric(z),label=names(z))})),"value_labels")
for(v in names(d))if(is.numeric(d[[v]]))d[[v]]<-as.numeric(d[[v]])
stopifnot(!anyNA(d$idencuesta),!anyDuplicated(d$idencuesta),all(d$muestra%in%1:2))
getv <- function(v,w) d[[paste0(v,"_w",w)]]
present <- function(w) getv("ola",w)%in%1
regular <- function(x) ifelse(x%in%1:2,x,NA_real_)
frequency <- function(s09,s10) ifelse(s09%in%1&s10%in%1:8,s10,NA_real_)
stopifnot(identical(frequency(c(2,1,1,-888),c(NA,1,-999,4)),c(NA_real_,1,NA_real_,NA_real_)))
sample_label<-ifelse(d$muestra==1,"M1","M2")
seg<-as.character(d$segmento_disenno)
stopifnot(all(tapply(d$estrato_disenno,seg,function(z)length(unique(z)))==1))
raw<-routing<-dates<-list()
for(w in c("01","03","05","07")) {
  stopifnot(identical(present(w),!is.na(getv("cuestion_completo",w))))
  for(v in c("s09","s10"))stopifnot(all(is.na(getv(v,w))|getv(v,w)%in%c(-999,-888,-777,-666,if(v=="s09")1:2 else 1:8)))
  dt<-as.Date(getv("fecha_entr",w),format="%Y-%m-%d")
  for(s in c("M1","M2")) {
    z<-present(w)&sample_label==s
    if(!any(z))next
    dates[[length(dates)+1]]<-data.frame(wave=w,sample=s,n=sum(z),n_date=sum(z&!is.na(dt)),first=as.character(min(dt[z],na.rm=TRUE)),last=as.character(max(dt[z],na.rm=TRUE)))
    for(v in c("s09","s10")) {tb<-table(ifelse(is.na(getv(v,w)[z]),"SYSTEM_MISSING",as.character(getv(v,w)[z])));raw[[length(raw)+1]]<-data.frame(wave=w,sample=s,item=v,code=names(tb),n=as.vector(tb))}
    a<-getv("s09",w);b<-getv("s10",w)
    stopifnot(sum(z&a%in%2&b%in%1:8)==0)
    tb<-table(s09=ifelse(is.na(a[z]),"SYSTEM_MISSING",a[z]),s10_status=ifelse(b[z]%in%1:8,"VALID",ifelse(is.na(b[z]),"SYSTEM_MISSING","SPECIAL_MISSING")))
    routing[[length(routing)+1]]<-cbind(wave=w,sample=s,as.data.frame(tb))
  }
}
save_table(do.call(rbind,raw),"raw_code_counts");save_table(do.call(rbind,routing),"s10_routing");save_table(do.call(rbind,dates),"field_dates")
pairs<-data.frame(interval=c("2016-2018","2018-2021","2021-2023"),origin=c("01","03","05"),destination=c("03","05","07"),middle=c("02","04","06"),year0=c(2016,2018,2021),year1=c(2018,2021,2023))
all_tables<-list(); membership<-list()
add <- function(x,name,period) {x<-cbind(interval=period,x);all_tables[[name]]<<-rbind(all_tables[[name]],x)}
summ <- function(x) {x<-x[is.finite(x)];c(n=length(x),min=if(length(x))min(x)else NA,q25=if(length(x))unname(stats::quantile(x,.25))else NA,median=if(length(x))stats::median(x)else NA,q75=if(length(x))unname(stats::quantile(x,.75))else NA,max=if(length(x))max(x)else NA,mean=if(length(x))mean(x)else NA)}
B<-1999L
for(pi in seq_len(nrow(pairs))) {
  p<-pairs[pi,];w0<-p$origin;w1<-p$destination;period<-p$interval
  date0<-as.Date(getv("fecha_entr",w0),format="%Y-%m-%d");date1<-as.Date(getv("fecha_entr",w1),format="%Y-%m-%d")
  elapsed<-as.numeric(date1-date0)/365.2425
  age0<-getv("m0_edad",w0);age1<-getv("m0_edad",w1);sex0<-getv("m0_sexo",w0);sex1<-getv("m0_sexo",w1)
  baseline<-present(w0)&!is.na(age0)&age0>=18&age0<=65;linked<-baseline&present(w1)
  valid_dates<-!is.na(date0)&!is.na(date1)&date1>date0&as.integer(format(date0,"%Y"))==p$year0&as.integer(format(date1,"%Y"))%in%if(w1=="07")c(2023,2024)else p$year1
  sex_ok<-sex0%in%1:2&sex1%in%1:2&sex0==sex1
  age_ok<-!is.na(age1-age0-elapsed)&abs(age1-age0-elapsed)<=1.05
  quality<-linked&sex_ok&valid_dates&!is.na(age1)&age1>=18&age1<=110
  strict_quality<-quality&age_ok
  r0<-regular(getv("s09",w0));r1<-regular(getv("s09",w1));f0<-frequency(getv("s09",w0),getv("s10",w0));f1<-frequency(getv("s09",w1),getv("s10",w1))
  rp<-quality&!is.na(r0)&!is.na(r1);fp<-quality&!is.na(f0)&!is.na(f1)
  membership[[period]]<-list(s09=rp,s10=fp,primary=quality)
  age_group<-as.character(cut(age0,c(17,29,44,59,65),labels=c("18-29","30-44","45-59","60-65")))
  sex<-ifelse(sex0==1,"Men",ifelse(sex0==2,"Women","Unknown"))
  education<-getv("m01",w0)
  edu<-ifelse(education%in%1:4,"Basic_or_less",ifelse(education%in%c(5,6,8),"Secondary",ifelse(education%in%c(7,9,10),"Higher","Unknown")))
  groups<-list(All=rep(TRUE,nrow(d)),M1=sample_label=="M1",M2=sample_label=="M2")
  for(s in c("Men","Women"))for(a in c("18-29","30-44","45-59","60-65"))groups[[paste(s,a,sep="_")]]<-sex==s&!is.na(age_group)&age_group==a
  for(e in c("Basic_or_less","Secondary","Higher","Unknown"))groups[[paste0("Education_",e)]]<-edu==e
  masks<-list(origin_participants=present(w0),destination_participants=present(w1),origin_age18_65=baseline,reinterviewed=linked,sex_consistent=linked&sex_ok,dates_valid_after_sex=linked&sex_ok&valid_dates,primary_links=quality,strict_age_consistent_links=strict_quality,s09_classifiable_pairs=rp,regular_both=quality&r0%in%1&r1%in%1,s10_classifiable_pairs=fp,absent_middle_return=quality&!present(p$middle))
  for(s in c("All","M1","M2")) {
    ss<-if(s=="All")rep(TRUE,nrow(d))else sample_label==s
    add(data.frame(sample=s,stage=names(masks),n=vapply(masks,function(z)sum(z&ss),0L)),"sample_flow",period)
    for(domain in c("linked_with_dates","primary_links","s09_pairs","s10_pairs")) {
      z<-switch(domain,linked_with_dates=linked,primary_links=quality,s09_pairs=rp,s10_pairs=fp)&ss
      add(data.frame(sample=s,domain=domain,t(summ(elapsed[z]))),"durations",period)
    }
    add(data.frame(sample=s,n_primary=sum(quality&ss),age_date_discordant=sum(quality&ss&!age_ok),age18_19_baseline=sum(baseline&ss&age0<=19),sex_discordant=sum(linked&ss&sex0%in%1:2&sex1%in%1:2&sex0!=sex1)),"quality_checks",period)
  }
  for(w in c(w0,w1))for(s in c("M1","M2"))for(v in c("ponderador01","ponderador02","ponderador_long_total","ponderador_long_panel"))for(domain in c("all_wave_respondents","s09_pairs","s10_pairs")) {
    vn<-paste0(v,"_w",w);if(!vn%in%names(d))next
    z<-sample_label==s&switch(domain,all_wave_respondents=present(w),s09_pairs=rp,s10_pairs=fp);wt<-d[[vn]];good<-z&is.finite(wt)&wt>0
    add(data.frame(wave=w,sample=s,variable=vn,domain=domain,n=sum(z),positive=sum(good),missing=sum(z&is.na(wt)),nonpositive=sum(z&!is.na(wt)&wt<=0),sum_weight=sum(wt[good]),min=if(any(good))min(wt[good])else NA,max=if(any(good))max(wt[good])else NA,ess=if(any(good))sum(wt[good])^2/sum(wt[good]^2)else NA),"weight_coverage",period)
  }
  for(g in names(groups))for(origin in c("All","1","2","Missing")) {
    z<-baseline&groups[[g]];z[is.na(z)]<-FALSE
    if(origin=="Missing")z<-z&is.na(r0)else if(origin!="All")z<-z&r0%in%as.numeric(origin)
    add(data.frame(group=g,s09_origin=origin,n_baseline=sum(z),n_reinterviewed=sum(z&present(w1)),n_s09_pairs=sum(z&rp),reinterview_fraction=if(sum(z))sum(z&present(w1))/sum(z)else NA),"retention_by_origin_group",period)
  }
  support<-do.call(rbind,lapply(c("Men","Women"),function(s)do.call(rbind,lapply(c("18-29","30-44","45-59","60-65"),function(a)do.call(rbind,lapply(c("Basic_or_less","Secondary","Higher","Unknown"),function(e){z<-sex==s&!is.na(age_group)&age_group==a&edu==e;z[is.na(z)]<-FALSE;data.frame(sex=s,age_group=a,education=e,n_s09=sum(z&rp),n_s10=sum(z&fp),small_s09=sum(z&rp)<30,small_s10=sum(z&fp)<30)}))))))
  add(support,"education_joint_support",period)
  if(period=="2021-2023") {
    # Reuse all published estimates and bootstrap intervals; only reconstruct masks for overlap checks.
    stopifnot(sum(rp)==1796,sum(fp)==502,sum(quality)==1802)
    for(name in c("transition_matrices_unweighted","change_summary_unweighted","paired_regular_share_change","quality_sensitivity"))add(read_old(name),name,period)
    add(read_old("bootstrap_design"),"bootstrap_design",period)
    for(item in c("s09","s10")) {
      a<-if(item=="s09")r0 else f0;b<-if(item=="s09")r1 else f1;z<-if(item=="s09")rp else fp
      expected<-read_old("transition_matrices_unweighted");expected<-expected[expected$group=="All"&expected$item==item,]
      stopifnot(all(vapply(seq_len(nrow(expected)),function(i)sum(z&a%in%expected$from[i]&b%in%expected$to[i]),0L)==expected$n_event))
    }
    next
  }
  stopifnot(!anyNA(d$segmento_disenno[baseline]),!anyNA(d$estrato_disenno[baseline]))
  units<-unique(data.frame(segment=seg[baseline],stratum=d$estrato_disenno[baseline]))
  add(data.frame(stratum=sort(unique(units$stratum)),segments=as.vector(table(units$stratum))),"bootstrap_design",period)
  set.seed(20231021+pi);boot<-matrix(0,nrow(units),B)
  # shortcut: segment bootstrap omits city-stage dependence; replace when complete design is available.
  for(h in unique(units$stratum)) {ix<-which(units$stratum==h);stopifnot(length(ix)>1);boot[ix,]<-stats::rmultinom(B,length(ix),rep(1/length(ix),length(ix)))}
  unit_index<-match(seg,units$segment)
  estimate<-function(den,num) {
    stopifnot(all(!num|den));n<-sum(den);k<-sum(num);g<-length(unique(seg[den]));pr<-if(n)k/n else NA_real_
    lo<-hi<-NA_real_;status<-if(!n)"empty_origin"else if(g<10)"fewer_than_10_segments"else if(k==0||k==n)"boundary_no_interval"else "exploratory_segment_bootstrap"
    if(n&&g>=10&&k>0&&k<n) {
      cd<-tabulate(unit_index[den],nbins=nrow(units));cn<-tabulate(unit_index[num],nbins=nrow(units))
      dd<-as.numeric(crossprod(cd,boot));nn<-as.numeric(crossprod(cn,boot));pp<-nn[dd>0]/dd[dd>0]
      if(length(pp)>=.95*B){ci<-stats::quantile(pp,c(.025,.975),names=FALSE);lo<-ci[1];hi<-ci[2]}else status<-"insufficient_bootstrap_support"
    }
    data.frame(n_origin=n,n_event=k,n_segments=g,estimate=pr,lower=lo,upper=hi,small_origin=n<30,rare_event=if(n)min(k,n-k)<5 else TRUE,ci_status=status)
  }
  matrices<-changes<-list()
  for(g in names(groups))for(item in c("s09","s10")) {
    gg<-groups[[g]];gg[is.na(gg)]<-FALSE;mask<-if(item=="s09")rp else fp;a<-if(item=="s09")r0 else f0;b<-if(item=="s09")r1 else f1;cats<-if(item=="s09")1:2 else 1:8
    for(fr in cats)for(to in cats){den<-mask&gg&a%in%fr;num<-den&b%in%to;matrices[[length(matrices)+1]]<-cbind(group=g,item=item,from=fr,to=to,estimate(den,num))}
    den<-mask&gg;events<-if(item=="s09")list(same=r0==r1,entry_regular=r0==2&r1==1,exit_regular=r0==1&r1==2)else list(same=f0==f1,increase=f1>f0,decrease=f1<f0)
    for(event in names(events)){ee<-events[[event]];ee[is.na(ee)]<-FALSE;changes[[length(changes)+1]]<-cbind(group=g,item=item,event=event,estimate(den,den&ee))}
  }
  matrices<-do.call(rbind,matrices);changes<-do.call(rbind,changes)
  for(item in c("s09","s10"))for(g in names(groups)){z<-matrices[matrices$item==item&matrices$group==g,];for(fr in unique(z$from)){a<-z[z$from==fr,];if(a$n_origin[1]>0)stopifnot(abs(sum(a$estimate)-1)<1e-12,sum(a$n_event)==a$n_origin[1])}}
  add(matrices,"transition_matrices_unweighted",period);add(changes,"change_summary_unweighted",period)
  net<-do.call(rbind,lapply(names(groups),function(g){z<-rp&groups[[g]];z[is.na(z)]<-FALSE;v<-as.numeric(r1%in%1)-as.numeric(r0%in%1);n<-sum(z);ci<-c(NA_real_,NA_real_)
    if(n&&length(unique(seg[z]))>=10&&length(unique(v[z]))>1){cd<-tabulate(unit_index[z],nbins=nrow(units));cn<-tabulate(unit_index[z&v==1],nbins=nrow(units))-tabulate(unit_index[z&v== -1],nbins=nrow(units));dd<-as.numeric(crossprod(cd,boot));nn<-as.numeric(crossprod(cn,boot));ci<-stats::quantile(nn[dd>0]/dd[dd>0],c(.025,.975),names=FALSE)}
    data.frame(group=g,n=n,regular_origin=sum(z&r0%in%1),regular_destination=sum(z&r1%in%1),difference=if(n)mean(v[z])else NA,lower=ci[1],upper=ci[2])}))
  add(net,"paired_regular_share_change",period)
  sensitivity<-list()
  for(scope in c("all_linked_no_quality_exclusion","primary_quality","strict_age_consistency","primary_complete_questionnaires"))for(item in c("s09","s10")) {
    z<-if(scope=="all_linked_no_quality_exclusion")linked else quality
    if(scope=="strict_age_consistency")z<-strict_quality
    if(scope=="primary_complete_questionnaires")z<-z&getv("cuestion_completo",w0)%in%1&getv("cuestion_completo",w1)%in%1
    a<-if(item=="s09")r0 else f0;b<-if(item=="s09")r1 else f1;z<-z&!is.na(a)&!is.na(b)
    for(event in c("same","increase","decrease")){ee<-if(event=="same")a==b else if(item=="s09"){if(event=="increase")a==2&b==1 else a==1&b==2}else{if(event=="increase")b>a else b<a};ee[is.na(ee)]<-FALSE;sensitivity[[length(sensitivity)+1]]<-data.frame(scope=scope,item=item,event=event,n=sum(z),n_event=sum(z&ee),proportion=if(sum(z))sum(z&ee)/sum(z)else NA)}
  }
  add(do.call(rbind,sensitivity),"quality_sensitivity",period)
}
for(name in names(all_tables))save_table(all_tables[[name]],name)
overlap<-counts<-list()
for(item in c("s09","s10","primary")) {
  mm<-sapply(membership,function(x)x[[item]])
  tb<-table(rowSums(mm));counts[[item]]<-data.frame(item=item,n_intervals=as.integer(names(tb)),n_people=as.integer(tb))
  for(a in colnames(mm))for(b in colnames(mm))overlap[[length(overlap)+1]]<-data.frame(item=item,interval_a=a,interval_b=b,n_same_people=sum(mm[,a]&mm[,b]))
}
save_table(do.call(rbind,overlap),"person_overlap");save_table(do.call(rbind,counts),"person_contributions")
comparison<-list()
for(period in pairs$interval)for(g in c("All","M1","M2")) {
  fl<-all_tables$sample_flow;fl<-fl[fl$interval==period&fl$sample==g,];n_at<-function(stage)fl$n[fl$stage==stage]
  du<-all_tables$durations;du<-du[du$interval==period&du$sample==g&du$domain=="primary_links",]
  ch<-all_tables$change_summary_unweighted;ch<-ch[ch$interval==period&ch$group==g,]
  val<-function(it,ev)ch$estimate[ch$item==it&ch$event==ev]
  ma<-all_tables$transition_matrices_unweighted;ma<-ma[ma$interval==period&ma$group==g&ma$item=="s09",]
  ne<-all_tables$paired_regular_share_change;ne<-ne[ne$interval==period&ne$group==g,]
  comparison[[length(comparison)+1]]<-data.frame(interval=period,sample=g,n_baseline=n_at("origin_age18_65"),n_reinterviewed=n_at("reinterviewed"),n_primary=n_at("primary_links"),n_s09=n_at("s09_classifiable_pairs"),n_s10=n_at("s10_classifiable_pairs"),median_years=du$median,min_years=du$min,max_years=du$max,s09_same=val("s09","same"),regular_stay=ma$estimate[ma$from==1&ma$to==1],nonregular_stay=ma$estimate[ma$from==2&ma$to==2],regular_net_pp=100*ne$difference,regular_net_lower_pp=100*ne$lower,regular_net_upper_pp=100*ne$upper,s10_same=val("s10","same"),s10_increase=val("s10","increase"),s10_decrease=val("s10","decrease"))
}
save_table(do.call(rbind,comparison),"interval_comparison")
stopifnot(identical(old_hash,tools::md5sum(old_files)))
save_table(data.frame(check=c("unique_longitudinal_ids","valid_codes_all_waves","s10_no_valid_for_nonregular","matrix_rows_sum_one","last_pair_counts_match","existing_tables_unchanged","no_pooled_independence_assumption"),passed=TRUE),"validation")
capture.output(utils::sessionInfo(),file=file.path(out,"session_info.txt"))
message(sprintf("Two new intervals computed; 2021-2023 estimates reused. Elapsed %.2f minutes.",as.numeric(difftime(Sys.time(),.t0,units="mins"))))
