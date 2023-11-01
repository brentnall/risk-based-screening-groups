#!/usr/bin/env python3
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
    
"""Script to determine 'optimal' risk-based screening strategies
Uses a linear program. This version loops over max capacity defined in the function (hard coded, not config file)
"""

__version__ = '0.1'
__author__ = 'Adam Brentnall'

from riskdata import RiskData
from risksolve import RiskSolve
import pandas as pd
import numpy as np

def runmodel(): # Run the model:

    # Load the data for this run:
    myrisk = RiskData()
 
    mysolve = RiskSolve(myrisk)

    if(mysolve.solved):
        mysolve.summary()
        mydf = mysolve.result
        mydf['h'] = np.repeat(myrisk.H, mysolve.nX)

        myHrange=range(105,400)

        mya2 = np.ndarray([len(myHrange)+1,2])
        mya2[0,:]=[myrisk.H,mysolve.sol['primal objective']]

        idx=0

        for idH in myHrange:

            idx+=1

            myrisk.H = idH 
            # Call the solver:
            mysolve = RiskSolve(myrisk)

            if(mysolve.solved):
                mysolve.summary()
                mydf2 = mysolve.result
                mydf2['h'] = np.repeat(idH, mysolve.nX)
                mydf = pd.concat([mydf, mydf2])
                mya2[idx,:] = [idH, mysolve.sol['primal objective']] 
            else:
                print("Could not solve")
	
    mydf.to_csv("out.csv") 
    pd.DataFrame(mya2).to_csv("out2.csv")


if __name__ == "__main__":
    runmodel()
