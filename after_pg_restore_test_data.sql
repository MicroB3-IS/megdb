CREATE TRIGGER aa_samples_b_trg BEFORE INSERT OR UPDATE ON core.samples FOR EACH ROW EXECUTE PROCEDURE core.samples_b_trg();

select core.rebuild_mg_view();