# Hosts Editor

Editor visual para o arquivo de hosts do Windows, com suporte a autosave e tema claro/escuro.

## 📥 Download da Última Release

1. Acesse a página de Releases do projeto no GitHub:  
   `https://github.com/<seu-usuario>/<seu-repo>/releases`
2. Baixe a versão mais recente (arquivo `.zip` ou `.exe`).

## ▶️ Como Rodar

> ⚠️ **É obrigatório executar como administrador** para que o app consiga ler e escrever em `C:\Windows\System32\drivers\etc\hosts`.

1. Extraia o `.zip` (se houver)  
2. Clique com o botão direito no executável e escolha **“Executar como administrador”**  
3. Aguarde a interface carregar

## 📖 Como Funciona

- **Lista de hosts**: exibe cada entrada com IP e hostname  
- **Seleção múltipla**: marque checkboxes e use o ícone de lixeira no cabeçalho para remover vários.  
- **Editar/adicionar**: use o botão “+” no topo para criar um novo entry; clique em ✏️ para editar.  
- **Toggle ativado**: rádio ao lado de cada linha habilita/desabilita a entrada (prefixa com `#`).  
- **Auto‑save / Auto‑reload**: ícones no rodapé ligam/desligam salvamento e recarregamento automáticos.  
- **Salvar manual**: botão “Salvar” no rodapé grava imediatamente no arquivo de hosts.  
- **Tema**: alterna entre modo claro e escuro com o ícone de sol/lua no AppBar.  

## ⚙️ Compilando o Projeto

### Pré‑requisitos

- [Flutter SDK](https://flutter.dev) (versão estável, com suporte a desktop Windows habilitado)  
- [Git](https://git-scm.com/)  
- Windows 10/11 com ferramentas de build (Visual Studio com workload “Desktop development with C++”)

### Passos

```bash
# Clone o repositório
git clone https://github.com/<seu-usuario>/<seu-repo>.git
cd <seu-repo>

# Instale dependências
flutter pub get

# Gere o código MobX
dart run build_runner build --delete-conflicting-outputs

# Compile para Windows
flutter build windows
````

O executável ficará em `build\windows\runner\Release\hosts_editor.exe`.

## 🛠️ Executando em Modo Debug

```bash
flutter run -d windows
```

Também **execute como administrador** se quiser testar gravação no hosts real.

## 🤝 Contribuições

PRs são bem‑vindas! Abra issues para bugs ou sugestões de melhoria.

## 📝 Licença

Este projeto está licenciado sob a [GNU General Public License v3.0](LICENSE).
