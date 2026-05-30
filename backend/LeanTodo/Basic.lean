namespace LeanTodo

structure Todo where
  id : Nat
  title : String
  done : Bool
deriving Repr, DecidableEq, Inhabited

structure TodoList where
  items : List Todo
  nextId : Nat
deriving Repr, Inhabited

inductive Command where
  | add (title : String)
  | toggle (id : Nat)
  | remove (id : Nat)
deriving Repr

namespace TodoList

def ids (l : TodoList) : List Nat := l.items.map (·.id)

structure Valid (l : TodoList) : Prop where
  ids_lt : ∀ t ∈ l.items, t.id < l.nextId
  nodup : l.ids.Nodup

def empty : TodoList := { items := [], nextId := 0 }

theorem empty_valid : empty.Valid := by
  refine ⟨?_, ?_⟩
  · intro t ht; simp [empty] at ht
  · simp [empty, ids]

def add (l : TodoList) (title : String) : TodoList :=
  { items := { id := l.nextId, title := title, done := false } :: l.items
    nextId := l.nextId + 1 }

def toggle (l : TodoList) (tid : Nat) : TodoList :=
  { l with items := l.items.map fun t => if t.id == tid then { t with done := !t.done } else t }

def remove (l : TodoList) (tid : Nat) : TodoList :=
  { l with items := l.items.filter fun t => t.id != tid }

theorem add_valid (l : TodoList) (title : String) (h : l.Valid) : (l.add title).Valid := by
  refine ⟨?_, ?_⟩
  · intro t ht
    simp only [add, List.mem_cons] at ht
    rcases ht with rfl | ht
    · exact Nat.lt_succ_self _
    · exact Nat.lt_succ_of_lt (h.ids_lt t ht)
  · simp only [add, ids, List.map_cons, List.nodup_cons]
    refine ⟨?_, h.nodup⟩
    intro hmem
    simp only [List.mem_map] at hmem
    obtain ⟨t, ht, hid⟩ := hmem
    have := h.ids_lt t ht
    omega

theorem toggle_valid (l : TodoList) (tid : Nat) (h : l.Valid) : (l.toggle tid).Valid := by
  have key : ∀ s : Todo,
      ((if s.id == tid then { s with done := !s.done } else s) : Todo).id = s.id := by
    intro s; split <;> rfl
  refine ⟨?_, ?_⟩
  · intro t ht
    simp only [toggle, List.mem_map] at ht
    obtain ⟨s, hs, rfl⟩ := ht
    rw [key s]
    exact h.ids_lt s hs
  · have heq : (l.toggle tid).ids = l.ids := by
      simp only [toggle, ids, List.map_map]
      apply List.map_congr_left
      intro s _
      exact key s
    rw [heq]
    exact h.nodup

theorem remove_valid (l : TodoList) (tid : Nat) (h : l.Valid) : (l.remove tid).Valid := by
  refine ⟨?_, ?_⟩
  · intro t ht
    simp only [remove, List.mem_filter] at ht
    exact h.ids_lt t ht.1
  · have hsub : (l.remove tid).items.Sublist l.items := by
      simp only [remove]
      exact List.filter_sublist
    have hids : (l.remove tid).ids.Sublist l.ids := by
      simp only [ids]
      exact hsub.map (·.id)
    exact hids.nodup h.nodup

def step (l : TodoList) : Command → TodoList
  | .add title => l.add title
  | .toggle tid => l.toggle tid
  | .remove tid => l.remove tid

theorem step_valid (l : TodoList) (c : Command) (h : l.Valid) : (l.step c).Valid := by
  cases c with
  | add title => exact add_valid l title h
  | toggle tid => exact toggle_valid l tid h
  | remove tid => exact remove_valid l tid h

instance (l : TodoList) : Decidable l.Valid :=
  decidable_of_iff
    ((∀ t ∈ l.items, t.id < l.nextId) ∧ l.ids.Nodup)
    ⟨fun h => ⟨h.1, h.2⟩, fun h => ⟨h.ids_lt, h.nodup⟩⟩

end TodoList

def VTodoList := { l : TodoList // l.Valid }

namespace VTodoList

def empty : VTodoList := ⟨TodoList.empty, TodoList.empty_valid⟩

def step (l : VTodoList) (c : Command) : VTodoList :=
  ⟨l.val.step c, TodoList.step_valid l.val c l.property⟩

def ofTodoList? (l : TodoList) : Option VTodoList :=
  if h : l.Valid then some ⟨l, h⟩ else none

end VTodoList
end LeanTodo
