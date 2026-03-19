param()

Set-Location "$PSScriptRoot\..\backend"

Write-Host "Aplicando migrations..."
alembic upgrade head

Write-Host "Rodando seed..."
python -m app.utils.seed

Write-Host "Setup concluido."
