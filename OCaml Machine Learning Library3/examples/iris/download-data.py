#!/usr/bin/env python3

import pmlb
import pandas as pd

data = pmlb.fetch_data('iris')
data.to_csv('iris.csv')
