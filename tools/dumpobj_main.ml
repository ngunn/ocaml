

open Dumpobj

let arg_list = [
  "-noloc", Arg.Clear print_locations, " : don't print source information";
]
let arg_usage =
  Printf.sprintf "%s [OPTIONS] FILES : dump content of bytecode files"
                 Sys.argv.(0)


let first_file = ref true

let arg_fun filename =
  let ic = open_in_bin filename in
  if not !first_file then print_newline ();
  first_file := false;
  Printf.printf "## start of ocaml dump of %S\n%!" filename;
  begin try
      dump_exe ic
    with Bytesections.Bad_magic_number ->
      seek_in ic 0; dump_obj filename ic
  end;
  close_in ic;
  Printf.printf "## end of ocaml dump of %S\n%!" filename

let main() =
  Arg.parse arg_list arg_fun arg_usage;
    exit 0

let _ = main ()

