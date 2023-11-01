# risk-based-screening-groups

Code and data used in the paper `An optimization framework to guide choice of thresholds for risk-based cancer screening' by Adam R Brentnall, Emma C Atakpa, Harry Hill, Ruggiero Santeramo, Celeste Damiani, Jack Cuzick, Giovanni Montana, Stephen W Duffy. The repository enables reproduction of the analysis done in the paper.

The files are organised in two directories

1. `algorithm`: python code to solve the optimisation problem, with input as described for the application in the paper.
1. `paper-analysis`: R code and data files output from the algorithm, that enable the figures in the paper.
 
## Algorithm overview 

The main routines are:

- **riskproto.py**: python code to optimise risk groups given constraints in `config.ini`, and input csv file (default is `input/input.csv`)
- **riskproto-iterH.py**: python code to optimise risk groups by looping over different values of the constraint (hard coded), given input file

The `input` sub-directory contains csv files for the scenarios considered in the paper. 

## Analysis R code overview

The R script `reprod-eval.R` may be used to reproduce the charts presented in the paper. These scripts use data in the sub-directory `data` and output to the sub-directory `figures`.

The `data` sub-directory includes several csv files with the prefix `output`. These were obtained by running the algorithm using input files in `algorithm`. It also includes the data from Supplementary Table 1 (`mirai-centiles.csv`), and data underlying Figure 1 (`histo.csv`).
 
# License

GNU GPL v3

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


Copyright 2023, Adam Brentnall

