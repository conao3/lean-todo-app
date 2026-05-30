import { createServerFn } from '@tanstack/react-start'
import { execFile } from 'node:child_process'
import { resolve } from 'node:path'

export type Todo = { id: number; title: string; done: boolean }
export type TodoList = { items: Todo[]; nextId: number }
export type Command =
  | { type: 'add'; title: string }
  | { type: 'toggle'; id: number }
  | { type: 'remove'; id: number }

let state: TodoList = { items: [], nextId: 0 }

const exePath = resolve(process.cwd(), '../backend/.lake/build/bin/todo')

function runLean(command: Command): Promise<TodoList> {
  return new Promise((res, rej) => {
    const child = execFile(exePath, (err, stdout, stderr) => {
      if (err) return rej(new Error(stderr || String(err)))
      const parsed = JSON.parse(stdout)
      if (!parsed.ok) return rej(new Error(parsed.error))
      res(parsed.state as TodoList)
    })
    child.stdin!.end(JSON.stringify({ state, command }))
  })
}

export const getTodos = createServerFn({ method: 'GET' }).handler(async () => state)

export const applyCommand = createServerFn({ method: 'POST' })
  .inputValidator((cmd: Command) => cmd)
  .handler(async ({ data }) => {
    state = await runLean(data)
    return state
  })
