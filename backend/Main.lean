import LeanTodo
import Lean.Data.Json

open Lean LeanTodo

def errorJson (msg : String) : Json :=
  Json.mkObj [("ok", Json.bool false), ("error", Json.str msg)]

def main : IO Unit := do
  let input ← (← IO.getStdin).readToEnd
  let out : Json :=
    match Json.parse input with
    | .error e => errorJson s!"parse error: {e}"
    | .ok j =>
      match (fromJson? j : Except String Request) with
      | .error e => errorJson e
      | .ok req =>
        match VTodoList.ofTodoList? req.state with
        | none => errorJson "invalid state: violates the verified invariant"
        | some vl => Json.mkObj [("ok", Json.bool true), ("state", toJson (vl.step req.command).val)]
  IO.println out.compress
