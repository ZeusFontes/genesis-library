# 🎬 Projeto GÊNESIS — Flutter

Aplicativo de streaming + biblioteca digital com identidade visual própria.

---

## ✅ Como rodar

### 1. Pré-requisitos
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code com extensão Flutter

### 2. Instalar dependências
```bash
cd genesis
flutter pub get
```

### 3. Adicionar a logo
Coloque o arquivo `genesis_logo.png` em:
```
assets/logo/genesis_logo.png
```
> Se não tiver a logo ainda, o app usa um ícone de fallback automático.

### 4. Rodar o app
```bash
flutter run
```

---

## 📁 Estrutura do Projeto

```
lib/
├── core/
│   ├── theme/         → AppTheme (ThemeData completo)
│   └── constants/     → AppColors, AppRoutes, AppAssets
├── models/            → MediaContent, Profile, Addon, CastMember
├── mocks/             → Dados fictícios para desenvolvimento
├── widgets/           → Componentes reutilizáveis
├── screens/
│   ├── auth/          → LoginScreen
│   ├── profiles/      → ProfileSelectionScreen
│   ├── home/          → Filmes, Séries, Livros
│   ├── details/       → MovieDetailScreen, BookDetailScreen
│   ├── addons/        → AddonsScreen
│   └── profile/       → ProfileScreen
├── navigation/        → MainNavigationScreen (BottomNav)
└── main.dart
```

---

## 🎨 Paleta de Cores

| Cor | Hex | Uso |
|-----|-----|-----|
| Background | `#30243F` | Fundo principal |
| Surface | `#4B2757` | Cards e surfaces |
| Secondary | `#6B4E8E` | Elementos secundários |
| Soft Accent | `#EFB27B` | Destaques suaves |
| Primary Accent | `#FC9D43` | CTAs e botões principais |

---

## 🔧 Dependências

| Pacote | Uso |
|--------|-----|
| `go_router` | Navegação declarativa |
| `flutter_riverpod` | Gerenciamento de estado |
| `cached_network_image` | Imagens com cache |
| `carousel_slider` | Hero banner rotativo |
| `google_fonts` | Tipografia |
| `flutter_animate` | Animações |
| `video_player` | Player de vídeo (domínio público) |
| `url_launcher` | Abrir links de streaming |
| `shimmer` | Loading skeleton |

---

## 🚀 Próximos passos sugeridos

- [ ] Integrar Firebase Auth no LoginScreen
- [ ] Substituir mocks por API real
- [ ] Integrar `video_player` no `PublicDomainPlayer`
- [ ] Adicionar Riverpod providers para estado global
- [ ] Implementar busca global
- [ ] Adicionar tela de onboarding
