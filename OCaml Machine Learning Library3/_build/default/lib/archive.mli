
type filename = string
exception File_not_found of string

(** [create ~name files] creates an archive containing all names in [files].
    Raises [File_not_found] if any of the files does not exist. *)
val create : name:filename -> ?destructive:bool -> filename list -> unit

(** [read ~name] reads the archive [name] and returns the list of files within it. *)
val read : filename -> f:(filename -> 'a) -> 'a list
