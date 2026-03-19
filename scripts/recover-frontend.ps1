param()

Write-Host "Parando processos Node..."
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force

$frontendPath = Join-Path $PSScriptRoot ".." "frontend"
Set-Location $frontendPath

Write-Host "Removendo node_modules e package-lock.json..."
if (Test-Path "node_modules") {
  Remove-Item -Recurse -Force "node_modules" -ErrorAction SilentlyContinue
}
if (Test-Path "package-lock.json") {
  Remove-Item -Force "package-lock.json" -ErrorAction SilentlyContinue
}

Write-Host "Limpando cache do npm..."
npm cache clean --force

Write-Host "Setando registry padrao..."
npm config set registry https://registry.npmjs.org/

Write-Host "Instalando dependencias..."
npm install

Write-Host "Concluido. Rode: npm run dev"
