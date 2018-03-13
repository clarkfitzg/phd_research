# Clark: Got this code from R.P., see email 
# Mon Mar 12 15:11:26 PDT 2018
# Run this to see what's actually happening:
#
# grep "OP:" read_table_example.R
#
# Genomics Pipeline Code

# This is a script to pull in a bunch of genotype data for about 300 individuals
# Essentially the raw data file is a set of loci (rows) for each base pair or marker (G, T, C, A), which have an associated genotype (columns) for each individual (AA, TT, etc). The file includes a genotype for each individual, and 3 probabilities associated with that genotype. To work with the file, I want to grab only the genotypes for each individual, and convert the file from wide to long. Then do some filtering and grouping to genotypes that are fixed for a given species (species specific markers). Then I can use these to assess hybridization.


# Load Packages -----------------------------------------------------------

suppressPackageStartupMessages({
  library(tidyverse);
  library(fst)
})


# READ AND FORMAT ---------------------------------------------------------

#startT <- Sys.time()
# OP: read text file 1 (large)
dat <- read_tsv(file = here("data_output/angsd/rana_snps_25k_thresh_v3.geno.gz"), col_names = FALSE)
# OP: Rename columns using literals
colnames(dat)[1:4] <- c("chromo","position", "major","minor") # add col names
#set up seq of numbers for cols of interest (genotypes):

# CLARK: We should be able to evaluate `seq()` with literal arguments
# below. More generally function results are either known, derived from the
# data, or random. One could imagine annotating everything in the AST with
# one of these tags.

geno_cols <- seq(5,1140, 4)
# subset to these cols:
# OP: Select subset of columns
dat_geno <- dat[,c(1:4, geno_cols)]
# append spp info to cols
# OP: Rename columns using current names
colnames(dat_geno)[5:146] <- paste0("rabo_", colnames(dat_geno)[5:146])
colnames(dat_geno)[147:286] <- paste0("rasi_", colnames(dat_geno)[147:286])
colnames(dat_geno)[287:288] <- paste0("hybrid_", colnames(dat_geno)[287:288])
endT <- Sys.time()
#endT-startT


# WRITE OUT AS FST FORMAT -------------------------------------------------

# write back out to fst for faster read:
# OP: save intermediate result
write.fst(dat_geno, here("data_output/angsd/rana_snps_25k_thresh_v3.fst"), compress = 50)


# READ IN AS FST ----------------------------------------------------------

suppressPackageStartupMessages({
  library(tidyverse);
  library(fst)
})

# read in data
#startT <- Sys.time()
# OP: load intermediate result (unnecessary if whole script executes)
dat_geno <- read.fst(path = here( "data_output/angsd/rana_snps_25k_thresh_v3.fst"))
#endT <- Sys.time()
#endT-startT



# ADD METADATA ------------------------------------------------------------

# read in the metadata:
# OP: Read text file 2
# OP: Sort based on column
# OP: Select columns 
metadat<- read_csv(here("data_output/rapture06_metadata_revised.csv")) %>% arrange(Seq) %>% 
  select(Seq, PlateID:SPP_pc1,lat:lon,Locality)

# read in clst file:
# OP: Read text file 3
clst <- read.table(file = here("data_output/bamlists/bamlist_mrg_rana_snps_25k_clst"), stringsAsFactors = F, header = TRUE)

# join 
# OP: Join text files 2 and 3
# OP: Rename column using literal
annot <- inner_join(clst, metadat, by=c("IID"="SampleID")) %>% 
  rename(SampleID = IID)# end up with 289

# duplicates: RAP601, SM020, SM061, SM113
# OP: Drop rows using integer literal
annot <- annot[-c(14, 31, 269, 257, 282),]

# refactor
# OP: Convert column to factor type
annot$SampleID <- factor(annot$SampleID)



# DATA GROUPING/FILTERING -------------------------------------------------

# make long
# OP: Convert table 1 from wide to long - Most subtle part
# OP: Rename columns
dat_geno2 <- gather(dat_geno, key = sample, value = geno, rabo_X5:hybrid_X1137) %>% 
  mutate(chromo_pos =  paste0(chromo, "_", position), # combine chromo_pos
         spp = substr(sample, 1, 4)) # add spp col

# group by geno
# OP: Group by columns and count
tst1 <- dat_geno2 %>% 
  group_by(chromo_pos, spp, geno) %>%
  tally() %>% 
# OP: Filter based on row expression
  filter(!geno=="NN") %>%
  add_count(spp) 

# OP: rm() variable to free memory. Could be done earlier.
rm(dat_geno) # to save room



# GET SPECIES SPECIFIC MARKERS --------------------------------------------

# filter to greater than 20 individuals, and one geno per marker  
# OP: Drop rows using expression
tst2 <- tst1 %>% filter(n > 20, nn==1) %>%  # this is a start
# OP: Group by columns and count
  group_by(chromo_pos) %>% 
# OP: Filter based on row expression
  filter(n() > 1) # make sure there's more than one genotype per marker (so one for each species)

# OP: Peek at data, exploratory analysis
head(tst2)

# make a list of markers
# OP: Select distinct rows
markers <- tst2 %>% distinct(chromo_pos)

# make new set w/ hybrids
# OP: Filter based on row expression
tst1_hyb <- dat_geno2 %>% filter(chromo_pos %in% markers$chromo_pos) %>% 
# OP: Group by columns and count
  group_by(chromo_pos, spp, geno) %>% 
  tally() %>%
# OP: Filter based on row expression
  filter(!geno=="NN") 

# filter to markers that work for hybrids too (so exist across all three spp categories)
# OP: Rename columns
markers2 <- tst1_hyb %>% rename(n_ind=n) %>% 
# OP: Group by columns and count
  group_by(chromo_pos) %>% 
  tally() %>% 
# OP: Filter based on row expression
  filter(n>2) #%>% select(-n) %>% 

# OP: Peek at data, exploratory analysis
markers2 %>% distinct(chromo_pos) %>% dim # 724 snps!

# join back:
# OP: Filter based on row expression
markers20 <- filter(tst1_hyb, chromo_pos %in% markers2$chromo_pos) %>% 
# OP: Group by columns and count
# OP: Rename columns
  group_by(chromo_pos, geno) %>% rename(n_inds=n) %>% 
# OP: Filter based on row expression
# OP: Select columns 
  tally() %>% filter(n==1) %>% select(-n) %>% 
# OP: Join
  inner_join(., tst1_hyb, by=c("chromo_pos","geno"))

# final filter to remove markers that don't exist for all 3 spp
# OP: Group by columns and count
# OP: Filter based on row expression
markers20 <- markers20 %>% group_by(chromo_pos) %>% 
  filter(n() > 1)

# total snps:
# OP: Peek at data, exploratory analysis
markers20 %>% distinct(chromo_pos) %>% dim


# PLOTS -------------------------------------------------------------------

ggplot() + geom_point(data=markers20[c(1:90),], aes(y=chromo_pos, x=geno, color=spp, shape=spp), alpha=0.9, size=3) + theme_classic(base_family = "Roboto Condensed") +
  theme(axis.text.y = element_text(size=6)) +
  labs(caption="Rows 1:90")

ggplot() + geom_point(data=markers20[c(91:180),], aes(y=chromo_pos, x=geno, color=spp, shape=spp), alpha=0.9, size=3) + theme_classic(base_family = "Roboto Condensed") +
  theme(axis.text.y = element_text(size=6)) +
  labs(caption="Rows 91:180")

ggplot() + geom_point(data=markers20[c(181:420),], aes(y=chromo_pos, x=geno, color=spp, shape=spp), alpha=0.9, size=3) + theme_classic(base_family = "Roboto Condensed") +
  theme(axis.text.y = element_text(size=6)) +
  labs(caption="Rows 181:420")

ggplot() + geom_point(data=markers20[c(181:420),], aes(y=chromo_pos, x=geno, color=spp, shape=spp), alpha=0.9, size=3) + theme_classic(base_family = "Roboto Condensed") +
  theme(axis.text.y = element_text(size=6)) +
  labs(caption="Rows 421:640")

