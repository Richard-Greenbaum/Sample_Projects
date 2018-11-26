(** A [Fstream] represents a potentially finite stream. *)

(** The type of an finite stream. *)
type 'a t

(** [from ~f] constructs an fstream out of a function
    that takes unit and returns an option. The stream
    ends when this function returns [None]. *)
val from : f:(unit -> 'a option) -> 'a t

(** [from_channel ch] constructs a [string Fstream.t]
    from the channel [ch]. *)
val from_channel : in_channel -> string t

(** [from_channel fn] constructs a [string Fstream.t]
    from the file [fn]. *)
val from_file : string -> string t

(** [map ~f s] is a new stream with [f] applied
    to every element of the stream. *)
val map : f:('a -> 'b) -> 'a t -> 'b t

(** [filter ~f s] is a stream with only the elements
    that match the predicate [f]. *)
val filter : f:('a -> bool) -> 'a t -> 'a t

(** [fold_left ~acc ~init s] folds left over the stream
    and produces a value with the same type as [init].
    This works the same as fold_left over lists. If [s]
    doesn't end, this function will not terminate. *)
val fold_left : f:('acc -> 'a -> 'acc) -> init:'acc -> 'a t -> 'acc

(** [append_to_file fun name] takes in a function that specifies what to write to the file
as well as a file name. The inputted function writes to the end of the specified file*)
val append_to_file : f:(out_channel -> unit) -> string -> unit
