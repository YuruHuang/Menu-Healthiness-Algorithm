import smogn
import pandas as pd
from sklearn.model_selection import train_test_split

# Define a function to build the file path, hiding the actual paths
def get_file_path(file_name, sub_folder=None):
    base_path = "your base directory"
    if sub_folder:
        return f"{base_path}{sub_folder}\\{file_name}"
    return f"{base_path}{file_name}"

# Load datasets
justeat = pd.read_csv(get_file_path('JustEat_extracted_220422.csv'))
ratings = pd.read_csv(get_file_path('ratings.csv'))

# Merge the hyginene rating column from 'ratings' into 'justeat'
justeat['hr'] = ratings.iloc[:, 1]

# Split the dataset into training and testing sets
train, test = train_test_split(justeat, test_size=0.1, random_state=27)
train = train.reset_index()

# Apply Synthetic Minority Over-sampling Technique (SMOTE)
train_smogn = smogn.smoter(
    data=train,
    y='predict',
    samp_method='balance',
    rel_method='auto'
)

# Save the processed datasets
train_smogn.to_csv(get_file_path('train_smogn.csv'))
test.to_csv(get_file_path('test.csv'))

# Create a DataFrame for merging ratings
ratings_for_merge = justeat[['url', 'hr']]

# Merge 'hr' into both training and testing sets
train_smogn_with_hr = train_smogn.merge(ratings_for_merge, how='left', on='url')
test_with_hr = test.merge(ratings_for_merge, how='left', on='url')

# Save the datasets after merging
train_smogn_with_hr.to_csv(get_file_path('train_smogn_whr.csv'))
test_with_hr.to_csv(get_file_path('test_smogn_whr.csv'))
