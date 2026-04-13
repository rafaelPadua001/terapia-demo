# Chat em Tempo Real

O chat foi adicionado como um modulo isolado em `realtime/`, sem alterar as rotas FastAPI existentes.

## Subir o servidor realtime

```powershell
cd realtime
npm install
npm run dev
```

## Subir o frontend

```powershell
cd frontend
npm install
npm run dev
```

## Variaveis opcionais

- `CHAT_PORT`: porta do servidor Socket.IO. Padrao `8100`
- `CHAT_CORS_ORIGIN`: origens permitidas separadas por virgula
- `VITE_CHAT_URL`: URL do servidor realtime para o frontend

## Regras de visibilidade

- `admin`, `therapist`, `terapeuta`, `reception`, `receptionist`: veem todos do mesmo tenant
- `patient` e `guardian`: veem apenas recepcao do mesmo tenant
