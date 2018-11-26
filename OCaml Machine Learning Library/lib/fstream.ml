(** The type of an finite stream. *)
type 'a t = Cons of 'a * 'a t lazy_t
          | End

(** [eval l] forces evaluation of [l]. *)
let eval l = Lazy.force l

(** [from ~f] constructs an fstream out of a function
    that takes unit and returns an option. The stream
    ends when this function returns [None]. *)
let rec from ~(f: unit -> 'a option) =
  match f () with
  | None -> End
  | Some a -> Cons (a, lazy (from ~f))

(** [from_channel ch] constructs a [string Fstream.t]
    from the channel [ch]. *)
let from_channel (ch: in_channel) =
  from ~f:(fun () ->
      try Some (input_line ch)
      with End_of_file -> None)

(** [from_channel fn] constructs a [string Fstream.t]
    from the file [fn]. *)
let from_file (fn: string) =
  let ch = open_in fn in
  from ~f:(fun () ->
      try Some (input_line ch)
      with End_of_file -> close_in ch; None)

(** [map ~f s] is a new stream with [f] applied
    to every element of the stream. *)
let rec map ~f s =
  match s with
  | End -> End
  | Cons(a, th) -> Cons (f a, lazy (map ~f (eval th)))

(** [filter ~f s] is a stream with only the elements
    that match the predicate [f]. *)
let rec filter ~f s =
  match s with
  | End -> End
  | Cons(a, th) ->
    if f a then
      Cons (a, lazy (filter ~f (eval th)))
    else
      filter ~f (eval th)

(** [fold_left ~acc ~init s] folds left over the stream
    and produces a value with the same type as [init].
    This works the same as fold_left over lists. If [s]
    doesn't end, this function will not terminate. *)
let rec fold_left ~f ~init s =
  match s with
  | End -> init
  | Cons(a, th) -> fold_left ~f ~init:(f init a) (eval th)

(** [append_to_file fun name] takes in a function that specifies what to write to 
    the file as well as a file name. The inputted function writes to the end of 
    the specified file *)
let append_to_file ~f fn =
  let ch = open_out_gen [Open_creat; Open_append] 400 fn in
  f ch;
  close_out ch
