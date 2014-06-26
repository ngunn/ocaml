
(* Author: Neil Gunn, Nov 2013 *)

(* Disassembler for .cmi interface files *)

(* ocamlrun dumpcmi file.cmi
 *   outputs: type signatures, crcs
 *)

let read filename =
	let ic = open_in_bin filename in
	try
		let magic_number = Cmt_format.read_magic_number ic in
			let cmi = 
				if magic_number = Config.cmi_magic_number then
					Cmi_format.input_cmi ic
				else
					raise(Cmi_format.Error(Cmi_format.Not_an_interface filename))
		in
		close_in ic;
		cmi
	with e ->
		close_in ic;
		raise e
		
let pr_item ppf sis =
	let osis = Printtyp.tree_of_signature sis in
		!Oprint.out_signature ppf osis

let dump_cmi (infos : Cmi_format.cmi_infos) =
	let ppf = Format.std_formatter in
		Format.fprintf ppf "name : %s@.signatures@\n  @[" infos.cmi_name;
		pr_item ppf infos.cmi_sign;
		Format.fprintf ppf "@]@\ncrcs@\n  @[";
		List.iter (fun (s,dig) -> Format.fprintf ppf "%-15s -> %s@\n" s (Digest.to_hex dig)) infos.cmi_crcs;
		Format.fprintf ppf "@]@."
	
let arg_list = []
let arg_usage = Printf.sprintf "%s CMI_FILES : dump content of cmi files" Sys.argv.(0)

let arg_fun ff filename =
	if not !ff then print_newline ();
	ff := false;
	let cmi = read filename in
		dump_cmi cmi

let main () =
	let first_file = ref true in
		Arg.parse arg_list (arg_fun first_file) arg_usage;
		exit 0

let _ = main ()
