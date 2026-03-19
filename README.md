# terapia-demo

Sistema de gestão clínica com `FastAPI + SQLAlchemy + PostgreSQL` no backend e `Vue 3 + Vuetify` no frontend.

## Visão Geral
- Cadastro e gestão de pacientes
- Cadastro e gestão de responsáveis
- Anamneses, avaliações, validações e evoluções
- Agendamentos com confirmação manual
- Integração de WhatsApp por link
- Controle de acesso por perfil
- Confirmação de e-mail para usuários com acesso ao portal

## Perfis de Acesso
- `admin`: acesso completo
- `therapist`: acesso clínico completo
- `receptionist`: acesso operacional
- `patient`: acesso apenas aos próprios dados
- `guardian`: acesso apenas aos pacientes vinculados

## Atualizações Recentes

### Pacientes e Responsáveis
- Relacionamento `N:N` entre pacientes e responsáveis via `patient_guardians`
- Um paciente pode ter múltiplos responsáveis
- Um responsável pode estar vinculado a múltiplos pacientes
- Formulário de paciente com:
  - multi-select de responsáveis existentes
  - criação inline de novo responsável
  - vínculo automático do novo responsável ao paciente

### Portal de Paciente e Responsável
- Usuários `patient` e `guardian` são redirecionados para `/portal`
- `patient` vê apenas o próprio cadastro
- `guardian` vê todos os pacientes vinculados, incluindo co-dependentes
- Formulários e ações de escrita ficam ocultos para esses perfis no frontend
- O backend continua sendo a fonte real de permissão

### RBAC no Backend
- Filtros por perfil aplicados em pacientes, avaliações, evoluções, validações e agendamentos
- Proteção contra acesso indevido por ID direto
- `patient` não acessa dados de terceiros
- `guardian` não acessa pacientes fora do seu vínculo

### Agendamentos
- CRUD de agendamentos ajustado
- Campo `is_first_visit` persistindo corretamente
- Campo `is_confirmed` para confirmação manual
- Endpoint de confirmação manual do agendamento
- Abertura do WhatsApp por link para envio manual da mensagem

### E-mail
- Criação automática de usuário para paciente/responsável quando houver e-mail
- Envio de confirmação de cadastro por e-mail
- Campo `email_is_confirmed` em `users`
- Tela `/confirm-email` no frontend

### Qualidade de Dados
- Correções de UTF-8 em textos do sistema
- Normalização de CPF e telefone
- Melhorias no `.env` para tolerar BOM e leitura segura no backend

## Estrutura
- `backend/`: API FastAPI, models, services, Alembic
- `frontend/`: aplicação Vue 3 + Vuetify
- `docs/`: documentação de uso

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

## Variáveis de Ambiente
Arquivo: `backend/.env`

Campos principais:
- `DATABASE_URL`
- `SECRET_KEY`
- `FRONTEND_URL`
- `SMTP_HOST`
- `SMTP_PORT`
- `CLINIC_EMAIL`
- `CLINIC_EMAIL_PASSWORD`

Para Gmail, use senha de app.

## Seeds
Arquivo: `backend/app/utils/seed.py`

Usuários de demonstração:
- `admin@clinic.com`
- `terapeuta@demo.com`
- `recepcao@demo.com`
- `paciente@demo.com`
- `responsavel@demo.com`

## Migrations Importantes
- `0013_add_email_confirmation.py`
- `0014_guardian_patients_cascade.py`
- `0015_patient_guardians_nn.py`

## Observações
- Após atualizar o backend, rode `alembic upgrade head`
- O frontend usa rota `/portal` para `patient` e `guardian`
- O sistema mantém compatibilidade com criação inline de responsável no formulário do paciente
