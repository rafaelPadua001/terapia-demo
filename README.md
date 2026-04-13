# terapia-demo

Sistema de gestao clinica com `FastAPI + SQLAlchemy + PostgreSQL` no backend e `Vue 3 + Vuetify` no frontend.

## Visao Geral
- Cadastro e gestao de pacientes
- Cadastro e gestao de responsaveis
- Anamneses, avaliacoes, validacoes e evolucoes
- Agendamentos com confirmacao manual
- Integracao de WhatsApp por link
- Controle de acesso por perfil
- Confirmacao de e-mail para usuarios com acesso ao portal

## Perfis de Acesso
- `admin`: acesso completo
- `therapist`: acesso clinico completo
- `receptionist`: acesso operacional
- `patient`: acesso apenas aos proprios dados
- `guardian`: acesso apenas aos pacientes vinculados

## Atualizacoes Recentes

### Pacientes e Responsaveis
- Relacionamento `N:N` entre pacientes e responsaveis via `patient_guardians`
- Um paciente pode ter multiplos responsaveis
- Um responsavel pode estar vinculado a multiplos pacientes
- Formulario de paciente com:
  - multi-select de responsaveis existentes
  - criacao inline de novo responsavel
  - vinculo automatico do novo responsavel ao paciente

### Portal de Paciente e Responsavel
- Usuarios `patient` e `guardian` sao redirecionados para `/portal`
- `patient` ve apenas o proprio cadastro
- `guardian` ve todos os pacientes vinculados, incluindo co-dependentes
- Formularios e acoes de escrita ficam ocultos para esses perfis no frontend
- O backend continua sendo a fonte real de permissao

### RBAC no Backend
- Filtros por perfil aplicados em pacientes, avaliacoes, evolucoes, validacoes e agendamentos
- Protecao contra acesso indevido por ID direto
- `patient` nao acessa dados de terceiros
- `guardian` nao acessa pacientes fora do seu vinculo

### Chat em Tempo Real
- Chat isolado em `realtime/` com Socket.IO
- Lista de usuarios online filtrada por role
- Mensagens em tempo real com status enviado, entregue e lido
- Indicador de digitacao
- Widget global com visual estilo WhatsApp

## Estrutura
- `backend/`: API FastAPI, models, services, Alembic
- `frontend/`: aplicacao Vue 3 + Vuetify
- `realtime/`: servidor Socket.IO isolado para chat em tempo real
- `docs/`: documentacao de uso

## Como Executar

### Backend
```bash
cd backend
alembic upgrade head
uvicorn app.main:app --reload
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

### Chat em Tempo Real
```bash
cd realtime
npm install
npm run dev
```

### Deploy Render (realtime em subpasta)
```bash
cd realtime && npm install && npm start
```

## Variaveis de Ambiente
Arquivo: `backend/.env`

Campos principais:
- `DATABASE_URL`
- `SECRET_KEY`
- `FRONTEND_URL`
- `SMTP_HOST`
- `SMTP_PORT`
- `CLINIC_EMAIL`
- `CLINIC_EMAIL_PASSWORD`
- `CHAT_PORT`
- `CHAT_CORS_ORIGIN`
- `VITE_CHAT_URL`

Para Gmail, use senha de app.

## Seeds
Arquivo: `backend/app/utils/seed.py`

Usuarios de demonstracao:
- `admin@clinic.com`
- `terapeuta@demo.com`
- `recepcao@demo.com`
- `paciente@demo.com`
- `responsavel@demo.com`

## Migrations Importantes
- `0013_add_email_confirmation.py`
- `0014_guardian_patients_cascade.py`
- `0015_patient_guardians_nn.py`

## Observacoes
- Apos atualizar o backend, rode `alembic upgrade head`
- O frontend usa rota `/portal` para `patient` e `guardian`
- O sistema mantem compatibilidade com criacao inline de responsavel no formulario do paciente
- O chat realtime roda isolado em `realtime/`
