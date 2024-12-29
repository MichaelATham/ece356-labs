from sklearn.tree import DecisionTreeClassifier, plot_tree
from sklearn.model_selection import cross_val_score
from sklearn.metrics import confusion_matrix
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('taskA.csv')

#Randomizing and shuffling the datapoints in the csv
df_shuffled = df.sample(frac=1, random_state=42)

X = df_shuffled.drop(['playerID', 'class'], axis=1)  
y = df_shuffled['class'] #class Data

#Transform data into trainning and data set
split_ratio = 0.8 # 80% Trainning vs 20% Testing
split_index = int(len(X) * split_ratio) 
X_train, X_test = X[:split_index], X[split_index:]
y_train, y_true = y[:split_index], y[split_index:]

#Init the tree
clf = DecisionTreeClassifier(max_depth=6, class_weight={0: 1, 1: 1.75}, min_samples_leaf=21)

#Cross validation used for extra metrics to check feature data while tuning the lab model
k = 5
cv_scores = cross_val_score(clf, X, y, cv=k)
print(f"CV scores per fold: {cv_scores}")
print(f"CV Average scores per fold: {cv_scores.mean()}")

clf = clf.fit(X_train, y_train)
y_pred = clf.predict(X_test)

#Confusion matrix generation
confusionMatrix = confusion_matrix(y_true, y_pred)
TN, FP, FN, TP = confusionMatrix.ravel()

#Confusion matrix calcs
Accuracy = (TP + TN) / (TP + TN + FP + FN)
Precision = TP / (TP + FP)
Recall = TP / (TP + FN)
Specificity = TN / (TN + FP)

print(confusionMatrix)
print(f"Accuracy: {Accuracy}, Precision: {Precision}, Recall: {Recall}, Specificity: {Specificity}")

#Tree Gen Below:
plt.figure(figsize=(25, 10))
plot_tree(clf, filled=True, feature_names=X.columns, class_names=['Not Nominated', 'Nominated'], rounded=True, fontsize=4)

plt.savefig('taskATree.svg', format='svg', dpi=600, bbox_inches='tight')

