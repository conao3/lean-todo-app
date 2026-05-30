import Lean.Data.Json
import LeanTodo.Basic

open Lean

namespace LeanTodo

deriving instance FromJson, ToJson for Todo
deriving instance FromJson, ToJson for TodoList

instance : FromJson Command where
  fromJson? j := do
    let type ← (← j.getObjVal? "type").getStr?
    match type with
    | "add" => return .add (← (← j.getObjVal? "title").getStr?)
    | "toggle" => return .toggle (← (← j.getObjVal? "id").getNat?)
    | "remove" => return .remove (← (← j.getObjVal? "id").getNat?)
    | other => throw s!"unknown command type: {other}"

structure Request where
  state : TodoList
  command : Command

instance : FromJson Request where
  fromJson? j := do
    let state : TodoList ← fromJson? (← j.getObjVal? "state")
    let command : Command ← fromJson? (← j.getObjVal? "command")
    return { state, command }

end LeanTodo
