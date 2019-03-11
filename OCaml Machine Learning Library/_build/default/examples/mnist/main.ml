open Ann

module PLayer = Perceptron.Layer(Differentiable.Sigmoid)
module PNet = Network.Make(PLayer)

let ( @.@ ) = PNet.(@.@)

let () = Random.self_init ()

let data = Parse.matrix_of_file "examples/mnist/mnist.csv"

let net =
    PLayer.create_layer ~inputs:784 ~outputs:10
    @.@ PLayer.create_layer ~inputs:10 ~outputs:10
    @.@ PNet.of_layer @@ PLayer.create_layer ~inputs:10 ~outputs:10

let loss_function actual expected =
  Matrix.return @@ Matrix.sub expected actual

let _
  =
    let net =
        PNet.train
        ~epsilon:(0.1)
        ~learning:(2.5)
        ~max_epoch:(Some 500)
        ~gradient_type:(Batch)
        ~output_file:(Some "mnist_results.csv")
        net data loss_function
    in
    Printf.printf "accuracy: %f\n" @@ PNet.eval_all net data



