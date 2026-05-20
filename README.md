# 🛡️ Aegis-DLP: Zero-Trust LLM Security & Data Loss Prevention Middleware

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Status](https://img.shields.io/badge/status-Proof_of_Concept-success.svg)
![Swift](https://img.shields.io/badge/SwiftUI-15.0+-orange.svg)
![FastAPI](https://img.shields.io/badge/FastAPI-Python_3.10+-009688.svg)

## 📌 Overview
Aegis-DLP is an autonomous, agent-based middleware designed to secure Large Language Model (LLM) communications. It acts as a Zero-Trust bridge between enterprise users and external AI providers, actively sanitizing Personally Identifiable Information (PII) such as Credit Cards, Passwords, and National IDs (TCKN) before they leave the corporate network.

## 🚀 Key Features (Proof of Concept)
* **Real-Time PII Sanitization:** Intercepts outgoing prompts and replaces sensitive data with secure tokens (e.g., `<CREDIT_CARD>`) with zero latency.
* **De-anonymization Engine:** Seamlessly re-injects the original context into the LLM's response before presenting it back to the user, ensuring a frictionless user experience.
* **Dynamic Policy Management:** Administrators can toggle specific masking engines (e.g., disable TCKN masking while keeping Credit Card masking active) on the fly via the iOS Command Center.
* **Human-in-the-Loop Kriz Management:** Features an "Incident Review" dashboard where administrators can explicitly **APPROVE** or **BLOCK** flagged transactions.
* **🚨 Global Kill Switch (Circuit Breaker):** A single-tap emergency mechanism to completely halt all outgoing LLM traffic in the event of a severe breach.

## 🏗️ System Architecture
1. **iOS Dashboard (SwiftUI):** The administrative command center for monitoring logs, adjusting policies, and triggering the kill switch.
2. **Core API Gateway (FastAPI):** The central nervous system handling requests, routing, and database logging.
3. **NLP Sanitizer Agent:** The middleware logic responsible for Named Entity Recognition (NER) and token replacement.
4. **Mock LLM Service:** A simulated generative AI endpoint to demonstrate the end-to-end data flow without incurring external API costs.

## 💻 Tech Stack
* **Frontend:** iOS, Swift, SwiftUI, MVVM Architecture
* **Backend:** Python, FastAPI, Pydantic, Uvicorn
* **Database:** SQLite (SQLAlchemy ORM)

## ⚙️ How to Run
**1. Start the Backend API**
```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload