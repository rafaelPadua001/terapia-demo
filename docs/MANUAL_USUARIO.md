# Manual do Usuario

## Como iniciar o sistema
1. Inicie o backend com: `uvicorn app.main:app --reload`.
2. Inicie o frontend com: `npm run dev`.
3. Acesse: `http://localhost:5173`.

## Acesso a API
- Base URL: `http://localhost:8000/api`
- Login: `POST /auth/login`

## Fluxo basico
1. Criar clinica + admin via seed.
2. Fazer login.
3. Cadastrar pacientes.
4. Registrar anamnese, avaliacoes e evolucoes.

## Acesso de pacientes e responsaveis
- Ao cadastrar um paciente com `email`, o sistema cria automaticamente um usuario de acesso para esse paciente.
- Ao cadastrar um responsavel com `email`, o sistema cria automaticamente um usuario de acesso para esse responsavel.
- A senha inicial padrao e `Brasil2026` quando nenhuma senha especifica e informada no cadastro.
- Recomenda-se trocar a senha no primeiro acesso.

## Possiveis erros e solucoes
- Erro de banco: verifique `DATABASE_URL` no `.env`.
- Erro de login: confirme usuario seed.
- Frontend nao abre: rode `scripts/fix-frontend.ps1`.
