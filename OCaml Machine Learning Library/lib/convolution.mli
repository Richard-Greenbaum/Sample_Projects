(** [filter f m] filters a matrix chunk [m] using the filter feature [f], resulting
    in a float value representing *)
val filter : Matrix.t -> Matrix.t -> float

(** [convolve f m s] performs convolution over a pixel matrix [matrix] using a
    chosen feature filter [feature]. It iterates this filtering process every
    [step] pixels. *)
val convolve : Matrix.t -> Matrix.t -> int -> Matrix.t

(** [pool h w s] performs the pooling operation over a convolved pixel [matrix]
    using a window of height [h], width [w] and pools every [stride] pixels.
    The act of pooling simple shrinks the pixel matrix by choosing the maximum
    value from the window and pooling that over *)
val pool : int -> int -> Matrix.t -> int -> Matrix.t