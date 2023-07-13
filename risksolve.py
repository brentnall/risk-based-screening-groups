#!/usr/bin/env python3
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
    
"""Class to solve screening allocation problem

Reads and stores input / output data
"""

__version__ = '0.1'
__author__ = 'Adam Brentnall'

import numpy as np
import pandas as pd
import configparser
from cvxopt import matrix, spmatrix, spdiag
from cvxopt import solvers
from datetime import date


class RiskSolve:
    
    """Risk-based screening problem to solve"""

    def __init__(self, input_riskdata):
        solvers.options['feastol']=1e-9
        # Risk setup data 
        self.riskdata = input_riskdata
        # Setup and run
        self._setup()
        # Print out summary
        #if(self.solved):
        #    self.summary() 
            ##self.summary_uptake()
        # Save
        #self.write_csv()

    def _setup(self):
        # constants
        self.nRISKGROUPS = self.riskdata.nRISKGROUPS
        self.nRISKSTRAT = self.riskdata.nRISKSTRAT
        self.nX = self.riskdata.scenario.shape[0]

        # input variables for the LP
        self.rij = self.riskdata.scenario.iloc[:,3].to_numpy().astype('float').reshape(1, self.nX)
       
        self.sij = self.riskdata.scenario.iloc[:,4].to_numpy().astype('float').reshape(1, self.nX)

        self.nij = self.riskdata.scenario.iloc[:,2].to_numpy().astype('float').reshape(1, self.nX)

        self.hij = self.riskdata.scenario.iloc[:,5].to_numpy().astype('float').reshape(1, self.nX)

        self.aij = self.riskdata.scenario.iloc[:,6].to_numpy().astype('float').reshape(1, self.nX)

        self.bij = self.riskdata.scenario.iloc[:,7].to_numpy().astype('float').reshape(1, self.nX)

        self.riskgroupidx = self.riskdata.scenario.iloc[:,0].to_numpy().astype('float').reshape(1, self.nX)
        
        self.riskstratidx = self.riskdata.scenario.iloc[:,1].to_numpy().astype('float').reshape(1, self.nX)
        
        ## bounds
        # max capacity
        self.bound_H = float(self.riskdata.H)

        self.soln = self.solve(self.rij, self.sij, self.nij, self.hij, self.aij, self.bij, self.bound_H, self.nX, self.nRISKGROUPS, self.nRISKSTRAT)
        


    def solve(self, my_r, my_s, my_n, my_h, my_a, my_b, my_boundH, nX, nRISKGROUPS, nRISKSTRAT):
        #set up and solve LP

        #xij < 1.0
        G1a = spmatrix(1.0, range(nX), range(nX))
        h1a = matrix(np.repeat(1,nX)) 
        # xij as real number more than 0
        G1b = spmatrix(-1.0, range(nX), range(nX))
        h1b = matrix(np.repeat(0.0,nX))

        #2. All No more than 100% patients in group invited
        G2 = spmatrix(1.0, range(nX), range(nX))
        h2 = matrix( (np.repeat(1.0,nX)).reshape(nX,1) )
        #print(np.array(G2))
        #print(np.array(h2))
        
        #3. total allocation is 1
        A3 = matrix( np.tile(np.identity(nRISKGROUPS), nRISKSTRAT))
        b3 = matrix(np.repeat(1.0, nRISKGROUPS))
        #print(np.array(A3))
        #print(b3)

        #4.constrain the resources
        G4 = matrix(my_n * my_h)
        h4 = matrix(my_boundH)
        #print(np.array(G4))
        #print(h4)
        
        ## objective
        mycost = matrix( (my_n * ( my_r * (my_s * my_a + (1 - my_s) * my_b) ) ).reshape(nX,1))
        print(np.array(mycost))
        
        ## set up complete LP
        A = matrix([A3])
        b = matrix([b3])

        #G = matrix([G1a, G1b, G2, G4 ])
        #h = matrix([h1a, h1b, h2, h4 ])
        G = matrix([G1a, G1b, G2, G4  ])
        h = matrix([h1a, h1b, h2, h4  ])
        #print(h)
        
        c = matrix(mycost)
        ## solve
        self.sol=solvers.lp(c,G,h,A,b,  solver='glpk')
        
        self.solved = (self.sol['status']=="optimal")

        self.__internals = {
            "A": A,
            "b": b,
            "G": G,
            "h": h,
            "c": c,
            "G1a": G1a,
            "G1b": G1b,
            "G2": G2,
            "A3": A3,
            "G4": G4,
            "h1a": h1a,
            "h1b": h1b,
            "h2": h2,
            "b3": b3,
            "h4": h4,
        }

        if(self.solved):
            self.xfit = self.sol['x']
        



    def summary(self):
        print("== algorithm summary stats==")
        print("expected adv cancer number/M %.2f" % float(100*self.sol['primal objective']))
        df=pd.DataFrame(self.riskgroupidx.reshape(self.nX, 1), columns=['riskgroupidx'])
        df['strategy'] =self.riskstratidx.reshape(self.nX, 1)
        df['num'] = np.round(np.array(self.xfit) * np.transpose(self.nij),0)
        df['perc']=np.round(np.array(self.xfit)*100,1)
        self.result = df
        print(df)
    
    def write_csv(self, outputfile='output.csv'):
        df=pd.DataFrame(self.riskgroupidx.reshape(self.nX, 1), columns=['riskgroupidx'])
        df['strategy'] =self.riskstratidx.reshape(self.nX, 1)
        df['num'] = np.round(np.array(self.xfit) * np.transpose(self.nij),0)
        df.to_csv(outputfile, index=False)
   
