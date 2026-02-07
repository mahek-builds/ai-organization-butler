🧹 Organization Butler

From Room Image → Smart Organization Plan

Organization Butler is an AI-powered assistant that analyzes a room image, detects clutter, calculates a messiness score, and generates an actionable organization plan — all through a conversational interface.

🚀 Hero Feature

Upload a single room photo, and get:

📦 Detected objects (clothes, books, cables, furniture, etc.)

📊 Messiness / clutter score (0–100)

🧠 Room state classification (Clean → Very Messy)

✅ Step-by-step organization plan

🏗️ System Architecture
Flutter App
   ↓
Serverpod Backend
   ↓
ML Inference Service
   ↓
Analysis + Plan Generation
   ↓
Flutter Assistant UI

👥 Team & Work Division
Team Members
Name	Role	Expertise
Mahek	ML Engineer	Object Detection, Clutter Scoring
Hirdesh	ML Engineer	Model Training, Evaluation
Lakshya	Flutter + Backend	Serverpod APIs, Integration
Dhruv	Flutter + Backend	Assistant UI, Backend Logic
🧠 Machine Learning Module
📌 Responsibilities

Room image analysis

Object detection

Clutter scoring logic

📂 Dataset & Annotation

Room types:

Bedroom

Study room

Living room

Annotated objects:

Clothes

Books

Cables / Chargers

Bottles

Furniture (bed, table, chair)

Tools used:

LabelImg / Roboflow

Dataset split:

Training

Validation

🤖 Object Detection Model

YOLOv5 (primary – high accuracy)

MobileNet-SSD (optional lightweight alternative)

Evaluation Metrics

Precision

Recall

mAP (Mean Average Precision)

Exported Formats

.pt

.onnx

📊 Clutter / Messiness Scoring
Scoring Logic

Messiness score is calculated using:

Number of detected objects

Object type weights
(clothes > books > cables > furniture)

Object spread and overlap

Room Classification
Score Range	Room State
0–25	Clean
26–50	Slightly Messy
51–75	Messy
76–100	Very Messy
ML Output (JSON)
{
  "objects": ["clothes", "books", "cables"],
  "messiness_score": 78,
  "room_state": "Messy"
}

🧩 Backend (Serverpod)
🔧 Responsibilities

Image upload handling

ML inference integration

Organization plan generation

Data persistence

🔌 API Endpoints
POST /analyzeRoom

Accepts room image

Sends image to ML service

Receives detected objects & clutter score

POST /generatePlan

Converts ML output into structured organization steps

GET /healthCheck

Backend health monitoring

🗄️ Database

PostgreSQL (via Serverpod)

Stores:

Analysis results

User sessions (optional)

💬 Assistant Interface (Flutter)
Features

Chat-style AI assistant

Image upload inside conversation

Visual display of:

Detected objects

Messiness score

Organization steps

Experience Goals

Friendly & helpful tone

Clear step-by-step guidance

Optional follow-up prompts

🔁 End-to-End Workflow

User uploads room image

Image sent to Serverpod backend

Backend calls ML inference service

ML returns objects + messiness score

Backend generates organization plan

Flutter app displays results conversationally

📦 Deliverables
ML Team

Trained object detection model

Clutter scoring logic

Inference script

ML documentation

Backend

Serverpod backend project

API endpoints

Database models

ML integration layer

Frontend

Flutter assistant UI

Image-based conversation flow

Backend integration

🎯 Key Outcome

A single room photo transforms into:

Object detection insights

Messiness score

Actionable organization plan

This creates a high-impact, scalable AI feature suitable for real-world use.

📜 License

This project is licensed under the MIT License.
