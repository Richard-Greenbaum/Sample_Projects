
(** Type of matrix *)
type t

(** [zeros ~m ~n] is a matrix full of zeros of size [m x n]. *)
val zeros : m:int -> n:int -> t

(** [ones ~m ~n] is a matrix full of ones of size [m x n]. *)
val ones : m:int -> n:int -> t

(** [random ~m ~n] is a matrix full of random floats of size [m x n]. *)
val random : m:int -> n:int -> t

(** [of_list l] is a matrix representation of [l]. *)
val of_list : float list list -> t

(** [to_row_list m] is a list of each row in matrix [m]. *)
val to_row_list : t -> t list

(** [mat_values m n v] is a matrix full of float [v] of size [m x n] *)
val mat_values : m:int -> n:int -> v:float -> t

(** [equals m1 m2] is true if [m1] is the same (structurally and same values) as
    [m2]. *)
val equals : t -> t -> bool

(** [sep m] separates the augmented matrix [a | m] into [(a, m)] *)
val sep : t -> (t * t)

(** [return to] takes [t] out of the option if possible, raising
    an exception otherwise. *)
val return : t option -> t

(** [fold_left fun acc t] returns the result of a fold_left function with 
    anonymous function fun and initial accumulator acc applied to matrix t *)
val fold_left : ('a -> float -> 'a) -> 'a -> t -> 'a

(* val fold2 : ('a -> 'b -> 'c -> 'c) -> 'c -> t -> 'c *)

(** [set m v ~i ~j] replaces cell [i, j] with value [v] in matrix [m]. *)
val set : t -> float -> i:int -> j:int -> t option

(** [height a] where [a] is an [m x n] matrix is [m] *)
val height : t -> int

(** [width a] where [a] is an [m x n] matrix is [n] *)
val width : t -> int

(** [entries t] returns the number of entries in matrix t*)
val entries : t -> int 

(** [width m1 m2] is [true] if m1 has the same dimensions as [m2]. *)
val size_equals : t -> t -> bool

(**[map f m] is the map for [f] on [m].
   Requires: [m] is an m x 1 matrix where m is the number of nodes in the layer *)
val map : (float -> float) -> t -> t

(** [map2 f m1 m2] is a matrix [m] where every [i, j] in [m] is equal to
    [f m1_i m2_i, f m1_j m2_j] *)
val map2 : (float -> float -> float) -> t -> t -> t option

(** [iter f m] applies [f] to every element in [m]. [f] needs to return [unit]. *)
val iter : (float -> unit) -> t -> unit

(** [sum m1] is the sum of every element in [m1] *)
val sum : t -> float

(** [add m1 m2] is the matrix addition of [m1] and [m2].
    [m1] must be the same size as [m2]. *)
val add : t -> t -> t option

(** [sub m1 m2] is the matrix subtraction of [m1] and [m2]. *)
val sub : t -> t -> t option

(** [square m n] converts the matrix [m] into a square matrix with side length 
    [n], where [n] is greater than the original max_dimension of the matrix 
    [m] *)
val square : t -> int -> t

(** [quad_split m] splits the matrix into its four quadrants. *)
val quad_split : t -> t * t * t * t

(** [quad_conn (q1, q2, q3, q4)] conjoins all quadrants into one larger matrix. *)
val quad_conn : t * t * t * t -> t

(** [mult m1 m2] is the matrix multiplication of [m1] and [m2].
    Raises: Failure "Bad Dimensions" if the dimensions of [m1] and [m2] are not correct *)
val mult : t -> t -> t

val mult_ : t -> t -> t

(** [dot m1 m2] takes the dot product of matrix [m1] and matrix [m2]. *)
val dot : t -> t -> float

(** [square m n] takes matrix m and extends its size until its dimensions are 
    n x n, therefore square. m must be greater than or equal to m. Otherwise the
    slice function can be used. *)
val square : t -> int -> t 

(** [scalar_mult m x] is the scalar multiplication of [m] and [x]. *)
val scalar_mult : t -> float -> t

(**[map m f] is the map for [f] on [m].
   Requires: [m] is an m x 1 matrix where m is the number of nodes in the layer *)
(* val map : (float -> float) -> t -> t *)

(**[slice m p1 p2] is a sub-section of [m] between [p1] and [p2] *)
val slice : int * int -> int * int -> t -> t

(** [inv m] is [Some i] if [m] is invertable and [None] otherwise. *)
val inv : t -> t option

(** [det m] is the determinant of [m]. *)
val det : t -> float

(** [norm m] is the norm of [m]. *)
val norm : t -> float

(** [transpose m] is the transpose of matrix [m]. *)
val transpose : t -> t

(** [drop_row m i] removes the [i]th row of [m]. *)
val drop_row : int -> t -> t

(** [drop_col m j] removes the [j]th column of [m]. *)
val drop_col : int -> t -> t

(** [to_matrix b] takes in an array of arrays of strings and converts it to a 
    matris of the floats that are contained in each string*)
val to_matrix : (string array) array -> t

(** [format t] prints [t] to [stdout].*)
val print : t -> unit

(** [format fmt t] prints out [t] to [fmt]. *)
val format : Format.formatter -> t -> unit

(** [size m] returns the length of the outer array of matrix m. *)
val size : t -> int

(** [get_first_n m n] returns a touple with the first n elements of matrix m 
    along with the rest of matrix m  *)
val get_first_n : t -> int -> t * t

(** [to_flat_list t] returns a representation of matrix t as a flattened list of floats*)
val to_flat_list : t -> float list
