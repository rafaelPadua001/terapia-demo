# Manual do Usuario

## Como iniciar o sistema
1. No backend, rode: `alembic upgrade head`
2. Depois inicie a API com: `uvicorn app.main:app --reload`
3. No frontend, rode: `npm install`
4. Depois inicie a interface com: `npm run dev`
5. Acesse: `http://localhost:5173`

## Acesso a API
- Base URL: `http://localhost:8000/api`
- Login: `POST /auth/login`

## Fluxo básico da clínica
1. Criar clínica e admin pela seed inicial
2. Fazer login com um perfil autorizado
3. Cadastrar pacientes
4. Vincular responsáveis existentes ou cadastrar um novo responsável no próprio formulário do paciente
5. Registrar anamnese, avaliações e evoluções
6. Criar agendamentos e enviar confirmação por WhatsApp

## Gestão de pacientes
- O cadastro de paciente permite:
  - nome
  - data de nascimento
  - CPF
  - e-mail
  - celular
  - diagnóstico
  - observações
- O sistema gera automaticamente um código de paciente

## Gestão de responsáveis
- O campo `Responsáveis` no formulário do paciente aceita múltiplos vínculos
- É possível:
  - selecionar responsáveis já existentes
  - cadastrar um novo responsável no próprio formulário
- Um mesmo responsável pode estar vinculado a mais de um paciente
- Um paciente pode ter mais de um responsável

## Acesso de pacientes e responsáveis
- Ao cadastrar um paciente com `email`, o sistema cria automaticamente um usuário de acesso para esse paciente
- Ao cadastrar um responsável com `email`, o sistema cria automaticamente um usuário de acesso para esse responsável
- A senha inicial padrão é `Brasil2026` quando nenhuma senha específica é informada
- Recomenda-se trocar a senha no primeiro acesso

## Confirmação de e-mail
- Usuários com e-mail cadastrado recebem mensagem de confirmação
- O link abre a tela `/confirm-email`
- Após a confirmação, o status fica salvo em `users.email_is_confirmed`

## Portal do paciente e do responsável

### Paciente
- É redirecionado para `/portal`
- Visualiza apenas os próprios dados
- Não vê formulários de criação, edição ou exclusão de outros registros

### Responsável
- É redirecionado para `/portal`
- Visualiza todos os pacientes vinculados ao seu perfil
- Pode acompanhar co-dependentes
- Não vê formulários administrativos

## Agendamentos
- O sistema permite criar, editar e excluir agendamentos conforme o perfil
- O campo `Primeira consulta` é salvo corretamente
- O envio por WhatsApp acontece por link
- Após enviar a mensagem manualmente, o usuário pode marcar o agendamento como confirmado

## Confirmação por WhatsApp
- O sistema gera link para WhatsApp com os dados da consulta
- O link pode ser aberto diretamente pela interface
- A confirmação do agendamento é manual e fica registrada no sistema

## Perfis de acesso
- `admin`: acesso completo
- `therapist`: acesso clínico completo
- `receptionist`: acesso operacional
- `patient`: acesso apenas aos próprios dados
- `guardian`: acesso apenas aos pacientes vinculados

## Seeds de teste
Perfis comuns de demonstração:
- `admin@clinic.com`
- `terapeuta@demo.com`
- `recepcao@demo.com`
- `paciente@demo.com`
- `responsavel@demo.com`

## Possíveis erros e soluções
- Erro de banco: verifique `DATABASE_URL` no `backend/.env`
- Erro de migration: rode `alembic upgrade head`
- Erro de login: confirme se o usuário da seed existe e está ativo
- Frontend não abre: confirme dependências com `npm install`
- E-mail não envia: revise `SMTP_HOST`, `SMTP_PORT`, `CLINIC_EMAIL` e `CLINIC_EMAIL_PASSWORD`

## Observações finais
- O backend é a fonte real de permissão
- O frontend apenas reflete as permissões para melhorar a experiência
- Em usuários `patient` e `guardian`, a visualização é restrita automaticamente
