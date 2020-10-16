# Quicker way to check if a file or directory exists.
RSpec::Matchers.define :exist_on_filesystem do
  match do |actual|
    expect(File.exists?(actual)).to be true
  end

  failure_message { |actual| "Expected #{actual} to exist as a directory or file." }
  failure_message_when_negated { |actual| "Expected #{actual} to not exist as a directory or file." }
end

# Easy way to search the Collections sidebar for a title
RSpec::Matchers.define :show_in_personal_sidebar do
  match do |actual|
    visit '/'
    expect(find('#personal_collections')).to have_content(actual.title.first)
  end

  failure_message { |actual| "Expected #{actual} to be listed in Personal Collections Sidebar" }
  failure_message_when_negated { |actual| "Expected #{actual} to not be listed in Personal Collections Sidebar" }
end

# Easy way to search the Collections sidebar for a title
RSpec::Matchers.define :show_in_course_sidebar do
  match do |actual|
    visit '/'
    expect(find('#course_collections')).to have_content(actual)
  end

  failure_message { |actual| "Expected #{actual} to be listed in Course Collections Sidebar" }
  failure_message_when_negated { |actual| "Expected #{actual} to not be listed in Course Collections Sidebar" }
end