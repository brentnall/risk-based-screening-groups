#!/usr/bin/env python3
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
    
"""Script to determine 'optimal' risk-based screening strategies
Solves one instance given H in config file
Uses a linear program.

"""

__version__ = '0.1'
__author__ = 'Adam Brentnall'

from riskdata import RiskData
from risksolve import RiskSolve

def runmodel(): # Run the model:

    # Load the data for this run:
    myrisk = RiskData()

    # Call the solver:
    mysolve = RiskSolve(myrisk)

    if(mysolve.solved):
        mysolve.summary()
        mysolve.write_csv()
    else:
        print("Could not solve")
	



if __name__ == "__main__":
    runmodel()
