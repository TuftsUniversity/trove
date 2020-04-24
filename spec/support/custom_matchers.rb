# Quicker way to check if a file or directory exists.
RSpec::Matchers.define :exist_on_filesystem do
  match do |actual|
    expect(File.exists?(actual)).to be true
  end

  failure_message { |actual| "Expected #{actual} to exist as a directory or file." }
  failure_message_when_negated { |actual| "Expected #{actual} to not exist as a directory or file." }
end