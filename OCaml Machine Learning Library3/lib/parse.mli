(** [split_line s] splits a string [s] in a csv file into a list of substrings
    delimited by standard regex separators. *)
val split_line : string -> string list

(** [to_matrix s] is a Matrix.t of the a string list list [s], whose elements
    are strings of floats. *)
val to_matrix : string list list -> Matrix.t

(** [matrix_of_channel c] is the Matrix.t of a given open channel [c] of a file. *)
val matrix_of_channel : in_channel -> Matrix.t

(** [selector_of_float n f] is a float list representing the a list of length [n]
    consisting of floats [f]. *)
val selector_of_float : int -> float -> float list

(** [unique m] is the number of unique elements in the Matrix.t [m]. *)
val unique : Matrix.t -> int

(** [matrix_of_file s] converts the matrix represented in the csv file with name
    [s] into a separated augmented matrix tuple of [data * output] *)
val matrix_of_file : string -> Matrix.t * Matrix.t

(** [split m1 m2 f1 f2] splits the given data and classification matrices [m1]
    and [m2] into training and testing sets depending on the given sizes of the
    floats [f1] and [f2] representing the amount of data entries per training
    or testing set. *)
val split : Matrix.t -> Matrix.t -> float -> float -> (Matrix.t * Matrix.t) list
