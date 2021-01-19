module FeatureHelpers
  # Attaches a file_set to a work. Can't use the Actors because they perform_later everything
  #    and we need it NOW.
  def attach_file_set_to_work(work, fs)
    work.reload unless work.new_record?
    fs.visibility = work.visibility
    work.ordered_members << fs
    work.representative = fs if work.representative_id.blank?
    # Save the work so the association between the work and the file_set is persisted (head_id)
    # NOTE: the work may not be valid, in which case this save doesn't do anything.
    work.save
  end
end