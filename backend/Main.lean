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
      | .ok req => Json.mkObj [("ok", Json.bool true), ("state", toJson (req.state.step req.command))]
  IO.println out.compress
