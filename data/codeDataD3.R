library(tidyr) # spread
library(dplyr) # mutate_each
library(reshape2) # melt

## Read in data 
dat = read.csv('allannual.csv', header=TRUE, stringsAsFactors = F)

# Basic processing 
dat$SuperSector = formatC(dat$SuperSector, width = 2, flag = 0)
dat$Industry = formatC(dat$Industry, width = 7, flag = 0)

## Create CSV file with employment by sector (as % of total: 1940-2016) ####
industries = c("0000000",
               "10000000", 
               "20000000",
               "31000000",
               "32000000" ,
               "40000000",
               '50000000',
               "55000000",
               "60000000", 
               "65000000",
               "70000000",
               "80000000",
               "90000000")

df = dat[ dat$Industry %in% industries,]

df = subset(df, select = c('Year', 'SuperSector', 'Value'))

df$SuperSector = paste0('X', df$SuperSector)

df = spread(df, SuperSector, Value)

df$Total <- df$X00
df <- df %>% mutate_each(funs((./Total)*100), starts_with("X"))
df <- df[,c(1, 3:(ncol(df)-1))]
df = melt(df, id.vars = 'Year')
colnames(df) = c('Year', 'Sector', 'Value')
df$Sector = gsub('X', '', df$Sector)

sectors = read.table('backup/ce.supersector.tsv', sep = '\t', header = T, row.names = NULL)
sectors = sectors[,c(1:2)]
colnames(sectors) = c('Sector', 'SectorName')
df = merge(df, sectors, by.df = 'Sector', sectors = 'Sector'); rm(sectors)
df = subset(df, select = c('SectorName',
                             'Year',
                             'Value'))
colnames(df)[1] = 'Sector'

df = df[df$Year %in% c(1940, 1960, 1980, 2000, 2016), ]

sectorsOrder = c('Education and health services', 'Professional and business services',
                 'Leisure and hospitality', 'Government',
                 'Other services', 'Financial activities',
                 'Construction', 'Information',
                 'Mining and logging', 'Trade, transportation, and utilities',
                 'Nondurable Goods', 'Durable Goods')

df = df[order(match(df$Sector, sectorsOrder)),]

write.csv(df, 'employmentbySector.csv', row.names = F)

## Create CSV file with employment for top sectors
df = dat[dat$Year >= 1990,]

industries = c("70722000",
               "65621000", 
               "65624000",
               "60561300" ,
               "65610000",
               '60541500',
               "65622000",
               "65623000")
               # "60541600",
               # "60561700",
               # "70713000",
               # "60541300")

df = df[ df$Industry %in% industries,]

df = subset(df, select = c('IndustryName',
                             'Year',
                             'Value'))

colnames(df) = c('Industry', 'Year', 'Value')

df$Value = df$Value/1000

df$Industry = gsub('Computer systems design and related services',
                    'Computer systems design',
                    df$Industry)

df$Industry = gsub('Nursing and residential care facilities',
                    'Nursing and residential care',
                    df$Industry)

df$Industry = gsub('Food services and drinking places',
                    'Food services and drinking',
                    df$Industry)

df$Industry = gsub('Ambulatory health care services',
                    'Ambulatory health care',
                    df$Industry)

sectorsOrder = c('Food services and drinking', 'Ambulatory health care', 'Social assistance',
                 'Employment services', 'Educational services', 'Computer systems design', 
                 'Hospitals', 'Nursing and residential care')

df = df[order(match(df$Industry, sectorsOrder)),]

write.csv(df, 'employmentbySectorgrowth.csv', row.names = F)
