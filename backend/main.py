# ========================================== #
# 1. KÜTÜPHANELER VE MODÜLLER
# ========================================== #
import traceback
import uvicorn
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

# Yerel Servisler (Local Services)
from services.dlp_service import dlp_agent
from services.mock_llm import mock_llm
from database import SessionLocal, AuditLog

# ========================================== #
# 2. UYGULAMA KURULUMU VE GLOBAL AYARLAR
# ========================================== #
app = FastAPI(
    title="Aegis-DLP Core API",
    description="Autonomous Agent-Based Middleware for Data Loss Prevention (DLP)",
    version="1.0.0"
)

# Canlı kural durumlarını bellekte tutuyoruz (Mock Redis görevi görür)
CURRENT_POLICIES = {
    "credit_card": True,
    "password": True,
    "tckn": True
}

# ========================================== #
# 3. VERİTABANI BAĞLANTISI (DEPENDENCY)
# ========================================== #
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ========================================== #
# 4. VERİ MODELLERİ (PYDANTIC SCHEMAS)
# ========================================== #

# -- Chat İstek/Cevap Modelleri --
class PromptRequest(BaseModel):
    user_id: str = Field(..., description="Kullanıcı ID (Örn: emp_4521)")
    prompt: str = Field(..., description="LLM'e gönderilecek orijinal metin")

class PromptResponse(BaseModel):
    llm_response: str
    status: str

# -- Kural (Policy) Modelleri --
class PolicyUpdateRequest(BaseModel):
    credit_card: bool
    password: bool
    tckn: bool

# -- Aksiyon Modelleri (Kriz Yönetimi) --
class ActionRequest(BaseModel):
    action: str  # "APPROVED" veya "BLOCKED"

# ========================================== #
# 5. SİSTEM VE KURAL YÖNETİMİ (POLICIES)
# ========================================== #
@app.get("/")
def read_root():
    return {"status": "healthy", "service": "Aegis-DLP Backend"}

@app.get("/policies")
def get_policies():
    """iOS tarafının başlangıçta kuralları okuması için"""
    return CURRENT_POLICIES

@app.put("/policies")
def update_policies(payload: PolicyUpdateRequest):
    """iOS'tan gelen Toggle buton güncellemelerini yakalar"""
    global CURRENT_POLICIES
    CURRENT_POLICIES["credit_card"] = payload.credit_card
    CURRENT_POLICIES["password"] = payload.password
    CURRENT_POLICIES["tckn"] = payload.tckn
    
    print(f"⚙️ KURAL GÜNCELLENDİ: {CURRENT_POLICIES}")
    return {"status": "updated", "policies": CURRENT_POLICIES}

# ========================================== #
# 6. ANA MOTOR: METİN İŞLEME VE SANSÜR (CHAT)
# ========================================== #
@app.post("/chat", response_model=PromptResponse)
async def process_prompt(payload: PromptRequest, db: Session = Depends(get_db)):
    try:
        # 1. Aşama: DLP Motoru ile Metni Tarama ve Maskeleme
        analiz = dlp_agent.sanitize_text(payload.prompt)
        
        # 2. Aşama: Veritabanına Loglama (Orijinal ve Sansürlü Haliyle)
        yeni_log = AuditLog(
            user_id=payload.user_id,
            original_prompt=payload.prompt,
            sanitized_prompt=analiz["sanitized_text"],
            is_secure=analiz["is_secure"],
            detected_entities=",".join(analiz["detected_entities"])
        )
        db.add(yeni_log)
        db.commit()

        # 3. Aşama: Güvenli Metni Sahte LLM'e Gönderme
        llm_cevabi = await mock_llm.generate_response(analiz["sanitized_text"])

        # 4. Aşama: Gelen Cevabı De-anonymize Etme (Eski Haline Çevirme)
        final_cevap = dlp_agent.deanonymize_text(llm_cevabi, analiz["entity_mapping"])

        return PromptResponse(
            llm_response=final_cevap,
            status="Success: Processed, Logged and Re-identified"
        )
        
    except Exception as e:
        # Hata ayıklama (Traceback) için detaylı log
        print("\n" + "="*50)
        print("🚨 SİSTEM ÇÖKTÜ! İŞTE DETAYI:")
        traceback.print_exc()
        print("="*50 + "\n")
        raise HTTPException(status_code=500, detail=str(e))

# ========================================== #
# 7. iOS DASHBOARD VE KRİZ YÖNETİMİ UÇLARI
# ========================================== #
@app.get("/logs")
async def get_audit_logs(db: Session = Depends(get_db)):
    """Dashboard'da göstermek üzere en son 20 güvenlik logunu getirir."""
    logs = db.query(AuditLog).order_by(AuditLog.timestamp.desc()).limit(20).all()
    
    log_list = []
    for log in logs:
        log_list.append({
            "id": log.id,
            "timestamp": log.timestamp.strftime("%H:%M"),
            "user_id": log.user_id,
            "is_secure": log.is_secure,
            "detected_entities": log.detected_entities,
            "original_prompt": log.original_prompt,
            "sanitized_prompt": log.sanitized_prompt
        })
        
    return log_list

@app.put("/logs/{log_id}/action")
def update_log_action(log_id: int, payload: ActionRequest, db: Session = Depends(get_db)):
    """iOS Dashboard'dan gelen Onayla/Engelle komutlarını yakalar."""
    renk = "🟢" if payload.action == "APPROVED" else "🔴"
    aksiyon_metni = "İZİN VERİLDİ" if payload.action == "APPROVED" else "ENGELLENDİ"
    
    print("\n" + "="*50)
    print(f"{renk} KRİZ YÖNETİMİ: Log ID [{log_id}] için aksiyon alındı!")
    print(f"{renk} DURUM: {aksiyon_metni}")
    print("="*50 + "\n")
    
    return {"status": "success", "log_id": log_id, "action": payload.action}

# ========================================== #
# 8. SUNUCUYU BAŞLATMA
# ========================================== #
if __name__ == "__main__":
    uvicorn.run("main.py:app", host="127.0.0.1", port=8000, reload=True)