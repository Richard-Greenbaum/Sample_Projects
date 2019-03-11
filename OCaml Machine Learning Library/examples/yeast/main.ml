open Ann

module PLayer = Perceptron_biases.Layer(Differentiable.Sigmoid)
module PNet = Network.Make(PLayer)

let ( @.@ ) = PNet.(@.@)

let () = Random.self_init ()

let (data, l) = Parse.matrix_of_file "examples/yeast/yeast.csv"
let data' = Matrix.drop_col 0 data
let data = (data', l)

let net =
    PLayer.create_layer ~inputs:8 ~outputs:3
    @.@ PNet.of_layer @@ PLayer.create_layer ~inputs:3 ~outputs:9

open Loss.CrossEntropy

let _ =
  (* let net = PNet.load "yeast.ann" in *)
  let net =
    PNet.train
      ~epsilon:(0.000001)
      ~learning:(2.5)
      (* ~max_epoch:(Some 2000) *)
      ~gradient_type:(MiniBatch 256)
      ~output_file:(Some "yeast_results.csv")
      (* ~dropout:(0.5) *)
      ~loss
      ~loss_deriv
      net data
  in
  (* PNet.save net "yeast"; *)
  Printf.printf "accuracy: %f\n" @@ PNet.eval_all net data
