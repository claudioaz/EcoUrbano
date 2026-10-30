from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field

CATEGORIAS = {"POLUICAO_AR", "ALAGAMENTO", "LIXO_IRREGULAR", "DESMATAMENTO", "MANANCIAL", "TRANSITO", "OUTRA"}
STATUS = {"ABERTA", "EM_ANALISE", "RESOLVIDA"}

class OcorrenciaCreate(BaseModel):
    titulo: str = Field(min_length=4, max_length=120)
    descricao: str = Field(min_length=10)
    categoria: str
    localizacao: str = Field(min_length=3, max_length=255)

class OcorrenciaStatusUpdate(BaseModel):
    status: str

class OcorrenciaResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    titulo: str
    descricao: str
    categoria: str
    localizacao: str
    status: str
    criada_em: datetime
