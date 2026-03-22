# 🚀 Guia de Deploy - GitHub Pages

## Status Atual ✅
- ✅ Build Flutter Web compilado com sucesso
- ✅ Base href configurado para `/adl_fono/`
- ✅ Arquivos copiados para raiz do repositório
- ✅ `.nojekyll` criado para evitar processamento Jekyll

## Próximos Passos

### 1️⃣ Verificar Alterações
```bash
git status
```
Você verá arquivos novos em staging:
- `.nojekyll`
- `index.html`
- `main.dart.js`
- `flutter.js`
- `assets/`, `icons/`, `canvaskit/`
- etc.

### 2️⃣ Adicionar e Fazer Commit
```bash
# Adicionar todos os arquivos
git add .

# Fazer commit
git commit -m "Deploy: compilar e publicar versão web do app (Flutter)"
```

### 3️⃣ Fazer Push
```bash
git push origin main
```

### 4️⃣ Aguardar GitHub Pages
- Aguarde 1-2 minutos
- GitHub Pages irá fazer build automaticamente
- Acesse: https://selds.github.io/adl_fono/

## ⚠️ Se a página ainda ficar em branco

1. **Verifique configurações do GitHub Pages:**
   - Abra: Settings → Pages
   - Certifique-se que está configurado para usar `main` branch
   - Verifique se build está ✅ (deve mostrar "Your site is published")

2. **Abra DevTools do navegador (F12):**
   - Aba "Console" - procure por erros de JavaScript
   - Aba "Network" - verifique se `index.html` foi carregado com status 200
   - Se ver 404 no `index.html`, o caminho está errado

3. **Limpe cache do navegador:**
   - Faça Ctrl+Shift+Delete e limpe cache
   - Ou abra em modo anônimo

4. **Se vir erros sobre Firebase:**
   - Verifique `firebase_options.dart`
   - Confirme que credenciais Firebase estão configuradas
   - Configure CORS no Firebase se necessário

## 📝 Para Atualizações Futuras

Sempre que quiser fazer uma nova versão:

```bash
# 1. Fazer alterações no código
# 2. Testar: flutter run -d chrome

# 3. Quando pronto, fazer build
flutter build web --release --base-href=/adl_fono/

# 4. Copiar arquivos
Copy-Item -Path "build/web/*" -Destination "." -Recurse -Force

# 5. Commit e push
git add .
git commit -m "Deploy: [descrição das mudanças]"
git push origin main
```

## 🔍 Troubleshooting

**Problema:** Página em branco
- **Solução:** Verifique base href em `index.html`, cache do navegador, console do DevTools

**Problema:** Erros do Firebase
- **Solução:** Confirme `firebase_options.dart` tem credenciais válidas

**Problema:** Arquivos não carregam (404 em assets)
- **Solução:** Verifique que `base href` está correto (`/adl_fono/`)

---

Pronto! O site estará disponível em poucos minutos! 🎉
