#!/usr/bin/env pwsh
# Deploy Flutter Web App to GitHub Pages
# Este script faz build e copia os arquivos para a raiz do repositório

Write-Host "🚀 Iniciando build Flutter Web com base-href=/adl_fono/" -ForegroundColor Cyan

# 1. Fazer build web
flutter build web --release --base-href=/adl_fono/

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build falhou!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build concluído com sucesso" -ForegroundColor Green

# 2. Copiar arquivos de build/web para a raiz (sobrescrevendo os existentes)
Write-Host "📋 Copiando arquivos de build/web para a raiz do repositório..." -ForegroundColor Cyan

$sourceDir = "build/web"
$targetDir = "."

if (Test-Path $sourceDir) {
    # Remove arquivos antigos (exceto .git e node_modules)
    Get-ChildItem -Path $targetDir -Exclude ".git", ".gitignore", "node_modules", ".env*", "README.md", "LICENSE", ".nojekyll" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    
    # Copia novos arquivos
    Copy-Item -Path "$sourceDir/*" -Destination $targetDir -Recurse -Force
    
    Write-Host "✅ Arquivos copiados com sucesso" -ForegroundColor Green
} else {
    Write-Host "❌ Diretório build/web não encontrado!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📝 Próximos passos:" -ForegroundColor Yellow
Write-Host "1. git add ."
Write-Host "2. git commit -m 'Deploy: atualizar versão web do app'"
Write-Host "3. git push origin main"
Write-Host ""
Write-Host "✨ Site estará disponível em: https://selds.github.io/adl_fono/" -ForegroundColor Green
