from fastapi import Depends, FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import func
from sqlalchemy.orm import Session
from .database import Base, engine, get_db
from .models import Ocorrencia
from .schemas import CATEGORIAS, STATUS, OcorrenciaCreate, OcorrenciaResponse, OcorrenciaStatusUpdate

Base.metadata.create_all(bind=engine)
app = FastAPI(title="EcoUrbano API", version="0.1.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

@app.get("/")
def inicio():
    return {"mensagem": "EcoUrbano API em funcionamento"}

@app.post("/ocorrencias", response_model=OcorrenciaResponse, status_code=201)
def criar_ocorrencia(dados: OcorrenciaCreate, db: Session = Depends(get_db)):
    if dados.categoria not in CATEGORIAS:
        raise HTTPException(422, "Categoria inválida.")
    item = Ocorrencia(**dados.model_dump())
    db.add(item)
    db.commit()
    db.refresh(item)
    return item

@app.get("/ocorrencias", response_model=list[OcorrenciaResponse])
def listar_ocorrencias(categoria: str | None = Query(None), status: str | None = Query(None), db: Session = Depends(get_db)):
    consulta = db.query(Ocorrencia)
    if categoria:
        if categoria not in CATEGORIAS:
            raise HTTPException(422, "Categoria inválida.")
        consulta = consulta.filter(Ocorrencia.categoria == categoria)
    if status:
        if status not in STATUS:
            raise HTTPException(422, "Status inválido.")
        consulta = consulta.filter(Ocorrencia.status == status)
    return consulta.order_by(Ocorrencia.criada_em.desc()).all()

@app.get("/ocorrencias/{ocorrencia_id}", response_model=OcorrenciaResponse)
def obter_ocorrencia(ocorrencia_id: int, db: Session = Depends(get_db)):
    item = db.get(Ocorrencia, ocorrencia_id)
    if not item:
        
        raise HTTPException(404, "Ocorrência não encontrada.")
    return item

@app.patch("/ocorrencias/{ocorrencia_id}/status", response_model=OcorrenciaResponse)
def atualizar_status(ocorrencia_id: int, dados: OcorrenciaStatusUpdate, db: Session = Depends(get_db)):
    if dados.status not in STATUS:
        raise HTTPException(422, "Status inválido.")
    item = db.get(Ocorrencia, ocorrencia_id)
    if not item:
        raise HTTPException(404, "Ocorrência não encontrada.")
    item.status = dados.status
    db.commit()
    db.refresh(item)
    return item

@app.get("/indicadores")
def indicadores(db: Session = Depends(get_db)):
    total = db.query(func.count(Ocorrencia.id)).scalar() or 0
    status = dict(db.query(Ocorrencia.status, func.count(Ocorrencia.id)).group_by(Ocorrencia.status).all())
    categorias = dict(db.query(Ocorrencia.categoria, func.count(Ocorrencia.id)).group_by(Ocorrencia.categoria).all())
    return {"total": total, "por_status": status, "por_categoria": categorias}
