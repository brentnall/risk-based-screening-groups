#!/usr/bin/env python3
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
    
"""Class to keep data on risk-based screening problem

Reads and stores input / output data
"""

__version__ = '0.1'
__author__ = 'Adam Brentnall'

import configparser
import pandas as pd

class RiskData:
    
    """Invitation data"""

    def __init__(self, input_path='input/input.csv', config_path='config.ini'):
        self.input_file_path = input_path
        self.input_config_path = config_path
        self.load_data()

    def load_data(self): #Load the data for this run

        self.scenario = pd.read_csv(self.input_file_path)

        self.nRISKGROUPS = self.scenario.iloc[:,0].max()

        self.nRISKSTRAT =  self.scenario.iloc[:,1].max()

        self.config = configparser.ConfigParser()

        self.config.read(self.input_config_path)

        self.advcan_screen = float(self.config['node_positive_screen']['a'])

        self.advcan_interval = float(self.config['node_positive_interval']['b'])

        self.H = float(self.config['max_capacity']['H'])


    
