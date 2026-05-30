import LeanTodo

partial def loop (stdin : IO.FS.Stream) : IO Unit := do
  IO.print "todo> "
  (← IO.getStdout).flush
  let line ← stdin.getLine
  if line.length == 0 then
    IO.println ""
    IO.println "bye"
  else
    let cmd := line.trimAscii.toString
    if cmd == "" then
      loop stdin
    else
      IO.println s!"received: {cmd}"
      loop stdin

def main : IO Unit := do
  IO.println "lean-todo backend running"
  IO.println "type a line and press enter (Ctrl-D to quit)"
  loop (← IO.getStdin)
