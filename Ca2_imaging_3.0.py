# -*- coding: utf-8 -*-
"""
Created on Wed Feb  5 15:13:34 2025

@author: yuhao
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Feb  4 13:49:28 2025

@author: yuhaohan
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Feb  4 10:07:49 2025

@author: yuhaohan
"""

import os
import pandas as pd
import numpy as np
from scipy.signal import find_peaks
import matplotlib.pyplot as plt
from statsmodels.nonparametric.smoothers_lowess import lowess

### USER INPUT

input_path = r"C:\Users\yuhao.I5G2SFFMIKA-134\Desktop\test_nat"  # Set input path
os.chdir(input_path)  # Change to the specified directory
x = 20  # Pixel size or time interval
key_word = "RawIntDen"  # Value being extracted from CSV file
window_size = 0.5  # Window size for smoothing from 0-1 (e.g. use 10% of total data point for smoothing)
threshold = 0.2 # to threshold peak detection. By defult it is 0.2 time higher than detected baseline
min_peak_distance = 5  # Minimum distance between peaks

## End of user input

# Define a function to smooth curve and find peaks using LOWESS baseline
def smooth_and_find_peaks_with_lowess(peaks):
    if len(peaks) == 0:
        raise ValueError("Error: Input data is empty, cannot process.")

    # Normalize the peak data
    peak_normalised = peaks / peaks.max()

    # Apply LOWESS to smooth the data (baseline)
    smoothed_baseline = lowess(peak_normalised, np.arange(len(peak_normalised)), frac = window_size, return_sorted=False)

    # Subtract baseline from the original data to get the residuals (peaks)
    peak_residuals = peak_normalised - smoothed_baseline

    if peak_residuals.max() == 0:
        raise ValueError("Error: All values in peak_residuals are zero. No peaks can be detected.")

    # Set peak detection threshold as 1.2 times the smoothed baseline
    peak_threshold = threshold * smoothed_baseline

    # Find peaks where the residuals are greater than the threshold
    indices, properties = find_peaks(peak_residuals, height=peak_threshold, distance=min_peak_distance)
    peak_values = properties["peak_heights"]

    # Plot the original and baseline-corrected data
    plt.plot(peak_normalised, label="Original Data")
    plt.plot(smoothed_baseline, label="Baseline (LOWESS)", linestyle='--')
    plt.plot(peak_residuals, label="Peak Residuals", linestyle='-.')
    plt.xlabel("Index")
    plt.ylabel("Normalized Intensity")
    plt.title("Peak Detection with LOWESS Baseline")

    for i in range(len(indices)):
        plt.annotate(
            "",
            (indices[i], peak_values[i]),
            textcoords="offset points",
            xytext=(0, 10),
            arrowprops=dict(facecolor="red", edgecolor="none", shrink=0.01),
        )

    plt.legend()
    plt.show()

    return indices.tolist()

# Example usage:
# peaks = np.random.random(100)  # Replace this with your actual peak data
# indices = smooth_and_find_peaks_with_lowess(peaks)


# Loop through each CSV file in the directory
all_profiles = {}  # Store profiles for all files
results_all_files = {}  # Store analysis results for all files

for file in os.listdir(input_path):
    if file.endswith(".csv"):
        df = pd.read_csv(file)

        # Reset individual dictionaries for each file
        individual_profiles = {}
        results_individual_profile = {}

        # Ensure key_word exists in column names
        matched_columns = [col for col in df.columns if key_word in col]
        if not matched_columns:
            print(f"Warning: No columns found containing '{key_word}' in {file}. Skipping.")
            continue

        for col_name in matched_columns:
            curve_value = df[col_name].dropna().values  # Remove NaNs and get values

            if len(curve_value) == 0:
                print(f"Warning: Column '{col_name}' in {file} is empty. Skipping.")
                continue

            curve_length = len(curve_value) * x  # Convert based on pixel size/time interval
            individual_profiles[col_name] = curve_value.tolist()

            # Find peaks
            try:
                peak_list = smooth_and_find_peaks_with_lowess(curve_value)
                number_of_peaks = len(peak_list)
                peak_freq = number_of_peaks / curve_length if curve_length > 0 else 0
            except ValueError as e:
                print(f"Skipping column '{col_name}' in {file} due to error: {e}")
                continue

            # Store individual profile results
            results_individual_profile[col_name] = {
                "number of peaks": number_of_peaks,
                "profile length": curve_length,
                "peak frequency": peak_freq,
            }

        all_profiles[file] = individual_profiles
        results_all_files[file] = results_individual_profile

# Save results to an Excel file
output_file = "peak_analysis_results.xlsx"

with pd.ExcelWriter(output_file, engine="openpyxl") as writer:
    for file, results in results_all_files.items():
        df_results = pd.DataFrame.from_dict(results, orient="index")
        df_results.to_excel(writer, sheet_name=os.path.splitext(file)[0][:31])  # Sheet name limit: 31 characters

print(f"\nResults saved to {output_file}")