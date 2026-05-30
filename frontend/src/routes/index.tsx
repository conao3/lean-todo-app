import { createFileRoute, useRouter } from '@tanstack/react-router'
import { useState } from 'react'
import { applyCommand, getTodos } from '#/server/todo'

export const Route = createFileRoute('/')({
  component: Home,
  loader: () => getTodos(),
})

function Home() {
  const list = Route.useLoaderData()
  const router = useRouter()
  const [title, setTitle] = useState('')

  const run = async (action: Promise<unknown>) => {
    await action
    await router.invalidate()
  }

  return (
    <div className="mx-auto max-w-xl p-8">
      <h1 className="text-3xl font-bold">lean-todo</h1>
      <p className="mt-1 text-sm text-gray-500">状態遷移は Lean で検証済み</p>

      <form
        className="mt-6 flex gap-2"
        onSubmit={async (e) => {
          e.preventDefault()
          const t = title.trim()
          if (!t) return
          setTitle('')
          await run(applyCommand({ data: { type: 'add', title: t } }))
        }}
      >
        <input
          className="flex-1 rounded border px-3 py-2"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="やることを入力"
        />
        <button className="rounded bg-black px-4 py-2 text-white" type="submit">
          追加
        </button>
      </form>

      <ul className="mt-6 space-y-2">
        {list.items.map((todo) => (
          <li key={todo.id} className="flex items-center gap-3 rounded border px-3 py-2">
            <input
              type="checkbox"
              checked={todo.done}
              onChange={() => run(applyCommand({ data: { type: 'toggle', id: todo.id } }))}
            />
            <span className={todo.done ? 'flex-1 text-gray-400 line-through' : 'flex-1'}>
              {todo.title}
            </span>
            <button
              type="button"
              className="text-sm text-red-600"
              onClick={() => run(applyCommand({ data: { type: 'remove', id: todo.id } }))}
            >
              削除
            </button>
          </li>
        ))}
        {list.items.length === 0 && <li className="text-gray-400">まだ何もありません</li>}
      </ul>
    </div>
  )
}
