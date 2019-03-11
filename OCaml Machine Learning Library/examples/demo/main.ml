
open Ann

(* Demonstration! *)

(* Our Demo Goal: Show how easy it is to quickly create a working Neural Network
    using our library and train a Network to answer some simple queries *)

(* Lets build a simple Neural Network, in order to do so:
    1. We will build a simple Neural Network, maybe with a few layers.
    2. We will create a small data set representing the truth table of an ___ gate.
    3. We will parse the data file into a form that we can actually interpret.
    4. We will train this Neural Network with truth table data of the data set.
    5. We will evaluate some random cases of our choosing to see if our new model works!
*)

(* TODO 1: Instantiate the Differentiable, Layer and Network Modules *)




(* TODO 2: After making a data set, Parse and interpret it *)




(* TODO 3: Train our Neural Network *)




(* TODO 4: Evaluate the Model with some test cases and see how we did *)




































































(* Creates a Layer Module *)
module PLayer = Perceptron.Layer(Differentiable.Sigmoid)

(* Creates a Network Module *)
module PNet = Network.Make(PLayer)

let ( @.@ ) = PNet.(@.@)

(* Creates a Network we are using by Combining Layers of Nodes *)
let net_AND =
  PLayer.create_layer ~inputs:2 ~outputs:5
  @.@ PLayer.create_layer ~inputs:5 ~outputs:5
  @.@ PNet.of_layer @@ PLayer.create_layer ~inputs:5 ~outputs:1

let net_ADD = 
  PLayer.create_layer ~inputs:3 ~outputs:64
  @.@ PLayer.create_layer ~inputs:64 ~outputs:128
  @.@ PNet.of_layer @@ PLayer.create_layer ~inputs:128 ~outputs:1


(* Simple and gate for training *)
let and_data = Parse.matrix_of_file "examples/data/and.csv"

let add_data = Parse.matrix_of_file "examples/data/adder.csv"

let loss_function actual expected =
  Matrix.print actual;
  Printf.printf "expected below:";
  Matrix.print expected;
  match Matrix.sub actual expected with
  | None -> failwith "[loss] Invalid loss function. Please try again."
  | Some l -> l

let fmt = Format.std_formatter

(* Training the network *)
let net_AND =
  PNet.train
    ~epsilon:(0.01)
    ~learning:(0.1)
    (* ~max_epoch:(Some 100) *)
    net_AND
    and_data 
    loss_function

let net_ADD =
  PNet.train
    ~epsilon:(0.1)
    ~learning:(0.1)
    (* ~max_epoch:(Some 1000) *)
    net_ADD
    add_data
    loss_function

(* Evaluations to check *)
let () =
  (* PNet.eval_all net_AND ~tests:[[[1.];[0.]]; [[0.];[0.]]; [[1.];[1.]];  [[0.];[0.]]]; *)
  PNet.eval_all net_ADD
    ~tests:[
      [ [1.]; [0.]; [0.]  ];
      [ [0.]; [1.]; [1.]  ];
      [ [1.]; [1.]; [1.]  ];
      [ [0.]; [0.]; [0.]  ]
    ];
