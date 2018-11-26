(** [pow x y] is [x] raised to the [y]th power. Exponentiation for ints. *)
val pow : int -> int -> int 

(** [bin_pow x] is true if x is an int that is a power of 2, else false. *)
val bin_pow : int -> bool

(** [pad n] is the next closest larger binary power. If [bin_pow n] is [true]
    then just returns [n]. *)
val pad : int -> int