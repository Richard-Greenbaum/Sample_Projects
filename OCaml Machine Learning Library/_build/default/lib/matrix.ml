(** type of a matrix *)
type t = (float array) array

(** [zeros m n] is a matrix with number of columns [m] and number of rows [n]
    whose entry values are all [0.0] *)
let zeros ~m ~n = Array.make_matrix m n 0.0

(** [ones m n] is a matrix with number of columns [m] and number of rows [n]
    whose entry values are all [1.0] *)
let ones ~m ~n = Array.make_matrix m n 1.0

(** [mat_values m n v] is a matrix with number of columns [m] and number of rows
    [n] whose entry values are all [v] *)
let mat_values ~m ~n ~v = Array.make_matrix m n v

(** [random m n] is a matrix with number of columns [m] and number of rows
    [n] whose entry values are all random numbers between [0.0] and [1.0] *)
let random ~m ~n =
  ones ~m ~n |> Array.map (fun rows ->
      Array.map (fun _v -> Random.float 1.0) rows)

(** [set m v i j] is [Some] matrix such that sets the entry at column [i] and 
    row [j] in matrix [m] to value [v]. If the matrix or coordinates are not 
    valid then returns [None]. *)
let set m v ~i ~j =
  try m.(i).(j) <- v; Some m with
  | Invalid_argument _ -> None

(** [height m] is the integer height of matrix [m] *)
let height m = Array.length m

(** [width m] is the integer width of matrix [m] *)
let width m = Array.length m.(0)

(** [entries m] is the integer number of entries in the matrix [m] *)
let entries m = 
  height m * width m

(** [size_equals m1 m2] is true if the dimensions of the two matricies [m1] and 
    [m2] are the same. *)
let size_equals m1 m2 =
  (width m1 = width m2) && (height m1 = height m2)

(** [equals m1 m2] is true if the matrices are completely congruent with regard
    to their entry values as well as their sizes. *)
let equals m1 m2 = 
  if not (size_equals m1 m2) 
  then failwith "[equals] unequal dimensions"
  else 
    let equal = ref true in 
    for i = 0 to (height m1) - 1 do
      for j = 0 to (width m1) - 1 do
        equal := (m1.(i).(j) = m2.(i).(j)) && !equal
      done
    done;
    !equal

(** [map f m] is a map function for a matrix [m] with map [f]. *)
let map f m =
  let m' = zeros ~m:(height m) ~n:(width m) in
  for i = 0 to (height m') - 1 do
    m'.(i) <- Array.map f m.(i)
  done;
  m'

(** [map2 f m1 m2] is a map function over two matricies [m1] and [m2] using 
    function [f], whose type is [('a -> 'b -> 'c)] *)
let map2 f m1 m2 =
  if (size_equals m1 m2) then
    let m' = zeros ~m:(height m1) ~n:(height m2) in
    for i = 0 to (height m1) - 1 do
      m'.(i) <- Array.map2 f m1.(i) m2.(i)
    done;
    Some m'
  else
    None

(** [iter f m] iterates over the matrix [m] while applying [f] to each entry *)
let iter f m =
  for i = 0 to (height m) - 1 do
    Array.iter f m.(i)
  done

(** [return m] unwraps a matrix.t option from [None] or [Some m], into its value
    [m] if it exists. Raises: Failure if input is [None]. *)
let return = function
  | None -> failwith "[Matrix.return] couldn't unwrap matrix."
  | Some x -> x

(** [fold_left f init m] folds over the matrix [m] using function [f] and 
    initial accumulator value [init] *)
let fold_left f init m = 
  Array.fold_left 
    (fun acc row -> Array.fold_left f acc row) init m

(** [to_matrix s] is the matrix of a string array array, whose string entries
    are floats. This method is used in Parse.ml for parsing a csv file. *)
let to_matrix s : t = 
  let height = Array.length s and width = Array.length s.(0) in 
  let matrix = zeros ~m:height ~n:width in 
  for i = 0 to height - 1 do
    for j = 0 to width - 1 do
      try matrix.(i).(j) <- float_of_string s.(i).(j)
      with Failure _ -> failwith @@ Printf.sprintf "\n fail string is '%s' \n" s.(i).(j)
    done 
  done;
  matrix

(** [check_dim m] raises failure if the dimensions of the matrix are poor, i.e.
    being 0 in any dimension. Otherwise it returns the original matrix. *)
let check_dim m = 
  if height m = 0 || width m = 0 then 
    failwith (
      Printf.sprintf 
        "[check_dim] Bad Matrix Dimensions, A width: %d, B height: %d" 
        (width m) 
        (height m)
    )
  else m

(** [sum m] is the sum of all float entries of the matrix [m] *)
let sum (m : (float array) array) : float = 
  check_dim m 
  |> fold_left (+.) 0.

(** [add m1 m2] is a new matrix whose entries [c_ij] are equal to the sum of 
    [m1_ij] and [m2_ij]. It is an application of the map function. *)
let add m1 m2 = map2 (+.) m1 m2

(** [sub m1 m2] is a new matrix whose entries [c_ij] are equal to the difference 
    of [m1_ij] and [m2_ij]. It is an application of the map function. *)
let sub m1 m2 = map2 (-.) m1 m2

(** [mult m1 m2] is the matrix multiplication of [m1] and [m2].
    Raises: Failure "Bad Dimensions" if the dimensions of [m1] and [m2] are not correct *)
let mult mA mB = 
  if width mA <> height mB then 
    failwith (
      Printf.sprintf 
        "[mult] Bad Matrix Dimensions, A width: %d, B height: %d" 
        (width mA) 
        (height mB)
    )
  else 
    let m = width (check_dim mA) in
    let n = height mA in 
    let p = width (check_dim mB) in
    let mC = zeros ~m:n ~n:p in
    for i = 0 to n - 1 do
      for j = 0 to p - 1 do
        for k = 0 to m - 1 do
          mC.(i).(j) <- mC.(i).(j) +. mA.(i).(k) *. mB.(k).(j)
        done
      done
    done;
    mC

(** [dot m1 m2] takes the dot product of matrix [m1] and matrix [m2]. *)
let dot mA mB =
  map2
    (fun a b -> a *. b)
    mA
    mB
  |> return
  |> sum

(** [max_dim a b] is the maximum integer dimension of the two input matrices
    [a] and [b] *)
let max_dim mA mB = 
  let (hA, wA, hB, wB) = (height mA, width mA, height mB, width mB) in 
  max wA (max wB (max hA hB))

(**[slice m p1 p2] is a sub-section of [m] between [p1] and [p2] *)
let slice (x1, y1) (x2, y2) m = 
  let min_x = min x1 x2 in
  let max_x = max x1 x2 in
  let min_y = min y1 y2 in
  let max_y = max y1 y2 in
  let matrix = zeros ~m:(max_y - min_y + 1) ~n:(max_x - min_x + 1) in 
  for i = min_y to max_y do
    for j = min_x to max_x do 
      matrix.(i - min_y).(j - min_x) <- m.(i).(j)
    done
  done;
  matrix

(** [square m n] takes matrix m and extends its size until its dimensions are 
    n x n, therefore square. m must be greater than or equal to m. Otherwise the
    slice function can be used. *)
let square m n = 
  (* must have n be of larger dimensions and even *)
  if height m = n && width m = n then m else 
    let n = n + (n mod 2) in 
    let matrix = zeros ~m:n ~n:n in 
    for i = 0 to height m - 1 do 
      for j = 0 to width m - 1 do 
        matrix.(i).(j) <- m.(i).(j)
      done 
    done;
    matrix

(* matrices must be square and even at dimensions *)
let quad_split m = 
  let mid' = ((height m) / 2) - 1 in 
  let end' = (height m - 1) in (
    slice (0, 0) (mid', mid') m,
    slice (mid' + 1, 0) (end', mid') m,
    slice (0, mid' + 1) (mid', end') m,
    slice (mid' + 1, mid' + 1) (end', end') m
  )

(** [quad_conn q] is a new matrix whose quadrants in order c11, c12, c21, and 
    c22 correspond to the quadrants provided in matrix * matrix * matrix * matrix
    tuple [t]. Requires: aij are have the same heights and widths, and are 
    valid matrices. *)
let quad_conn (a11, a12, a21, a22) =
  let split_n = height a11 in
  let n = height a11 * 2 in
  let matrix = zeros ~m:n ~n:n in 
  for c = 0 to n - 1 do
    for r = 0 to n - 1 do
      match (c < split_n, r < split_n) with 
      | true, true -> (
          (* a11 matrix *)
          matrix.(c).(r) <- a11.(c).(r)
        )
      | false, true -> (
          (* a12 matrix *)
          matrix.(c).(r) <- a12.(c - split_n).(r)
        )
      | true, false -> (
          (* a21 matrix *)
          matrix.(c).(r) <- a21.(c).(r - split_n)
        )
      | false, false -> (
          (* a22 matrix *)
          matrix.(c).(r) <- a22.(c - split_n).(r - split_n)
        )
    done 
  done;
  matrix

(** [strassen a b] performs the strassen multiplication method on the two 
    matrices [a] and [b]. Requires: [a] and [b] are both square matrices of 
    equal dimensions, whose dimension [N] is a power of two. Raises: 
    "Bad Dimensions" if [N] is [0]. *)
let strassen mA mB = 
  let rec strass n a b = 
    if n = 0 then failwith "[strassen] Bad Dimensions"
    else if n = 1 then (
      Array.make_matrix 1 1 (a.(0).(0) *. b.(0).(0))
    )
    else if n = 2 then (
      let m = zeros ~m:2 ~n:2 in 
      m.(0).(0) <- (a.(0).(0) *. b.(0).(0)) +. (a.(1).(0) *. b.(0).(1));
      m.(0).(1) <- (a.(0).(0) *. b.(1).(0)) +. (a.(1).(0) *. b.(1).(1));
      m.(1).(0) <- (a.(0).(1) *. b.(0).(0)) +. (a.(1).(1) *. b.(0).(1));
      m.(1).(1) <- (a.(0).(1) *. b.(1).(0)) +. (a.(1).(1) *. b.(1).(1));
      m
    )
    else (
      (* [r = return] is an option unwrapping function *)
      let r = return in 
      let a11, a12, a21, a22 = quad_split mA in
      let b11, b12, b21, b22 = quad_split mB in 

      let s1 = sub b12 b22 in
      let s2 = add a11 a12 in
      let s3 = add a21 a22 in
      let s4 = sub b21 b11 in
      let s5 = add a11 a22 in
      let s6 = add b11 b22 in
      let s7 = sub a12 a22 in
      let s8 = add b21 b22 in
      let s9 = sub a11 a21 in 
      let s10 = add b11 b12 in 

      let p1 = strass (n/2) a11 (r s1) in
      let p2 = strass (n/2) (r s2) b22 in 
      let p3 = strass (n/2) (r s3) b11 in
      let p4 = strass (n/2) a22 (r s4) in 
      let p5 = strass (n/2) (r s5) (r s6) in 
      let p6 = strass (n/2) (r s7) (r s8) in 
      let p7 = strass (n/2) (r s9) (r s10) in 

      let c11 = r @@ add (r @@ sub (r @@ add p5 p4) p2) p6 in
      let c12 = r @@ add p1 p2 in
      let c21 = r @@ add p3 p4 in
      let c22 = r @@ sub (r @@ sub (r @@ add p5 p1) p3) p7 in

      quad_conn (c11, c12, c21, c22)
    )
  in strass (height mA) mA mB

(** [mult_ a b] is the more efficient multiplication method that uses the 
    strassen method. Raises: "Bad Dimensions" if the matrices cannot be 
    multiplied. *)
let mult_ mA mB : t = 
  if width mA <> height mB then 
    failwith (
      Printf.sprintf 
        "[mult] Bad Matrix Dimensions, A width: %d, B height: %d" 
        (width mA) 
        (height mB)
    )
  else (
    (* convert to square matricies *)
    let n = Num.pad (max_dim mA mB) in
    let mA' = square mA n in 
    let mB' = square mB n in 
    strassen mA' mB' 
    |> slice (0, 0) (height mA - 1, width mB - 1))

(** [scalar_mult m s] scales every entry value in the matrix [m] by scalar [s] *)
let scalar_mult m scale =
  m |> Array.map (fun rows ->
      Array.map (fun v -> v *. scale) rows)

(** [inv m] is [Some i] if [m] is invertable and [None] otherwise. *)
let det m = failwith "nyi"

(** [det m] is the determinant of [m]. *)
let inv _m = failwith "nyi"

(** [norm m] is the norm of [m]. *)
let norm m =
  Array.fold_left
    (fun sum col ->
       Array.fold_left
         (fun row_sum entry ->
            let abs_e = abs_float entry in
            row_sum +. (abs_e ** 2.))
         sum col)
    0. m

(** [transpose m] is the transpose of matrix [m]. *)
let transpose m =
  let nm = zeros ~m:(width m) ~n:(height m) in
  for i = 0 to (height m) - 1 do
    for j = 0 to (width m) - 1 do
      nm.(j).(i) <- m.(i).(j)
      (* nm.(j).(i) <- m.(i).(j); *)
    done
  done;
  nm

(** [drop_row m i] removes the [i]th row of [m]. *)
let drop_row idx m =
  let copy = ones ~m:(height m - 1) ~n:(width m) in
  let rec help i n =
    if i <= (height copy) then
      (if i = idx then
         help (i+1) (n)
       else
         (copy.(n) <- m.(i);
          help (i+1) (n+1)))
  in
  help 0 0;
  copy

(** [drop_col m j] removes the [j]th column of [m]. *)
let drop_col i m =
  transpose @@ drop_row i (transpose m)

(** [sep m] separates the augmented matrix [a | m] into [(a, m)] *)
let sep (m : t) =
  let mT = transpose m in
  let output = mT.(height mT - 1) in
  let input_m = zeros ~m:(height mT - 1) ~n:(width m) in
  for i = 0 to height mT - 2 do
    input_m.(i) <- mT.(i)
  done;
  (transpose input_m, transpose [|output|])

(** [of_list l] is a matrix representation of [l]. *)
let of_list l =
  List.map Array.of_list l
  |> Array.of_list

(** [to_row_list m] is a list of each row in matrix [m]. *)
let to_row_list m =
  List.map
    (fun x -> transpose [|x|])
    (Array.to_list m)

(** [format fmt t] prints out [t] to [fmt]. *)
let format fmt m =
  let open Format in
  fprintf fmt "%d x %d\n" (height m) (width m);
  m |> Array.iter (fun rows ->
      fprintf fmt "[";
      rows |> Array.iter (fun v -> fprintf fmt " %f " v);
      fprintf fmt "]\n";)

(** [format t] prints [t] to [stdout].*)
let print t = format (Format.std_formatter) t

(** [size m] returns the length of the outer array of matrix m. *)
let size m = Array.length m

(** [get_first_n m n] returns a touple with the first n elements of matrix m 
    along with the rest of matrix m  *)
let get_first_n (m:t) n = 
  let rec helper (m:float array list) acc counter = 
    if counter = 0 then Array.of_list (List.rev acc), Array.of_list m
    else
      match m with 
      | h::t -> helper t (h :: acc) (counter-1)
      | _ -> failwith "empty list in get_first_n"
  in 
  helper (Array.to_list m) [] n

(** [to_flat_list t] returns a representation of matrix t as a flattened list of floats*)
let to_flat_list m =
  let new_list1 = Array.to_list m in
  let new_list2 = List.map (fun a -> Array.to_list a) new_list1 in
  List.flatten new_list2
