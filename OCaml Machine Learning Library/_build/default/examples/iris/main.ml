open Ann

module PLayer = Perceptron_biases.Layer(Differentiable.Sigmoid)
module PNet = Network.Make(PLayer)

let ( @.@ ) = PNet.(@.@)

let () = Random.self_init ()

let (data, l) = Parse.matrix_of_file "examples/iris/iris.csv"
let data' = Matrix.drop_col 0 data
let data = (data', l)

let net =
    PLayer.create_layer ~inputs:4 ~outputs:10
    (* @.@ PLayer.create_layer ~inputs:10 ~outputs:10 *)
    @.@ PNet.of_layer @@ PLayer.create_layer ~inputs:10 ~outputs:3

(* open! Loss.Hinge
 * open! Loss.CrossEntropy *)
open! Loss.SquaredDifference

let _ =
  (* let net = PNet.load "iris.ann" in *)
  let net =
    PNet.train
      ~epsilon:(0.1)
      ~learning:(0.1)
      (* ~max_epoch:(Some 5000) *)
      ~gradient_type:(MiniBatch 128)
      ~dropout:(0.2)
      ~output_file:(Some "iris_results.csv")
      ~loss
      ~loss_deriv
      net data
  in
  PNet.save net "iris";
  Printf.printf "accuracy: %f\n"
  @@ PNet.eval_all
    (* ~expand_output:true *)
    net data
