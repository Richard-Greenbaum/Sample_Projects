
type 'a t = Cons of 'a * 'a t lazy_t
          | End

(** [eval l] forces evaluation of [l]. *)
let eval l = Lazy.force l

let rec from ~(f: unit -> 'a option) =
  match f () with
  | None -> End
  | Some a -> Cons (a, lazy (from ~f))

let from_channel (ch: in_channel) =
  from ~f:(fun () ->
      try Some (input_line ch)
      with End_of_file -> None)

let from_file (fn: string) =
  let ch = open_in fn in
  from ~f:(fun () ->
      try Some (input_line ch)
      with End_of_file -> close_in ch; None)

let rec map ~f s =
  match s with
  | End -> End
  | Cons(a, th) -> Cons (f a, lazy (map ~f (eval th)))

let rec filter ~f s =
  match s with
  | End -> End
  | Cons(a, th) ->
    if f a then
      Cons (a, lazy (filter ~f (eval th)))
    else
      filter ~f (eval th)

let rec fold_left ~f ~init s =
  match s with
  | End -> init
  | Cons(a, th) -> fold_left ~f ~init:(f init a) (eval th)

let append_to_file ~f fn =
  let ch = open_out_gen [Open_creat; Open_append] 400 fn in
  f ch;
  close_out ch
