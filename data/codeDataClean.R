library(tidyr) # spread
library(dplyr) # mutate_each
library(reshape2) # melt

# https://download.bls.gov/pub/time.series/ce/
# 3/15/2017  8:31 AM    366936984 ce.data.0.AllCESSeries

# Data cleaning
dat = read.table('ce.data.0.AllCESSeries.tsv', sep="\t", header=TRUE)

# Field #/Data Element	Length		Value(Example)		
# 1. series_id          17		CEU0500000001
# 2. year               4		1988	
# 3. period             3		M01		
# 4. value              12      	103623	 	
# 5. footnote_codes     10		It varies
# The series_id (CEU0500000001) can be broken out into:
# survey abbreviation	=		CE
# seasonal (code) 	=		U
# industry_code		=		05000000
# data_type_code	=		01

## Extract annual data
dat = dat[dat$period == 'M13',]

# Break series_id into its component pieces 
dat$Survey = substring(dat$series_id, 0,2)
dat$Seasonal = substring(dat$series_id, 3,3)
dat$Industry = substring(dat$series_id, 4,11)
dat$SuperSector = substring(dat$Industry, 0,2)
dat$Data = substring(dat$series_id, 12,13)

# Extract total employees only 
dat = dat[dat$Data == '01',]

# Add in super sector names 
sectors = read.table('../backup/ce.supersector.tsv', sep = '\t', quote = NULL, header = T, row.names = NULL)
sectors = sectors[,c(1:2)]
colnames(sectors) = c('SuperSector', 'SectorName')
dat = merge(dat, sectors, by.dat = 'Supersector', sectors = 'Supersector'); rm(sectors)

# Add in industry names 
industries = read.table('../backup/ce.industry.tsv', sep = '\t', quote = NULL, header = T, row.names = NULL)
industries = industries[,c(1,2, 4)]
colnames(industries) = c('Industry', 'NAICSCode', 'IndustryName')
dat = merge(dat, industries, by.dat = 'Industry', industries = 'Industry'); rm(industries)

# Subset smaller df 
dat = subset (dat, select = c('year',
                              'SuperSector',
                              'SectorName',
                              'Industry',
                              'IndustryName',
                              'NAICSCode',
                              'value'))

# Rename columns 
colnames(dat)[1] = 'Year'
colnames(dat)[7] = 'Value'

write.csv(dat, '../allannual.csv', row.names = F)
