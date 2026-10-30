# EcoUrbano — backend inicial da APS

## 1. Criar o banco no MySQL Workbench
```sql
CREATE DATABASE ecourbano CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

## 2. Preparar (PowerShell, na pasta EcoUrbano)
```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
notepad .env
```
No `.env`, substitua `SUA_SENHA` pela senha do MySQL. Não compartilhe esse arquivo.

## 3. Iniciar a API
```powershell
uvicorn backend.main:app --reload --host 127.0.0.1 --port 8000
```
Abra http://127.0.0.1:8000/docs

## 4. Testar POST /ocorrencias
```json
{
  "titulo": "Alagamento na avenida",
  "descricao": "Acúmulo de água após chuva forte próximo ao ponto de ônibus.",
  "categoria": "ALAGAMENTO",
  "localizacao": "Avenida de exemplo, São Paulo"
}
```
Depois teste GET /ocorrencias e GET /indicadores.

Categorias: POLUICAO_AR, ALAGAMENTO, LIXO_IRREGULAR, DESMATAMENTO, MANANCIAL, TRANSITO, OUTRA.
Status: ABERTA, EM_ANALISE, RESOLVIDA.

A tabela é criada automaticamente na primeira execução. O endpoint de atualização de status ainda não tem autenticação administrativa; CORS está permissivo apenas para desenvolvimento local. O Flutter será integrado na próxima etapa.
