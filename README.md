# lean-todo-app

Lean 4 で検証した Todo の状態遷移コアと、TanStack Start + React のフロントエンドで構成する Todo アプリ。

## アーキテクチャ

```
frontend/   TanStack Start + React。UI と HTTP を担う
backend/    Lean 4 (lake)。Todo の状態・遷移・不変条件を定義し証明する
```

Todo リストの状態と各操作 (追加・完了切り替え・削除) を Lean 4 で状態機械として定義し、「不正な状態に遷移しない」性質を証明する。フロントエンドは状態を表示し、操作を発行する。

## 開発環境

flake の devShell に lean4 (lake 同梱)・Node.js を固定している。

```sh
nix develop
```

direnv を使う場合は `.envrc.example` を `.envrc` にコピーする。

## backend (Lean 4)

```sh
cd backend
lake build
```

## frontend (TanStack Start)

```sh
cd frontend
npm run dev      # http://localhost:3000
npm run build
npm run test
```
