#Read in library
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from sklearn.metrics import confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.metrics import classification_report
from sklearn.feature_extraction.image import grid_to_graph
from sklearn import tree
from sklearn.externals.six import StringIO
from IPython.display import Image, display
import pydotplus


# Importing Dataset
file_name = 'Path\\telecom.csv' 
telecom_data = pd.read_table(file_name, sep= ',')

# Exploratory analysis:
telecom_data.shape
telecom_data.head()
telecom_data.dtypes
telecom_data.isna().sum()

# Convert the categorical data to numeric.
##Obtain the values to be converted
telecom_data.CUSTOMER_TYPE.unique()
telecom_data.GENDER.unique()
telecom_data.MARITAL_STATUS.unique()
telecom_data.OCCUP_CD.unique()
telecom_data.PAY_METD.unique()
telecom_data.TOP1_INT_CD.unique()
telecom_data.TOP2_INT_CD.unique()
telecom_data.TOP3_INT_CD.unique()

## Convert TOP1_INT_CD, TOP2_INT_CD, TOP3_INT_CD to numeric
### Replace "NONE" by np.NaN
telecom_data.TOP1_INT_CD.replace(['NONE'], [np.nan], inplace=True)
telecom_data.TOP2_INT_CD.replace(['NONE'], [np.nan], inplace=True)
telecom_data.TOP3_INT_CD.replace(['NONE'], [np.nan], inplace=True)

### Convert String to Numerical
telecom_data[["TOP1_INT_CD", "TOP2_INT_CD", "TOP3_INT_CD"]] = telecom_data[["TOP1_INT_CD", "TOP2_INT_CD", "TOP3_INT_CD"]].apply(pd.to_numeric)
telecom_data.TOP1_INT_CD.unique()
telecom_data.TOP2_INT_CD.unique()
telecom_data.TOP3_INT_CD.unique()

### Fill in missing values of numerical data with median values
telecom_data.isna().sum()
telecom_data.fillna(telecom_data.median(), inplace=True) 
telecom_data.isna().sum()

## Convert the remaining categorical columns to numeric
telecom_data.dtypes

# fill missing values of categorical variables with most frequent values
telecom_data.MARITAL_STATUS.fillna(telecom_data.MARITAL_STATUS.value_counts().index[0], inplace=True)    
telecom_data.GENDER.fillna(telecom_data.GENDER.value_counts().index[0], inplace=True)     
telecom_data.OCCUP_CD.fillna(telecom_data.OCCUP_CD.value_counts().index[0], inplace=True)     
telecom_data.PAY_METD.fillna(telecom_data.PAY_METD.value_counts().index[0], inplace=True)     
telecom_data.isna().sum()

### Copy the 5 remaining categorical columns into a new object and change the names
num_cols = pd.DataFrame(telecom_data[['CUSTOMER_TYPE','GENDER','MARITAL_STATUS',
                                       'OCCUP_CD','PAY_METD']])

num_cols.rename(columns={'CUSTOMER_TYPE':'CUSTOMER_TYPE2','GENDER':'GENDER2',
                         'MARITAL_STATUS':'MARITAL_STATUS2', 'OCCUP_CD':'OCCUP_CD2',
                         'PAY_METD':'PAY_METD2'}, inplace=True)


### Convert the values into numerical
num_cols['CUSTOMER_TYPE2'].replace(['4G', '3G'],[1,2], inplace=True)
num_cols['GENDER2'].replace(['F', 'M'],[1,2], inplace=True)
num_cols['MARITAL_STATUS2'].replace(['M', 'S'],[1,2], inplace=True)

num_cols['OCCUP_CD2'].replace(['OTH', 'STUD', 'MGR', 'EXEC', 'HWF', 'SELF', 'ENG', 'POL',
       'GOVT', 'CLRC', 'TCHR', 'FAC', 'SHOP', 'MED', 'AGT'],[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15], inplace=True)

num_cols['PAY_METD2'].replace(['cs', 'co', 'dd', 'cg', 'cx'],[1,2,3,4,5], inplace=True)

telecom_data2 = pd.concat([telecom_data, num_cols], axis=1)
telecom_data2.dtypes

## Drop redundant columns and recheck to ensure all the columns are now numeric with no missing values
data_clean=telecom_data2.drop(columns=['CUSTOMER_TYPE','GENDER','MARITAL_STATUS','OCCUP_CD','PAY_METD'])
data_clean.rename(columns={'CUSTOMER_TYPE2':'CUSTOMER_TYPE','GENDER2':'GENDER',
                         'MARITAL_STATUS2':'MARITAL_STATUS', 'OCCUP_CD2':'OCCUP_CD',
                         'PAY_METD2':'PAY_METD'}, inplace=True)

data_clean.shape
data_clean.isna().sum()
data_clean.dtypes


# Seperating the target variable
Y = data_clean['CUSTOMER_TYPE']
X = data_clean.drop(columns =['CUSTOMER_TYPE', 'Serial_Number'])

# Spliting the dataset into train and test
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size = 0.3, random_state = 100)

# Show the number of records as well as the frequency distribution 
## of Customer_Type in both datasets
X_train.shape
Y_train.shape
X_test.shape
Y_test.shape

Y_train.value_counts()

train_plot=Y_train.value_counts().plot(kind='bar')
plt.xlabel('Customer Type')
train_plot.set_xticklabels(['3G','4G'])
plt.ylabel('Frequency')
plt.title('Frequency Distribution of Customer Type in Training Data')

Y_test.value_counts()

test_plot=Y_test.value_counts().plot(kind='bar')
plt.xlabel('Customer Type')
test_plot.set_xticklabels(['3G','4G'])
plt.ylabel('Frequency')
plt.title('Frequency Distribution of Customer Type in Validation Data')

#Build a decision tree with 2-way splits, using Gini index as splitting criterion
# Maximum depth =3
#Creating the classifier object
clf_gini1 = tree.DecisionTreeClassifier(criterion = "gini",splitter="best",
random_state = 1234, max_depth=3, min_samples_leaf=5)

# Performing training
clf1=clf_gini1.fit(X_train, Y_train)

# Visualize the decision tree
col_names = list(X_train.columns.values)
dot_data = StringIO()
tree.export_graphviz(clf1, out_file=dot_data, feature_names=col_names, filled=True,rounded=True)
graph = pydotplus.graph_from_dot_data(dot_data.getvalue())
display(Image(graph.create_png()))

# Prediction on test with giniIndex
Y_pred = clf_gini1.predict(X_test)
print("Predicted values:")
print(Y_pred)

# Calculate accuracy
print("Confusion Matrix: ",
confusion_matrix(Y_test, Y_pred))

print ("Accuracy : ",
accuracy_score(Y_test,Y_pred)*100)

print("Report : ",
classification_report(Y_test, Y_pred))


# Maximum depth =2
#Creating the classifier object
clf_gini2 = tree.DecisionTreeClassifier(criterion = "gini",splitter="best",
random_state = 1234, max_depth=2, min_samples_leaf=5)

# Performing training
clf2=clf_gini2.fit(X_train, Y_train)

# Visualize the decision tree
col_names = list(X_train.columns.values)
dot_data2 = StringIO()
tree.export_graphviz(clf2, out_file=dot_data2, feature_names=col_names, filled=True,rounded=True)
graph = pydotplus.graph_from_dot_data(dot_data2.getvalue())
display(Image(graph.create_png()))

# Prediction on test with giniIndex
Y_pred = clf_gini2.predict(X_test)
print("Predicted values:")
print(Y_pred)

# Calculate accuracy
print("Confusion Matrix: ",
confusion_matrix(Y_test, Y_pred))

print ("Accuracy : ",
accuracy_score(Y_test,Y_pred)*100)

print("Report : ",
classification_report(Y_test, Y_pred))