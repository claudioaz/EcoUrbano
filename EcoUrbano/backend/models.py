from sqlalchemy import Column, DateTime, Integer, String, Text, func
from .database import Base

class Ocorrencia(Base):
    __tablename__ = "ocorrencias"
    id = Column(Integer, primary_key=True, index=True)
    titulo = Column(String(120), nullable=False)
    descricao = Column(Text, nullable=False)
    categoria = Column(String(40), nullable=False, index=True)
    localizacao = Column(String(255), nullable=False)
    status = Column(String(30), nullable=False, default="ABERTA", index=True)
    criada_em = Column(DateTime, server_default=func.now(), nullable=False)
