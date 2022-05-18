
from sklearn.metrics import classification_report, accuracy_score, confusion_matrix
from xgboost.sklearn import XGBClassifier

from typing import Dict, Tuple, Optional, List
import logging

import mlflow
import mlflow.exceptions
from mlflow.models import infer_signature
from mlflow.models.model import ModelInfo
from mlflow.entities.model_registry import ModelVersion

logger = logging.getLogger(__name__)
mlflow.set_tracking_uri('http://ec2-18-221-225-181.us-east-2.compute.amazonaws.com:5000')


class MlFlowService:
    def __init__(self):
        self._s3_bucket = None
        self._tracking_uri = None

    def log_sklearn_model(
            self,
            model: XGBClassifier,
            artifact_path,
            X_train,
            y_test,
            predictions,
            df_shape: Tuple,
    ) -> Optional[ModelVersion]:
        logger.info("Logging sklearn model to MLFlow")
        MlFlowService.log_model_metrics(X_train, y_test, predictions, df_shape)
        model_signature = infer_signature(X_train, predictions)

        model_info = mlflow.sklearn.log_model(
            model,
            artifact_path,
            signature=model_signature,
            input_example=X_train[:5]
        )

        logger.info("Finished logging model to MlFlow")
        return None

    @staticmethod
    def log_model_metrics(X_train, y_test, predictions, df_shape):
        cm = confusion_matrix(y_test, predictions)
        cr = classification_report(y_test, predictions)
        acc = accuracy_score(y_test, predictions)

        logger.info(f'Confusion Matrix\n {cm}')
        logger.info(f'Classification Report\n {cr}')
        logger.info(f'Accuracy_score: {acc}')

        # why did I do this as a one liner...
        classification_matrix_metrics = {
            f'CM {i} {"Correct" if i == list(x).index(y) else f"Incorrectly Classified as {list(x).index(y)}"}': y
            for i, x in enumerate(cm) for y in x}

        metrics = {
            'DF Shape X': df_shape[1],
            'DF Shape Y': df_shape[0],
            'Train Data Shape X': X_train.shape[1],
            'Train Data Shape Y': X_train.shape[0],
            'Accuracy': acc
        }
        metrics.update(classification_matrix_metrics)
        logger.info(f"Generated metrics: {metrics}")
        MlFlowService.log_metrics_to_current_experiment(metrics)
        logger.info('Logged metrics to MlFlow')

    @staticmethod
    def log_metrics_to_current_experiment(metrics: Dict):
        mlflow.log_metrics(metrics)

    @staticmethod
    def set_tags(tags: Dict):
        logger.info(f'Setting MlFlow Tags: {tags}')
        for k, v in tags.items():
            mlflow.set_tag(k, str(v))

    @staticmethod
    def load_model_from_source(source_path):
        return mlflow.sklearn.load_model(model_uri=source_path)

    @staticmethod
    def get_model_feature_names(model: XGBClassifier):
        return model.get_booster().feature_names
