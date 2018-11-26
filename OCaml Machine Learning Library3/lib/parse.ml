
(** [split_line s] splits a string [s] in a csv file into a list of substrings
    delimited by standard regex separators. *)
let split_line s : string list =
  let regexp = Str.regexp "[ \r\t,]" in
  Str.split regexp s

(** [to_matrix s] is a Matrix.t of the a string list list [s], whose elements
    are strings of floats. *)
let to_matrix (strings : (string list) list) : Matrix.t =
  strings
  |> List.map Array.of_list
  |> Array.of_list
  |> Matrix.to_matrix

(** [matrix_of_channel c] is the Matrix.t of a given open channel [c] of a file. *)
let matrix_of_channel (c : in_channel) =
  Fstream.from_channel c
  |> Fstream.map ~f:(split_line)
  |> Fstream.map ~f:(fun x -> List.filter (function "" -> false | _ -> true) x)
  |> Fstream.filter ~f:(function
      | [] -> false
      | hd :: _ -> hd <> "#")
  |> Fstream.fold_left ~f:(fun acc e -> e :: acc) ~init:[]
  |> to_matrix

(** [selector_of_float n f] is a float list representing the a list of length [n]
    consisting of floats [f]. *)
let selector_of_float n_classes f =
  let sel = (Array.make n_classes 0.0) in
  sel.(int_of_float f) <- 1.0;
  Array.to_list sel

(** [unique m] is the number of unique elements in the Matrix.t [m]. *)
let unique m =
  List.length @@ Matrix.fold_left
    (fun acc e ->
       if List.mem e acc then
         acc
       else
         e :: acc)
    []
    m

(** [matrix_of_file s] converts the matrix represented in the csv file with name
    [s] into a separated augmented matrix tuple of [data * output] *)
let matrix_of_file name =
  if not (Sys.file_exists name)
  then failwith "[matrix_of_file] file not found." else
  if Filename.extension name <> ".csv"
  then failwith "[matrix_of_file] invalid file type" else
    let ch = open_in name in
    let m = matrix_of_channel ch in
    close_in ch;
    let (features, output) = Matrix.sep m in
    let n_labels = unique output in
    let output' = Matrix.fold_left
        (fun acc e ->
           (selector_of_float n_labels e) :: acc)
        []
        output
    in
    (features, Matrix.of_list @@ List.rev output')

(** [split m1 m2 f1 f2] splits the given data and classification matrices [m1]
    and [m2] into training and testing sets depending on the given sizes of the
    floats [f1] and [f2] representing the amount of data entries per training
    or testing set. *)
let split data_m class_m train_p val_p = 
  Printf.printf "%d\n" (Matrix.size data_m);
  let train_cut = int_of_float @@ (float_of_int @@ Matrix.size data_m) *. train_p in 
  Printf.printf "%d\n" train_cut;
  let (train_d, rest_d) = Matrix.get_first_n data_m train_cut in 
  let val_cut = int_of_float @@ (float_of_int @@ (Matrix.size rest_d)) *. (val_p /. ((float_of_int @@ 1) -. train_p)) in 
  Printf.printf "%d\nworld" val_cut;
  let (val_d, test_d) =  Matrix.get_first_n rest_d val_cut in 
  let (train_m, rest_m) = Matrix.get_first_n class_m train_cut in 
  let (val_m, test_m) =  Matrix.get_first_n rest_m val_cut in 
  [train_d,train_m; val_d,val_m; test_d,test_m]