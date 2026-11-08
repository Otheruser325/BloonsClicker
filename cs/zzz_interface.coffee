# Console/debug interface: expose the real serializer/parser under their own
# names (these used to shadow them with the localStorage wrappers).
@export_save = export_save
@import_save = import_save
@save_to_local_storage = save_to_local_storage
@load_save_from_local_storage = load_save_from_local_storage

@gens = gens
@items = items

@update_language = update_language

@bitfield_to_sstr = bitfield_to_sstr
