open Display

let scope_ppformat ~display_format ((d,s),_) =
  match display_format with
  | Human_readable ->
    (Location.dummy, "there is to human-readable pretty printer for you, use --format=json")
  | Dev -> 
    (Location.dummy, Format.asprintf "@[<v>%a@ %a@]" PP.scopes s PP.definitions d)

let scope_jsonformat (defscopes,_) : json = PP.to_json defscopes

let scope_format : 'a format = {
  pp = scope_ppformat;
  to_json = scope_jsonformat;
}