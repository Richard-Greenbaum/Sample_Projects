(* Simpler Name bindings for height and width *)

(** [height] is [Matrix.height] *)
let height = Matrix.height

(** [width] is [Matrix.width] *)
let width = Matrix.width

(** [filter f m] filters a matrix chunk [m] using the filter feature [f], resulting
    in a float value representing *)
let filter f m =
  Matrix.fold_left
    (+.)
    0.
    (Matrix.return (Matrix.map2 (+.) f m))
  /. float_of_int (Matrix.entries m)

(* let build_filters n rf cf = Matrix.zeros n rf cf  *)
(** [convolve f m s] performs convolution over a pixel matrix [matrix] using a
    chosen feature filter [feature]. It iterates this filtering process every
    [step] pixels. *)
let convolve feature matrix step = failwith "nyi"

(** [pool h w s] performs the pooling operation over a convolved pixel [matrix]
    using a window of height [h], width [w] and pools every [stride] pixels.
    The act of pooling simple shrinks the pixel matrix by choosing the maximum
    value from the window and pooling that over *)
let pool h w matrix stride = failwith "nyi"
