# VisionMate AI Models

To enable the AI features of VisionMate, you must download the following model files and place them in the `assets/models/` directory.

## Required Files

1.  **YOLOv8n TFLite Model** (`yolo_nano.tflite`)
    *   **Description**: Used for real-time object detection (obstacles, people, vehicles).
    *   **Download**: [Link to Official YOLOv8n TFLite](https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n_float32.tflite)
    *   **Action**: Rename the downloaded file to `yolo_nano.tflite` and place it in `mobile_app/assets/models/`.

2.  **MobileFaceNet ONNX Model** (`mobilefacenet.onnx`)
    *   **Description**: Used for extracting 128D face embeddings for face recognition.
    *   **Download**: [Link to MobileFaceNet ONNX](https://github.com/onnx/models/raw/main/vision/body_analysis/arcface/model/arcfaceresnet100-8.onnx) (or similar 128D extraction model)
    *   **Action**: Rename the downloaded file to `mobilefacenet.onnx` and place it in `mobile_app/assets/models/`.

## Directory Structure
visionmate/
  mobile_app/
    assets/
      models/
        yolo_nano.tflite
        mobilefacenet.onnx

> **Note**: The app comes with placeholder text files to ensure the directory structure exists. You must replace them with the real binary model files for the app to function correctly.
