#!/usr/bin/env python3

import pmlb
import pandas as pd

data = pmlb.fetch_data('yeast')
data.to_csv('yeast.csv')
