open Ann

(* creates a layer *)
module PLayer = Perceptron.Layer(Differentiable.Sigmoid)
module PNet = Network.Make(PLayer)

let ( @.@ ) = PNet.(@.@)

let () = Random.self_init ()

let net =
  PLayer.create_layer ~inputs:2 ~outputs:5
  @.@ PNet.of_layer @@ PLayer.create_layer ~inputs:5 ~outputs:2

let and_data = Parse.matrix_of_file "examples/data/and.csv"

let (banana, l) = Parse.matrix_of_file "examples/data/banana.csv"
let banana = Matrix.drop_col 0 banana
let banana = (banana, l)

let test = Parse.split (fst banana) (snd banana) 0.7 0.2

(* open Loss.SquaredDifference *)
(* open Loss.Hinge *)
open Loss.CrossEntropy

let fmt = Format.std_formatter
let data = and_data
let _ =
  (* let (features, labels) = data in
   * Matrix.print features;
   * Matrix.print labels; *)
  let net =
    PNet.train
      ~epsilon:(0.1)
      ~learning:(-2.5)
      (* ~max_epoch:(Some 500) *)
      (* ~gradient_type:(Batch) *)
      (* ~gradient_type:(MiniBatch 64) *)
      ~gradient_type:(Batch)
      ~output_file:(Some "results.csv")
      ~loss
      ~loss_deriv
      net data
  in
  Printf.printf "accuracy: %f\n" @@ PNet.eval_all net data
  (* matrix.print @@ pnet.evaluate (matrix.of_list [[10.]; [30.]]) net;
     matrix.print @@ pnet.evaluate (matrix.of_list [[0.]; [0.]]) net;
     matrix.print @@ pnet.evaluate (matrix.of_list [[-100.]; [30.]]) net; *)
  (* Matrix.print @@ PNet.evaluate (Matrix.of_list [[1.]; [0.]]) net;
   * Matrix.print @@ PNet.evaluate (Matrix.of_list [[0.75]; [0.25]]) net;
   * Matrix.print @@ PNet.evaluate (Matrix.of_list [[0.4]; [0.30]]) net;
   * Matrix.print @@ PNet.evaluate (Matrix.of_list [[-0.4]; [0.60]]) net; *)
  (* Printf.printf "0 0 : %d\n" @@ classify @@ PNet.evaluate (Matrix.of_list [[0.]; [0.]]) net;
   * Printf.printf "1 0 : %d\n" @@ classify @@ PNet.evaluate (Matrix.of_list [[1.]; [0.]]) net;
   * Printf.printf "0 1 : %d\n" @@ classify @@ PNet.evaluate (Matrix.of_list [[0.]; [1.]]) net;
   * Printf.printf "1 1 : %d\n" @@ classify @@ PNet.evaluate (Matrix.of_list [[1.]; [1.]]) net; *)
  (* matrix.format fmt @@ pnet.evaluate i net *)
